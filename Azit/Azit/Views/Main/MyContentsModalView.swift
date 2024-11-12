//
//  MyContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

struct MyContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @State var story: Story?
    @State private var scale: CGFloat = 0.1
    @State private var userInfo: UserInfo? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            if userInfo != nil {
                ContentsModalTopView(selectedUserInfo: userInfo!)
                
                StoryContentsView(story: $story)
            }
            
            HStack {
                Button(action: {
                    // isPresentedLikedSheet
                }) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.accent)
                        .frame(width: 30)
                        .fontWeight(.light)
                }
            }
        }
        .padding()
        .background(.subColor4)
        .cornerRadius(8)
        .scaleEffect(scale)
        .onAppear {
            Task {
                // 사용자 본인의 정보 받아오기
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                // 사용자 본인의 정보 변수에 저장
                userInfo = userInfoStore.userInfo
                // 사용자 본인의 story
                try await story = storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
            }
            
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.1
            }
        }
        .frame(width: (screenBounds?.width ?? 0) - 32)
    }
}

