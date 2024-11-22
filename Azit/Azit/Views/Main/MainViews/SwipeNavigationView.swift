//
//  SwipeNavigationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/22/24.
//

import SwiftUI

struct SwipeNavigationView: View {
    @State private var offset: CGFloat = 0 // 드래그 오프셋
    @State private var currentIndex: Int = 1
    @State private var isShowToast = false
    private let animationDuration: Double = 0.25 // 애니메이션 지속 시간

    var views: [AnyView] {
        [
            AnyView(MyPageView()),
            AnyView(MainView()),
            AnyView(MessageView(isShowToast: $isShowToast))
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<views.count, id: \.self) { index in
                    views[index]
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: CGFloat(index - currentIndex) * geometry.size.width + offset)
                        .zIndex(index == currentIndex ? 1 : 0) // 현재 보이는 뷰를 가장 앞으로
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 양쪽 끝에서 드래그를 제한
                        if (currentIndex == 0 && value.translation.width > 0) || (currentIndex == views.count - 1 && value.translation.width < 0) {
                            offset = 0
                        } else {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width / 4 // 스와이프 감도
                        if value.translation.width < -threshold, currentIndex < views.count - 1 {
                            // 왼쪽으로 스와이프 -> 다음 뷰로 이동
                            withAnimation(.easeOut(duration: animationDuration)) {
                                currentIndex += 1
                                offset = 0
                            }
                        } else if value.translation.width > threshold, currentIndex > 0 {
                            // 오른쪽으로 스와이프 -> 이전 뷰로 이동
                            withAnimation(.easeOut(duration: animationDuration)) {
                                currentIndex -= 1
                                offset = 0
                            }
                        } else {
                            // 스와이프 취소
                            withAnimation(.easeOut(duration: animationDuration)) {
                                offset = 0
                            }
                        }
                    }
            )
        }
//        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SwipeNavigationView()
}
