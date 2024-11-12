//
//  UserInfo.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation

struct UserInfo: Codable, Equatable, Identifiable {
    var id: String // uid
    var email: String  // email
    var nickname: String // 닉네임
    var profileImageName: String // 프로필 이모티콘
    var previousState: String // 이전 이모티콘 상태 저장
    var friends: [String] // 유저 uid
    var latitude: Double // 위도
    var longitude: Double // 경도    
}
