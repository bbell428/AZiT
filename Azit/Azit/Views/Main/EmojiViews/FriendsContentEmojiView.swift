//
//  MainContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI
import Kingfisher

// 친구의 story Circle
struct FriendsContentEmojiView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var userInfo: UserInfo // 선택 된 친구 story
    @Binding var rotation: Double // 각도
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var selectedIndex: Int // 선택 된 index의 데이터를 유지하기 위함
        
    @State var randomAngleOffset: Double
    @State private var isPassed24Hours: Bool = false
    
    @State var story: Story?
    
    var index: Int // 선택 된 index의 데이터를 유지하기 위함
    var startEllipse: (width: CGFloat, height: CGFloat) // 타원의 시작점
    var endEllipse: (width: CGFloat, height: CGFloat) // 타원의 끝점
    var interpolationRatio: CGFloat // 타원 내 위치를 설정
    let emojiManager = EmojiManager()
    
    
    var body: some View {
        let majorAxis = startEllipse.width / 2 * (1 - interpolationRatio) + endEllipse.width / 2 * interpolationRatio // 타원의 넓은 부분
        let minorAxis = startEllipse.height / 2 * (1 - interpolationRatio) + endEllipse.height / 2 * interpolationRatio // 타원의 좁은 부분
        let angle = (rotation + randomAngleOffset) * .pi / 180 // 각도
        
        Button {
            selectedIndex = index // 선택 된 친구의 index 유지
            isFriendsModalPresented = true
        } label: {
            // frame들에서의 interpolationRatio은 거리에 따른 각 Circle들의 거리를 계산하기 위함
            VStack {
                Text("\(userInfo.nickname)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(UIColor.darkGray))
                    .frame(minWidth: 100)
                    .padding(.top, -40).scaleEffect(1)
                    .offset(x: 0, y: -25 * (1 - interpolationRatio))
                
                ZStack {
                    EllipticalGradient(
                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                        center: .center,
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.5
                    )
                    .frame(width: 40 * (2.2 - interpolationRatio), height: 10 * (2.2 - interpolationRatio))
                    
                    Circle()
                        .fill(.white.opacity(0.2))
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 5)
                                if let codepoints = emojiManager.getCodepoints(forName: story?.emoji ?? "") {
                                    KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25 * (2.2 - interpolationRatio), height: 25 * (2.2 - interpolationRatio))
                                }
                            }
                        )
                        
                        .offset(x: 0, y: -25 * (2.2 - interpolationRatio))
                        .frame(width: 40 * (2.2 - interpolationRatio), height: 40 * (2.2 - interpolationRatio))
                }
            }
        }
        .frame(width: 50, height: 50)
        .offset(x: majorAxis * cos(angle), y: minorAxis * sin(angle) + 270)
        .animation(.easeInOut(duration: 0.5), value: rotation)
        .onAppear {
            Task {
                print("interpolationRatio: \(interpolationRatio)")
                // 선택 된 친구의 story
                var tempStories = await storyStore.loadStorysByIds(ids: [userInfo.id])
                
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
            }
        }
    }
}
