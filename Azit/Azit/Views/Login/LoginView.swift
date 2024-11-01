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
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    
    @State private var isAutoLogin = false // 자동 로그인 상태
    @State private var isPassword = false // 비밀번호 노출
    
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
                TextField("이메일을 입력하세요", text: $authManager.email)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never) // 소문자로만 입력
                    .disableAutocorrection(true)         // 자동 수정 비활성화
                    .focused($focus, equals: .email) // 이메일 포커스로 지정
                    .onSubmit {
                        self.focus = .password // 다음 포커스로 -> 비밀번호 필드로
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.85)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focus == .email ? Color.accentColor : Color.black, lineWidth: 1) // 테두리 검정
                    )
                    .padding(6)
                
                HStack {
                    if isPassword {
                        TextField("비밀번호를 입력하세요", text: $authManager.password)
                        
                    } else {
                        SecureField("비밀번호를 입력하세요", text: $authManager.password)
                    }
                    
                    Button(action: {
                        isPassword.toggle()
                    }) {
                        // 비밀번호 보임/숨김 상태에 따라 아이콘 변경
                        Image(systemName: isPassword ? "eye" : "eye.slash")
                            .foregroundColor(.gray)                 // 아이콘 색상 설정
                    }
                }
                .font(.subheadline)
                .focused($focus, equals: .password) // 포커스를 패스워드로
                .onSubmit {
                    signInWithEmailPassword() // Submit 누르면 로그인 시도
                }
                .padding()
                .frame(width: geometry.size.width * 0.85)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(focus == .password ? Color.accentColor : Color.black, lineWidth: 1)
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
                .frame(width: geometry.size.width * 0.85)
                .padding(.vertical, 4)
                .padding(.bottom, 8)
                
                
                Button {
                    signInWithEmailPassword()
                } label: {
                    if authManager.authenticationState != .authenticating {
                        Text("이메일로 로그인")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!authManager.isValid)  // 입력이 유효하지 않을 경우 버튼 비활성화
                .frame(width: geometry.size.width * 0.85)
                .buttonStyle(.borderedProminent) // 강조된 버튼 스타일 적용
                .cornerRadius(20)
                
                // MARK: 회원가입
                HStack {
                    Button {
                        authManager.switchFlow()
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
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.keyboard) // 키보드 올라올 때 화면 찌부되는 거 사라지게 함
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

// 간편로그인버튼
struct SignInButton: View {
    var imageName: String
    var backColor: Color
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("\(imageName)")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(10)
        }
        .background(backColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

// 텍스트필드 제외하고 빈 곳 터치하면 키보드 내리기
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
