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
    @Binding var isShowToast: Bool
    
    var body: some View {
        NavigationStack {
                VStack {
                    ZStack(alignment: .top) {
                        // 상단바
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 25))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 30)

                            // 가운데 텍스트 영역
                            Text("Messages")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                            .frame(height: 70)
                        
                        if chatListStore.chatRoomList.isEmpty {
                            VStack(alignment: .center) {
                                Spacer()  // 위쪽 Spacer
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
                            .frame(maxHeight: .infinity)  // 화면 중앙에 오도록 설정
                        } else {
                            ChatRoomListView(isShowToast: $isShowToast) // 메시지 목록
                                .padding(.top, 70)
                                .frame(maxHeight: .infinity)
                                .refreshable {
                                    // 메시지 새로 고침 로직
                                }
                        }
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
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

//#Preview {
//    NavigationStack {
//        MessageView()
//            .environmentObject(ChatListStore())
//            .environmentObject(AuthManager())
//            .environmentObject(UserInfoStore())
//    }
//}
