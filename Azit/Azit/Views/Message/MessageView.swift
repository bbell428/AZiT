//
//  MessageView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatListStore: ChatListStore
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    MessageTopBar() // 상단바
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    
                    ChatRoomListView() // 메시지 목록
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                        .refreshable {
                            // 메시지 새로 고침 로직
                        }
                }
            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                chatListStore.fetchChatRooms(userId: userInfoStore.userInfo?.id ?? "")
            }
        }
    }
}

struct MessageTopBar: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                // 첫 번째 영역 (왼쪽 빈 공간)
                Color.clear
                    .frame(maxWidth: .infinity)
                
                // 가운데 텍스트 영역
                Text("Messages")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // 세 번째 영역 (오른쪽 화살표)
                Button {
                    
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 30) // 우측 여백 추가
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MessageView()
            .environmentObject(ChatListStore())
    }
}
