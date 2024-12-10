//
//  MessageTopBarView.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import SwiftUI

struct MessageListTopBarView: View {
    @Binding var currentIndex: Int // 메인화면으로 돌아가기 위한
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                withAnimation(.easeInOut) {
                    currentIndex = 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 30)
            
            // 가운데 텍스트 영역
            Text("Messages")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Color.clear
                .frame(maxWidth: .infinity)
        }
        .frame(height: 70)
    }
}
