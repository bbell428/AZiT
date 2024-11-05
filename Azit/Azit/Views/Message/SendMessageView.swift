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
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text(chat.message)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .background(.accent)
                        .cornerRadius(15)
                        .id(chat.id)
                    
                    Text(chat.formattedCreateAt)
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                }
            }
            .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SendMessage(chat: Chat(createAt: Date(), message: "안녕하세요! 반갑습니다 어서오세요 안녕하세요! 반갑습니다 어서오세요 \n새로운 줄입니다!", sender: "parkjunyoung"))
}
