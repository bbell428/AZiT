//
//  MainContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

// 친구의 story Circle
struct FriendsContentEmojiView: View {
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var userInfo: UserInfo // 선택 된 친구 story
    @Binding var rotation: Double // 각도
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var selectedIndex: Int // 선택 된 index의 데이터를 유지하기 위함
        
    @State var randomAngleOffset: Double
    @State private var isPassed24Hours: Bool = false
    
    var index: Int // 선택 된 index의 데이터를 유지하기 위함
    var startEllipse: (width: CGFloat, height: CGFloat) // 타원의 시작점
    var endEllipse: (width: CGFloat, height: CGFloat) // 타원의 끝점
    var interpolationRatio: CGFloat // 타원 내 위치를 설정
    
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
                
                ZStack {
                    Ellipse()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                             center: .center,
                                             startRadius: 0,
                                             endRadius: 20))
                        .frame(width: 20 * (1.5 - interpolationRatio), height: 10 * (1.5 - interpolationRatio))
                    
                    Circle()
                        .fill(.clear)
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 3)
                                Text(userInfo.previousState)
                                    .font(.system(size: 25 * (1.5 - interpolationRatio)))
                            }
                            
                        )
                        .offset(x: 0, y: -30)
                        .frame(width: 40 * (1.5 - interpolationRatio), height: 40 * (1.5 - interpolationRatio))
                }
            }
        }
        .frame(width: 50, height: 50)
        .offset(x: majorAxis * cos(angle), y: minorAxis * sin(angle) + 250)
        .animation(.easeInOut(duration: 0.5), value: rotation)
        .onAppear {
            Task {
                // 선택 된 친구의 story
                let story = try await storyStore.loadRecentStoryById(id: userInfo.id)
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
    }
}
