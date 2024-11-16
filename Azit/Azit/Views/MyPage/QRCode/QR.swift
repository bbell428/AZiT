//
//  QR.swift
//  Azit
//
//  Created by 김종혁 on 11/15/24.
//

// QR코드 만들면서, QR코드를 이미지로 생성하는 클래스
import CoreImage.CIFilterBuiltins
import Observation
import SwiftUI


class QR: ObservableObject {
    @Published var dataString = ""
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    // dataString을 사용해 QR 코드 이미지를 생성, UIImage -> Image로 변환
    var qrCode: Image {
        let data = Data(dataString.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            return Image(uiImage: uiImage)
        }
        
        return Image(systemName: "xmark.circle")
    }
}
