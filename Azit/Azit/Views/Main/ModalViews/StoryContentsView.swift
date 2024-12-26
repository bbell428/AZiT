import SwiftUI
import FirebaseStorage
import Kingfisher

struct StoryContentsView: View {
    let story: Story
    let emojiManager = EmojiManager()
    @EnvironmentObject var albumStore: AlbumStore
    @State private var image: UIImage?
    @State private var isLoadingImage = false
    @State private var loadFailed = false
    
    var body: some View {
        VStack {
            // 스토리에 이미지가 있을 경우
            if !story.image.isEmpty {
                if !story.content.isEmpty {
                    HStack {
                        Text(story.content)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 336, height: 448)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else if isLoadingImage {
                    ProgressView()
                        .frame(height: 200)
                } else {
                    LoadFailView()
                }
            } else if !story.emoji.isEmpty {
                if !story.content.isEmpty {
                    HStack {
                        SpeechBubbleView(text: story.content)
                    }
                    .padding(.bottom, -50)
                }
                
                let emojiComponents = story.emoji.components(separatedBy: "*")
                if let codepoints = emojiManager.getCodepoints(forName: emojiComponents[0]) {
                    let urlString = EmojiManager.getTwemojiURL(for: codepoints)
                    
                    KFImage(URL(string: urlString))
                        .placeholder {
                            if emojiComponents.count > 1 {
                                Text(emojiComponents[1])
                                    .font(.system(size: 60))
                            } else {
                                Text("User")
                            }
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .padding(.top, 40)
                }
            } else if !story.content.isEmpty {
                HStack {
                    Text(story.content)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .onAppear {
            loadStoryImage()
        }
    }
    
    private func loadStoryImage() {
        guard !story.image.isEmpty else { return }
        isLoadingImage = true
        loadFailed = false
        
        // 캐시에 있는지 확인
        if let cachedImage = albumStore.cacheImages[story.image] {
            self.image = cachedImage
            isLoadingImage = false
            return
        }
        
        // 캐시에 없으면 Firebase에서 다운로드
        let storage = Storage.storage()
        let imageRef = storage.reference().child("image/\(story.image)")
        
        imageRef.getData(maxSize: 1_000_000) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("이미지 로드 실패: \(error.localizedDescription)")
                    loadFailed = true
                } else if let data = data, let downloadedImage = UIImage(data: data) {
                    self.image = downloadedImage
                    // 다운로드 성공 시 캐시에 저장
                    albumStore.cacheImages[story.image] = downloadedImage
                }
                isLoadingImage = false
            }
        }
    }
}
