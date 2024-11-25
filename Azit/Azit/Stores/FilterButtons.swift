//
//  FilterButtons.swift
//  Azit
//
//  Created by 홍지수 on 11/23/24.
//

import SwiftUI
import OrderedCollections

@ViewBuilder
func filterView(dict: Binding<[String: Bool]>, isAllSelected: Binding<Bool>, userInfoStore: UserInfoStore) -> some View {
    ScrollView(showsIndicators: false) {
        // "ALL" 버튼
        Button(action: {
            isAllSelected.wrappedValue = true
            // 개별 친구 선택 해제
            for key in dict.wrappedValue.keys {
                dict.wrappedValue[key] = false
            }
        }) {
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(isAllSelected.wrappedValue ? .accent.opacity(0.5) : .subColor4)
                    Image(systemName: "person.fill")
                        .foregroundStyle(.accent)
                }
                .padding()
                Text("ALL")
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundStyle(isAllSelected.wrappedValue ? .accent : .gray)
                Spacer()
                if isAllSelected.wrappedValue {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
            .padding(.horizontal)
        }

        Divider()

        // 개별 친구 버튼
        ForEach(dict.wrappedValue.keys.sorted(), id: \.self) { friendID in
            Button(action: {
                // 개별 친구 선택 시 "ALL" 버튼 비활성화
                dict.wrappedValue[friendID]?.toggle()
                updateAllSelectedStateExternally(dict: dict, isAllSelected: isAllSelected, userInfoStore: userInfoStore)
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(dict.wrappedValue[friendID] == true ? .accent.opacity(0.5) : .subColor4)
                        Text(userInfoStore.friendInfo[friendID]?.profileImageName ?? "")
                            .font(.title3)
                    }
                    .padding()
                    Text(userInfoStore.friendInfo[friendID]?.nickname ?? "")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(dict.wrappedValue[friendID] == true ? .accent : .gray)
                    Spacer()
                    if dict.wrappedValue[friendID] == true {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .padding(.horizontal, 10)
            Divider()
        }
    }
    .padding([.leading, .trailing])
}

// 추가: 외부에서 updateAllSelectedState 호출을 위한 함수
@MainActor func updateAllSelectedStateExternally(dict: Binding<[String: Bool]>, isAllSelected: Binding<Bool>, userInfoStore: UserInfoStore) {
    guard let friends = userInfoStore.userInfo?.friends else { return }
    let selectedFriendsCount = dict.wrappedValue.filter { $0.value }.count

    if selectedFriendsCount == friends.count || selectedFriendsCount == 0 {
        isAllSelected.wrappedValue = true
        for key in dict.wrappedValue.keys {
            dict.wrappedValue[key] = false
        }
    } else {
        isAllSelected.wrappedValue = false
    }
}
//@ViewBuilder
//func filterView(dict: Binding<[String: Bool]>) -> some View {
//    ScrollView(showsIndicators: false) {
//        // "ALL" button
//        Button(action: {
//            dict.wrappedValue.keys.forEach { dict.wrappedValue[$0] = true }
//        }) {
//            HStack {
//                ZStack {
//                    Circle()
//                        .frame(width: 40, height: 40)
//                        .foregroundStyle(.accent.opacity(0.5))
//                    Image(systemName: "person.fill")
//                        .foregroundStyle(.accent)
//                }
//                .padding()
//                Text("ALL")
//                    .font(.headline)
//                    .fontWeight(.light)
//                    .foregroundStyle(.accent)
//                Spacer()
//                Image(systemName: "checkmark")
//                    .foregroundStyle(.accent)
//            }
//            .padding(.horizontal)
//        }
//
//        Divider()
//
//        // Individual friend buttons
//        ForEach(dict.wrappedValue.keys.sorted(), id: \.self) { friendID in
//            Button(action: {
//                dict.wrappedValue[friendID]?.toggle()
//            }) {
//                HStack {
//                    ZStack {
//                        Circle()
//                            .frame(width: 40, height: 40)
//                            .foregroundStyle(dict.wrappedValue[friendID] == true ? .accent.opacity(0.5) : .subColor4)
//                        Text(userInfoStore.friendInfo[friendID]?.profileImageName ?? "")
//                            .font(.title3)
//                    }
//                    .padding()
//                    Text(userInfoStore.friendInfo[friendID]?.nickname ?? "")
//                        .font(.headline)
//                        .fontWeight(.light)
//                        .foregroundStyle(dict.wrappedValue[friendID] == true ? .accent : .gray)
//                    Spacer()
//                    if dict.wrappedValue[friendID] == true {
//                        Image(systemName: "checkmark")
//                            .foregroundStyle(.accent)
//                    }
//                }
//            }
//            .padding(.horizontal, 10)
//            Divider()
//        }
//    }
//    .padding([.leading, .trailing])
//}
