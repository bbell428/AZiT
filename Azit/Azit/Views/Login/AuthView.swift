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
    
    var body: some View {
        VStack {
            // 로그인 상태에 따라 보이는 화면을 다르게 함
            switch authManager.authenticationState {
            case .splash:
                SplashView()
            case .unauthenticated, .authenticating:
                LoginView()
            case .authenticated:
                MainView()
                    .environmentObject(authManager)
                    .environmentObject(userInfoStore)
                    .onAppear {
                        Task {
                            // 로그인 후, 해당 디바이스로 UserInfo에 토큰 저장
                            await userInfoStore.updateFCMToken(authManager.userID, fcmToken: targetToken)
                            
                            // 로그인 후, 첫 화면에 보일 때 나의 채팅방에 있는 알림 총 개수를 업데이트하기 위해 사용
                            await sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: userInfoStore.sumIntegerValuesContainingUserID(userID: authManager.userID), friendUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: "", viewType: "")
                            
                            // 위치 권한 허용 check
                            locationManager.checkAuthorization()
                        }
                    }
            case .profileExist:
                ProfileDetailView()
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
