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
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure() // Firebase 초기화

        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            if granted {
                print("알림 등록이 완료되었습니다.")
            }
        }
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    // Google 로그인
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// 백그라운드에서 푸시 알림을 탭했을 때 실행
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // foreground 상에서 알림이 보이게끔 해준다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

// 파이어베이스 MessagingDelegate 설정
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 여기서 이제 서버로 다시 fcm 토큰을 보내줘야 한다!
        // 그러나 서버가 없기 때문에 이렇게 token을 출력하게 한다.
        // 이 토큰은 뒤에서 Test할때 필요하다!
        print("FCM Token: \(fcmToken)")
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
    @StateObject private var editPhotoStore = EditPhotoStore()
    
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
                .environmentObject(editPhotoStore)
                .onOpenURL { url in
                    if url.scheme == "azit", let userID = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host {
                        authManager.deepUserID = userID
                        print("QR 코드로부터 받은 User ID:", userID)
                    }
                }
        }
    }
}
