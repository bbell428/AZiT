//
//  LoadFailView.swift
//  Azit
//
//  Created by 박준영 on 12/9/24.
//

import SwiftUI

// 로드 실패 View
struct LoadFailView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.slash")
                .font(.title2)
                .foregroundColor(.gray)
            Text("이미지 로드 실패")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 90, height: 120)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}
