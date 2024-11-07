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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30) // 우측 여백 추가
                        }

                        // 가운데 텍스트 영역
                        Text("Messages")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                    }
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    
                    ChatRoomListView() // 메시지 목록
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                        .refreshable {
                            // 메시지 새로 고침 로직
                        }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .swipeActions(edge: .trailing) {
            MainView()
        }
        .onAppear {
            Task {
                //await userInfoStore.loadUserInfo(userID: authManager.userID)
                chatListStore.fetchChatRooms(userId: userInfoStore.userInfo?.id ?? "")
            }
        }
        .onDisappear {
            chatListStore.removeChatRoomsListener()
        }
    }
}

#Preview {
    NavigationStack {
        MessageView()
            .environmentObject(ChatListStore())
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
    }
}
