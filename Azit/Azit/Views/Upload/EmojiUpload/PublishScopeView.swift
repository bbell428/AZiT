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
    
    @State var isAllSelected: Bool = true
    @State var isSelected: [String : Bool] = [:]
    @State private var scale: CGFloat = 0.1
    @State var publishingtargets: [String] = []

    
    var body: some View {
        VStack() {
            Text("공개 범위")
                .padding(.top, 35)
                .padding(.bottom, 20)
            
            if userInfoStore.userInfo?.friends.count == 0 {
                Text("친구를 초대해보세요!")
            } else {
                Divider()
                
                ScrollView(showsIndicators: false) {
                    // ALL에게 공개
                    Button (action: {
                        isAllSelected = true
                        if isAllSelected {
                            // 모든 친구 선택
                            if let friendsID = userInfoStore.userInfo?.friends {
                                for friendID in friendsID {
                                    isSelected[friendID] = false
                                    if let friendNickname = userInfoStore.friendInfo[friendID]?.nickname {
                                        if !publishingtargets.contains(friendNickname) {
                                            publishingtargets.append(friendNickname)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ) {
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(isAllSelected ? .accent.opacity(0.5) : .subColor4)
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.accent)
                            }
                            .padding()
                            Text("ALL")
                                .font(.headline)
                                .fontWeight(.light)
                                .foregroundStyle(isAllSelected ? .accent : .gray)
                            Spacer()
                            
                            if isAllSelected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.accent)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    // MARK: - 친구 리스트
                    if let friendsID = userInfoStore.userInfo?.friends {
                        
                        
                        ForEach(friendsID, id: \.self) { friendID in
                            Button(action: {
                                isAllSelected = false
//                                isSelected[friendID]?.toggle()
                                if isSelected[friendID] ?? true {
                                    isSelected[friendID] = false
                                } else {
                                    isSelected[friendID] = true
                                }
                                
                                if let isSelected = isSelected[friendID] {
                                    publishingtargets.append(userInfoStore.friendInfo[friendID]?.id ?? "")
                                } else {
                                    publishingtargets.removeAll { $0 == (userInfoStore.friendInfo[friendID]?.id ?? "") }
                                }
                            }) {
                                HStack {
                                    if let isSelected = isSelected[friendID] {
                                        ZStack {
                                            Circle()
                                                .frame(width: 40, height: 40)
//                                                .foregroundStyle(.subColor4)
                                                .foregroundStyle(isSelected ? .accent.opacity(0.5) : .subColor4)
                                            Text(userInfoStore.friendInfo[friendID]?.profileImageName ?? "")
                                                .font(.title3)
                                        }
                                        .padding()
                                        Text(userInfoStore.friendInfo[friendID]?.nickname ?? "")
                                            .font(.headline)
                                            .fontWeight(.light)
                                            .foregroundStyle(isSelected ? .accent : .gray)
                                        //                                    .foregroundStyle(isSelected[friendID] ?? nil ? Color.accentColor : Color.black)
                                        Spacer()
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.accent)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            Divider()
                            
                            
                            
                        }
                    } else {
                        VStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("친구를 초대해보세요!")
                        }
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(Color.accentColor)
                    }
                }
                .padding([.leading, .trailing])
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                
                
                .onAppear {
                    Task {
                        await userInfoStore.loadUserInfo(userID: authManager.userID)
                        userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                        
                        // 모든 친구 기본적으로 넣기
                        if storyDraft.publishedTargets == [] {
                            storyDraft.publishedTargets = userInfoStore.userInfo?.friends ?? []
                        }
                    }
                }
                .onAppear {
                    // `isSelected` 초기화
                    if let friends = userInfoStore.userInfo?.friends {
                        for friend in friends {
                            if isSelected[friend] == nil {
                                isSelected[friend] = false
                            }
                        }
                    }
                }
                .onDisappear() {
                    storyDraft.publishedTargets = publishingtargets
                }
        }

        }
    }
}

