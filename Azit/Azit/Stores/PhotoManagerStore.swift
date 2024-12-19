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
    @Published var photos: [UIImage] = [] // 불러온 사진 저장
    private var latestAssetIdentifier: String? // 마지막으로 로드된 이미지의 identifier

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
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard assets.count > 0 else { return }
        
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 200, height: 200)
        var newAssets: [PHAsset] = []

        // 최신 이미지 이후의 새 이미지만 필터링
        if let latestIdentifier = latestAssetIdentifier {
            assets.enumerateObjects { asset, index, stop in
                if asset.localIdentifier == latestIdentifier {
                    stop.pointee = true
                } else {
                    newAssets.append(asset)
                }
            }
        } else {
            // 최초 로드 시 전체 로드
            newAssets = assets.objects(at: IndexSet(0..<assets.count))
        }

        // 새 이미지를 처리
        for asset in newAssets {
            await fetchImage(for: asset, with: imageManager, targetSize: targetSize)
        }

        // 최신 이미지의 identifier 업데이트
        if let firstAsset = assets.firstObject {
            latestAssetIdentifier = firstAsset.localIdentifier
        }
    }
    
    private func fetchImage(for asset: PHAsset, with manager: PHCachingImageManager, targetSize: CGSize) async {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.photos.append(image)
                    }
                }
                continuation.resume()
            }
        }
    }
}
