//
//  AuthView.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var locationManager: LocationManager
    
    @AppStorage("fcmToken") private var targetToken: String = ""
    
    @Binding var url: URL?
    @State private var navigateToChatDetail = false
    @State private var chatRoomId: String?
    @State private var profileImageFriend: String?
    @State private var nicknameFriend: String?
    
    
    var body: some View {
        NavigationStack {
            VStack {
                // 로그인 상태에 따라 보이는 화면을 다르게 함
                switch authManager.authenticationState {
                case .splash:
                    SplashView()
                case .unauthenticated, .authenticating:
                    LoginView()
                case .authenticated:
                    SwipeNavigationView(url: $url)
                        .environmentObject(authManager)
                        .environmentObject(userInfoStore)
                        .onAppear {
                            Task {
                                // 로그인 후, 해당 디바이스로 UserInfo에 토큰 저장
                                await userInfoStore.updateFCMToken(authManager.userID, fcmToken: targetToken)
                                
                                await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID), friendUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: "", viewType: "chatDetail")
                                
                                // 위치 권한 허용 check
                                locationManager.checkAuthorization()
                            }
                        }
                        .navigationDestination(isPresented: $navigateToChatDetail) {
                            if let roomId = chatRoomId {
                                MessageDetailView(
                                    friend: UserInfo(
                                        id: roomId,
                                        email: "", // Replace with actual data
                                        nickname: "", // Replace with actual data
                                        profileImageName: "", // Default profile image
                                        previousState: "",
                                        friends: [],
                                        latitude: 0.0,
                                        longitude: 0.0,
                                        blockedFriends: [],
                                        fcmToken: ""
                                    ),
                                    roomId: roomId,
                                    nickname: nicknameFriend ?? "",
                                    userId: roomId,
                                    profileImageName: profileImageFriend ?? "",
                                    isShowToast: .constant(false)
                                )
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .didReceiveNotification)) { notification in
                            if let userInfo = notification.userInfo,
                               let viewType = userInfo["viewType"] as? String,
                               let friendNickname = userInfo["friendNickname"] as? String,
                               let friendProfileImage = userInfo["friendProfileImage"] as? String,
                               let chatId = userInfo["chatId"] as? String,
                               
                               viewType == "chatDetail" {
                                self.nicknameFriend = friendNickname
                                self.profileImageFriend = friendProfileImage
                                self.chatRoomId = chatId
                                self.navigateToChatDetail = true
                            }
                        }
                case .profileExist:
                    ProfileDetailView()
                }
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
