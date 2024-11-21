//
//  EllipsesView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
// 0, 1 1, 2, 2, 3
struct EllipsesView: View {
    var body: some View {
        ZStack {
            // 첫 번째 타원
            Ellipse()
                .fill(.clear)
                .overlay(
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1)
                )
                .frame(width: Constants.ellipses[3].width, height: Constants.ellipses[3].height)
                .offset(y: 300)
                .zIndex(3)
            
            // 두 번째 타원
            Ellipse()
                .fill(.clear)
                .overlay(
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1)
                )
                .frame(width: Constants.ellipses[2].width, height: Constants.ellipses[2].height)
                .offset(y: 300)
                .zIndex(2)
            
            // 세 번째 타원
            Ellipse()
                .fill(.clear)
                .overlay(
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1)
                )
                .frame(width: Constants.ellipses[1].width, height: Constants.ellipses[1].height)
                .offset(y: 300)
                .zIndex(1)
            
            // 네 번째 타원
            Ellipse()
                .fill(
                    EllipticalGradient(
                        gradient: Gradient(colors: [.ellipseColor0, .ellipseColor1, .ellipseColor2, .ellipseColor3, .ellipseColor4, .ellipseColor5, .ellipseColor6, .ellipseColor7, .ellipseColor8, .ellipseColor9, .ellipseColor10]),
                        center: .center,
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.5
                    )
                )
                .overlay(
                    Ellipse()
                        .stroke(Color.white, lineWidth: 1)
                )
                .frame(width: Constants.ellipses[0].width, height: Constants.ellipses[0].height)
                .offset(y: 300)
                .zIndex(0)
        }
    }
}
