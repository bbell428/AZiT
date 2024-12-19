import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Kingfisher

// 받은 메시지
struct GetMessage: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var albumStore: AlbumStore
    
    @State private var isLoadingStory: Bool = false // 스토리를 불러오는중인가?
    @State private var isLoadingImage: Bool = true // 이미지를 불러오는중인가?
    @State private var isLoadFailed: Bool = false // 불러오는데 실패했는가?
    
    @State private var shareStory: Story? // 메시지 형태 : 스토리
    @State private var errorMessage: String? // 불러오는데 실패한 오류 내용
    @State private var image: UIImage? // 스토리 이미지
    
    @Binding var isFriendsContentModalPresented: Bool // 스토리를 open 했는가?
    @Binding var selectedAlbum: Story? // 친구 스토리
    
    @Binding var isSelectedImage: Bool // 이미지를 선택했을때
    @Binding var selectedImage: UIImage? // 선택된 이미지
    
    var chat: Chat // 채팅
    var profileImageName: String // 상대방 프로필 아이콘
    let emojiManager = EmojiManager()
    
    var body: some View {
        HStack(alignment: .top) {
            Text(profileImageName)
                .font(.largeTitle)
                .padding(.leading, 20)
            
            // 받은 메시지 내용
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    // 메시지 타입이 "Story" 라면
                    if let story = shareStory {
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
                                isFriendsContentModalPresented = true // 스토리 open
                                selectedAlbum = story // 선택된 스토리 내용
                            } label: {
                                VStack {
                                    // 선택된 스토리에 Image가 포함되어 있다면
                                    if !story.image.isEmpty {
                                        if let image = image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(3/4, contentMode: .fit)
                                                .frame(width: 90, height: 120)
                                                .cornerRadius(15)
                                            // 이미지를 불러오는중이라면 progressView
                                        } else if isLoadingImage {
                                            ProgressView()
                                                .frame(width: 90, height: 120)
                                            // 로드 실패 시 대체 뷰
                                        } else {
                                            LoadFailView()
                                        }
                                        // 선택된 스토리에 이모지 & 텍스트만 있다면
                                    } else {
                                        VStack {
                                            Spacer()
                                            // 텍스트가 존재한다면
                                            if !story.content.isEmpty {
                                                SpeechBubbleView(text: story.content)
                                                    .font(.caption)
                                                    .padding(.bottom, 5)
                                            }
                                            // 이모지가 존재한다면
                                            let emojiComponents = story.emoji.components(separatedBy: "*")
                                            if let codepoints = emojiManager.getCodepoints(forName: emojiComponents[0]) {
                                                let urlString = EmojiManager.getTwemojiURL(for: codepoints)
                                                
                                                KFImage(URL(string: urlString))
                                                    //.placeholder { Text(emojiComponents[1]) }
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                            }
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
                        }
                        // 스토리를 불러오는중이라면
                    } else if isLoadingStory {
                        Text("Loading story...")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        // 스토리를 불러오는중에 에러가 발생했다면
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            // 메시지 타입이 "UploadImage" 라면
                            if let uploadImage = chat.uploadImage, !uploadImage.isEmpty {
                                if let loadedImage = image {
                                    Button {
                                        selectedImage = loadedImage
                                        isSelectedImage.toggle()
                                    } label: {
                                        Image(uiImage: loadedImage)
                                            .resizable()
                                            .aspectRatio(3/4, contentMode: .fit)
                                            .frame(width: 180, height: 240)
                                            .cornerRadius(15)
                                    }
                                    // 이미지를 불러오는중이라면
                                } else if isLoadingImage {
                                    ProgressView()
                                        .frame(width: 180, height: 240)
                                    // 이미지 불러오는중에 에러가 발생했다면
                                } else {
                                    LoadFailView()
                                }
                                // 메시지 타입이 "Text" 라면
                            } else {
                                Text(chat.message)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.accent)
                                    .cornerRadius(15)
                                    .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                                    .id(chat.id)
                            }
                        }
                        
                        // 읽음/미읽음 처리
                        if !chat.readBy.contains(where: { $0 != authManager.userID }) {
                            Text("1")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)
                        }
                        
                        // 메시지를 보낸 시간
                        Text(chat.formattedCreateAt)
                            .font(.caption2)
                            .foregroundStyle(Color.gray.opacity(0.7))
                    }
                    .frame(maxWidth: 300, alignment: .leading)
                }
            }
            .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
            .frame(maxWidth: 300, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            loadStoryAndImage() // 스토리와 이미지 불러오기
        }
    }
    
    // 스토리와 이미지 불러오기
    private func loadStoryAndImage() {
        Task {
            // 1. 스토리 로드
            if let storyId = chat.storyId, !storyId.isEmpty {
                isLoadingStory = true
                errorMessage = nil
                
                do {
                    let fetchedStory = try await fetchStory(storyId: storyId)
                    
                    if !fetchedStory.image.isEmpty {
                        await loadImage(imageStoreID: fetchedStory.image)
                    }
                    
                    self.shareStory = fetchedStory
                } catch {
                    // error.localizedDescription
                    errorMessage = "로딩 중 문제가 발생했습니다."
                }
                
                isLoadingStory = false
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
        isLoadFailed = false

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
            isLoadFailed = true
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
