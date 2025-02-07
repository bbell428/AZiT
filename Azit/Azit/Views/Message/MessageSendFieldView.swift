//
//  MessageSendFieldView.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

// 메시지 보내는 공간
struct MessageSendFieldView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @State var text: String = "" // 텍스트 필드
    
    @State var otherUserInfo: UserInfo? // 상대방 아이디로 UserInfo 할당하기 위해 사용
    
    @Binding var isOpenGallery: Bool
    @Binding var textEditorHeight: CGFloat // 초기 높이
    @Binding var selectedMessage: Chat? // 선택된 채팅
    
    var roomId: String   // 채팅방 ID
    var nickname: String // 상대방 닉네임
    var friendId: String // 상대방 ID
    
    var body: some View {
        VStack(alignment: .leading) {
            if selectedMessage != nil {
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.2)
                    .background(Color.gray)
                
                HStack {
                    VStack(alignment: .leading) {
                        if selectedMessage?.sender != userInfoStore.userInfo?.id {
                            HStack {
                                Image(systemName: "arrow.turn.down.right")
                                    .foregroundStyle(.gray)
                                
                                Text("replying to \(nickname)")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                        } else {
                            HStack {
                                Image(systemName: "arrow.turn.down.right")
                                    .foregroundStyle(.gray)
                                
                                Text("replying to \(userInfoStore.userInfo!.nickname)")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                        }
                        Text((selectedMessage?.message.count)! > 20 ? "\(selectedMessage!.message.prefix(20))..." : "\(selectedMessage?.message ?? "")")
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                            .padding(.vertical, 2.5)
                            .padding(.horizontal, 15)
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedMessage = nil
                    } label: {
                        Image(systemName: "delete.right.fill")
                            .font(.title2)
                    }
                    .padding(.horizontal, 15)
                }
                .frame(maxWidth: .infinity)
                .padding(5)
            }
            
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: textEditorHeight + 10)
                    .cornerRadius(20)
                    .padding(.horizontal, 10)
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .zIndex(1)
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    Button {
                        // 갤러리 open
                        isOpenGallery = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.bottom, 5)
                    
                    // 텍스트 입력 필드
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text("\(nickname)에게 보내기")
                                .foregroundColor(Color.gray.opacity(0.3))
                                .padding(.horizontal, 10)
                                .zIndex(5)
                        }
                        
                        TextEditor(text: $text)
                            .foregroundColor(Color.black)
                            .frame(height: textEditorHeight)
                            .scrollContentBackground(.hidden)
                            .cornerRadius(15)
                            .onChange(of: text) { _, _ in
                                adjustHeight() // 높이 조정
                            }
                            .padding(.top, 5)
                    }
                    
                    // 전송 버튼
                    if !text.isEmpty {
                        Button(action: {
                            Task {
                                guard !text.isEmpty else { return }
                                print("메시지 내용: \(text)")
                                
                                // 답장하려는 메시지를 선택한 경우에 메시지를 보낼 때,
                                if selectedMessage != nil {
                                    await chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: friendId, replyMessage: (selectedMessage?.message.count)! > 15 ? "\(selectedMessage!.message.prefix(15))..." : "\(selectedMessage?.message ?? "")")
                                } else {
                                    await chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: friendId)
                                }
                                
                                if otherUserInfo?.fcmToken != nil {
                                    // 상대방이 알림을 받을 설정을 했는지 확인
                                    let notificationEnabled = try await userInfoStore.getNotificationMessageByUserID(userID: friendId)
                                    
                                    if !notificationEnabled {
                                        // 상대방이 해당 채팅방에 있다면 알림X
                                        NetworkManager.shared.updateChatStatusIfNeeded(userId: friendId, chatId: roomId) { isActive in
                                            if isActive {
                                                print("상대방이 채팅방에 있습니다.")
                                                text = "" // 메시지 전송 후 입력 필드를 초기화
                                            } else {
                                                Task {
                                                    sendNotificationToServer(
                                                        myNickname: userInfoStore.userInfo?.nickname ?? "",
                                                        message: text,
                                                        fcmToken: otherUserInfo?.fcmToken ?? "",
                                                        badge: await userInfoStore.sumIntegerValuesContainingUserID(userID: otherUserInfo?.id ?? ""),
                                                        myUserInfo: userInfoStore.userInfo!,
                                                        chatId: roomId,
                                                        viewType: "chatDetail"
                                                    )
                                                    
                                                    text = "" // 메시지 전송 후 입력 필드를 초기화
                                                }
                                            }
                                        }
                                    } else {
                                        text = ""
                                        print("상대방 메시지 해제 알림이 On입니다.")
                                        // 알림은 안가면서 상대방 앱 배지는 업데이트를 위해
                                        sendNotificationToServer(
                                            myNickname: "",
                                            message: "",
                                            fcmToken: otherUserInfo?.fcmToken ?? "",
                                            badge: await userInfoStore.sumIntegerValuesContainingUserID(userID: otherUserInfo?.id ?? ""),
                                            myUserInfo: userInfoStore.userInfo!,
                                            chatId: "",
                                            viewType: ""
                                        )
                                    }
                                }
                                
//                                text = "" // 메시지 전송 후 입력 필드를 초기화
                                adjustHeight() // 높이 리셋
                                selectedMessage = nil // 선택된 메시지 해제
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .padding(.horizontal, 12.5)
                                .padding(.vertical, 7)
                                .font(.title3)
                                .foregroundColor(.white)
                                .background(text.isEmpty ? .gray : .accent)
                                .cornerRadius(15)
                        }
                        .padding(.bottom, 5)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .zIndex(2)
            }
            .padding(.bottom, 5)
        }
        .onAppear {
            // 채팅방에 들어갈 때, 해당 채팅방에 접속 상태 업데이트
            NetworkManager.shared.updateChatStatus(
                userId: authManager.userID,
                chatId: roomId,
                isActive: true // 채팅방 접속 상태 업데이트
            ) { result in
                switch result {
                case .success:
                    print("Chat status success")
                case .failure(let error):
                    print("Chat status failure: \(error.localizedDescription)")
                }
            }
            
            // 상대방의 UserInfo 가져옴, 상대방 토큰을 위해 사용함
            userInfoStore.getUserInfoByIdWithCompletion(id: friendId) { userInfo in
                if let userInfo = userInfo {
                    DispatchQueue.main.async {
                        self.otherUserInfo = userInfo
                        print("Updated User Info: (userInfo.nickname)")
                    }
                } else {
                    print("No user data available or error occurred.")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Task {
                    // 해당 채팅방으로 들어간다면 읽지 않는 알림 개수를 계산하여 서버로 전송 후, 앱 뱃지 알림 개수 계산하고 업데이트
                    await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID), myUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: "", notificationMessage: false), chatId: "", viewType: "")
                }
            }
        }
        .onDisappear {
            // 채팅방에 나갈 때, 해당 채팅방에 접속 상태 업데이트
            NetworkManager.shared.updateChatStatus(
                userId: authManager.userID,
                chatId: roomId,
                isActive: false // 채팅방 떠날 때 상태 업데이트
            ) { result in
                switch result {
                case .success:
                    print("Chat status success")
                case .failure(let error):
                    print("Chat status failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 텍스트 에디터 높이를 동적으로 조정하는 함수
    private func adjustHeight() {
        let width = UIScreen.main.bounds.width - 150 // 좌우 여백 포함
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let boundingBox = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        textEditorHeight = max(40, boundingBox.height + 16) // 기본 높이 보장
    }
}


