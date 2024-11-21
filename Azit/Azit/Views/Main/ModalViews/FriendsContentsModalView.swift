//
//  FriendsContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI
import AlertToast
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}

struct FriendsContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @Binding var message: String
    var selectedUserInfo: UserInfo
    @Binding var isShowToast: Bool
    
    @State var story: Story? = nil
    @State private var isLiked: Bool = false
    @State private var scale: CGFloat = 0.1
    
    @State private var isLoadingStory = true // Story 로딩 상태
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            ContentsModalTopView(story: $story, selectedUserInfo: selectedUserInfo)
            
            if isLoadingStory {
                ProgressView() // Story 로딩 중 표시
            } else {
                if let story = story {
                    StoryContentsView(story: story) // 로드된 Story 전달
                } else {
                    Text("스토리가 없습니다.")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                ZStack(alignment: .trailing) {
                    TextField("message", text: $message, prompt: Text("\(selectedUserInfo.nickname)에게 메세지 보내기")
                        .font(.caption))
                    .padding(3)
                    .padding(.leading, 10)
                    .frame(height: 30)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.accent, lineWidth: 1)
                    )
                    .onSubmit {
                        sendMessage()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if !message.isEmpty {
                        sendMessage()
                    } else {
                        isLiked.toggle()
                        
                        if isLiked {
                            Task {
                                story?.likes.append(userInfoStore.userInfo?.id ?? "")
                                await storyStore.addStory(story!)
                            }
                        } else {
                            Task {
                                story?.likes.removeAll(where: { $0 == userInfoStore.userInfo?.id ?? "" })
                                await storyStore.addStory(story!)
                            }
                        }
                    }
                }) {
                    Image(systemName: !message.isEmpty ? "paperplane.fill" : (isLiked ? "heart.fill" : "heart"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.accent)
                        .frame(width: 25, height: 25)
                }
            }
        }
//        .toast(isPresenting: $showToast, alert: {
//            AlertToast(displayMode: .alert, type: .systemImage("envelope.open", Color.white), title: "전송 완료", style: .style(backgroundColor: .subColor1, titleColor: Color.white))
//        })
        .padding()
        .background(.subColor4)
        .cornerRadius(8)
        .scaleEffect(scale)
        .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight - 150 : keyboardObserver.keyboardHeight)
        .animation(.easeOut(duration: 0.3), value: keyboardObserver.keyboardHeight)
        .onTapGesture {
            self.endTextEditing()
        }
        .onAppear {
            message = ""
            
            Task {
                await loadStory()
            }
           
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.1
            }
        }
        .frame(width: (screenBounds?.width ?? 0) - 32)
    }
    
    private func loadStory() async {
        Task {
            isLoadingStory = true
            if story == nil {
                do {
                    story = try await storyStore.loadRecentStoryById(id: selectedUserInfo.id)
                    
                    if let contains = story?.likes.contains(userInfoStore.userInfo?.id ?? "") {
                        isLiked = contains ? true : false
                    }
                } catch {
                    print("스토리 로드 실패: \(error.localizedDescription)")
                }
            }
            isLoadingStory = false
        }
    }
    
    private func sendMessage() {
        Task {
            guard !message.isEmpty else { return }
            await chatDetailViewStore.sendMessage(
                text: message,
                myId: userInfoStore.userInfo?.id ?? "",
                friendId: story?.userId ?? "",
                storyId: story?.id ?? ""
            )
            print("메시지 전송에 성공했습니다!")
            message = ""
            isShowToast.toggle()
        }
    }
}
