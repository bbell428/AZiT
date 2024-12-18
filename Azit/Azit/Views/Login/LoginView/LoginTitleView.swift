//
//  LoginTitleView.swift
//  Azit
//
//  Created by 김종혁 on 12/19/24.
//

import SwiftUI

struct LoginTitleView: View {
    var body: some View {
        VStack {
            Text("Hello,")
                .font(.system(size: 20))
            Text("AZiT")
                .font(.system(size: 60))
                .fontWeight(.black)
        }
        .foregroundStyle(.accent)
        .padding(.bottom, 100)
    }
}
