//
//  MessageDetailTopbarView.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import SwiftUI

struct MessageDetailTopBarView: View {
    let dismissAction: () -> Void
    var nickname: String
    var profileImageName: String
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                dismissAction() // 이전 화면으로 돌아가기
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                }
            }
            .padding(.leading, 20)
            
            ZStack(alignment: .center) {
                Circle()
                    .fill(.subColor4)
                    .frame(width: 40, height: 40)
                
                Text(profileImageName)
                    .font(.title3)
            }
            .frame(alignment: .leading)
            .padding(.leading, 10)
            
            Text(nickname)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            
            Color.clear
                .frame(maxWidth: .infinity)
        }
        .frame(height: 70)
    }
}
