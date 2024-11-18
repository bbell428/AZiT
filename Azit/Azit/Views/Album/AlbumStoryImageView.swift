import SwiftUI
import FirebaseStorage

struct AlbumStoryImageView: View {
    var imageStoreID: String?
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .cornerRadius(15)
                .padding(.horizontal, 2.5)
                //.background(.subColor4.opacity(0.95))
                .frame(width: 115, height: 155)
        }
    }
}
