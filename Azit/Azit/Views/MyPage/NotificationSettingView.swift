//
//  NotificationSettingView.swift
//  Azit
//
//  Created by 김종혁 on 2/7/25.
//

import SwiftUI

struct NotificationSettingView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @Environment(\.dismiss) var dismiss
    
    @State private var isNotificationsEnabled = false // 버튼 클릭 시
    @State private var isAlert = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                
                Text("알림 설정")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Color.clear
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 70)
            .background(Color.white)
            
            // 알림 설정 스위치
            VStack {
                Toggle(isOn: Binding(
                    get: { isNotificationsEnabled },
                    set: { newValue in
                        if newValue {
                            isAlert = true  // ON으로 변경 시 Alert 띄우기
                        } else {
                            isNotificationsEnabled = false
                            Task {
                                await userInfoStore.updateUserInfo(UserInfo(
                                    id: authManager.userID,
                                    email: authManager.email,
                                    nickname: userInfoStore.userInfo?.nickname ?? "",
                                    profileImageName: userInfoStore.userInfo?.profileImageName ?? "",
                                    previousState: userInfoStore.userInfo?.previousState ?? "",
                                    friends: userInfoStore.userInfo?.friends ?? [""],
                                    latitude: userInfoStore.userInfo?.latitude ?? 0.0,
                                    longitude: userInfoStore.userInfo?.longitude ?? 0.0,
                                    blockedFriends: [],
                                    fcmToken: userInfoStore.userInfo?.fcmToken ?? "", notificationMessage: false)
                                )
                            }
                        }
                    }
                )) {
                    Text("전체 알림 메시지 해제")
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding()
            }
            
            Spacer()
        }
        .frame(width: 370)
        .navigationBarBackButtonHidden(true)
        .alert("메시지 알림을 끄시겠습니까?", isPresented: $isAlert) {
            Button("아니요", role: .cancel) {
                isNotificationsEnabled = false
            }
            Button("예", role: .destructive) {
                isNotificationsEnabled = true
                Task {
                    await userInfoStore.updateUserInfo(UserInfo(
                        id: authManager.userID,
                        email: authManager.email,
                        nickname: userInfoStore.userInfo?.nickname ?? "",
                        profileImageName: userInfoStore.userInfo?.profileImageName ?? "",
                        previousState: userInfoStore.userInfo?.previousState ?? "",
                        friends: userInfoStore.userInfo?.friends ?? [""],
                        latitude: userInfoStore.userInfo?.latitude ?? 0.0,
                        longitude: userInfoStore.userInfo?.longitude ?? 0.0,
                        blockedFriends: [],
                        fcmToken: userInfoStore.userInfo?.fcmToken ?? "", notificationMessage: true)
                    )
                }
            }
        } message: {
            Text("알림을 끄면 중요한 메시지를 받을 수 없습니다.")
        }
        .onAppear {
            Task {
                isNotificationsEnabled = try await userInfoStore.getNotificationMessageByUserID(userID: authManager.userID)
            }
        }
    }
}
