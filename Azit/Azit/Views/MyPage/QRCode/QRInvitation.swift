//
//  QRInvitation.swift
//  Azit
//
//  Created by 김종혁 on 11/15/24.

//MARK: QR 혹은 링크로 초대장을 받게되어 앱에 접속했을 때, 초대장 뷰

import SwiftUI

struct QRInvitation: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Image("QRBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.95)
            
            VStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 200, height: 200)
                    
                    Text("\(userInfoStore.userInfo?.profileImageName ?? "")")
                        .font(.system(size: 120))
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 1, y: 3)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Text("\(userInfoStore.userInfo?.nickname ?? "")")
                            .bold()
                        Text("님을")
                    }
                    Text("친구 추가하시겠습니까?")
                }
                
                Spacer()
                
                Divider()
                    .background(Color.accentColor)
                
                HStack(spacing: 65) {
                    Button {
                        // yes
                        dismiss()
                    } label: {
                        Text("YES")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    Divider()
                        .background(Color.accentColor)
                        .padding(.top, -8)
                        .frame(height: 100)
                    
                    Button {
                        // NO
                        dismiss()
                    } label: {
                        Text("NO")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.black)
                    }
                }
                .padding(.bottom, 10)
            }
            .frame(width: 330)
        }
        .frame(maxWidth: 350, maxHeight: 450)
    }
}

#Preview {
    QRInvitation()
}
