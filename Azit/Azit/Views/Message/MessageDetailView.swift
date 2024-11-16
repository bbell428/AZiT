//
//  MessageDetailView.swift
//  Azit
//
//  Created by 박준영 on 11/4/24.
//

import SwiftUI
import UIKit

// 키보드 내리기 위한
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// NavigationTitle를 숨겨도, 뒤로가는 제스처(Swipe)는 그대로 유지하기 위한
// 단점 : 모든 NavigationStack에 적용됨 (extension으로)
extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct CustomNavigationView<Content: View>: UIViewControllerRepresentable {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: content))
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        uiViewController.setViewControllers([UIHostingController(rootView: content)], animated: false)
    }
}

// 1:1 메시지방 View
struct MessageDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @Environment(\.dismiss) var dismiss
    @State var isFriendsContentModalPresented: Bool = false
    @State var selectedAlbum: Story?
    @State var message: String = ""
    @State var friend: UserInfo // 상대방 정보
    var roomId: String // 메시지방 id
    var nickname: String // 상대방 닉네임
    var userId: String // 상대방 id
    var profileImageName: String // 상대방 프로필 아이콘
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 스토리 클릭시, 상세 정보
                if isFriendsContentModalPresented {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isFriendsContentModalPresented = false
                                message = ""
                            }
                            .zIndex(2)
                        
                        FriendsContentsModalView(message: $message, selectedUserInfo: $friend, story: selectedAlbum)
                            .zIndex(3)
                            .frame(maxHeight: .infinity, alignment: .center)
                }
                
                    VStack {
                        // 채팅방 상단 (dismiss를 사용하기 위한 클로저 처리)
                        MessageDetailTopBar(dismissAction: { dismiss() }, nickname: nickname, profileImageName: profileImageName)
                            .frame(maxHeight: 80)
                            .zIndex(1)
                        
                        // 채팅방 메시지 내용
                        TextMessage(profileImageName: profileImageName, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum)
                            .zIndex(1)
                        
                        // 메시지 입력 공간
                        MessageSendField(roomId: roomId, nickname: nickname, userId: userId)
                            .frame(maxHeight: 50)
                            .padding(.bottom)
                            .zIndex(1)
                    }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                chatDetailViewStore.getChatMessages(roomId: roomId, userId: authManager.userID)
            }
            .onDisappear {
                chatDetailViewStore.removeChatMessagesListener()
            }
        }
    }
}

// 채팅방 상단
struct MessageDetailTopBar: View {
    let dismissAction: () -> Void
    var nickname: String
    var profileImageName: String
    
    var body: some View {
        HStack {
            Button(action: {
                dismissAction() // dismiss: 이전 화면으로 돌아가기
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.black)
                    //Text("Custom Back")
                }
            }
            .frame(alignment: .leading)
            .padding(.leading, 20)
            
            ZStack(alignment: .center) {
                Circle()
                    .fill(.subColor3)
                    .frame(width: 60, height: 60)
                
                Text(profileImageName)
                    .font(.system(size: 40))
            }
            .frame(alignment: .leading)
            .padding(.leading, 10)
            
            Text(nickname)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            
        }
    }
}

// 채팅방 메시지 내용
struct TextMessage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    var profileImageName: String
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedAlbum: Story?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatDetailViewStore.chatList, id: \.id) { chat in
                        if chat.sender == authManager.userID {
                            PostMessage(chat: chat, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum)
                        } else {
                                GetMessage(chat: chat, profileImageName: profileImageName)
                        }
                    }
            
                    Rectangle()
                        .fill(Color.white)
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
            }
        }
        // 다른곳 터치시 키보드 내리기
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// 메시지 보내는 공간
struct MessageSendField: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @State var text: String = "" // 텍스트 필드
    var roomId: String
    var nickname: String
    var userId: String // 상대방 id
    
    var body: some View {
        HStack {
            TextField("\(nickname)에게 보내기", text: $text)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                // 키보드에 있는 전송 버튼을 활용할때,
                .onSubmit {
                    // 메시지가 비어 있지 않을 경우에만 전송
                    guard !text.isEmpty else { return }
                    Task {
                        print("메시지 전송: \(text)")
                        chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: userId)
                        text = "" // 메시지 전송 후 입력 필드를 비웁니다.
                    }
                }
            
            // 전송 버튼
            Button(action: {
                Task {
                    print("메시지 전송: \(text)")
                    chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: userId)
                    text = "" // 메시지 전송 후 입력 필드를 비웁니다.
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .padding()
            }
            // 텍스트가 없으면 버튼 비활성화
            .disabled(text.isEmpty)
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    MessageDetailView(roomId: "chu_parkjunyoung", nickname: "Test", profileImageName: "🐶")
//        .environmentObject(ChatDetailViewStore())
//}
