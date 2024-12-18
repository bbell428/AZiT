//
//  PhotoManager.swift
//  Azit
//
//  Created by 박준영 on 12/19/24.
//

import Foundation
import UIKit
import Photos

class PhotoManagerStore: ObservableObject {
    @Published var photos: [UIImage] = []
    
    func requestPhotos() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized else {
            print("Photo Library access denied")
            return
        }
        
        await fetchPhotos()
    }
    
    private func fetchPhotos() async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // fetchLimit 제거로 전체 사진 로드
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 200, height: 200)
        
        for asset in assets.objects(at: IndexSet(0..<assets.count)) {
            await fetchImage(for: asset, with: imageManager, targetSize: targetSize)
        }
    }
    
    private func fetchImage(for asset: PHAsset, with manager: PHCachingImageManager, targetSize: CGSize) async {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    self.photos.append(image)
                }
                continuation.resume()
            }
        }
    }
}
