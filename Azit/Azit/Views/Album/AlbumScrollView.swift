//
//  AlbumScrollView.swift
//  Azit
//
//  Created by 박준영 on 11/15/24.
//

import Foundation
import SwiftUI
import Kingfisher

// 친구 스토리 리스트
struct AlbumScrollView : View {
    @EnvironmentObject var albumstore: AlbumStore
    let emojiManager = EmojiManager()
    
    @Binding var lastOffsetY: CGFloat
    @Binding var isShowVerticalScroll: Bool
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedStory: Story? // 선택된 스토리
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Rectangle()
                .frame(height: 160)
                .foregroundStyle(Color.white)
            
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: ScrollPreferenceKey.self,
                        value: proxy.frame(in: .global).origin.y
                    )
            }
            .frame(height: 0)
            .onPreferenceChange(ScrollPreferenceKey.self) { value in
                if abs(value - lastOffsetY) > 120 && lastOffsetY < 400 {
                    withAnimation {
                        isShowVerticalScroll = value > lastOffsetY
                    }
                    lastOffsetY = value
                }
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(110)), count: 3), // 각 셀의 고정 너비
                alignment: .leading,
                spacing: 10 // 셀 간의 간격
            ) {
                ForEach(albumstore.getTimeGroupedStories(), id: \.title) { group in
                    Section(
                        header: HStack {
                            Text(group.title)
                                .font(.caption)
                                .padding(.horizontal, 7.5)
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                            .padding(.top, 20)
                    ) {
                        ForEach(group.stories) { story in
                            VStack(alignment: .center) { // 가운데 정렬
                                Button {
                                    selectedStory = story
                                    isFriendsContentModalPresented = true
                                } label: {
                                    VStack {
                                        // 스토리에 이미지가 포함되어있을때,
                                        if !story.image.isEmpty {
                                            if let cachedImage = albumstore.cacheImages[story.image] {
                                                // MARK: 이미지 스토리 View
                                                AlbumStoryImageView(imageStoreID: story.image, image: cachedImage)
                                                    .frame(width: 110, height: 150)
                                                    .cornerRadius(15)
                                            } else {
                                                ProgressView()
                                                    .frame(width: 110, height: 150)
                                            }
                                            // 스토리에 이모지 or 텍스트가 포함되어있을때,
                                        } else {
                                            VStack {
                                                Spacer()
                                                // 스토리에 텍스트가 포함되어있다면,
                                                if !story.content.isEmpty {
                                                    // MARK: 말풍선 View
                                                    SpeechBubbleView(text: story.content)
                                                        .font(.caption)
                                                        .padding(.bottom, 5)
                                                }
                                                let emojiComponents = story.emoji.components(separatedBy: "*")
                                                if let codepoints = emojiManager.getCodepoints(forName: emojiComponents[0]) {
                                                    let urlString = EmojiManager.getTwemojiURL(for: codepoints)
                                                    
                                                    KFImage(URL(string: urlString))
                                                        //.placeholder { Text(emojiComponents[1]) }
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                }
                                            }
                                            .frame(width: 110, height: 150) // 고정된 크기
                                            .background(
                                                Image("storyBackImage")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            )
                                            .cornerRadius(15)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 7.5)
                        }
                    }
                }
            }
        }
    }
}
