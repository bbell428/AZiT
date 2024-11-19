//
//  EllipsesView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct EllipsesView: View {
    var body: some View {
        // 타원 생성
        ForEach(0..<4, id: \.self) { index in
            Ellipse()
                .fill(Utility.createGradient(index: index, width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234))))
                .frame(width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234)))
                .overlay(
                    Ellipse()
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                )
                .offset(y: 300)
                .zIndex(0)
        }
    }
}
