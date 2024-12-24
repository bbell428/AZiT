//
//  SignupView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI

struct SignupView: View {
    @State private var errorMessageEmail: String? // 이메일 확인 에러메시지
    @State private var errorMessagePassword: String? // 비밀번호 확인 에러메시지
    @State private var selectedDomain: String? = "naver.com" // 도메인 전달 -> SignUpEmailTextField
    
    @State private var isErrorPassword = false // 비밀번호 틀리면 테두리색 빨갛게
    @State private var isErrorPasswordConfirm = false
    @State private var isErrorEmail = false // 이메일 틀리면 테두리색 빨갛게
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        // 타이틀 뷰
        SignUpTitleView()
        .frame(width: 330)
        
        VStack(alignment: .center) {
            // 로그인 에러 메시지
            if !authManager.errorMessage.isEmpty {
                HStack {
                    Spacer()
                    
                    Text(errorMessageEmail ?? "")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .fontWeight(.heavy)
                        .onChange(of: errorMessageEmail) {
                            self.errorMessageEmail = errorMessageEmail
                        }
                }
                .frame(width: 330)
            }
            
            
            // MARK: 이메일로 로그인
            VStack(alignment: .leading) {
                SignUpEmailTextField(
                    inputText: "이메일",
                    email: $authManager.email,
                    focus: $focus,
                    selectedDomain: $selectedDomain,
                    isErrorEmail: $isErrorEmail
                )
                
                Text("(예시. AZIT@naver.com)")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .frame(width: 330)
            .padding(.bottom, 30)
            
            // 비밀번호가 서로 같지 않으면
            if let message = errorMessagePassword {
                HStack {
                    Spacer()
                    Text(message)
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .fontWeight(.heavy)
                }
                .frame(width: 330)
            }
            
            VStack(alignment: .leading) {
                PasswordTextField(
                    inputText: "비밀번호",
                    password: $authManager.password,
                    focus: $focus,
                    focusType: .password,
                    onSubmit: confirmPassword,
                    isErrorPassword: $isErrorPassword
                )
                
                PasswordTextField(
                    inputText: "비밀번호 확인",
                    password: $authManager.confirmPassword,
                    focus: $focus,
                    focusType: .confirmPassword,
                    onSubmit: signUpWithEmailPassword,
                    isErrorPassword: $isErrorPasswordConfirm
                )
                
                Text("비밀번호는 숫자, 영문, 특수문자를 혼합하여 8~12자로 입력해주세요.")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .frame(width: 330)
            
            Spacer()
            
            //MARK: 회원가입 버튼
            LoginButton(
                inputText: "회원가입",
                isLoading: authManager.authenticationState == .authenticating,
                isValid: authManager.isValid && !authManager.confirmPassword.isEmpty,
                action: signUpWithEmailPassword,
                focus: $focus
            )
            .frame(width: 330)
            .padding(.bottom, 10)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .ignoresSafeArea(.keyboard)
        .navigationTitle("회원가입")
        .onAppear {
            authManager.email = ""
            authManager.password = ""
            authManager.confirmPassword = ""
            authManager.errorMessage = ""
            errorMessagePassword = ""
            isErrorPassword = false
            isErrorEmail = false
        }
    }
    
    // 포커스를 비밀번호 확인으로
    private func confirmPassword() {
        self.focus = .confirmPassword
    }
    
    // 회원가입 유효성 검사
    private func signUpWithEmailPassword() {
        Task {
            // 숫자를 포함하는 정규식
            let numberRegex = ".*\\d.*"
            
            // 문자를 포함하는 정규식
            let letterRegex = ".*[a-zA-Z].*"
            
            // 특수문자 포함하는 정규식
            let specialCharacterRegex = ".*[!@#$%^&*(),.?\":{}|<>].*"
            
            // 도메인 선택 작성 혹은 '@' 입력하여 직접 이메일 작성
            let fullEmail: String
            
            if authManager.email.contains("@") {
                fullEmail = authManager.email
            } else {
                fullEmail = "\(authManager.email)@\(selectedDomain ?? "")"
            }
            
            if authManager.password != authManager.confirmPassword {
                errorMessagePassword = "비밀번호가 일치하지 않습니다."
                isErrorPassword = true
                errorMessageEmail = ""
                isErrorEmail = false
            } else if authManager.password.count < 8 || authManager.password.count > 12 {
                errorMessagePassword = "비밀번호는 8~12자로 입력해주세요."
                isErrorPassword = true
                errorMessageEmail = ""
                isErrorEmail = false
            } else if !NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: authManager.password) {
                errorMessagePassword = "비밀번호는 숫자 1개 이상 포함해주세요."
                isErrorPassword = true
                errorMessageEmail = ""
                isErrorEmail = false
            } else if !NSPredicate(format: "SELF MATCHES %@", letterRegex).evaluate(with: authManager.password) {
                errorMessagePassword = "비밀번호는 영문 대소문자 1개 이상 포함해주세요."
                isErrorPassword = true
                errorMessageEmail = ""
                isErrorEmail = false
            } else if !NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: authManager.password) {
                errorMessagePassword = "비밀번호는 특수문자 1개 이상 포함해주세요."
                isErrorPassword = true
                errorMessageEmail = ""
                isErrorEmail = false
            } else {
                errorMessagePassword = ""
                isErrorPassword = false
                errorMessageEmail = ""
                isErrorEmail = false
                
                if await authManager.signUpWithEmailPassword(fullEmail) == true {
                    dismiss()
                }
                isErrorEmail = true
            }
            
            if authManager.errorMessage == "The email address is badly formatted." {
                errorMessageEmail = "이메일 형식이 아닙니다."
            } else if authManager.errorMessage == "The email address is already in use by another account." {
                errorMessageEmail = "이미 존재한 이메일입니다."
            }
        }
    }
}

//#Preview {
//    SignupView()
//        .environmentObject(AuthManager())
//}
