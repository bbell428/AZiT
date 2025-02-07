//
//  UserInfo.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct UserInfo: Codable, Equatable, Identifiable {
    var id: String // uid
    var email: String  // email
    var nickname: String // 닉네임
    var profileImageName: String // 프로필 이모티콘
    var previousState: String // 이전 이모티콘 상태 저장
    var friends: [String] // 유저 uid
    var latitude: Double // 위도
    var longitude: Double // 경도
    var blockedFriends: [String] // 차단된 유저
    var fcmToken: String = ""
    var notificationMessage: Bool // 메시지 알림 권한으로 사용 - true: 알림X
    
    init(document: QueryDocumentSnapshot) async throws {
        let docData = document.data()
        
        self.id = document.documentID
        self.email = docData["email"] as? String ?? ""
        self.nickname = docData["nickname"] as? String ?? ""
        self.profileImageName = docData["profileImageName"] as? String ?? ""
        self.previousState = docData["previousState"] as? String ?? ""
        self.friends = docData["friends"] as? [String] ?? []
        self.latitude = docData["latitude"] as? Double ?? 0.0
        self.longitude = docData["longitude"] as? Double ?? 0.0
        self.blockedFriends = docData["blockedFriends"] as? [String] ?? []
        self.fcmToken = docData["fcmToken"] as? String ?? ""
        self.notificationMessage = docData["notificationMessage"] as? Bool ?? false
    }
    
    init(id: String, email: String, nickname: String, profileImageName: String, previousState: String, friends: [String], latitude: Double, longitude: Double, blockedFriends: [String], fcmToken: String, notificationMessage: Bool) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.profileImageName = profileImageName
        self.previousState = previousState
        self.friends = friends
        self.latitude = latitude
        self.longitude = longitude
        self.blockedFriends = blockedFriends
        self.fcmToken = fcmToken
        self.notificationMessage = notificationMessage
    }
}
