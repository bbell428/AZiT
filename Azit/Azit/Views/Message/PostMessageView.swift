import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct PostMessage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var albumStore: AlbumStore // 캐시 저장을 위한 AlbumStore
    var chat: Chat
    
    @State private var shareStory: Story?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var image: UIImage? // UIImage로 변경
    @State private var isLoadingImage: Bool = true
    @State private var loadFailed: Bool = false
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedAlbum: Story?
    
    @Binding var isSelectedImage: Bool // 이미지를 선택했을때
    @Binding var selectedImage: UIImage? // 선택된 이미지
    
    var nickname: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(alignment: .top) {
                VStack(alignment: .trailing, spacing: 5) {
                    if let story = shareStory {
                        // Story가 존재하는 경우
                        HStack(spacing: 0) {
                            Text("\(nickname)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)
                            Text("님의 게시물에 답장했습니다.")
                                .font(.caption2)
                                .fontWeight(.light)
                        }
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        
                        HStack {
                            Button {
                                isFriendsContentModalPresented = true
                                selectedAlbum = story
                            } label: {
                                VStack {
                                    if !story.image.isEmpty {
                                        if let image = image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 90, height: 120)
                                                .cornerRadius(15)
                                        } else if isLoadingImage {
                                            ProgressView()
                                                .frame(width: 90, height: 120)
                                        } else {
                                            PlaceholderView() // 로드 실패 시 대체 뷰
                                        }
                                    } else {
                                        // 이모지와 텍스트만 표시
                                        VStack {
                                            Spacer()
                                            SpeechBubbleView(text: story.content)
                                                .font(.caption)
                                                .padding(.bottom, 5)
                                            Text(story.emoji)
                                                .font(.largeTitle)
                                            Spacer()
                                        }
                                        .frame(width: 90, height: 120) // 고정된 크기
                                        .background(
                                            Image("storyBackImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        )
                                        .cornerRadius(15)
                                    }
                                }
                            }
                            
                            Rectangle()
                                .cornerRadius(15)
                                .frame(width: 3, height: 120)
                                .foregroundStyle(Color.gray.opacity(0.07))
                        }
                        
                    } else if isLoading {
                        Text("스토리 로딩중...")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .trailing) {
                            if !chat.readBy.contains(where: { $0 != authManager.userID }) {
                                Text("1")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
                            }
                            Text(chat.formattedCreateAt)
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                        }
                        
                        // Check if chat has an uploaded image and load it if available
                        if let uploadImage = chat.uploadImage, !uploadImage.isEmpty {
                            if let loadedImage = image {
                                Button {
                                    selectedImage = loadedImage
                                    isSelectedImage.toggle()
                                } label: {
                                    Image(uiImage: loadedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 180, height: 240)
                                        .cornerRadius(15)
                                }

                            } else if isLoadingImage {
                                ProgressView()
                                    .frame(width: 90, height: 120)
                            } else {
                                PlaceholderView() // Placeholder if the image load fails
                            }
                        } else {
                            Text(chat.message)
                                .font(.subheadline)
                                .foregroundStyle(Color.black.opacity(0.5))
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                                .id(chat.id)
                        }
                    }
                    .frame(maxWidth: 300, alignment: .trailing)
                }
            }
        }
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .onAppear {
            loadStoryAndImage() // 기존의 스토리와 이미지 로딩을 포함하도록 변경
        }
    }
    
    // 스토리와 이미지 불러오기
    private func loadStoryAndImage() {
        Task {
            // 1. 스토리 로드
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
            
            // 2. chat.uploadImage 로드
            if let uploadImage = chat.uploadImage, !uploadImage.isEmpty {
                await loadImage(imageStoreID: uploadImage)
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
    
    // Firebase Storage에서 이미지를 비동기적으로 가져오기
    private func loadImage(imageStoreID: String) async {
        isLoadingImage = true
        loadFailed = false

        // 캐시 확인
        if let cachedImage = albumStore.cacheImages[imageStoreID] {
            self.image = cachedImage
            isLoadingImage = false
            return
        }

        let storage = Storage.storage()
        let imageRef = storage.reference().child("image/\(imageStoreID)")

        do {
            let data = try await fetchData(from: imageRef)
            if let downloadedImage = UIImage(data: data) {
                self.image = downloadedImage
                // 캐시에 저장
                albumStore.cacheImages[imageStoreID] = downloadedImage
            }
        } catch {
            loadFailed = true
            print("이미지 로드 실패: \(error.localizedDescription)")
        }

        isLoadingImage = false
    }

    // Firebase Storage의 getData를 async/await로 래핑
    private func fetchData(from imageRef: StorageReference) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            imageRef.getData(maxSize: 1_000_000) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: -1, userInfo: nil))
                }
            }
        }
    }
}

// PlaceholderView: 이미지 로드 실패 시 대체 UI
struct PlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.slash")
                .font(.title2)
                .foregroundColor(.gray)
            Text("이미지 로드 실패")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 90, height: 120)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}
