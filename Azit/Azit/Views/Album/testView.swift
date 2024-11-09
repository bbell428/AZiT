//
//  testView.swift
//  Azit
//
//  Created by 박준영 on 11/9/24.
//

import SwiftUI

struct testView: View {
    @State private var isScrolledDown = false
        @State private var lastScrollPosition: CGFloat = 0
        
        var body: some View {
            ZStack(alignment: .top) {
                // TOP 위젯
                if !isScrolledDown {
                    Text("TOP")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: isScrolledDown)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<50, id: \.self) { index in
                            Text("Item \(index)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let yOffset = geo.frame(in: .global).minY
                                // 스크롤이 위에서 아래로 움직임을 감지
                                if yOffset > lastScrollPosition {
                                    isScrolledDown = false
                                } else if yOffset < lastScrollPosition {
                                    isScrolledDown = true
                                }
                                lastScrollPosition = yOffset
                            }
                            return Color.clear
                        }
                    )
                }
            }
        }
}

#Preview {
    testView()
}
