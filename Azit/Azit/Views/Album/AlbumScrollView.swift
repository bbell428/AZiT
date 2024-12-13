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
    @Binding var isShowHorizontalScroll: Bool
    @Binding var isFriendsContentModalPresented: Bool
    
    @Binding var selectedAlbum: Story?
    
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
                        isShowHorizontalScroll = value > lastOffsetY
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
                                    selectedAlbum = story
                                    isFriendsContentModalPresented = true
                                } label: {
                                    VStack {
                                        if !story.image.isEmpty {
                                            // 이미지가 있을 경우
                                            if let cachedImage = albumstore.cacheImages[story.image] {
                                                AlbumStoryImageView(imageStoreID: story.image, image: cachedImage)
                                                    .frame(width: 110, height: 150)
                                                    .cornerRadius(15)
                                            } else {
                                                ProgressView()
                                                    .frame(width: 110, height: 150)
                                            }
                                        } else {
                                            // 이모지와 텍스트만 표시
                                            VStack {
                                                Spacer()
                                                if !story.content.isEmpty {
                                                    SpeechBubbleView(text: story.content)
                                                        .font(.caption)
                                                        .padding(.bottom, 5)
                                                }
//                                                if let codepoints = emojiManager.getCodepoints(forName: story.emoji.components(separatedBy: "*")[0]) {
//                                                    if let url = URL(string: EmojiManager.getTwemojiURL(for: codepoints)) {
//                                                        KFImage(url)
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(width: 40, height: 40)
//                                                            .placeholder {
//                                                                // 이미지 로드 전 기본 이모지 표시
//                                                                Text(emojiManager.getCodepoints(forName: story.emoji.components(separatedBy: "*")[1]))
//                                                                    .font(.title)
//                                                            }
//                                                    }
//                                                }
                                                if let codepoints = emojiManager.getCodepoints(forName: story.emoji) {
                    KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                                                Spacer()
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
