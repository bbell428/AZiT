//
//  RectPreferenceKey.swift
//  Azit
//
//  Created by 박준영 on 12/11/24.
//

import SwiftUI

// FriendSegmentView에서 사용되는 용도
struct RectPreferenceKey: PreferenceKey {
    typealias Value = CGRect
    
    static var defaultValue = CGRect.zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect)
    {
        value = nextValue()
    }
}
