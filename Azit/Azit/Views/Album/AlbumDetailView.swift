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
    @EnvironmentObject var albumstore: AlbumStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Binding var isFriendsContentModalPresented: Bool
    @Binding var message: String
    @Binding var selectedIndex: Int
    @Binding var isShowToast: Bool
    var selectedAlbum: Story?
    var list: [UserInfo]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isFriendsContentModalPresented = false
                    message = ""
                }
                .zIndex(1)
            
            if let matchingUserInfo = list.first(where: { $0.id == selectedAlbum?.userId }) {
                FriendsContentsModalView(
                    message: $message,
                    selectedUserInfo: matchingUserInfo,
                    isShowToast: $isShowToast,
                    story: selectedAlbum
                )
                .zIndex(2)
                .frame(maxHeight: .infinity, alignment: .center)
            } else {
                Text("해당 사용자를 찾을 수 없습니다.")
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
    }
}
