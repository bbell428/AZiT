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
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @State private var isReadyToNavigate: Bool = false

    var body: some View {
        VStack {
            if isReadyToNavigate {
                AuthView()
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            Task {
                isReadyToNavigate = true
            }
        }
    }
}
