import SwiftUI
import FirebaseStorage

// 이미지 스토리 View
struct AlbumStoryImageView: View {
    var imageStoreID: String?
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(3/4, contentMode: .fit)
                .cornerRadius(15)
                .padding(.horizontal, 2.5)
                .frame(width: 115, height: 155)
        }
    }
}
