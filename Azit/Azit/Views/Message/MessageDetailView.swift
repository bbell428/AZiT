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
                
                // 사진에서 이미지를 선택했는가?
                if chatDetailViewStore.isChoicePhoto {
                    // MARK: 업로드 전 선택한 이미지가 맞는지 선택하는 View
                    CheckUploadImageView(friendId: friendId)
                        .zIndex(2)
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
                
                // 이미지 업로드 중일 때 ProgressView와 텍스트 표시
                if chatDetailViewStore.isLoadChatList {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("채팅 불러오는중..")
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
                    RoomMessageListView(isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, isSelectedImage: $isSelectedImage, selectedImage: $selectedImage, nickname: nickname, profileImageName: profileImageName, roomId: roomId)
                        .zIndex(1)
                    
                    // MARK: 메시지 입력 공간
                    MessageSendFieldView(isOpenGallery: $isOpenGallery, textEditorHeight: $textEditorHeight, roomId: roomId, nickname: nickname  ,friendId: friendId)
                        .frame(height: textEditorHeight)
                        .padding(.bottom, 10)
                        .zIndex(1)
                }
            }
            .onAppear {
                Task {
                    // 채팅방 리스트 리스너 off
                    chatListStore.removeChatRoomsListener()
                }
            }
            .onDisappear {
                Task {
                    // 채팅방 리스트 리스너 on
                     chatListStore.fetchChatRooms(userId: userInfoStore.userInfo?.id ?? "")
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

