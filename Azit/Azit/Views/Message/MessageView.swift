//
//  MessageView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MessageView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    MessageTopBar() // 상단바
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                    
                    MessageList() // 메시지 목록
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                        .refreshable {
                            // 메시지 새로 고침 로직
                        }
                }
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

struct MessageList: View {
    @EnvironmentObject var chatListStore: ChatListStore
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatListStore.chatList, id: \.id) { chatroom in
                        NavigationLink {
                            MessageDetailView()
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

#Preview {
    NavigationStack {
        MessageView()
            .environmentObject(ChatListStore())
    }
}
