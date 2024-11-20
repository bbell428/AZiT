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
    @Binding var isPassed24Hours: Bool
    let emojiManager = EmojiManager()
    
    var previousState: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.clear)
                .frame(width: width, height: height)
                .overlay(
                    ZStack {
                        // 24시간 지남 여부에 따라 색 변경, 24시간 이 전: 그레디언트, 24시간 이 후: 흰 색
                        Circle()
                            .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createLinearGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 3)
                        
                        if let codepoints = emojiManager.getCodepoints(forName: previousState) {
                            KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                    }
                )
            // 24시간이 지남 여부에 따라 + Circle이 반영 
            if isPassed24Hours {
                Circle()
                    .fill(.white)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Text("+")
                            .fontWeight(.black)
                    )
                    .offset(y: 50)
            }
        }
    }
}
