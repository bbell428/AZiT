//
//  SignInButtonView.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

//MARK: 간편로그인버튼
struct SignInButton: View {
    var imageName: String
    var backColor: Color
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("\(imageName)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
        }
        .frame(width: 44, height: 44)
        .background(backColor)
        .clipShape(RoundedRectangle(cornerRadius: imageName == "GoogleLogo" ? 0 : 8))
    }
}
