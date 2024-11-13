//
//  QRcodeView.swift
//  Azit
//
//  Created by 김종혁 on 11/12/24.
//

import CoreImage.CIFilterBuiltins
import Observation
import SwiftUI


class QR: ObservableObject {
    @Published var dataString = ""
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
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

struct QRCodeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = QR()
    
    var body: some View {
        VStack {
            viewModel.qrCode
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
                .onAppear {
                    // 딥 링크 URL 생성
                    let deepLinkURL = "azit://\(authManager.userID)"
                    viewModel.dataString = deepLinkURL
                }
            
            Text("이 QR 코드를 스캔하면 AZiT 앱이 열립니다.")
                .padding()
            
            
//            if let url = URL(string: viewModel.dataString) {
//                Link("Open AZiT App", destination: url)
//                    .padding()
//            }
        }
    }
}
#Preview {
    QRCodeView()
}
