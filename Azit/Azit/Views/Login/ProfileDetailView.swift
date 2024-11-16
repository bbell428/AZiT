//
//  ProfileDetailView.swift
//  Azit
//
//  Created by 김종혁 on 11/4/24.
//

import SwiftUI

struct ProfileDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    
    @FocusState private var focus: FocusableField?
    
    @State var isShowNickname: Bool = false
    @State var isShowEmoji: Bool = false // 이모지 존재에따라 테두리 색
    @State var isNicknameExists: Bool = false
    
    @State private var emoji: String = "" // 기본 이모지
    @State private var nickname: String = ""
    @State var isSheetEmoji = false // 이모지 뷰
    
    private func StartAzit() {
        Task {
            let newUserInfo = UserInfo(
                id: authManager.userID,
                email: authManager.email,
                nickname: nickname,
                profileImageName: emoji,
                previousState: emoji,
                friends: [],
                latitude: 0.0,
                longitude: 0.0,
                blockedFriends: []
            )
            await userInfoStore.addUserInfo(newUserInfo)
            authManager.authenticationState = .authenticated
        }
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack {
                    Text("프로필 아이콘")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button {
                        isSheetEmoji.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(
                                    isShowEmoji ? Color.accentColor : Color.black,
                                    style: isShowEmoji ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10])
                                    
                                )
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                            if emoji == "" {
                                Image(systemName: "plus")
                                    .font(.system(size: geometry.size.width * 0.1))
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Text(emoji)
                                    .font(.system(size: geometry.size.width * 0.17))
                                    .onAppear {
                                        isShowEmoji = true
                                    }
                            }
                        }
                    }
                    .onChange(of: emoji) {
                        // 이모지가 여러 개 입력된 경우 첫 번째 문자만 유지
                        if emoji.count > 1 {
                            emoji = String(emoji.suffix(1))
                        }
                    }
                }
                .padding(.top, 90)
                .padding(.bottom, 40)
                
                if isNicknameExists {
                    Text("이미 사용중인 닉네임입니다.")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                }
                VStack(alignment: .leading) {
                    NicknameTextField(
                        inputText: "닉네임을 입력해주세요",
                        nickname: $nickname,
                        focus: $focus,
                        isShowNickname: $isShowNickname,
                        isNicknameExists: $isNicknameExists
                    )
                    
                    Text("닉네임은 추후 변경이 가능하며 2~8자로 입력해주세요.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(width: geometry.size.width * 0.62)
                
                Spacer()
                Button {
                    authManager.signOut()
                } label: {
                    Text("로그아웃")
                }
                StartButton(
                    inputText: "시작하기",
                    isLoading: authManager.authenticationState == .authenticating,
                    isShowNickname: isShowNickname,
                    isShowEmoji: isShowEmoji,
                    action: StartAzit
                )
                .frame(width: geometry.size.width * 0.85)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            }
            .sheet(isPresented: $isSheetEmoji) { // 시트로 이모지 뷰 띄움
                EmojiSheetView(show: $isSheetEmoji, txt: $emoji)
                    .presentationDetents([.fraction(0.4)])
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.endTextEditing()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ProfileDetailView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
}
