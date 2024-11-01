//
//  Story.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation

struct Story: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var userId: String // 작성자 uid
    
    var likes: [String] = [] // 좋아요를 누른 사람 (유저 uid)
    var date: Date // 작성날짜
    var latitude: Double = 0.0 // 위도
    var longitude: Double = 0.0 // 경도
    
    var emoji: String = "" // 이모지
    var image: String = "" // 이미지
    var content: String = "" // 작성글
    
    var publishedTargets: [String] = [] // 공개 대상 (유저 uid)
}
