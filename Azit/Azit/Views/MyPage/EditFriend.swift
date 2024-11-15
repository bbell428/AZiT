//
//  EditFriend.swift
//  Azit
//
//  Created by 김종혁 on 11/15/24.
//

import SwiftUI

struct EditFriend: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    var friendID: String
    @Binding var isEditFriend: Bool
    
    var body: some View {
        ZStack {
            Color.subColor4
                .cornerRadius(15)
            
            VStack(alignment: .center) {
                Button {
                    // 삭제하기
                    userInfoStore.removeFriend(friendID: friendID, currentUserID: authManager.userID)
                    isEditFriend = false
                } label: {
                    Text("삭제하기")
                        .bold()
                }
                
                Divider()
                    .background(Color.accentColor)
                    .frame(width: 80)
                
                Button {
                    // 차단하기
                    userInfoStore.removeFriend(friendID: friendID, currentUserID: authManager.userID)
                    isEditFriend = false
                } label: {
                    Text("차단하기")
                        .bold()
                }
            }
        }
        .frame(width: 120, height: 90)
    }
}

//#Preview {
//    EditFriend()
//}
