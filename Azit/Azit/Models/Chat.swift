//
//  Chat.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable, Identifiable {
    var id: String? // 채팅방 id
    var createAt: Date // 보낸 날짜
    var message: String // 메시지 내용
    var sender: String // 보낸 사람의 uid
    var readBy: [String] // 읽은 사람 uid
    
    var storyId: String? = "" // 게시물 공유 id
    var uploadImage: String? = "" // 이미지 단독 공유 id
    var replyMessage: String? = ""
    // 무슨 채팅에 답변 했는가? (선택한 메시지가 기록에 남음)
    
    // 포맷팅된 날짜 속성
    var formattedCreateAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm" // "오전/오후 h:mm" 형식
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 포맷팅 설정
        return formatter.string(from: createAt)
    }
}

//struct ChatSection: Identifiable {
//    var id: String { dateString }
//    let dateString: String
//    let chats: [Chat]
//}
