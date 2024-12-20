//
//  SignUpEmailTextFieldView.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

//MARK: 회원가입 이메일 입력 필드
struct SignUpEmailTextField: View {
    @EnvironmentObject var authManager: AuthManager
    var inputText: String
    @Binding var email: String
    @FocusState.Binding var focus: FocusableField?
    @Binding var selectedDomain: String?
    
    @Binding var isErrorEmail: Bool
    
    let domains = ["naver.com", "gmail.com", "icloud.com"]
    
    var body: some View {
        HStack {
            TextField("\(inputText)", text: $email)
                .font(.subheadline)
                .textInputAutocapitalization(.never) // 소문자로만 입력
                .disableAutocorrection(true)         // 자동 수정 비활성화
                .focused($focus, equals: .email)     // 이메일 포커스로 지정
                .onSubmit {
                    focus = .password                // 다음 포커스로 비밀번호 필드로 이동
                }
                .onChange(of: email) {
                    if email.contains("@") {
                        selectedDomain = nil // 입력하면서 @가 입력되면 선택 도메인 nil
                    } else {
                        selectedDomain = "naver.com"
                    }
                }
                .keyboardType(.emailAddress) // 키보드를 이메일 형식
            
            // '@' 이메일에 포함되지 않은 경우에만 메뉴 표시
            if !email.contains("@") {
                Menu {
                    ForEach(domains, id: \.self) { domain in
                        Button {
                            selectedDomain = domain
                        } label: {
                            Text(domain)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("@")
                            .foregroundStyle(Color.black)
                        Text(selectedDomain ?? "")
                            .foregroundColor(.accentColor)
                            .underline()
                        Image(systemName: "arrowtriangle.down.fill")
                            .padding(.top, 4)
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    focus == .email ? Color.accentColor : (isErrorEmail ? Color.red : Color.gray), lineWidth: 1
                ) // 포커스에 따른 테두리 색상
        )
    }
}
