//
//  Blur.swift
//  Azit
//
//  Created by 홍지수 on 11/22/24.
//
import SwiftUI

// UIKit의 UIBlurEffect를 활용한 블러 뷰
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


// 사용 예시 -
//Image("sample") // 이미지
//    .resizable()
//    .scaledToFill()
//    .edgesIgnoringSafeArea(.all)
//
//Color.gray.opacity(0.01) // 블러를 줄 색상 or 기본 도형
//    .background(
//        BlurView(style: .systemMaterialDark) // iOS 스타일 블러
//    )
//    .edgesIgnoringSafeArea(.all)
