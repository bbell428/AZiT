//
//  MessageView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

// 메시지 채팅방 View
struct MessageView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatListStore: ChatListStore
    @Environment(\.dismiss) var dismiss
    @Binding var isSendFriendStoryToast: Bool // 상대방 게시물에 메시지를 전송했는가? (Toast Message)
    @Binding var isShowingMessageView: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .top) {
                    // MARK: 상단바
                    MessageListTopBarView(isShowingMessageView: $isShowingMessageView)
                    
                    // 만약, 생성된 채팅방 리스트가 없다면?
                    if chatListStore.chatRoomList.isEmpty {
                        VStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "ellipsis.message.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.gray)
                                .padding(.bottom, 10)
                            Text("친구 스토리에 답장을 하면 채팅방이 생성됩니다.")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            Spacer()  // 아래쪽 Spacer
                        }
                        .padding(.top, 70)
                        .frame(maxHeight: .infinity)
                        // 생성된 채팅방 리스트가 1개 이상 존재
                    } else {
                        // MARK: 채팅방 리스트
                        ChatRoomListView(isSendFriendStoryToast: $isSendFriendStoryToast)
                            .padding(.top, 70)
                            .frame(maxHeight: .infinity)
                    }
                }
            }
        }
        .transition(.move(edge: .trailing))
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation(.easeInOut) {
                            isShowingMessageView = false
                        }
                    }
                }
        )
        .navigationBarBackButtonHidden(true)
/// 메인화면에서 호출중으로, 메시지 View에서 추가적으로 호출하지 않음.
        .onAppear {
            Task {
                chatListStore.fetchChatRooms(userId: userInfoStore.userInfo?.id ?? "")
            }
        }
        .onDisappear {
            chatListStore.removeChatRoomsListener()
        }
    }
}
