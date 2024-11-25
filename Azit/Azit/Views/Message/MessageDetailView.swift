//
//  MessageDetailView.swift
//  Azit
//
//  Created by 박준영 on 11/4/24.
//

import SwiftUI
import UIKit
import _PhotosUI_SwiftUI

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
    
    @Binding var isShowToast: Bool
    
    @State var isOpenGallery: Bool = false
    @State private var textEditorHeight: CGFloat = 40 // 초기 높이
    @State var isSelectedImage: Bool = false // 이미지를 선택했을때
    @State var selectedImage: UIImage? // 선택된 이미지
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 스토리 클릭시, 상세 정보 (상대방 스토리를 선택했을때)
                if isFriendsContentModalPresented {
                    if selectedAlbum?.userId == userId {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isFriendsContentModalPresented = false
                                message = ""
                            }
                            .zIndex(2)
                        
                        FriendsContentsModalView(message: $message, selectedUserInfo: friend, isShowToast: $isShowToast, story: selectedAlbum)
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
                
                if isSelectedImage {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isSelectedImage = false
                        }
                        .zIndex(8)
                    
                    VStack(spacing: 10) {
                        Image(uiImage: selectedImage!)
                        HStack(spacing: 8) {
                            Button {
                                chatDetailViewStore.saveImageToPhotoLibrary(image: selectedImage!)
                            } label: {
                                Image(systemName: "tray.and.arrow.down.fill")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }

                            Text("핸드폰에 저장")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(width: 200, height: 50) // 원하는 크기로 조정
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .zIndex(9)
                }
                
                VStack {
                    // 채팅방 상단 (dismiss를 사용하기 위한 클로저 처리)
                    MessageDetailTopBar(dismissAction: { dismiss() }, nickname: nickname, profileImageName: profileImageName)
                        .frame(maxHeight: 80)
                        .zIndex(1)
                    
                    // 채팅방 메시지 내용
                    TextMessage(profileImageName: profileImageName, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, nickname: nickname, isSelectedImage: $isSelectedImage, selectedImage: $selectedImage)
                        .zIndex(1)
                    
                    // 메시지 입력 공간
                    MessageSendField(roomId: roomId, nickname: nickname, userId: userId, isOpenGallery: $isOpenGallery, textEditorHeight: $textEditorHeight)
                        .frame(height: textEditorHeight)
                    //.frame(maxHeight: 80) // 높이 제한 설정
                        .padding(.bottom, 10)
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
                    .fill(.subColor4)
                    .frame(width: 40, height: 40)
                
                Text(profileImageName)
                    .font(.title3)
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
    
    var nickname: String
    
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @Binding var isSelectedImage: Bool // 이미지를 선택했을때
    @Binding var selectedImage: UIImage? // 선택된 이미지
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatDetailViewStore.chatList, id: \.id) { chat in
                        if chat.sender == authManager.userID {
                            PostMessage(chat: chat, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, isSelectedImage: $isSelectedImage,
                                        selectedImage: $selectedImage,nickname: nickname)
                        } else {
                            GetMessage(chat: chat, profileImageName: profileImageName, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum, isSelectedImage: $isSelectedImage, selectedImage: $selectedImage)
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
                .onChange(of: keyboardObserver.isKeyboardVisible) { isVisible in
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

// 메시지 보내는 공간
struct MessageSendField: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @State var text: String = "" // 텍스트 필드
    var roomId: String
    var nickname: String
    var userId: String // 상대방 id
    @State var otherUserInfo: UserInfo? // 상대방 아이디로 UserInfo 할당하기 위해 사용
    
    @Binding var isOpenGallery: Bool
    @Binding var textEditorHeight: CGFloat // 초기 높이
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .frame(height: textEditorHeight + 10)
            //.frame(maxHeight: 80) // 높이 제한 설정
                .cornerRadius(20)
                .padding(.horizontal, 10)
                .foregroundStyle(Color.gray.opacity(0.1))
                .zIndex(1)
            
            HStack(alignment: .bottom) {
                Spacer()
                
                PhotosPicker(
                    selection: $chatDetailViewStore.imageSelection,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                    }
                    .onChange(of: chatDetailViewStore.imageSelection) { _, _ in
                        if chatDetailViewStore.imageSelection != nil {
                            Task {
                                // 이미지 처리 및 업로드 로직 호출
                                await chatDetailViewStore.handleImageSelection()
                                await chatDetailViewStore.uploadImage(myId: userInfoStore.userInfo?.id ?? "", friendId: userId)
                            }
                        }
                    }
                
                // 텍스트 입력 필드
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("\(nickname)에게 보내기")
                            .foregroundColor(Color.gray.opacity(0.3))
                            .padding(.horizontal, 10)
                            .zIndex(5)
                    }
                    
                    TextEditor(text: $text)
                        //.padding(.horizontal, 5)
                        .foregroundColor(Color.black)
                        .frame(height: textEditorHeight)
                        .scrollContentBackground(.hidden)
                    //.frame(maxHeight: 80) // 높이 제한 설정
                    //.background(Color.gray.opacity(0.1)) // 텍스트 에디터 배경색 회색 적용
                        .cornerRadius(15)
                        .onChange(of: text) { _, _ in
                            adjustHeight() // 높이 조정
                        }
                }
                
                // 전송 버튼
                Button(action: {
                    Task {
                        guard !text.isEmpty else { return }
                        print("메시지 전송: \(text)")
                        await chatDetailViewStore.sendMessage(text: text, myId: userInfoStore.userInfo?.id ?? "", friendId: userId)
                        
                        sendNotificationToServer(myNickname: userInfoStore.userInfo?.nickname ?? "", message: text, fcmToken: otherUserInfo?.fcmToken ?? "", badge: await userInfoStore.sumIntegerValuesContainingUserID(userID: otherUserInfo?.id ?? "")) // 푸시 알림-메시지
                        
                        text = "" // 메시지 전송 후 입력 필드를 초기화
                        adjustHeight() // 높이 리셋
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .padding(.horizontal, 12.5)
                        .padding(.vertical, 5)
                        .font(.title3)
                        .foregroundColor(.white)
                        .background(.accent)
                        .cornerRadius(15)
                }
                .padding(.bottom, 3)
                .disabled(text.isEmpty)
                
                Spacer()
            }
            .padding(10)
            .zIndex(2)
        }
        .onAppear {
            Task {
                // 상대방의 UserInfo 가져옴, 상대방 토큰을 위해 사용함
                otherUserInfo = try await userInfoStore.getUserInfoById(id: userId) ?? UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0, blockedFriends: [], fcmToken: "")
                
                // 해당 채팅방으로 들어가면 배지 업데이트(읽음 메시지는 배지 알림 개수 전체에서 빼기)
                await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID))
            }
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

//#Preview {
//    MessageDetailView(roomId: "chu_parkjunyoung", nickname: "Test", profileImageName: "🐶")
//        .environmentObject(ChatDetailViewStore())
//}
