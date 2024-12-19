//
//  EmojiPickerView.swift
//  Azit
//
//  Created by 홍지수 on 11/6/24.
//

import SwiftUI
import Foundation
import Kingfisher

public struct EmojiPickerView: View {
    @State private var search: String = ""
    @State private var searchEnabled: Bool
    
    @Binding public var selectedEmoji: String
    
    private var selectedColor: Color
    let emojis: [Emoji]
    private var searchResults: [Emoji] {
        if search.isEmpty {
            return emojis
        } else {
            return emojis
                .filter { $0.name.lowercased().contains(search.lowercased()) }
        }
    }
    let columns = [
        GridItem(.adaptive(minimum: 45))
    ]
    
    public init(selectedEmoji: Binding<String>, searchEnabled: Bool = false, selectedColor: Color = Color.accentColor.opacity(0.5), emojiProvider: any EmojiProvider = DefaultEmojiProvider()) {
        self._selectedEmoji = selectedEmoji
        self.selectedColor = selectedColor
        self.searchEnabled = searchEnabled
        self.emojis = emojiProvider.getAll()
    }
    
    public var body: some View {
        SearchView(search: $search, searchEnabled: $searchEnabled)
            .frame(width: 340, height: 40)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(searchResults, id: \.self) { emoji in
                    RoundedRectangle(cornerRadius: 15)
                        .fill((selectedEmoji == "\(emoji.name)*\(emoji.emoji)" ? selectedColor : Color.subColor2).opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            // Kingfisher를 사용하여 Twemoji 이미지 로드
                            KFImage(URL(string: EmojiManager.getTwemojiURL(for: emoji.code)))
                                .placeholder {
                                    // 이미지 로드 전 기본 이모지 표시
                                    Text(emoji.emoji)
                                        .font(.title)
                                }
//                                .onFailure { error in
//                                    print("Failed to load image for \(emoji.emoji): \(error)")
//                                }
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .onTapGesture {
                            selectedEmoji = "\(emoji.name)*\(emoji.emoji)"
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
}
