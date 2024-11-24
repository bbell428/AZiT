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

    @State private var isSelected: [String: Bool] = [:]
    @State private var isAllSelected: Bool = true

    var body: some View {
        VStack {
            Text("공개 범위")
                .padding(.top, 35)
                .padding(.bottom, 20)

            if userInfoStore.userInfo?.friends.isEmpty ?? true {
                Text("친구를 초대해보세요!")
            } else {
                Divider()

                filterView(dict: $isSelected, isAllSelected: $isAllSelected, userInfoStore: userInfoStore)
                    .onAppear {
                        initializeSelectionState()
                    }
                    .onDisappear {
                        // 종료 시 선택된 친구들을 storyDraft.publishedTargets에 저장
                        storyDraft.publishedTargets = getSelectedFriends()
                    }
                    .onChange(of: isSelected) { _ in
                        updateAllSelectedState()
                        updatePublishedTargets()
                    }
                    .onChange(of: isAllSelected) { _ in
                        updateSelectionStateBasedOnAllSelected()
                        updatePublishedTargets()
                    }
            }
        }
    }

    private func initializeSelectionState() {
        Task {
            // 친구 정보 로드
            await userInfoStore.loadUserInfo(userID: authManager.userID)
            userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])

            guard let friends = userInfoStore.userInfo?.friends else { return }

            // 이전에 선택한 상태가 있으면 복원하고, 없으면 모든 친구를 선택
            if storyDraft.publishedTargets.isEmpty {
                isAllSelected = true
                for friend in friends {
                    isSelected[friend] = false
                }
                storyDraft.publishedTargets = friends
            } else {
                for friend in friends {
                    isSelected[friend] = storyDraft.publishedTargets.contains(friend)
                }
                isAllSelected = storyDraft.publishedTargets.count == friends.count
            }
        }
    }

    private func updateAllSelectedState() {
        guard let friends = userInfoStore.userInfo?.friends else { return }
        let selectedFriendsCount = isSelected.filter { $0.value }.count

        if selectedFriendsCount == friends.count || selectedFriendsCount == 0 {
            // 아무도 선택되지 않았거나 모든 친구가 선택되었을 때 "ALL" 버튼 활성화
            isAllSelected = true
            for key in isSelected.keys {
                isSelected[key] = false
            }
        } else {
            isAllSelected = false
        }
    }

    private func updateSelectionStateBasedOnAllSelected() {
        if isAllSelected {
            // "ALL" 버튼이 활성화되면 개별 친구 선택을 해제하고 publishedTargets 업데이트
            for key in isSelected.keys {
                isSelected[key] = false
            }
            updatePublishedTargets() // 추가: 모든 친구를 publishedTargets에 저장
        }
    }

    private func updatePublishedTargets() {
        guard let friends = userInfoStore.userInfo?.friends else { return }
        if isAllSelected {
            // "ALL" 선택 시 모든 친구를 포함
            storyDraft.publishedTargets = friends
        } else {
            // 개별 선택 시 선택된 친구들만 포함
            storyDraft.publishedTargets = isSelected.filter { $0.value }.map { $0.key }
        }
    }

    private func getSelectedFriends() -> [String] {
        if isAllSelected {
            return userInfoStore.userInfo?.friends ?? []
        } else {
            return isSelected.filter { $0.value }.map { $0.key }
        }
    }
}

