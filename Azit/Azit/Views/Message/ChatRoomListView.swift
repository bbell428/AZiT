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
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isSendFriendStoryToast: Bool // 상대방 게시물에 메시지를 전송했는가? (Toast Message)
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(chatListStore.chatRoomList, id: \.id) { chatroom in
                        // 나와 채팅중인 상대방의 ID를 기반으로 친구 정보를 가져옴
                        if let otherParticipantID = chatroom.participants.first(where: { $0 != authManager.userID }),
                           let friend = userInfoStore.friendInfo[otherParticipantID] {
                            
                            // MARK: 1:1 메시지방 View
                            NavigationLink {
                                MessageDetailView(
                                    friend: friend,
                                    isSendFriendStoryToast: $isSendFriendStoryToast,
                                    roomId: chatroom.roomId,
                                    nickname: friend.nickname,
                                    friendId: friend.id,
                                    profileImageName: friend.profileImageName
                                )
                            } label: {
                                HStack {
                                    // 프로필
                                    ZStack(alignment: .center) {
                                        Circle()
                                            .fill(Color.subColor3)
                                            .frame(width: 60, height: 60)
                                        
                                        Text(friend.profileImageName)
                                            .font(.largeTitle)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    // 최근 채팅 내용
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(friend.nickname) // 친구의 닉네임
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            
                                            Text(chatroom.formattedLastMessageAt) // 보내고 나서 지난 시간
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                        }
                                        
                                        // 메시지 길이가 15 보다 크다면 생략표시
                                        Text(chatroom.lastMessage.count > 15 ? "\(chatroom.lastMessage.prefix(15))..." : chatroom.lastMessage)
                                            .font(.subheadline)
                                            .fontWeight(.thin)
                                            .foregroundColor(.black)
                                            .lineLimit(2) // 최대 3줄까지만 표시
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    // 읽지 않은 메시지가 1개 이상 있을 시,
                                    if let unreadCount = chatroom.unreadCount[authManager.userID], unreadCount > 0 {
                                        ZStack(alignment: .center) {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 20, height: 20)
                                            
                                            Text("\(unreadCount)")
                                                .font(.subheadline)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.trailing, 30)
                                    }
                                }
                                .frame(height: 80)
                            }
                        }
                    }
                }
            }
    }
}
