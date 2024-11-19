//
//  ChatRoom.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation
import FirebaseFirestore

// 채팅방
struct ChatRoom: Codable, Identifiable {
    @DocumentID var id: String?
    var lastMessage: String // 마지막으로 보낸 메시지 내용
    var lastMessageAt: Date // 마지막으로 보낸 메시지 시간
    var participants: [String] // 대화 참가자들 UID (예: ["user1", "user2"])
    var roomId: String // 채팅방 id
    var unreadCount: [String: Int] // 사용자별 읽지 않은 메시지 개수
    // var readStatus: [String: Date] // 각 참가자의 마지막 읽은 메시지 시점
    // var notReadCount: [String: Int] = [:] // 각 참가자의 읽지 않은 메시지 개수
    
    // 현재 시간을 바인딩하여 날짜를 포맷하는 연산 프로퍼티
        var formattedLastMessageAt: String {
            let calendar = Calendar.current
            let now = Date()

            // 날짜 차이 계산
            let components = calendar.dateComponents([.minute, .hour, .day], from: lastMessageAt, to: now)

            if let dayDifference = components.day, dayDifference >= 1 {
                return "\(dayDifference)일 전"
            } else if let hourDifference = components.hour, hourDifference >= 1 {
                return "\(hourDifference)시간 전"
            } else if let minuteDifference = components.minute {
                if minuteDifference >= 1 {
                    return "\(minuteDifference)분 전"
                } else {
                    return "방금 전"
                }
            }

            // 기본 형식화: 하루 이내이면 "오후 4:11" 형식으로 표시
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "a h:mm" // "오후 4:11" 형식
            return dateFormatter.string(from: lastMessageAt)
        }
}

//struct ChatRoomWithUser: Codable {
//    var chatRoom: ChatRoom
//    var chatUser: UserInfo
//    var myUid: String
//    var unreadCount: Int = 0
//}
