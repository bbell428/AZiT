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
                LazyVStack(spacing: 20) {
                    ForEach(chatListStore.chatRoomList, id: \.id) { chatroom in
                        // authManager.userID를 제외한 첫 번째 참가자 UID 찾기
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
                                        }
                                        
                                        // 메시지 길이가 10 보다 크다면 생략표시
                                        Text(chatroom.lastMessage.count > 10 ? "\(chatroom.lastMessage.prefix(10))..." : chatroom.lastMessage)
                                            .font(.subheadline)
                                            .fontWeight(.thin)
                                            .foregroundStyle(Color.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                    
                                    //                                    ZStack(alignment: .center) {
                                    //                                        Circle()
                                    //                                            .fill(Color.red)
                                    //                                            .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    //
                                    //                                        Text("1")
                                    //                                            .font(.subheadline)
                                    //                                            .foregroundStyle(Color.white)
                                    //                                    }
                                    //                                    .frame(alignment: .trailing)
                                    //                                    .padding(.trailing, 20)
                                }
                                .frame(height: geometry.size.height * 0.1)
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
