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
    @Binding var isAnimatingForStroke: Bool
    
    @State private var story: Story?
    @State private var friends: [UserInfo] = []
    @State private var scale: CGFloat = 0.1
    @State private var userInfo: UserInfo?
    @State private var isPresentedLikedSheet: Bool = false
    @State private var isLoadingStory: Bool = true // Story 로딩 상태 추가
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 15) {
                if let userInfo = userInfo {
                    // 상단 뷰
                    ContentsModalTopView(story: $story, selectedUserInfo: userInfo)
                    
                    // Story 로딩 상태 처리
                    if isLoadingStory {
                        ProgressView() // 로딩 중 표시
                    } else if let story = story {
                        StoryContentsView(story: story) // 로드된 Story 전달
                    } else {
                        Text("스토리가 없습니다.")
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    // Likes 버튼
                    Button {
                        isPresentedLikedSheet = true
                    } label: {
                        VStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.accent)
                                .frame(width: 30)
                                .fontWeight(.light)
                            
//                            Text("Likes")
//                                .font(.caption)
//                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // + 버튼 (이모지 추가)
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
            .cornerRadius(15)
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
                EmojiView(isDisplayEmojiPicker: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented, isAnimatingForStroke: $isAnimatingForStroke)
                    .zIndex(3)
            }
        }
        .onAppear {
            loadUserAndStoryData()
        }
    }
    
    private func loadUserAndStoryData() {
        Task {
            isLoadingStory = true // 로딩 시작
            do {
                // 사용자 본인의 정보 가져오기
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfo = userInfoStore.userInfo
                
                // 사용자 본인의 Story 가져오기
                story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                
                // Story 좋아요 목록에서 친구 정보 가져오기
                if let friendIDs = story?.likes {
                    friends = try await userInfoStore.loadUsersInfoByEmail(userID: friendIDs)
                }
            } catch {
                print("데이터 로드 실패: \(error.localizedDescription)")
            }
            isLoadingStory = false // 로딩 종료
        }
    }
}
