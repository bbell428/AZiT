//
//  SignupView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    private func signUpWithEmailPassword() {
        Task {
            if await authManager.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    // 포커스를 비밀번호 확인으로
    private func confirmPassword() {
        self.focus = .confirmPassword
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.system(size: geometry.size.width * 0.1))
                        .fontWeight(.thin)
                    Text("AZiT")
                        .font(.system(size: geometry.size.width * 0.13))
                        .fontWeight(.black)
                }
                .foregroundStyle(.accent)
                .padding(.bottom, geometry.size.height * 0.12)
                
                // 로그인 에러 메시지
                if !authManager.errorMessage.isEmpty {
                    VStack {
                        Text("이메일 형식이 아닙니다")
                            .font(.caption)
                            .foregroundColor(Color.red)
                            .fontWeight(.heavy)
                    }
                }
                
                // MARK: 이메일로 로그인
                EmailTextField(
                    inputText: "이메일",
                    email: $authManager.email,
                    focus: $focus
                )
                .frame(width: geometry.size.width * 0.85)
                .padding(6)
                
                PasswordTextField(
                    inputText: "비밀번호",
                    password: $authManager.password,
                    focus: $focus,
                    focusType: .password,
                    onSubmit: confirmPassword
                )
                .frame(width: geometry.size.width * 0.85)
            
                PasswordTextField(
                    inputText: "비밀번호 확인",
                    password: $authManager.confirmPassword,
                    focus: $focus,
                    focusType: .confirmPassword,
                    onSubmit: signUpWithEmailPassword
                )
                .frame(width: geometry.size.width * 0.85)
                
                Spacer()
                
                //MARK: 회원가입 버튼
                LoginButton(
                    inputText: "회원가입",
                    isLoading: authManager.authenticationState == .authenticating,
                    isValid: authManager.isValid,
                    action: signUpWithEmailPassword
                )
                .frame(width: geometry.size.width * 0.85)
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
    SignupView()
        .environmentObject(AuthManager())
}
