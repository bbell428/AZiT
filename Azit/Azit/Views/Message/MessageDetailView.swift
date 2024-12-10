//
//  MessageDetailView.swift
//  Azit
//
//  Created by 박준영 on 11/4/24.
//

import SwiftUI
import UIKit
import _PhotosUI_SwiftUI

// 1:1 메시지방 View
struct MessageDetailView: View {
    @EnvironmentObject var chatListStore: ChatListStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @Environment(\.dismiss) var dismiss
    
    @State var isFriendsContentModalPresented: Bool = false
    @State var message: String = "" // 스토리에서 보낼 메시지
    @State var isOpenGallery: Bool = false // 업로드 할 이미지를 선택하기 위해 갤러리를 open 했을때
    @State var isSelectedImage: Bool = false // 이미지를 선택했을때
    @State var textEditorHeight: CGFloat = 40 // 키보드 초기 높이
    
    @State var selectedAlbum: Story? // 선택된 스토리 정보
    @State var friend: UserInfo // 상대방 정보
    @State var selectedImage: UIImage? // 선택된 이미지
    
    @Binding var isSendFriendStoryToast: Bool // 상대방의 게시물을 open 했는가?
    
    
    var roomId: String // 메시지방 id
    var nickname: String // 상대방 닉네임
    var friendId: String // 상대방 id
    var profileImageName: String // 상대방 프로필 아이콘
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 스토리 클릭시, 상세 정보 (상대방 스토리를 선택했을때)
                if isFriendsContentModalPresented {
                    if selectedAlbum?.userId == friendId {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isFriendsContentModalPresented = false // 닫기
                                message = "" // 스토리에서 보내는 메시지 내용 지우기
                            }
                            .zIndex(2)
                        
                        // MARK: 친구 스토리
                        FriendsContentsModalView(message: $message, selectedUserInfo: friend, isSendFriendStoryToast: $isSendFriendStoryToast, story: selectedAlbum)
                            .zIndex(3)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                }
                
                // 이미지 업로드 중일 때 ProgressView와 텍스트 표시
                if chatDetailViewStore.isUploading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("이미지 업로드중..")
                                .foregroundStyle(Color.white)
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(Color.black.opacity(0.3))
                    .zIndex(9)
                }
                
                // 이미지를 클릭했을때,
                if isSelectedImage {
                    // MARK: 이미지 상세 View
                    SelectedUploadImageView(isSelectedImage: $isSelectedImage, selectedImage: $selectedImage)
                        .zIndex(2)
                }
                
                VStack {
                    // MARK: 채팅방 상단
                    // dismiss를 사용하기 위한 클로저 처리
                    MessageDetailTopBarView(dismissAction: { dismiss() }, nickname: nickname, profileImageName: profileImageName)
                        .zIndex(1)
                    
                    // MARK: 채팅방 메시지 내용
                    RoomMessageListView(isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, isSelectedImage: $isSelectedImage, selectedImage: $selectedImage, nickname: nickname, profileImageName: profileImageName)
                        .zIndex(1)
                    
                    // MARK: 메시지 입력 공간
                    MessageSendFieldView(isOpenGallery: $isOpenGallery, textEditorHeight: $textEditorHeight, roomId: roomId, nickname: nickname, friendId: friendId)
                        .frame(height: textEditorHeight)
                        .padding(.bottom, 10)
                        .zIndex(1)
                }
            }
            .onAppear {
                Task {
                    // 채팅방 리스트 리스너 off
                    chatListStore.removeChatRoomsListener()
                    // 해당 채팅방 데이터 리스너 on
                    chatDetailViewStore.getChatMessages(roomId: roomId, userId: authManager.userID)
                }
            }
            .onDisappear {
                Task {
                    // 채팅방 리스트 리스너 on
                    chatListStore.fetchChatRooms(userId: userInfoStore.userInfo?.id ?? "")
                    // 해당 채팅방 데이터 리스너 off
                    chatDetailViewStore.removeChatMessagesListener()
                }
                .padding(.bottom, 3)
                .disabled(text.isEmpty)
                
                Spacer()
            }
            .padding(10)
            .zIndex(2)
        }
        .onAppear {
            // 상대방의 UserInfo 가져옴, 상대방 토큰을 위해 사용함
            userInfoStore.getUserInfoById(id: userId) { userInfo in
                if let userInfo = userInfo {
                    DispatchQueue.main.async {
                        self.otherUserInfo = userInfo
                        print("Updated User Info: \(userInfo.nickname)")
                    }
                } else {
                    print("No user data available or error occurred.")
                }
            }
            Task {
                // 해당 채팅방으로 들어가면 배지 업데이트(읽음 메시지는 배지 알림 개수 전체에서 빼기)
                await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID), friendUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: roomId, viewType: "chatDetail")
            }
            .navigationBarBackButtonHidden(true)
        }
        //.frame(maxHeight: 80) // 높이 제한 설정
    }
    
    // 텍스트 에디터 높이를 동적으로 조정하는 함수
    private func adjustHeight() {
        let width = UIScreen.main.bounds.width - 150 // 좌우 여백 포함
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let boundingBox = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        textEditorHeight = max(40, boundingBox.height + 20) // 기본 높이 보장
    }
}
