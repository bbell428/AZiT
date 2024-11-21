//
//  AzitApp.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import UIKit
import BackgroundTasks
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure() // Firebase 초기화
        
        return true
    }
    
    // Google 로그인
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct AzitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var userInfoStore  = UserInfoStore()
    @StateObject private var storyStore = StoryStore()
    @StateObject private var chatListStore = ChatListStore()
    @StateObject private var chatDetailViewStore = ChatDetailViewStore()
    @StateObject private var photoImageStore = PhotoImageStore()
    @StateObject private var albumStore = AlbumStore()
    @StateObject private var storyDraft = StoryDraft()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var cameraService = CameraService()
    
    @State private var timer: Timer?
        
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(userInfoStore)
                .environmentObject(chatListStore)
                .environmentObject(storyStore)
                .environmentObject(chatDetailViewStore)
                .environmentObject(photoImageStore)
                .environmentObject(storyDraft)
                .environmentObject(locationManager)
                .environmentObject(albumStore)
                .environmentObject(cameraService)
                .onOpenURL { url in
                    if url.scheme == "azit", let userID = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host {
                        authManager.deepUserID = userID
                        print("QR 코드로부터 받은 User ID:", userID)
                    }
                }
        }
    }
}
