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
    @DocumentID var id: String? // 채팅방 id(Document)
    var postId: String?
    var lastMessage: String // 마지막으로 보낸 메시지 내용
    var lastMessageAt: Date // 마지막으로 보낸 메시지 시간
    // var participant: [String] // 대화 참가자들 UID (예: ["user1", "user2"])
    // var readStatus: [String: Date] // 각 참가자의 마지막 읽은 메시지 시점
}

//struct ChatRoomWithUser: Codable {
//    var chatRoom: ChatRoom
//    var chatUser: UserInfo
//    var myUid: String
//    var unreadCount: Int = 0
//}
