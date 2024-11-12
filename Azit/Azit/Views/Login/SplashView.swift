//
//  SplashView.swift
//  Azit
//
//  Created by 김종혁 on 11/6/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SplashView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Image("SplashImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea() // 화면 전체를 차지하도록 설정
        }
        .onAppear {
            authManager.registerAuthStateHandler()
        }
    }
}
