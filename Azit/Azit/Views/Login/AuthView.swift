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
    
    @State private var isShowingLoginSheet: Bool = false
    
    var body: some View {
        VStack {
            // 로그인 상태에 따라 보이는 화면을 다르게 함
            switch authManager.authenticationState {
            case .unauthenticated, .authenticating:
                VStack {
                    LoginView()
                }
            case .authenticated:
                VStack {
                    Text("로그인 후 뷰")
                    Button {
                        authManager.signOut()
                    } label: {
                        Text("로그아웃")
                    }

                }
            }
        }
    }
}

#Preview {
    AuthView()
}
