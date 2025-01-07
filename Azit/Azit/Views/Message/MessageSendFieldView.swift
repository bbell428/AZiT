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
                if selectedMessage?.sender != userInfoStore.userInfo?.id {
                    Text("\(nickname)님에게 답장 보내기")
                        .padding(.horizontal, 10)
                } else {
                    Text("\(userInfoStore.userInfo!.nickname)님에게 답장 보내기")
                        .padding(.horizontal, 10)
                }
                Text(selectedMessage?.message ?? "")
                    .padding(.horizontal, 10)
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
                                
                                await chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: friendId)
                                
                                // 상대방이 로그아웃 한 상태가 아니라면 메시지 입력하여 전송 시, 알림을 보냄
                                if otherUserInfo?.fcmToken != nil {
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
                                }
                                
//                                text = "" // 메시지 전송 후 입력 필드를 초기화
                                adjustHeight() // 높이 리셋
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
                .padding(10)
                .zIndex(2)
            }
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
                    await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID), myUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: "", viewType: "")
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


