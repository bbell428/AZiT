//
//  UnderlineModifier.swift
//  Azit
//
//  Created by 박준영 on 12/11/24.
//

import SwiftUI

// FriendSegmentView에서 사용되는 용도
struct UnderlineModifier: ViewModifier {
    var selectedIndex: Int
    let frames: [CGRect]
    
    func body(content: Content) -> some View
    {
        content
            .background(
                Rectangle()
                    .fill(.accent.opacity(0.5))
                    .frame(width: frames[selectedIndex].width, height: 3)
                    .cornerRadius(15)
                    .offset(x: (frames[selectedIndex].minX+20) - frames[0].minX), alignment: .bottomLeading
            )
            .animation(.default, value: selectedIndex)
    }
}
