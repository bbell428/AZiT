//
//  AzitApp.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure() // 파이어베이스 초기화
        return true
    }
    
    // 구글 로그인을 위해 추가할 부분
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct AzitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var userInfoStore  = UserInfoStore()
    @StateObject private var chatListStore = ChatListStore()
    @StateObject private var chatDetailViewStore = ChatDetailViewStore()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(userInfoStore)
                .environmentObject(chatListStore)
                .environmentObject(chatDetailViewStore)
        }
        
    }
}
