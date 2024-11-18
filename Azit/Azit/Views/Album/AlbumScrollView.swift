//
//  AlbumScrollView.swift
//  Azit
//
//  Created by 박준영 on 11/15/24.
//

import Foundation
import SwiftUI

// 친구 스토리 리스트
struct AlbumScrollView : View {
    @EnvironmentObject var albumstore: AlbumStore
    
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), alignment: .leading, spacing: 5) {
                ForEach(albumstore.getTimeGroupedStories(), id: \.title) { group in
                    Section(header: HStack {
                        Text(group.title)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.gray)
                        Spacer()
                    }
                        .padding(.top, 20)
                    ) {
                        ForEach(group.stories) { story in
                            VStack(alignment: .leading) {
                                Button {
                                    selectedAlbum = story
                                    isFriendsContentModalPresented = true
                                } label: {
                                    VStack {
                                        // 스토리에 사진이 포함,
                                        if !story.image.isEmpty {
                                            //AlbumStoryImageView(imageStoreID: story.image)
                                        } else {
                                            // 스토리에 이모지 & 텍스트만 존재
                                            VStack {
                                                Spacer()
                                                SpeechBubbleView(text: story.content)
                                                    .font(.caption)
                                                    .padding(.bottom, 5)
                                                Text(story.emoji)
                                                    .font(.largeTitle)
                                                Spacer()
                                            }
                                            .background(
                                                Image("storyBackImage")
                                            )
                                            .frame(maxWidth: .infinity)
                                            //.background(.subColor4.opacity(0.95))
                                            .cornerRadius(15) // 추가
                                        }
                                    }
                                    .padding(.horizontal, 2.5)
                                    .frame(width: 115, height: 155)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
