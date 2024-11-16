import SwiftUI
import Firebase
import FirebaseFirestore

struct PostMessage: View {
    @EnvironmentObject var authManager: AuthManager
    var chat: Chat
    
    @State private var shareStory: Story?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State var message: String? = ""
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var selectedAlbum: Story?
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .trailing) {
                // 스토리에 답장을 보내는 메시지라면,
                if let story = shareStory {
                    Button {
                        isFriendsContentModalPresented = true
                        selectedAlbum = story
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Story: \(story.emoji)") // 예: story.title 출력
                                .font(.subheadline)
                                .foregroundStyle(Color.blue)
                            Text("Content: \(story.content)")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
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
                    VStack(alignment: .trailing) {
                        if !chat.readBy.contains(where: { $0 != authManager.userID }) {
                            VStack {
                                Text("1") // 미읽음 표시
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
                            }
                        }
                        
                        // 보낸 시간
                        Text(chat.formattedCreateAt)
                            .font(.caption2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                    }
                    
                    // 보낸 내용
                    Text(chat.message)
                        .font(.headline)
                        .foregroundStyle(Color.black.opacity(0.5))
                        .multilineTextAlignment(.trailing)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(15)
                        .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                        .id(chat.id)
                }
                .frame(maxWidth: 300, alignment: .trailing)
            }
        }
        .onAppear {
            if let storyId = chat.storyId, !storyId.isEmpty {
                Task {
                    await fetchStory(storyId: storyId)
                }
            }
        }
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // Firestore에서 Story 가져오기
    private func fetchStory(storyId: String) async {
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        
        do {
            // Firestore에서 문서를 가져옴
            let document = try await db.collection("Story").document(storyId).getDocument()
            
            // DocumentSnapshot에서 데이터 추출
            guard let data = document.data() else {
                errorMessage = "No data found for this story."
                return
            }
            
            // Firestore 데이터에서 각 필드를 별도로 추출하여 변수에 저장
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
            
            // Date 처리
            let dateTimestamp = data["date"] as? Timestamp
            let date = dateTimestamp?.dateValue() ?? Date()
            
            // Story 객체 생성
            self.shareStory = Story(id: document.documentID,
                                    userId: userId,
                                    likes: likes, date: date,
                                    latitude: latitude, longitude: longitude, address: address, emoji: emoji,
                                    image: image, content: content,
                                    publishedTargets: publishedTargets,
                                    readUsers: readUsers)
            
        } catch {
            errorMessage = "Failed to load story: \(error.localizedDescription)"
            print("Error loading story: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

//#Preview {
//    PostMessage(chat: Chat(createAt: Date(), message: "안녕하세요! 반갑습니다 어서오세요 안녕하세요! 반갑습니다 어서오세요 \n새로운 줄입니다!", sender: "parkjunyoung", readBy: ["parkjunyoung"]))
//}
