//
//  Utility.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

struct Utility {
    // MARK: - Gradient
    static func createGradient(index: Int, width: CGFloat, height: CGFloat) -> RadialGradient {
        let colors: [Color] = [.subColor4, .subColor3, .subColor2, .subColor1]
        let startColor: Color = colors[index]
        
        return RadialGradient(
            gradient: Gradient(colors: [startColor.opacity(1), .clear]),
            center: .center,
            startRadius: 0,
            endRadius: 150 + height / 2
        )
    }
    
    static func createLinearGradient(colors: [Color]) -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    
    // MARK: - 위도 경도 기반 거리 계산
    static func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let r = 6371.0 // 지구의 반지름 (킬로미터)

        let lat1Rad = lat1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let deltaLat = (lat2 - lat1) * .pi / 180.0
        let deltaLon = (lon2 - lon1) * .pi / 180.0

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon / 2) * sin(deltaLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return r * c // 거리 (킬로미터)
    }
    
    // MARK: - 24시간 지남 여부 판별
    static func hasPassed24Hours(from date: Date) -> Bool {
        let hoursDifference = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
        return hoursDifference >= 24
    }
    
    // MARK: - 거리에 따른 유저 정렬
    static func sortUsersByDistance(from user: UserInfo, users: [UserInfo]) -> [UserInfo] {
        return users.sorted { (user1, user2) -> Bool in
            let distance1 = Utility.haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user1.latitude, lon2: user1.longitude)
            let distance2 = Utility.haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user2.latitude, lon2: user2.longitude)
            return distance1 < distance2
        }
    }
    
    // MARK: - 작성 일 시간 계산
    static func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)달 전"
        } else if let week = components.weekOfYear, week > 0 {
            return "\(week)주 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}
