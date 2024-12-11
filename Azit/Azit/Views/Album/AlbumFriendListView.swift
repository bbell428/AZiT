//
//  AlbumFriendListView.swift
//  Azit
//
//  Created by 박준영 on 11/15/24.
//

import Foundation
import SwiftUI

// 친구 리스트 View
struct AlbumFriendListView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Binding var isShowVerticalScroll: Bool // 밑으로 스크롤되어서 화면이 숨겨져 있는가?
    @Binding var selectedIndex: Int // 선택된 친구 (순서, index)
    
    var combinedFriendList: [UserInfo]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: 친구 리스트 선택 스크롤
            FriendSegmentView(selectedIndex: $selectedIndex, titles: combinedFriendList)
                .zIndex(3)
            
            VStack {
                Rectangle()
                    .fill(.accent)
                    .frame(height: 0.2, alignment: .bottomLeading)
                    .padding(.bottom, 1.4)
            }
            .zIndex(2)
        }
        .background(Color.white)
        .padding(.top, 70)
        .animation(.easeInOut(duration: 0.3), value: isShowVerticalScroll)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
