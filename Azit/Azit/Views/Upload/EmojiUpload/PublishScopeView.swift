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
