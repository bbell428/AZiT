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
    
    @Environment(\.openURL) var openURL
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(userInfoStore)
                .environmentObject(chatListStore)
                .environmentObject(StoryStore())
                .environmentObject(chatDetailViewStore)
                .environmentObject(StoryDraft())
                .environmentObject(LocationManager())
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
        
    }
    func handleDeepLink(url: URL) {
        // URL에서 필요한 정보 추출
        let data = url.host ?? ""
        print("딥 링크로 받은 데이터: \(data)")
        // 필요한 로직 처리
    }
}
