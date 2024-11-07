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
    @StateObject private var authManager: AuthManager = AuthManager()
    @StateObject private var userInfoStore: UserInfoStore = UserInfoStore()
    
    var body: some View {
        VStack {
            // 로그인 상태에 따라 보이는 화면을 다르게 함
            switch authManager.authenticationState {
            case .unauthenticated, .authenticating:
                VStack {
                    LoginView()
                        .environmentObject(authManager)
                }
            case .authenticated:
                VStack {
                    if authManager.isNicknameExist  {
                        MainView()
                            .environmentObject(authManager)
                            .environmentObject(userInfoStore)
                    } else {
                        ProfileDetailView()
                            .environmentObject(authManager)
                    }
                }
                .task {
                    authManager.isNicknameExist =  await userInfoStore.isNicknameExists(for: authManager.userID)
                }
                
            }
        }
    }
}

#Preview {
    AuthView()
}
