//
//  LoginView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @StateObject private var authApple = AuthApple()
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    
    @State private var isAutoLogin = false // 자동 로그인 상태
    @State private var isErrorPassword = false // 비밀번호 틀리면 테두리색 빨갛게
    @State private var isErrorEmail = false // 이메일 틀리면 테두리색 빨갛게
    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in // 키보드 올리면 화면 찌부되어갖고 ignoresSafeArea 사용할려고 사용
                VStack(alignment: .center) {
                    
                    // 로그인 타이틀
                    LoginTitleView()
                    
                    // 로그인 에러 메시지
                    if let errorMessage = handleErrorMessages(authManager: authManager) {
                        ErrorMessageView(message: errorMessage, isErrorEmail: $isErrorEmail, isErrorPassword: $isErrorPassword)
                            .frame(width: 330)
                    }
                    
                    // MARK: 이메일로 로그인
                    EmailTextField(
                        inputText: "이메일을 입력하세요",
                        email: $authManager.email,
                        focus: $focus,
                        isErrorEmail: $isErrorEmail
                    )
                    .frame(width: 330)
                    .padding(6)
                    
                    PasswordTextField(
                        inputText: "비밀번호를 입력하세요",
                        password: $authManager.password,
                        focus: $focus,
                        focusType: .password,
                        onSubmit: {
                            signInWithEmailPassword(authManager: authManager, dismiss: dismiss)
                        },
                        isErrorPassword: $isErrorPassword
                    )
                    .frame(width: 330)
                    .padding(.bottom, 30)
                    
                    //MARK: 로그인 버튼
                    LoginButton(
                        inputText: "이메일로 로그인",
                        isLoading: authManager.authenticationState == .authenticating,
                        isValid: authManager.isValid,
                        action: {
                            signInWithEmailPassword(authManager: authManager, dismiss: dismiss)
                        },
                        focus: $focus
                    )
                    .frame(width: 330)
                    .padding(.bottom, 10)
                    
                    // MARK: 회원가입
                    HStack {
                        NavigationLink {
                            SignupView()
                        } label: {
                            Text("회원가입")
                                .font(.callout)
                                .fontWeight(.light)
                                .underline()
                                .foregroundStyle(.accent)
                        }
                    }
                    .padding(.bottom, 110)
                    
                    // MARK: 간편로그인
                    HStack {
                        VStack { Divider() }
                        Text(" 간편로그인 ")
                            .font(.footnote)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                        VStack { Divider() }
                    }
                    .frame(width: 330)
                    .padding(.bottom, 12)
                    
                    HStack(spacing: 30) {
                        SignInButton(imageName: "GoogleLogo", backColor: .white) {
                            signInWithGoogle(authManager: authManager, dismiss: dismiss)
                        }
                        SignInButton(imageName: "AppleLogo", backColor: .black) {
                            authApple.startSignInWithAppleFlow()
                        }
                    }
                }
                .contentShape(Rectangle())  // 빈 영역 터치 가능
                .onTapGesture {             // 빈 영역 터치시 함수 호출 -> 키보드 내려감
                    UIApplication.shared.endEditing()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .onAppear {
                    authManager.email = ""
                    authManager.password = ""
                    isErrorEmail = false
                    isErrorPassword = false
                }
                .onDisappear { // 백버튼으로 돌아왔을 때
                    authManager.password = ""
                    isErrorEmail = false
                    isErrorPassword = false
                }
            }
        }
        .ignoresSafeArea(.keyboard) // 키보드 올라올 때 화면 찌부되는 거 사라지게 함
    }
}

//#Preview {
//    LoginView()
//        .environmentObject(AuthManager())
//}

