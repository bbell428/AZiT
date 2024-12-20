//
//  SelectedEmoji.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

// ProfileDetailView 시작하기 버튼
struct SelectedEmoji: View {
    @Binding var isSheetEmoji: Bool
    @Binding var isShowEmoji: Bool
    @Binding var emoji: String
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Text("프로필 아이콘")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Button {
                isSheetEmoji.toggle()
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            isShowEmoji ? Color.accentColor : Color.black,
                            style: isShowEmoji ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10])
                            
                        )
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                    if emoji == "" {
                        Image(systemName: "plus")
                            .font(.system(size: geometry.size.width * 0.1))
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Text(emoji)
                            .font(.system(size: geometry.size.width * 0.17))
                            .onAppear {
                                isShowEmoji = true
                            }
                    }
                }
            }
            .onChange(of: emoji) {
                // 이모지가 여러 개 입력된 경우 첫 번째 문자만 유지
                if emoji.count > 1 {
                    emoji = String(emoji.suffix(1))
                }
            }
        }

    }
}
