//
//  Chat.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable {
    @DocumentID var id: String?
    var message: String
    var sender: String //보낸 사람의 uid
    var readBy: [String] //1:1 대화이지만 읽은 사람들의 uid를 모아둠
    var createAt: Date
}

struct ChatSection: Identifiable {
    var id: String { dateString }
    let dateString: String
    let chats: [Chat]
}
