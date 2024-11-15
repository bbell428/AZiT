//
//  PhotoImageStore.swift
//  Azit
//
//  Created by 홍지수 on 11/13/24.
//

import Foundation
import FirebaseStorage
import SwiftUI

class PhotoImageStore: ObservableObject {
    private var imageCache = NSCache<NSString, UIImage>()
    
    @Published var images: [UIImage] = [] // 이미지 이름이 추적이 안됨 -> index로 매칭을 했다.
    
    // 스토리지에 이미지 파일
    func UploadImage(image: UIImage ,imageName: String) {
        let uploadRef = Storage.storage().reference(withPath: "img/\(imageName)")
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"

        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetaData, error) in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                return
            }
            print("complete: \(String(describing: downloadMetaData))")
        }
    }
    
    func loadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: imageName as NSString) {
            completion(cachedImage)
            return
        }
        
        let storagRef = Storage.storage().reference(withPath: "img/\(imageName)")
        storagRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("에러 발생: \(error.localizedDescription)")
                completion(nil) // 에러 발생 시 nil 반환
                return
            }
            guard let tempImage = UIImage(data: data!) else {
                completion(nil) // 이미지 변환 실패 시 nil 반환
                return
            }
            
            self.images.append(tempImage)
            print(tempImage)
            
            self.imageCache.setObject(tempImage, forKey: imageName as NSString)
            completion(tempImage)
        }
    }
    
    func deleteImageFromCache(imageName: String) {
        imageCache.removeObject(forKey: imageName as NSString)
    }
}
