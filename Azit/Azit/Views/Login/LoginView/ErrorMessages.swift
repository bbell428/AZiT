//
//  ErrorMessage.swift
//  Azit
//
//  Created by 김종혁 on 12/19/24.
//

import SwiftUI

@MainActor
func handleErrorMessages(authManager: AuthManager) -> String? {
    switch authManager.errorMessage {
    case "The email address is badly formatted.":
        return "이메일 형식이 아닙니다."
    case "The supplied auth credential is malformed or has expired.":
        return "이메일 혹은 비밀번호를 확인해주세요"
    default:
        return nil
    }
}

struct ErrorMessageView: View {
    let message: String
    @Binding var isErrorEmail: Bool
    @Binding var isErrorPassword: Bool
    
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.red)
            .fontWeight(.heavy)
            .onAppear {
                // 에러 메시지에 따라 상태 업데이트
                if message == "이메일 형식이 아닙니다." {
                    isErrorEmail = true
                    isErrorPassword = false
                } else if message == "이메일 혹은 비밀번호를 확인해주세요" {
                    isErrorEmail = false
                    isErrorPassword = true
                }
            }
            .onChange(of: message) {
                if message == "이메일 형식이 아닙니다." {
                    isErrorEmail = true
                    isErrorPassword = false
                } else if message == "이메일 혹은 비밀번호를 확인해주세요" {
                    isErrorEmail = false
                    isErrorPassword = true
                }
            }
    }
}
