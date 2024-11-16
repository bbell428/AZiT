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
    
    @Binding var isDisplayEmojiPicker: Bool
    @Binding var isMyModalPresented: Bool
    
    
    @State var story: Story?
    @State var friends: [UserInfo] = []
    @State private var scale: CGFloat = 0.1
    @State private var userInfo: UserInfo? = nil
    @State private var isPresentedLikedSheet: Bool = false
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 15) {
                if userInfo != nil {
                    ContentsModalTopView(story: $story, selectedUserInfo: userInfo!)
                    
                    StoryContentsView(story: $story)
                }
                
                HStack {
                    Button {
                        isPresentedLikedSheet = true
                    } label: {
                        VStack {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.accent)
                                .frame(width: 30)
                                .fontWeight(.light)
                            
                        Text("Likes")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        isDisplayEmojiPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.accent)
                            .frame(width: 30)
                            .fontWeight(.light)                        
                    }
                    
                    Spacer()
                    Spacer()
                        .frame(width: 30)
                }
            }
            .padding()
            .background(.subColor4)
            .cornerRadius(8)
            .scaleEffect(scale)
            .onAppear {
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
            .sheet(isPresented: $isPresentedLikedSheet) {
                LikesSheetView(friends: $friends)
            }
            
            // + 버튼 클릭했을 시
            if isDisplayEmojiPicker {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isDisplayEmojiPicker = false
                    }
                    .zIndex(2)
                EmojiView(isDisplayEmojiPicker: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented)
                    .zIndex(3)
            }
        }
        .onAppear {
            // 친구들 이름 목록 배열화
            Task {
                // 사용자 본인의 정보 받아오기
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                // 사용자 본인의 정보 변수에 저장
                userInfo = userInfoStore.userInfo
                // 사용자 본인의 story
                story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                // 친구 ID 가져오기
                let friendIDs: [String] = story?.likes ?? []
                // 친구 ID로 UserInfo 불러오기
                friends = try await userInfoStore.loadUsersInfoByEmail(userID: friendIDs)
            }
        }
    }
}
