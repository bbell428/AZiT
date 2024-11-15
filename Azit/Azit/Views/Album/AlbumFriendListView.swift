//
//  AlbumFriendListView.swift
//  Azit
//
//  Created by 박준영 on 11/15/24.
//

import Foundation
import SwiftUI

// 친구 리스트
struct AlbumFriendListView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Binding var isShowHorizontalScroll: Bool
    @Binding var selectedIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            FriendSegmentView(selectedIndex: $selectedIndex, titles: userInfoStore.friendInfos)
                .animation(.easeInOut(duration: 0.3), value: isShowHorizontalScroll)
            //.padding(.leading, 20)
            //.background(Color.white)
                .zIndex(3)
            
            VStack {
                Rectangle()
                    .fill(.accent)
                    .frame(height: 0.2, alignment: .bottomLeading)
                    .padding(.bottom, 1.4)
            }
            .zIndex(2)
        }
    }
}
