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
        let uploadRef = Storage.storage().reference(withPath: "image/\(imageName)")
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
    
    // 스토리지에서 이미지 가져옴
    func loadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: imageName as NSString) {
            completion(cachedImage)
            return
        }
        
        let storagRef = Storage.storage().reference(withPath: "image/\(imageName)")
        storagRef.getData(maxSize: 3 * 1024 * 1024) { (data, error) in
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

extension PhotoImageStore {
    func loadImageAsync(imageName: String) async -> UIImage? {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(returning: nil)
                return
            }
            
            // 이미지 로드
            self.loadImage(imageName: imageName) { image in
                guard let image = image else {
                    continuation.resume(returning: nil)
                    return
                }

                // 이미지 리사이즈 후 압축
                if let processedImage = self.resizeAndCompressImage(image: image, targetSize: CGSize(width: image.size.width * 0.5, height: image.size.height * 0.5)) {
                    continuation.resume(returning: processedImage)
                } else {
                    print("이미지 처리 실패")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func resizeAndCompressImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        // 리사이즈
        guard let resizedImage = resizeImage(image: image, targetSize: targetSize) else {
            print("이미지 리사이즈 실패")
            return nil
        }
        
        // 압축
        if let compressedData = resizedImage.jpegData(compressionQuality: 0.7),
           let compressedImage = UIImage(data: compressedData) {
            return compressedImage
        } else {
            print("이미지 압축 실패")
            return nil
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // 최종적으로 리사이즈된 크기 계산 (비율에 맞춰서)
        let newWidth = CGFloat(cgImage.width) * 0.5
        let newHeight = CGFloat(cgImage.height) * 0.5

        // 리사이즈된 이미지 크기를 가지고 비트맵 컨텍스트 생성
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                      width: Int(newWidth),
                                      height: Int(newHeight),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4 * Int(newWidth),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        // 이미지를 해당 크기대로 그리기
        let drawRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        context.draw(cgImage, in: drawRect)

        // 리사이즈된 CGImage를 UIImage로 변환
        guard let resizedCGImage = context.makeImage() else { return nil }
        
        // 90도 회전 (오른쪽으로)
        let rotatedImage = rotateImage(image: UIImage(cgImage: resizedCGImage))
        
        return rotatedImage
    }

    func rotateImage(image: UIImage) -> UIImage? {
        // 회전 변환: 90도 오른쪽 회전
        let transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        // 이미지 크기
        let size = image.size
        
        // 회전된 이미지의 경계 크기 계산
        let newWidth = size.height
        let newHeight = size.width
        
        // 그래픽 컨텍스트 생성 (회전된 크기 반영)
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 회전 설정
        context.translateBy(x: newWidth / 2, y: newHeight / 2)
        context.concatenate(transform)
        
        // 이미지를 회전하고 그리기
        image.draw(at: CGPoint(x: -size.width / 2, y: -size.height / 2))
        
        // 회전된 이미지를 가져오기
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }

}
