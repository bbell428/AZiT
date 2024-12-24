//
//  SignUpTitleView.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

struct SignUpTitleView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.system(size: 30))
                    .fontWeight(.thin)
                    .padding(.bottom, -20)
                Text("AZiT")
                    .font(.system(size: 38))
                    .fontWeight(.black)
            }
            .foregroundStyle(.accent)
            .padding(.top, 30)
            
            Spacer()
        }
    }
}
