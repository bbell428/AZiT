//
//  RoomMessageListView.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import SwiftUI

// 채팅방 내용 리스트
struct RoomMessageListView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedAlbum: Story?
    @Binding var isSelectedImage: Bool // 이미지를 선택했을때
    @Binding var selectedImage: UIImage? // 선택된 이미지
    
    var nickname: String
    var profileImageName: String
    var roomId: String
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월 d일" // 날짜 형식에 맞게 설정
        return formatter
    }()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 메시지를 날짜별로 그룹화
                    let TimeLineMessages = chatDetailViewStore.groupMessagesByDate(chatDetailViewStore.chatList)
                    
                    ForEach(TimeLineMessages.keys.sorted{
                        // 날짜 문자열을 Date로 변환 후 비교
                        guard let firstDate = dateFormatter.date(from: $0),
                              let secondDate = dateFormatter.date(from: $1) else {
                            return false
                        }
                        return firstDate < secondDate // 오름차순 정렬
                    }, id: \.self) { date in
                        Section {
                            // 만약, date에 해당하는 값이 존재한다면 채팅 메시지를 출력
                            // 없다면 빈공백으로 만들고, 날짜를 출력시킴
                            ForEach(TimeLineMessages[date] ?? []) { chat in
                                if chat.sender == authManager.userID {
                                    // 보낸 메시지
                                    PostMessage(isFriendsContentModalPresented: $isFriendsContentModalPresented,
                                                isSelectedImage: $isSelectedImage,
                                                selectedAlbum: $selectedAlbum,
                                                selectedImage: $selectedImage,
                                                chat: chat,
                                                nickname: nickname)
                                } else {
                                    // 받은 메시지
                                    GetMessage(isFriendsContentModalPresented: $isFriendsContentModalPresented,
                                               selectedAlbum: $selectedAlbum,
                                               isSelectedImage: $isSelectedImage,
                                               selectedImage: $selectedImage,
                                               chat: chat,
                                               profileImageName: profileImageName)
//                                    .onLongPressGesture(minimumDuration: 1.5) {
//                                            print("선택")
//                                        }
                                }
                            }
                            // 날짜 구분선
                        } header: {
                            Text(date)
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .padding(8)
                        }
                    }
                    
                    // 최하단 scroll 용도
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .id("Bottom")
                }
                .onAppear {
                    Task {
                        // 해당 채팅방 데이터 리스너 on
                        chatDetailViewStore.getChatMessages(roomId: roomId, userId: authManager.userID)
                    }
                }
                .onDisappear {
                    Task {
                        // 해당 채팅방 데이터 리스너 off
                        chatDetailViewStore.removeChatMessagesListener()
                    }
                }
                .onChange(of: chatDetailViewStore.isLoadChatList) { _, isLoadChatList in
                    if !isLoadChatList {
                        print("하단으로 이동")
                        proxy.scrollTo("Bottom", anchor: .bottom)
                    }
                }
                // 메시지가 전송/전달 되면 하단 스크롤으로 이동
                .onChange(of: chatDetailViewStore.lastMessageId) { _, _ in
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
                // 키보드가 올라오면 하단 스크롤로 이동
                .onChange(of: keyboardObserver.isKeyboardVisible) { _, isVisible in
                    if isVisible {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                proxy.scrollTo("Bottom", anchor: .bottom)
                            }
                        }
                    } else {
                        proxy.scrollTo("Bottom", anchor: .top)
                    }
                }
            }
        }
        // 다른 곳 터치 시 키보드 내리기
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
