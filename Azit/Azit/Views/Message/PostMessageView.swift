//
//  PostMessage.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 보낸 메시지
struct PostMessage: View {
    var chat: Chat
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Text(chat.formattedCreateAt)
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                    .frame(height: 20, alignment: .bottomTrailing)
                    .padding(.top, 15)
            }
            
            VStack {
                Text(chat.message)
                    .font(.headline)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .frame(width: 100, height: 20, alignment: .topTrailing)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .id(chat.id)
            }
            .background(Color.gray.opacity(0.4))
            .cornerRadius(15)
            .padding(.trailing, 30)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
