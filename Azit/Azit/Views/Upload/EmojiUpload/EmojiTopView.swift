//
//  EmojiTopView.swift
//  Azit
//
//  Created by 홍지수 on 12/9/24.
//

import SwiftUI

struct EmojiTopView : View {
    @EnvironmentObject var storyDraft: StoryDraft // EmojiView에서 생성한 Story 임시 저장
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Binding var isShowingsheet: Bool
    @Binding var friendID: String
    
    var body : some View {
        // 상단 바
        HStack {
            // 위치
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.accentColor)
                Text(storyDraft.address)
                    .font(.caption2)
            }
            Spacer()
            
            // 공개 범위
            Button(action: {
                isShowingsheet.toggle()
//                        Task {
//                            friendID = try await userInfoStore.getUserNameById(id: storyDraft.publishedTargets[0])
//                        }
            }) {
                HStack {
                    Image(systemName: "person")
                    
                    if storyDraft.publishedTargets.count == userInfoStore.userInfo?.friends.count {
                        Text("ALL")
                    } else if storyDraft.publishedTargets.count == 1 {
                        Text("\(friendID)")
                    } else {
                        Text("\(friendID) 외 \(storyDraft.publishedTargets.count - 1)명")
                    }
                    
                    Text(">")
                }
                .font(.caption2)
            }
        }
        .padding([.horizontal, .bottom])
    }
}
