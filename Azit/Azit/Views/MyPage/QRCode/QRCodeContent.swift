//
//  QRCodeContent.swift
//  Azit
//
//  Created by 김종혁 on 11/14/24.
//

import SwiftUI

// 공유하기로 보여질 이미지 뷰
struct QRCodeContent: View {
    var QRImage: Image
    var userID: String
    var userName: String
    
    var body: some View {
        ZStack {
            Image("QRBackground")
                .opacity(0.95)
            
            VStack {
                QRImage
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                Divider()
                    .background(Color.gradation2)
                    .padding(.top, 20)
                
                VStack(alignment: .center) {
                    HStack(spacing: 5) {
                        Text(userName)
                            .bold()
                        Text("의 AZiT")
                    }
                    
                    Text("초대장")
                }
                .font(.title2)
                .padding(.top, 15)
            }
            .frame(width: 200)
        }
        .frame(width: 320, height: 480)
    }
}