//struct PublishScopeView: View {
//    @EnvironmentObject var storyStore: StoryStore
//    @EnvironmentObject var storyDraft: StoryDraft
//    @EnvironmentObject var authManager: AuthManager
//    @EnvironmentObject var userInfoStore: UserInfoStore
//    
//    @State var isAllSelected: Bool = true
//    @State var isSelected: [String : Bool] = [:]
//    @State private var scale: CGFloat = 0.1
//    @State var publishingtargets: [String] = []
//    
//    
//    var body: some View {
//        VStack() {
//            Text("공개 범위")
//                .padding(.top, 35)
//                .padding(.bottom, 20)
//            
//            if userInfoStore.userInfo?.friends.count == 0 {
//                Text("친구를 초대해보세요!")
//            } else {
//                Divider()
//                
//                ScrollView(showsIndicators: false) {
//                    // ALL에게 공개
//                    Button (action: {
//                        isAllSelected = true
//                        if isAllSelected {
//                            // 모든 친구 선택
//                            if let friendsID = userInfoStore.userInfo?.friends {
//                                for friendID in friendsID {
//                                    isSelected[friendID] = false
//                                    if let friendNickname = userInfoStore.friendInfo[friendID]?.nickname {
//                                        if !publishingtargets.contains(friendNickname) {
//                                            publishingtargets.append(friendNickname)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    ) {
//                        HStack {
//                            ZStack {
//                                Circle()
//                                    .frame(width: 40, height: 40)
//                                    .foregroundStyle(isAllSelected ? .accent.opacity(0.5) : .subColor4)
//                                Image(systemName: "person.fill")
//                                    .foregroundStyle(.accent)
//                            }
//                            .padding()
//                            Text("ALL")
//                                .font(.headline)
//                                .fontWeight(.light)
//                                .foregroundStyle(isAllSelected ? .accent : .gray)
//                            Spacer()
//                            
//                            if isAllSelected {
//                                Image(systemName: "checkmark")
//                                    .foregroundStyle(.accent)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    Divider()
//                    // MARK: - 친구 리스트
//                    if let friendsID = userInfoStore.userInfo?.friends {
//                        
//                        
//                        ForEach(friendsID, id: \.self) { friendID in
//                            Button(action: {
//                                isAllSelected = false
//                                
//                                if isSelected[friendID] ?? true {
//                                    isSelected[friendID] = false
//                                } else {
//                                    isSelected[friendID] = true
//                                }
//                                
////                                if let isSelected = isSelected[friendID] {
////                                    publishingtargets.append(userInfoStore.friendInfo[friendID]?.id ?? "")
////                                } else {
////                                    publishingtargets.removeAll { $0 == (userInfoStore.friendInfo[friendID]?.id ?? "") }
////                                }
//                            }) {
//                                HStack {
//                                    if let isSelected = isSelected[friendID] {
//                                        ZStack {
//                                            Circle()
//                                                .frame(width: 40, height: 40)
////                                                .foregroundStyle(.subColor4)
//                                                .foregroundStyle(isSelected ? .accent.opacity(0.5) : .subColor4)
//                                            Text(userInfoStore.friendInfo[friendID]?.profileImageName ?? "")
//                                                .font(.title3)
//                                        }
//                                        .padding()
//                                        Text(userInfoStore.friendInfo[friendID]?.nickname ?? "")
//                                            .font(.headline)
//                                            .fontWeight(.light)
//                                            .foregroundStyle(isSelected ? .accent : .gray)
//                                        //                                    .foregroundStyle(isSelected[friendID] ?? nil ? Color.accentColor : Color.black)
//                                        Spacer()
//                                        if isSelected {
//                                            Image(systemName: "checkmark")
//                                                .foregroundStyle(.accent)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 10)
//                            Divider()
//                            
//                            
//                            
//                        }
//                    } else {
//                        VStack {
//                            Image(systemName: "person.fill.badge.plus")
//                            Text("친구를 초대해보세요!")
//                        }
//                        .font(.headline)
//                        .fontWeight(.light)
//                        .foregroundStyle(Color.accentColor)
//                    }
//                }
//                .padding([.leading, .trailing])
//                .presentationDetents([.fraction(0.5)])
//                .presentationDragIndicator(.visible)
//                
//                
//                .onAppear {
//                    Task {
//                        await userInfoStore.loadUserInfo(userID: authManager.userID)
//                        userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
//                        
//                        // 모든 친구 기본적으로 넣기
//                        if storyDraft.publishedTargets == [] {
//                            storyDraft.publishedTargets = userInfoStore.userInfo?.friends ?? []
//                        }
//                    }
//                }
//                .onAppear {
//                    // `isSelected` 초기화
//                    if let friends = userInfoStore.userInfo?.friends {
//                        for friend in friends {
//                            if isSelected[friend] == nil {
//                                isSelected[friend] = false
//                            }
//                        }
//                    }
//                }
//                .onDisappear() {
//                    storyDraft.publishedTargets = publishingtargets
//                }
//        }
//
//        }
//    }
//}
//
