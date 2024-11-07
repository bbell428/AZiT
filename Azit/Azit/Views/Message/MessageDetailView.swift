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

struct MessageDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @Environment(\.dismiss) var dismiss
    var roomId: String
    var nickname: String
    var profileImageName: String
    
    var body: some View {
        NavigationStack {
            VStack {
                // 채팅방 상단 (dismiss를 사용하기 위한 클로저 처리)
                MessageDetailTopBar(dismissAction: { dismiss() }, nickname: nickname, profileImageName: profileImageName)
                    .frame(maxHeight: 80)
                
                // 채팅방 메시지 내용
                TextMessage(profileImageName: profileImageName)
                
                // 메시지 입력 공간
                MessageSendField(roomId: roomId, nickname: nickname)
                    .frame(maxHeight: 50)
                    .padding(.bottom)
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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatDetailViewStore.chatList, id: \.id) { chat in
                        if chat.sender == authManager.userID {
                            PostMessage(chat: chat)
                        } else {
                            GetMessage(chat: chat, profileImageName: profileImageName)
                        }
                    }
                    Rectangle()
                        .fill(Color.white)
                        .id("Bottom")
                    //PostMessage()
                }
                .onAppear {
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
                .onChange(of: chatDetailViewStore.lastMessageId) { id, _ in
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
            }
            //            .task(id: chatDetailViewStore.lastMessageId) {
            //                print("\(chatDetailViewStore.lastMessageId)")
            //                withAnimation {
            //                    proxy.scrollTo(chatDetailViewStore.lastMessageId, anchor: .bottom)
            //                }
            //            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// 메시지 보내는 공간
struct MessageSendField: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @State var text: String = ""
    var roomId: String
    var nickname: String
    
    var body: some View {
        HStack {
            TextField("\(nickname)에게 보내기", text: $text)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                .onSubmit {
                    // 메시지가 비어 있지 않을 경우에만 전송
                    guard !text.isEmpty else { return }
                    Task {
                        print("메시지 전송: \(text)")
                        chatDetailViewStore.sendMessage(text: text, roomId: roomId, userId: authManager.userID)
                        text = "" // 메시지 전송 후 입력 필드를 비웁니다.
                    }
                }
            
            Button(action: {
                Task {
                    print("메시지 전송: \(text)")
                    chatDetailViewStore.sendMessage(text: text, roomId: roomId, userId: authManager.userID)
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

#Preview {
    MessageDetailView(roomId: "chu_parkjunyoung", nickname: "Test", profileImageName: "🐶")
        .environmentObject(ChatDetailViewStore())
}
