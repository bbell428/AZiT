//
//  StartButton.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

// 프로필 디테일 뷰에서 시작하기 버튼
struct StartButton: View {
    var inputText: String   // 버튼의 텍스트
    var isLoading: Bool     // 로그인 중일 때 로딩 상태
    var isShowNickname: Bool     // 입력 없으면 버튼 비활성
    var isShowEmoji: Bool     // 이모지 없으면 버튼 비활성
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity) // 버튼 형식은 텍스트필드와 달리 가로가 전체로 먹지 않아서 사용
            } else {
                Text(inputText)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!isShowNickname || !isShowEmoji)
        .buttonStyle(.borderedProminent)
        .cornerRadius(15)
    }
}
