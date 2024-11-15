import SwiftUI
import FirebaseStorage

struct AlbumStoryImageView: View {
    var imageStoreID: String?
    
    @State private var imageURL: URL?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false

    var body: some View {
        VStack {
            if isLoading {
                // 이미지 로딩 중일 때 표시할 ProgressView
                ProgressView()
                    .frame(width: 120, height: 160)
            } else if loadFailed {
                // 이미지 로드 실패 시 표시할 대체 뷰
                VStack(alignment: .center) {
                    Spacer()
                    Image(systemName: "questionmark.square.dashed")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.gray)
                        .padding(.bottom, 10)
                    Text("이미지 로드 실패")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
                .frame(width: 120, height: 160)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
            } else if let imageURL = imageURL {
                // URL을 받았다면 AsyncImage로 이미지 표시
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 160)
                    case .success(let image):
                        image
                            .resizable()
                            .cornerRadius(15)
                            //.background(.subColor4.opacity(0.95))
                            .frame(width: 120, height: 160)
                    case .failure:
                        // 이미지 로드 실패 시 대체 이미지 표시
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 120, height: 160)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .onAppear {
            loadImage(imageStoreID: imageStoreID)
        }
    }
    
    // Firebase Storage에서 URL을 비동기적으로 가져오는 함수
    private func loadImage(imageStoreID: String?) {
        guard let imageStoreID = imageStoreID else {
            isLoading = false
            loadFailed = true
            return
        }
        
        let storage = Storage.storage()
        let imageRef = storage.reference().child("Image/\(imageStoreID).jpg")
        
        Task {
            do {
                let url = try await imageRef.downloadURL()
                imageURL = url
                isLoading = false
            } catch {
                print("이미지 로드 실패: \(error.localizedDescription)")
                loadFailed = true
                isLoading = false
            }
        }
    }
}
