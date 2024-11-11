//
//  Utility.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

struct Utility {
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
    
    static func createCircleGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [.accent, .gradation1, .gradation2]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
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
    
    static func hasPassed24Hours(from date: Date) -> Bool {
        let hoursDifference = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
        return hoursDifference >= 24
    }
}
