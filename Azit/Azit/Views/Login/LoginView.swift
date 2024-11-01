//
//  LoginView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
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
        VStack(alignment: .center) {
            VStack {
                Text("Hello,")
                    .font(.system(size: 20))
                Text("AZIT")
                    .font(.system(size: 65))
                    .fontWeight(.bold)
            }
            .foregroundStyle(.accent)
            
            // 로그인 에러 메시지
            if !authManager.errorMessage.isEmpty {
                VStack {
                    Text("아이디와 비밀번호를 확인해주세요.")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            //MARK: 이메일로 로그인
            HStack {
                TextField("이메일을 입력하세요", text: $authManager.email)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never) // 대문자 금지
                    .disableAutocorrection(true)         // 자동 수정 금지
                    .focused($focus, equals: .email)
                    .submitLabel(.next)                  // 키보드 다음
                    .onSubmit {
                        self.focus = .password           // 포커스가 패스워드로, 이메일 입력 안하면 비밀번호 입력X
                    }
                    .padding() // 내부 여백 추가
                    .cornerRadius(8) // 모서리를 둥글게
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1) // 테두리 설정
                    )
            }
            
            HStack {
                SecureField("비밀번호를 입력하세요", text: $authManager.password)
                    .font(.subheadline)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        signInWithEmailPassword()
                    }
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            
            Button(action: signInWithEmailPassword) {
                if authManager.authenticationState != .authenticating {
                    Text("이메일로 로그인")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!authManager.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                VStack { Divider() }
                Text("or")
                VStack { Divider() }
            }
            
            // 구글로 로그인
            Button(action: signInWithGoogle) {
                Text("Sign in with Google")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(alignment: .leading) {
                        Image("Google")
                            .frame(width: 30, alignment: .center)
                    }
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .buttonStyle(.bordered)
            
            HStack {
                Text("Don't have an account yet?")
                Button(action: { authManager.switchFlow() }) {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        }
        .listStyle(.plain)
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
