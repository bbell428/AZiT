//
//  SendMessageView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// 받은 메시지
struct GetMessage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    var chat: Chat
    var profileImageName: String // 상대방 프로필 아이콘
    
    @State private var shareStory: Story?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var imageURL: URL?
    @State private var isLoadingImage: Bool = true
    @State private var loadFailed: Bool = false
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedAlbum: Story?
    
    //var nickname: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(profileImageName)
                .font(.largeTitle)
                .padding(.leading, 20)
            
            // 받은 메시지 내용
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    if let story = shareStory {
                        // Story가 존재하는 경우
                        HStack(spacing: 0) {
                            Text("\(userInfoStore.userInfo!.nickname)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)
                            Text("님의 게시물에 답장했습니다.")
                                .font(.caption2)
                                .fontWeight(.light)
                        }
                        
                        HStack {
                            Rectangle()
                                .cornerRadius(15)
                                .frame(width: 3, height: 120)
                                .foregroundStyle(Color.gray.opacity(0.07))
                            
                            Button {
                                isFriendsContentModalPresented = true
                                selectedAlbum = story
                            } label: {
                                VStack {
                                    if let imageURL = imageURL, !loadFailed {
                                        // 이미지가 있으면 URL로 로드
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 90, height: 120)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 90, height: 120)
                                                    .cornerRadius(15)
                                            case .failure:
                                                PlaceholderView() // 로드 실패 시 대체 뷰
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        // 이미지가 없을 경우 기본 콘텐츠 표시
                                        VStack {
                                            Spacer()
                                            SpeechBubbleView(text: story.content)
                                                .font(.caption)
                                                .padding(.bottom, 5)
                                            Text(story.emoji)
                                                .font(.largeTitle)
                                            Spacer()
                                        }
                                        .frame(width: 90, height: 120)
                                        .background(
                                            Image("storyBackImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        )
                                        .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        
                        
                    } else if isLoading {
                        Text("Loading story...")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                    HStack(alignment: .bottom) {
                        Text(chat.message)
                            .font(.headline)
                            .foregroundStyle(Color.black.opacity(0.5))
                            .multilineTextAlignment(.trailing)
                            //.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .padding(10)
                            .background(.accent)
                            .cornerRadius(15)
                            .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                            .id(chat.id)
                        
                        VStack(alignment: .leading) {
                            if !chat.readBy.contains(where: { $0 != authManager.userID }) {
                                Text("1")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
                            }
                            Text(chat.formattedCreateAt)
                                .font(.caption2)
                                .fontWeight(.light)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(maxWidth: 300, alignment: .leading)
                }
            }
            .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
            .frame(maxWidth: 300, alignment: .leading)
            //.padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            loadStoryAndImage()
        }
    }
    
    // 스토리와 이미지 불러오기
    private func loadStoryAndImage() {
        Task {
            if let storyId = chat.storyId, !storyId.isEmpty {
                isLoading = true
                errorMessage = nil
                
                do {
                    let fetchedStory = try await fetchStory(storyId: storyId)
                    
                    if !fetchedStory.image.isEmpty {
                        await loadImage(imageStoreID: fetchedStory.image)
                    }
                    
                    self.shareStory = fetchedStory
                } catch {
                    errorMessage = "Failed to load story: \(error.localizedDescription)"
                }
                
                isLoading = false
            }
        }
    }
    
    // Firestore에서 Story 가져오기
    private func fetchStory(storyId: String) async throws -> Story {
        let db = Firestore.firestore()
        let document = try await db.collection("Story").document(storyId).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])
        }
        
        let userId = data["userId"] as? String ?? ""
        let emoji = data["emoji"] as? String ?? ""
        let content = data["content"] as? String ?? ""
        let likes = data["likes"] as? [String] ?? []
        let latitude = data["latitude"] as? Double ?? 0.0
        let longitude = data["longitude"] as? Double ?? 0.0
        let address = data["address"] as? String ?? ""
        let image = data["image"] as? String ?? ""
        let publishedTargets = data["publishedTargets"] as? [String] ?? []
        let readUsers = data["readUsers"] as? [String] ?? []
        let dateTimestamp = data["date"] as? Timestamp
        let date = dateTimestamp?.dateValue() ?? Date()
        
        return Story(id: document.documentID,
                     userId: userId,
                     likes: likes,
                     date: date,
                     latitude: latitude,
                     longitude: longitude,
                     address: address,
                     emoji: emoji,
                     image: image,
                     content: content,
                     publishedTargets: publishedTargets,
                     readUsers: readUsers)
    }
    
    // Firebase Storage에서 URL을 비동기적으로 가져오는 함수
    private func loadImage(imageStoreID: String) async {
        isLoadingImage = true
        loadFailed = false
        
        let storage = Storage.storage()
        let imageRef = storage.reference().child("image/\(imageStoreID)")
        
        do {
            self.imageURL = try await imageRef.downloadURL()
        } catch {
            loadFailed = true
            print("이미지 로드 실패: \(error.localizedDescription)")
        }
        
        isLoadingImage = false
    }
}

//#Preview {
//    GetMessage(chat: Chat(createAt: Date(), message: "안녕하세요! 반갑습니다 어서오세요 안녕하세요! 반갑습니다 어서오세요 \n새로운 줄입니다!", sender: "parkjunyoung", readBy: ["parkjunyoung"]), profileImageName: "\u{1F642}")
//}
