//
//  ModalIdentificationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct ModalIdentificationView: View {
    @Binding var isMyModalPresented: Bool // 사용자 자신의 모달 컨트롤
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var isDisplayEmojiPicker: Bool // 사용자 자신의 게시글 작성 모달 컨트롤
    @Binding var isPassed24Hours: Bool // 사용자 자신의 게시글 작성 후 24시간에 대한 판별 여부
    @Binding var isAnimatingForStroke: Bool
    @Binding var users: [UserInfo]
    @Binding var message: String
    @Binding var selectedIndex: Int
    @Binding var isSendFriendStoryToast: Bool
    
    var body: some View {
        // 친구의 모달이 불렸을 때
        if isFriendsModalPresented {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isFriendsModalPresented = false
                }
                .zIndex(2)
            
            if !users.isEmpty {
                FriendsContentsModalView(message: $message, selectedUserInfo: users[selectedIndex], isSendFriendStoryToast: $isSendFriendStoryToast)
                    .zIndex(3)
            }
        }
        
        // story 작성 후 24시간이 지났을 때
        if isPassed24Hours {
            if isDisplayEmojiPicker {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isDisplayEmojiPicker = false
                    }
                    .zIndex(2)
                EmojiView(isDisplayEmojiPicker: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented, isAnimatingForStroke: $isAnimatingForStroke)
                    .zIndex(3)
            }
        // story 작성 후 24시간이 지나지 않았을 때
        } else {
            if isMyModalPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isMyModalPresented = false
                    }
                    .zIndex(2)
                MyContentsModalView(isDisplayEmojiPicker: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented, isAnimatingForStroke: $isAnimatingForStroke)
                    .zIndex(3)
            }
        }
    }
}
