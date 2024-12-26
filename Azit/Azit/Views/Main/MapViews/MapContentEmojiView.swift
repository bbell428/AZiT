//
//  MapContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
import MapKit
import Kingfisher

struct MapContentEmojiView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    let emojiManager = EmojiManager()
    
    @Binding var user: UserInfo // 선택 된 친구
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var selectedIndex: Int
    
    @State var isPassed24Hours: Bool = false // 친구의 게시글 작성 후 24시간에 대한 판별 여부
    
    @State private var story: Story?
    
    var region: MKCoordinateRegion
    var index: Int
    
    var body: some View {
        VStack {
            Button {
                isFriendsModalPresented = true
                selectedIndex = index // 선택 된 친구의 index 유지
            } label: {
                ZStack {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                             center: .center,
                                             startRadius: 0,
                                             endRadius: 20))
                    
                    VStack {
                        Circle()
                            .fill(.white.opacity(0.8))
                            .overlay(
                                VStack {
                                    ZStack {
                                        Circle()
                                            .stroke(isPassed24Hours ? AnyShapeStyle(Utility.createLinearGradient(colors: [.ellipseColor2.opacity(0.5), .ellipseColor2])) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 15)
                                            .frame(width: 90, height: 90)
                                        
                                        let emojiComponents = story?.emoji.components(separatedBy: "*")
                                        if let codepoints = emojiManager.getCodepoints(forName: emojiComponents?[0] ?? "") {
                                            let urlString = EmojiManager.getTwemojiURL(for: codepoints)
                                            
                                            let placeholderText = emojiComponents?.count ?? 1 > 1 ? emojiComponents?[1] : "" // 안전한 인덱스 접근
                                            
                                            KFImage(URL(string: urlString))
                                                .placeholder { Text(placeholderText ?? "").font(.system(size: 60)) }
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                        }
                                    }
                                }
                            )
                            .frame(width: 90, height: 90)
                        
                        HStack {
                            Spacer()
                            
                            Capsule()
                                .fill(isPassed24Hours ? .ellipseColor2 : .accent)
                                .overlay(
                                    Text(user.nickname)
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .bold()
                                )
                                .frame(height: 25)
                                .offset(y: -10)
                                .zIndex(1)
                                .padding([.leading, .trailing], 5)
                            
                            Spacer()
                        }
                    }
                }
            }
            .scaleEffect(max(0.5, min(1.0, 1.0 / (region.span.latitudeDelta * 12.5))))
        }
        .onAppear {
            Task {
                // 선택 된 친구의 story
                var tempStories = await storyStore.loadStorysByIds(ids: [user.id])
                
                tempStories = tempStories.sorted { $0.date > $1.date }
                
                if tempStories.count > 0 {
                    var tempStory = Story(userId: "", date: Date.now)
                    
                    for story in tempStories {
                        tempStory = story
                        
                        if tempStory.publishedTargets.contains(userInfoStore.userInfo?.id ?? "") || tempStory.publishedTargets.isEmpty {
                            
                            self.story = tempStory
                            
                            break
                        }
                    }
                }
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story?.date ?? Date.now)
                
                // 선택 된 친구의 story
                let story = try await storyStore.loadRecentStoryById(id: user.id)
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
    }
}
