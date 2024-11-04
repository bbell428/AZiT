//
//  SignupView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI

struct SignupView: View {
    @State var exEamilString: String = "" // 이메일 작성 예시
    @State var exPasswordString: String = "" // 비밀번호 작성 예시
    @State private var errorMessagePassword: String? // 비밀번호 확인 에러메시지
    @State private var selectedDomain: String? = "naver.com" // 도메인 전달 -> SignUpEmailTextField
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    private func signUpWithEmailPassword() {
        // 정규식을 사용하여 비밀번호 형식 검사 (대문자 혹은 소문자, 숫자 포함)
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)[A-Za-z\\d]{8,12}$"
        
        // 도메인 선택 작성 혹은 '@' 입력하여 직접 이메일 작성
        let fullEmail: String
        if authManager.email.contains("@") {
            fullEmail = authManager.email
        } else {
            fullEmail = "\(authManager.email)@\(selectedDomain ?? "")"
        }
        
        if authManager.password != authManager.confirmPassword {
            errorMessagePassword = "비밀번호가 일치하지 않습니다."
        } else if authManager.password.count < 8 || authManager.password.count > 12 {
            errorMessagePassword = "비밀번호는 8~12자로 입력해주세요."
        } else if !NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: authManager.password) {
            errorMessagePassword = "비밀번호는 영문 대소문자 1개 이상 포함해주세요."
        } else {
            errorMessagePassword = ""
            Task {
                if await authManager.signUpWithEmailPassword(fullEmail) == true {
                    dismiss()
                }
            }
        }
    }
    
    // 포커스를 비밀번호 확인으로
    private func confirmPassword() {
        self.focus = .confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Welcome")
                            .font(.system(size: geometry.size.width * 0.08))
                            .fontWeight(.thin)
                            .padding(.bottom, -25)
                        Text("AZiT")
                            .font(.system(size: geometry.size.width * 0.106))
                            .fontWeight(.black)
                    }
                    .foregroundStyle(.accent)
                    .padding(.top, 30)
                    
                    // 로그인 에러 메시지
                    if !authManager.errorMessage.isEmpty {
                        HStack {
                            Spacer()
                            if authManager.errorMessage == "The email address is badly formatted." {
                                Text("이메일 형식이 아닙니다.")
                                    .font(.caption)
                                    .foregroundColor(Color.red)
                                    .fontWeight(.heavy)
                            } else {
                                Text("이미 존재한 이메일입니다.")
                                    .font(.caption)
                                    .foregroundColor(Color.red)
                                    .fontWeight(.heavy)
                            }
                        }
                    }
                    
                    
                    // MARK: 이메일로 로그인
                    VStack(alignment: .leading) {
                        SignUpEmailTextField(
                            inputText: "이메일",
                            email: $authManager.email,
                            focus: $focus,
                            selectedDomain: $selectedDomain
                        )
                        
                        Text(exEamilString)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    .padding(.bottom, 30)
                    .onAppear {
                        self.exEamilString = "(예시. AZIT@naver.com)"
                    }
                    
                    // 비밀번호가 서로 같지 않으면
                    if let message = errorMessagePassword {
                        HStack {
                            Spacer()
                            Text(message)
                                .font(.caption)
                                .foregroundColor(Color.red)
                                .fontWeight(.heavy)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        PasswordTextField(
                            inputText: "비밀번호",
                            password: $authManager.password,
                            focus: $focus,
                            focusType: .password,
                            onSubmit: confirmPassword
                        )
                        
                        PasswordTextField(
                            inputText: "비밀번호 확인",
                            password: $authManager.confirmPassword,
                            focus: $focus,
                            focusType: .confirmPassword,
                            onSubmit: signUpWithEmailPassword
                        )
                        
                        Text(exPasswordString)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    .onAppear {
                        self.exPasswordString = "비밀번호는 영문 대소문자, 숫자를 혼합하여 8~12자로 입력해주세요."
                    }
                    
                    Spacer()
                    
                    //MARK: 회원가입 버튼
                    LoginButton(
                        inputText: "회원가입",
                        isLoading: authManager.authenticationState == .authenticating,
                        isValid: authManager.isValid,
                        action: signUpWithEmailPassword
                    )
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.endTextEditing()
                }
                .frame(width: geometry.size.width * 0.85)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("회원가입")
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthManager())
}
