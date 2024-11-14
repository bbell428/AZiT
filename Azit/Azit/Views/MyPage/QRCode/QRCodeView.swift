//
//  QRcodeView.swift
//  Azit
//
//  Created by 김종혁 on 11/12/24.
//

import CoreImage.CIFilterBuiltins
import Observation
import SwiftUI

// QR코드 만들면서, QR코드를 이미지로 생성하는 클래스
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

struct QRCodeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @StateObject private var viewModel = QR()
    
    @State private var renderedImage: UIImage? // 렌더링 이미지 (이미지로 된 뷰)
    @State private var isShareSheetPresented = false // 공유창 띄움
    
    var body: some View {
        ZStack {
            Image("QRBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.95)
            
            VStack {
                // QR 코드 생성 후 이미지화
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
                        
                        // QRCodeContent의 내용 렌더링
                        let renderer = ImageRenderer(content: QRCodeContent(QRImage: viewModel.qrCode, userID: authManager.userID, userName: userInfoStore.userInfo?.nickname ?? ""))
                        renderer.scale = 3
                        if let cgImage = renderer.cgImage {
                            renderedImage = UIImage(cgImage: cgImage) // UIImage로 변환하여 저장
                        }
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

                Button {
                    isShareSheetPresented = true
                } label: {
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
                .sheet(isPresented: $isShareSheetPresented) {
                    QRShareSheet(shareItems: [
                        "\(userInfoStore.userInfo?.nickname ?? "")님께서 AZiT에 초대합니다.", "azit://\(authManager.userID)", renderedImage ?? UIImage()]
                    )
                }
            }
            .frame(width: 200)
        }
        .frame(maxWidth: 350, maxHeight: 450)
    }
    
}
#Preview {
    QRCodeView()
}
