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
    @AppStorage("fcmToken") private var targetToken: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                
                // 프로필 이모지 선택 뷰
                SelectedEmoji(isSheetEmoji: $isSheetEmoji, isShowEmoji: $isShowEmoji, emoji: $emoji, geometry: geometry)
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
                    
                    Text("닉네임은 추후 변경이 가능하며 8자 이하로 입력해주세요.")
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
                UIApplication.shared.endEditing()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.keyboard)
    }
    
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
                blockedFriends: [],
                fcmToken: targetToken
            )
            await userInfoStore.addUserInfo(newUserInfo)
            authManager.authenticationState = .authenticated
        }
    }
}

//#Preview {
//    ProfileDetailView()
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//}
