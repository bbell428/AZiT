//
//  MyContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
import Kingfisher

// 사용자 본인의 Circle Button의 label
struct MyContentEmojiView: View {
    @Binding var isMainExposed: Bool // 메인 화면인지 맵 화면인지
    @Binding var isPassed24Hours: Bool
    let emojiManager = EmojiManager()
    
    var previousState: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isMainExposed ? .white.opacity(0.2) : .white.opacity(0.7))
                .frame(width: width, height: height)
                .overlay(
                    ZStack {
                        // 24시간 지남 여부에 따라 색 변경, 24시간 이 전: 그레디언트, 24시간 이 후: 흰 색
                        
                        if isMainExposed {
                            Circle()
                                .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 7)
                        } else {
                            Circle()
                                .stroke(isPassed24Hours ? AnyShapeStyle(Utility.createLinearGradient(colors: [.ellipseColor2.opacity(0.5), .ellipseColor2])) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 15)
                        }
                        
                        if let codepoints = emojiManager.getCodepoints(forName: previousState) {
                            KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                .resizable()
                                .scaledToFit()
                                .frame(width: width * 0.75, height: width * 0.75)
                        }
                    }
                )
                .zIndex(0)
            // 24시간이 지남 여부에 따라 + Circle이 반영
            if isPassed24Hours {
                Circle()
                    .fill(.white)
                    .frame(width: width / 5, height: height / 5)
                    .overlay(
                        Text("+")
                            .fontWeight(.black)
                    )
                    .offset(y: height / 2)
                    .zIndex(1)
            }
        }
    }
}
