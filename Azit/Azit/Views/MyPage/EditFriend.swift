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
    
    @State var isDelete: Bool = false // 친구 삭제 알럿
    @State var isBlocked: Bool = false // 친구 차단 알럿
    
    var friendID: String
    var friendNickname: String
    @Binding var isEditFriend: Bool
    
    var body: some View {
        ZStack {
            Color.subColor4
                .cornerRadius(15)
            
            VStack(alignment: .center) {
                Button {
                    isDelete = true
                } label: {
                    Text("삭제하기")
                        .bold()
                }
                .alert("\(friendNickname)", isPresented: $isDelete, actions: {
                    Button("예") {
                        Task {
                            userInfoStore.removeFriend(friendID: friendID, currentUserID: authManager.userID)
                            await userInfoStore.loadUserInfo(userID: authManager.userID)
                        }
                        isEditFriend = false
                    }
                    
                    Button("아니요", role: .cancel) {
                        isEditFriend = false
                    }
                }, message: {
                    Text("선택한 친구를 삭제합니다.")
                })
                
                Divider()
                    .background(Color.accentColor)
                    .frame(width: 80)
                
                Button {
                    isBlocked = true
                } label: {
                    Text("차단하기")
                        .bold()
                }
                .alert("\(friendNickname)", isPresented: $isBlocked, actions: {
                    Button("예") {
                        Task {
                            guard var currentBlockedFriends = userInfoStore.userInfo?.blockedFriends else { return }
                            currentBlockedFriends.append(friendID) // friendID를 배열에 추가
                            
                            // 차단 유저 추가
                            await userInfoStore.updateUserInfo(UserInfo(
                                id: authManager.userID,
                                email: authManager.email,
                                nickname: userInfoStore.userInfo?.nickname ?? "",
                                profileImageName: userInfoStore.userInfo?.profileImageName ?? "",
                                previousState: userInfoStore.userInfo?.previousState ?? "",
                                friends: userInfoStore.userInfo?.friends ?? [""],
                                latitude: userInfoStore.userInfo?.latitude ?? 0.0,
                                longitude: userInfoStore.userInfo?.longitude ?? 0.0,
                                blockedFriends: currentBlockedFriends)
                            )
                            
                            userInfoStore.removeFriend(friendID: friendID, currentUserID: authManager.userID)
                            await userInfoStore.loadUserInfo(userID: authManager.userID)
                        }
                        isEditFriend = false
                    }
                    
                    Button("아니요", role: .cancel) {
                        isEditFriend = false
                    }
                }, message: {
                    Text("선택한 친구를 차단합니다.")
                })
            }
        }
        .frame(width: 120, height: 90)
    }
}

//#Preview {
//    EditFriend()
//}
