//
//  SwipeModifier.swift
//  Azit
//
//  Created by 박준영 on 12/12/24.
//

import SwiftUI

struct SwipeModifier: ViewModifier {
    @Binding var offset: CGFloat
    @Binding var isShowingMessageView: Bool
    @Binding var isShowingMyPageView: Bool
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        if offset < -100 { // 왼쪽으로 스와이프
                            withAnimation(.easeInOut) {
                                isShowingMessageView = true
                            }
                        } else if offset > 100 { // 오른쪽으로 스와이프
                            withAnimation(.easeInOut) {
                                isShowingMyPageView = true
                            }
                        }
                        offset = 0 // 초기화
                    }
            )
    }
}
