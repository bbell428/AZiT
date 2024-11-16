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
    
    @Environment(\.scenePhase) private var scenePhase
        
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
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .background:
                        startLoadStoryTimer()
                        WidgetCenter.shared.reloadAllTimelines()
                        print("background")
                    case .active:
                        print("active")
                        stopLoadStoryTimer()
                    case .inactive:
                        print("inactive")
                    @unknown default:
                        break
                    }
                }
        }
    }
    
    private func startLoadStoryTimer() {
        guard timer == nil else { return } // 타이머가 이미 실행 중이면 새로 시작하지 않음
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0 * 1, repeats: true) { _ in
            Task {
                do {
                    print("타이머 시작")
                    
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    let story = try await storyStore.loadFriendsRecentStoryByIds(ids: userInfoStore.userInfo?.friends ?? [])
                    await storyStore.updateSharedUserDefaults(recentStory: story)
                    
                    let userInfos = try await userInfoStore.loadUsersInfoByEmail(userID: [story.userId])
                    await userInfoStore.updateSharedUserDefaults(user: userInfos[0])
        
                    await photoImageStore.loadImage(imageName: story.id) { image in
                        Task {
                            print("메인의 startLoadStoryTimer\(image)")
                            if image != nil {
                                await storyStore.updateSharedUserDefaults(image: (image ?? UIImage(systemName: "xmark.circle")!)!)
                            }
                        }
                    }
                } catch {
                    print("startLoadStoryTimer error: \(error)")
                }
            }
        }
    }
    
    private func stopLoadStoryTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
