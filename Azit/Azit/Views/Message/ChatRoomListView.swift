//
//  ChatRoomListView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

struct ChatRoomListView: View {
    @EnvironmentObject var chatListStore: ChatListStore
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatListStore.chatRoomList, id: \.id) { chatroom in
                        NavigationLink {
                            MessageDetailView(roomId: chatroom.roomId)
                        } label: {
                            HStack {
                                ZStack(alignment: .center) {
                                    Circle()
                                        .fill(.subColor3)
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                    
                                    Text("\u{1F642}")
                                        .font(.largeTitle)
                                }
                                .frame(alignment: .leading)
                                .padding(.leading, 20)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("\( chatroom.participants.first!)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.black)
                                        Text(chatroom.formattedLastMessageAt)
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    Text("\(chatroom.lastMessage)")
                                        .font(.subheadline)
                                        .fontWeight(.thin)
                                        .foregroundStyle(Color.black)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                
                                ZStack(alignment: .center) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Text("1")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white)
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 20)
                                
                            }
                            .frame(height: geometry.size.height * 0.1)
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
