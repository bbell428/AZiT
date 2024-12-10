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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatDetailViewStore.chatList, id: \.id) { chat in
                        if chat.sender == authManager.userID {
                            // MARK: 보낸 메시지
                            PostMessage(isFriendsContentModalPresented: $isFriendsContentModalPresented, isSelectedImage: $isSelectedImage, selectedAlbum: $selectedAlbum, selectedImage: $selectedImage, chat: chat, nickname: nickname)
                        } else {
                            // MARK: 받은 메시지
                            GetMessage(isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, isSelectedImage: $isSelectedImage, selectedImage: $selectedImage, chat: chat, profileImageName: profileImageName)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                        .id("Bottom")
                }
                // 초기에 가장 하단 스크롤으로 이동
                .onAppear {
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
                // 메시지가 전송/전달 되면 하단 스크롤으로 이동
                .onChange(of: chatDetailViewStore.lastMessageId) { id, _ in
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
                        proxy.scrollTo("Bottom", anchor: .bottom)
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
