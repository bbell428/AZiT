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
    @EnvironmentObject var userInfoStore: UserInfoStore
    @StateObject private var viewModel = QR()
    
    var body: some View {
        ZStack {
            Image("QRBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.95)
            
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
                
                Divider()
                    .background(Color.gradation2)
                    .padding(.top, 20)
                
                VStack(alignment: .center) {
                    HStack(spacing: 5) {
                        Text(userInfoStore.userInfo?.nickname ?? "")
                            .bold()
                        Text("의 AZiT")
                    }
                    
                    Text("초대장")
                }
                .font(.title2)
                .padding(.top, 15)
                
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 45, height: 45)
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding(.bottom, 5)
                }
                
            }
            .frame(maxWidth: 200, maxHeight: .infinity)
        }
        .frame(width: 350, height: 450)

    }
}
#Preview {
    QRCodeView()
}
