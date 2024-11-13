//
//  PublishScopeView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI

struct PublishScopeView: View {
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @State var isSelected: [String : Bool] = [:]
    @State var AllSelected: Bool = true
    
    var body: some View {
        List {
            Button (action: {
                AllSelected = true
                if AllSelected {
                    for friendID in userInfoStore.userInfo?.friends ?? [] {
                        isSelected[friendID] = false
                    }
                }
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.subColor4)
                        Image(systemName: "person")
                            .foregroundStyle(.accent)
                    }
                    Text("ALL")
                        .font(.title2)
                        .foregroundStyle(.accent)
                    Spacer()
                    if AllSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .padding(10)
            
            // 친구 리스트
//            if let friendsID = userInfoStore.userInfo?.friends {
//                ForEach(friendsID, id: \.self) { friendID in
//                    Button(action: {
//                        isSelected[friendID]?.toggle()
//                        if isSelected[friendID] ?? true {
//                            
//                            storyDraft.publishedTargets.append(userInfoStore.friendInfo[friendID]?.nickname ?? "")
//                        } else {
//                            storyDraft.publishedTargets.remove(at: userInfoStore.friendInfo[friendID]?.nickname ?? "")
//                        }
//                        
//                    }) {
//                        HStack {
//                            ZStack {
//                                Circle()
//                                    .frame(width: 50, height: 50)
//                                    .foregroundStyle(.secondary)
//                                Text(userInfoStore.friendInfo[friendID]?.profileImageName ?? "")
//                                    .font(.title2)
//                            }
//                            Text(userInfoStore.friendInfo[friendID]?.nickname ?? "")
//                                .font(.title2)
//                            Spacer()
//                            if isSelected[friendID] {
//                                Image(systemName: "checkmark")
//                                    .foregroundStyle(.accent)
//                            }
//                        }
//                    }
//                    .padding(10)
//                }
//            } else {
//                Text("No friends available")
//            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
            }
        }
    }
}

