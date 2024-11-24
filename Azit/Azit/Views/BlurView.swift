//
//  Blur.swift
//  Swipe
//
//  Created by 홍지수 on 11/22/24.
//

import SwiftUI

// UIKit의 UIBlurEffect를 활용한 블러 뷰
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var cornerRadius: CGFloat // 코너 반경 추가

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)

        // 코너 반경 및 마스크 설정
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = cornerRadius
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
    }
}


// 활용법 - 도형이나 색상에 사용
//RoundedRectangle(cornerRadius: 20)
//    .fill(Color.white.opacity(0.1)) // 사각형 반투명 색상
//    .background(
//        BlurView(style: .systemMaterial) // 사각형 블러
//    )
//    .frame(width: 300, height: 400) // 사각형 크기
//    .overlay(
//        Image("goorae")
//            .resizable()
//            .frame(width: 200, height:  100)
//            .font(.headline)
//            .foregroundColor(.white)
//            .cornerRadius(30)
//    )
