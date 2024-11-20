//
//  QR.swift
//  Azit
//
//  Created by 김종혁 on 11/15/24.
//

// QR코드 만들면서, QR코드를 이미지로 생성하는 클래스
import CoreImage.CIFilterBuiltins
import SwiftUI

class QR: ObservableObject {
    @Published var dataString = ""
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    // dataString을 사용해 QR 코드 이미지를 생성, UIImage -> Image로 변환
    var qrCode: Image {
        let data = Data(dataString.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            // 해상도를 높이기 위해 스케일 변환
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            
            // falseColor 필터로 QR 코드 색상과 배경 색상 지정
            let colorFilter = CIFilter.falseColor()
            colorFilter.inputImage = transformedImage
            colorFilter.color0 = CIColor(color: .black) // QR 코드 색상 (검정)
            colorFilter.color1 = CIColor(color: .clear) // 배경 색상 (투명)
            
            if let transparentQR = colorFilter.outputImage,
               let cgimg = context.createCGImage(transparentQR, from: transparentQR.extent) {
                let uiImage = UIImage(cgImage: cgimg)
                return Image(uiImage: uiImage)
            }
        }
        
        return Image(systemName: "xmark.circle")
    }
}
