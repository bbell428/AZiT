//
//  LoginView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    
    @State private var isAutoLogin = false // 자동 로그인 상태
    
    private func signInWithEmailPassword() {
        Task {
            if await authManager.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    private func signInWithGoogle() {
        Task {
            if await authManager.signInWithGoogle() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    VStack {
                        Text("Hello,")
                            .font(.system(size: geometry.size.width * 0.05))
                        Text("AZiT")
                            .font(.system(size: geometry.size.width * 0.16))
                            .fontWeight(.black)
                    }
                    .foregroundStyle(.accent)
                    .padding(.bottom, geometry.size.height * 0.12)
                    
                    // 로그인 에러 메시지
                    if !authManager.errorMessage.isEmpty {
                        VStack {
                            Text("아이디와 비밀번호를 확인해주세요.")
                                .font(.caption)
                                .foregroundColor(Color.red)
                                .fontWeight(.heavy)
                        }
                    }
                    
                    // MARK: 이메일로 로그인
                    EmailTextField(
                        inputText: "이메일을 입력하세요",
                        email: $authManager.email,
                        focus: $focus
                    )
                    .frame(width: geometry.size.width * 0.85)
                    .padding(6)
                    
                    PasswordTextField(
                        inputText: "비밀번호를 입력하세요",
                        password: $authManager.password,
                        focus: $focus,
                        focusType: .password,
                        onSubmit: signInWithEmailPassword
                    )
                    
                    //MARK: 자동 로그인 체크박스 추가
                    HStack {
                        Button {
                            isAutoLogin.toggle()
                        } label: {
                            HStack {
                                Image(systemName: isAutoLogin ? "checkmark.square" : "square")
                                Text("로그인 유지")
                                    .font(.footnote)
                            }
                        }
                        .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.bottom, 8)
                    
                    //MARK: 로그인 버튼
                    LoginButton(
                        inputText: "이메일로 로그인",
                        isLoading: authManager.authenticationState == .authenticating,
                        isValid: authManager.isValid,
                        action: signInWithEmailPassword
                    )
                    
                    // MARK: 회원가입
                    HStack {
                        NavigationLink {
                            SignupView()
                        } label: {
                            Text("회원가입")
                                .font(.footnote)
                                .fontWeight(.light)
                                .underline()
                                .foregroundStyle(.accent)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 40)
                    
                    // MARK: 간편로그인
                    HStack {
                        VStack { Divider() }
                        Text(" 간편로그인 ")
                            .font(.footnote)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                        VStack { Divider() }
                    }
                    .padding(.bottom, 12)
                    
                    HStack(spacing: 20) {
                        SignInButton(imageName: "GoogleLogo", backColor: .white) {
                            signInWithGoogle()
                        }
                        SignInButton(imageName: "AppleLogo", backColor: .black) {
                            // Apple 로그인 액션
                        }
                    }
                }
                .contentShape(Rectangle())  // 빈 영역 터치 가능
                .onTapGesture {             // 빈 영역 터치시 함수 호출 -> 키보드 내려감
                    self.endTextEditing()
                }
                .frame(width: geometry.size.width * 0.85)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea(.keyboard) // 키보드 올라올 때 화면 찌부되는 거 사라지게 함
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

