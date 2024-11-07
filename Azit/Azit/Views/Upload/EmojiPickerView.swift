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

    @Environment(\.dismiss) var dismiss

    @Binding public var selectedEmoji: Emoji?

    @State private var search: String = ""

    private var selectedColor: Color
    @State private var searchEnabled: Bool

    public init(selectedEmoji: Binding<Emoji?>, searchEnabled: Bool = false, selectedColor: Color = .blue, emojiProvider: EmojiProvider = DefaultEmojiProvider()) {
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
                        .fill((selectedEmoji == emoji ? selectedColor : Color.subColor2).opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(emoji.value)
                                .font(.title)
                        }
                        .onTapGesture {
                            selectedEmoji = emoji
                            dismiss()
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
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

    public init() { }

    public func getAll() -> [Emoji] {
        return Smile.list().map({ Emoji(value: $0, name: name(emoji: $0).first ?? "") })
    }

}

public protocol EmojiProvider {
    func getAll() -> [Emoji]
}
