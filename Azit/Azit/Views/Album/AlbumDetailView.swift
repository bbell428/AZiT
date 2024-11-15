//
//  AlbumDetailView.swift
//  Azit
//
//  Created by 박준영 on 11/15/24.
//

import Foundation
import SwiftUI

// 스토리 클릭시, 상세 정보
struct AlbumDetailView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var message: String
    @Binding var selectedIndex: Int
    var selectedAlbum: Story?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isFriendsContentModalPresented = false
                    message = ""
                }
                .zIndex(1)
            
            FriendsContentsModalView(message: $message, selectedUserInfo: $userInfoStore.friendInfos[selectedIndex], story: selectedAlbum)
                .zIndex(2)
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}
