//
//  PhotoGalleryView.swift
//  Azit
//
//  Created by 박준영 on 12/18/24.
//

import SwiftUI
import Photos

struct PhotoGalleryView: View {
    @StateObject private var photoManager = PhotoManager()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(photoManager.photos, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            //.clipped()
                    }
                }
            }
            .navigationTitle("Gallery")
            .onAppear {
                photoManager.requestPhotos()
            }
        }
    }
}

class PhotoManager: ObservableObject {
    @Published var photos: [UIImage] = []

    func requestPhotos() {
        // 사진 접근 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.fetchPhotos()
            } else {
                print("Photo Library access denied")
            }
        }
    }

    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 50 // 최근 50개의 사진만 가져오기

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 200, height: 200) // 원하는 이미지 크기

        assets.enumerateObjects { asset, _, _ in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true

            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.photos.append(image)
                    }
                }
            }
        }
    }
}
