//
//  MapContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
import MapKit

struct MapContentEmojiView: View {
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var user: UserInfo // 선택 된 친구
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var selectedIndex: Int
    
    @State var isPassed24Hours: Bool = false // 친구의 게시글 작성 후 24시간에 대한 판별 여부
    
    var region: MKCoordinateRegion
    var index: Int
    
    var body: some View {
        VStack {
            Text(user.nickname)
                .font(.caption)
                .foregroundStyle(.black)
                .padding(.top, max(-40, min(-20, -40 * (1.0 / (region.span.latitudeDelta * 12.5)))))
            
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
                    
                    Circle()
                        .fill(.white.opacity(0.7))
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 5)
                                Text(user.previousState)
                                    .font(.system(size: 45))
                            }
                        )
                        .offset(x: 0, y: -30)
                        .frame(width: 60, height: 60)
                }
            }
            .scaleEffect(max(0.5, min(1.0, 1.0 / (region.span.latitudeDelta * 12.5))))
        }
        .onAppear {
            Task {
                // 선택 된 친구의 story
                let story = try await storyStore.loadRecentStoryById(id: user.id)
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
    }
}
