//
//  SendMessageView.swift
//  Azit
//
//  Created by 박준영 on 11/5/24.
//
import SwiftUI

// 받은 메시지
struct GetMessage: View {
    @EnvironmentObject var authManager: AuthManager
    var chat: Chat
    var profileImageName: String // 상대방 프로필 아이콘
    
    var body: some View {
        HStack(alignment: .top) {
            Text(profileImageName)
                .font(.largeTitle)
                .padding(.leading, 20)
            
            // 받은 메시지 내용
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text(chat.message)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(.accent)
                        .cornerRadius(15)
                        .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
                        .id(chat.id)
                    
                    // readBy 리스트에 내 uid가 포함되지 않았다면 (아마 필요없을거같긴함)
                    VStack(alignment: .leading) {
                        if !chat.readBy.contains(authManager.userID) {
                                Text("1") // 미읽음 처리
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.green)
                        }
                        Text(chat.formattedCreateAt)
                            .font(.caption2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true) // 높이를 내용에 맞게 조절
            .frame(maxWidth: 300, alignment: .leading)
            //.padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GetMessage(chat: Chat(createAt: Date(), message: "안녕하세요! 반갑습니다 어서오세요 안녕하세요! 반갑습니다 어서오세요 \n새로운 줄입니다!", sender: "parkjunyoung", readBy: ["parkjunyoung"]), profileImageName: "\u{1F642}")
}
