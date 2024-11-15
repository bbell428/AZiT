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

//class SchedulingService {
//    static let shared = SchedulingService()
//    
//    func registerBackgroundTask() {
//        print("Registering background task")
//        
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "education.techit.Azit.widgetRefresh", using: nil) { task in
//            if let appRefreshTask = task as? BGAppRefreshTask {
//                self.handleAppRefresh(task: appRefreshTask)
//                print("Background task started")
//            } else {
//                print("Task is not of type BGAppRefreshTask")
//            }
//        }
//    }
//    
//    func handleAppRefresh(task: BGAppRefreshTask) {
//        Task {
//            print("Handle app refresh called")
//                        
//            task.expirationHandler = {
//                task.setTaskCompleted(success: false)
//            }
//            
//            print("***** Background Task Executed *****")
//            
//            task.setTaskCompleted(success: true)
//            
//            scheduleAppRefresh()
//            
//            BGTaskScheduler.shared.getPendingTaskRequests { requests in
//                print("Pending tasks: \(requests)")
//            }
//        }
//    }
//    
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "education.techit.Azit.widgetRefresh")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
//        
//        print(Date.now)
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            print("Background task request scheduled.")
//        } catch {
//            print("Failed to schedule app refresh: \(error)")
//        }
//    }
//}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure() // Firebase 초기화
        
//        SchedulingService.shared.registerBackgroundTask()
        
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
    @StateObject private var albumStore = AlbumStore()
    
    @State private var timer: Timer?
        
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(userInfoStore)
                .environmentObject(chatListStore)
                .environmentObject(storyStore)
                .environmentObject(chatDetailViewStore)
                .environmentObject(StoryDraft())
                .environmentObject(LocationManager())
                .environmentObject(albumStore)
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
//                        SchedulingService.shared.scheduleAppRefresh()
                        //appDelegate.background += 1
                        print("background")
                    case .active:
                        print("active")
                        stopLoadStoryTimer()
//                        BGTaskScheduler.shared.getPendingTaskRequests(completionHandler: { request in
//                            print("Pending task requests: \(request)")
//                        })
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 15.0 * 1, repeats: true) { _ in
            Task {
                do {
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    let story = try await storyStore.loadFriendsRecentStoryByIds(ids: userInfoStore.userInfo?.friends ?? [])
                    await storyStore.updateSharedUserDefaults(recentStory: story)
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
