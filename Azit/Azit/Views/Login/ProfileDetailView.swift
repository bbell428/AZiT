//
//  ProfileDetailView.swift
//  Azit
//
//  Created by 김종혁 on 11/4/24.
//

import SwiftUI

struct ProfileDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @FocusState private var focus: FocusableField?
    
    @State var isEmptyNickname: Bool = false
    @State private var emoji: String = "🤦🏻" // 기본 이모지
    @State private var nickname: String = ""
    
    private func StartAzit() {
        
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack {
                    Text("프로필 아이콘")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button(action: {
                        //
                    }) {
                        ZStack {
                            Circle()
                                .stroke(
                                    Color.gray,
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10])
                                )
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                            if emoji == "" {
                                Image(systemName: "plus")
                                    .font(.system(size: geometry.size.width * 0.1))
                                    .foregroundStyle(Color.accentColor)
                            }
                            Text(emoji)
                                .font(.system(size: geometry.size.width * 0.17))
                        }
                    }
                }
                .padding(.top, 90)
                .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    NicknameTextField(
                        inputText: "닉네임을 입력해주세요",
                        nickname: $nickname,
                        focus: $focus,
                        isEmptyNickname: $isEmptyNickname
                    )
                    
                    Text("닉네임은 추후 변경이 가능하며 2~8자로 입력해주세요.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(width: geometry.size.width * 0.62)
                
                Spacer()
                
                StartButton(
                    inputText: "시작하기",
                    isLoading: authManager.authenticationState == .authenticating,
                    isEmptyNickname: isEmptyNickname,
                    action: StartAzit
                )
                .frame(width: geometry.size.width * 0.85)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ProfileDetailView()
        .environmentObject(AuthManager())
}
