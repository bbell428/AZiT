//
//  ChatRoomListView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 메시지 채팅방 List View
struct ChatRoomListView: View {
    @EnvironmentObject var chatListStore: ChatListStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @Binding var isShowToast: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) { // Divider로 구분하므로 spacing은 0으로 설정
                    ForEach(Array(chatListStore.chatRoomList.enumerated()), id: \.element.id) { index, chatroom in
                        if let otherParticipantID = chatroom.participants.first(where: { $0 != authManager.userID }),
                           let friend = userInfoStore.friendInfo[otherParticipantID] {
                            NavigationLink {
                                MessageDetailView(
                                    friend: friend,
                                    roomId: chatroom.roomId,
                                    nickname: friend.nickname,
                                    userId: friend.id, profileImageName: friend.profileImageName,
                                    isShowToast: $isShowToast
                                )
                            } label: {
                                HStack {
                                    ZStack(alignment: .center) {
                                        Circle()
                                            .fill(.subColor3)
                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                        
                                        Text(friend.profileImageName) // 프로필 이미지가 문자열로 설정된 경우
                                            .font(.largeTitle)
                                    }
                                    .frame(alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text("\(friend.nickname)") // 친구의 닉네임
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.black)
                                            
                                            Text(chatroom.formattedLastMessageAt) // 보내고 나서 지난 시간
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                            
                                            if let unreadCount = chatroom.notReadCount[authManager.userID] { // 상대방 UID로 값 접근
                                                    Text("\(unreadCount)") // 상대방의 읽지 않은 메시지 개수 표시
                                                        .font(.subheadline)
                                                        .foregroundStyle(.red)
                                                } else {
                                                    Text("0") // 기본값
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                                }
                                        }
                                        
                                        // 메시지 길이가 12 보다 크다면 생략표시
                                        Text(chatroom.lastMessage.count > 12 ? "\(chatroom.lastMessage.prefix(12))..." : chatroom.lastMessage)
                                            .font(.subheadline)
                                            .fontWeight(.thin)
                                            .foregroundStyle(Color.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                }
                                .frame(height: geometry.size.height * 0.1)
                            }
                            
                            // Divider 추가 (마지막 항목 제외)
                            if index < chatListStore.chatRoomList.count - 1 {
                                Divider()
                                    .padding(.horizontal, geometry.size.width * 0.06) // 프로필 이미지 크기에 맞춰 패딩
                                    .padding(.vertical, geometry.size.height * 0.02)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            chatListStore.startTimer() // MessageView가 나타날 때 타이머 시작
        }
        .onDisappear {
            chatListStore.stopTimer() // MessageView가 닫힐 때 타이머 중지
        }
    }
}
