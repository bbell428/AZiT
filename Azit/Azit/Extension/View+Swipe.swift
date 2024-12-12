//
//  View+Swipe.swift
//  Azit
//
//  Created by Hyunwoo Shin on 12/11/24.
//

import SwiftUI

extension View {
    func swipe(offset: Binding<CGFloat>, isShowingMessageView: Binding<Bool>, isShowingMyPageView: Binding<Bool>) -> some View {
        self.modifier(SwipeModifier(offset: offset, isShowingMessageView: isShowingMessageView, isShowingMyPageView: isShowingMyPageView))
    }
}
