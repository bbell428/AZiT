//
//  Untitled.swift
//  Azit
//
//  Created by 김종혁 on 12/29/24.
//
// 실시간 채팅 확인 여부를 위한 구조체

import Foundation

struct ChatStatusRequest: Codable {
    let userId: String // 유저 아이디
    let chatId: String // 채팅방 아이디
    let isActive: Bool // 접속 상태
}
