//
//  NicknameTextField.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

//MARK: 프로필 디테일
// 닉네임 입력 필드
struct NicknameTextField: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    
    var inputText: String
    @Binding var nickname: String
    
    @FocusState.Binding var focus: FocusableField?
    @Binding var isShowNickname: Bool
    @Binding var isNicknameExists: Bool
    
    var body: some View {
        TextField("\(inputText)", text: $nickname)
            .font(.subheadline)
            .focused($focus, equals: .nickname)
            .onSubmit {
                //
            }
            .padding()
            .cornerRadius(15)
            .multilineTextAlignment(.center)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(focus == .nickname ? Color.accentColor : Color.gray, lineWidth: 1) // 포커스에 따른 테두리 색상
            )
            .onChange(of: nickname) {
                // 특수문자와 공백을 제외한 문자열로 필터링
                let filteredNickname = nickname.filter { $0.isLetter || $0.isNumber }
                
                // 필터링된 결과로 업데이트
                if filteredNickname != nickname {
                    nickname = filteredNickname
                }
                
                // 한글 자음/모음만 입력된 경우 확인
                let hasSingleConsonantOrVowel = nickname.contains { char in
                    let scalar = char.unicodeScalars.first!
                    return (0x3131...0x318E).contains(scalar.value) // 한글 자음 및 모음 범위
                }
                
                // 닉네임 길이 조건에 따라 isShowNickname 설정
                if nickname.count > 0 && nickname.count < 9 && !hasSingleConsonantOrVowel {
                    Task {
                        if await userInfoStore.isNicknameExists(nickname) {
                            isShowNickname = false
                            isNicknameExists = true
                        } else {
                            isShowNickname = true
                            isNicknameExists = false
                        }
                    }
                } else {
                    isShowNickname = false
                }
            }
        
    }
}
