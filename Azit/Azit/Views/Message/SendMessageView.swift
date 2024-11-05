//
//  SendMessageView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 받은 메시지
struct SendMessage: View {
    var chat: Chat
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\u{1F642}")
                .font(.largeTitle)
                .padding(.leading, 20)
            
            VStack {
                Text(chat.message)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 200, alignment: .topLeading)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }
            .background(.accent)
            .cornerRadius(15)
            .padding(.leading, 10)
            
            VStack {
                Text(chat.formattedCreateAt)
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                    .frame(height: 200, alignment: .bottomLeading)
                    .padding(.top, 15)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
