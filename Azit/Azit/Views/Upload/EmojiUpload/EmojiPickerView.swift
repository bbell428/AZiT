//
//  EmojiPickerView.swift
//  Azit
//
//  Created by 홍지수 on 11/6/24.
//

import SwiftUI
import Foundation
import Smile

public struct EmojiPickerView: View {
    @Binding public var selectedEmoji: String

    @State private var search: String = ""

    private var selectedColor: Color
    @State private var searchEnabled: Bool
    @State private var twemojiCache: [String: UIImage] = [:] // Twemoji 캐싱

    public init(selectedEmoji: Binding<String>, searchEnabled: Bool = false, selectedColor: Color = .blue, emojiProvider: EmojiProvider = DefaultEmojiProvider()) {
        self._selectedEmoji = selectedEmoji
        self.selectedColor = selectedColor
        self.searchEnabled = searchEnabled
        self.emojis = emojiProvider.getAll()
    }

    let columns = [
        GridItem(.adaptive(minimum: 45))
    ]

    let emojis: [Emoji]

    private var searchResults: [Emoji] {
        if search.isEmpty {
            return emojis
        } else {
            return emojis
                .filter { $0.name.lowercased().contains(search.lowercased()) }
        }
    }

    public var body: some View {
        SearchView(search: $search, searchEnabled: $searchEnabled)
            .frame(width: 340, height: 40)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(searchResults, id: \.self) { emoji in
                    RoundedRectangle(cornerRadius: 16)
                        .fill((getEmojiName(for: selectedEmoji, in: searchResults) == emoji.name ? selectedColor : Color.subColor2).opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            if let image = twemojiCache[emoji.value] {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            } else {
                                ProgressView() // 로딩 중 표시
                                    .frame(width: 30, height: 30)
                                    .onAppear {
                                        loadTwemoji(for: emoji.value)
                                    }
                            }
                        }
                        .onTapGesture {
                            selectedEmoji = emoji.value
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
    /// Twemoji 로드 함수
    private func loadTwemoji(for emojiValue: String) {
        let components = emojiValue.unicodeScalars.map { String(format: "%x", $0.value) }
        let unicodeHex = components.joined(separator: "-")
        let urlString = "https://twemoji.maxcdn.com/v/latest/72x72/\(unicodeHex).png"

        guard let url = URL(string: urlString) else { return }

        // 비동기로 Twemoji 로드
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                twemojiCache[emojiValue] = image
            }
        }.resume()
    }
}

func getEmojiName(for value: String, in emojis: [Emoji]) -> String? {
    return emojis.first(where: { $0.value == value })?.name
}

public struct Emoji: Hashable {
    public let value: String
    public let name: String

    public init(value: String, name: String) {
        self.value = value
        self.name = name
    }
}

public final class DefaultEmojiProvider: EmojiProvider {
    private let emojis: [Emoji]

    public init() {
        // 여기에서 JSON 데이터를 로드하여 Emoji 배열 생성
        if let url = Bundle.main.url(forResource: "icon", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: []),
           let root = json as? [String: Any],
           let icons = root["icons"] as? [String: Any] {
            self.emojis = icons.map { (key, value) in
                let name = key.replacingOccurrences(of: "-", with: " ").capitalized
                return Emoji(value: key, name: name)
            }
        } else {
            self.emojis = []
        }
    }

    public func getAll() -> [Emoji] {
        return emojis
    }
}

public protocol EmojiProvider {
    func getAll() -> [Emoji]
}
