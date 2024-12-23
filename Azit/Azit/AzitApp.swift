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
    static var receivedURL: URL?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
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
        
        // 자동 초기화 방지 대응
        Messaging.messaging().isAutoInitEnabled = true
        
        // 현재 등록 토큰 가져오기
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        return true
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }
    
    // 푸시 알림 수신 처리
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("알림 처리 로직")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // Google 로그인
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// 푸시 알림이 도착했을 경우
extension AppDelegate: UNUserNotificationCenterDelegate {
    // foreground 상에서 알림이 보이게끔 해준다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let badge = notification.request.content.userInfo["badge"] as? Int {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // background 알림을 클릭했을 때 전달받는 값, 백그라운드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // 데이터 파싱
        if let viewType = userInfo["viewType"] as? String,
           let friendNickname = userInfo["friendNickname"] as? String,
           let friendProfileImage = userInfo["friendProfileImage"] as? String,
           let chatId = userInfo["chatId"] as? String,
           let friendId = userInfo["friendId"] as? String {
            
            // 알림 데이터를 NotificationCenter로 전달
            NotificationCenter.default.post(
                name: .didReceiveNotification,
                object: nil,
                userInfo: ["viewType": viewType, "friendNickname": friendNickname, "friendProfileImage": friendProfileImage, "chatId": chatId, "friendId": friendId]
            )
            
            // 백그라운드에서 알림 클릭 시, 받아오는 값을 변수에 할당
            DispatchQueue.main.async {
                FriendsStore.shared.nicknameFriend = friendNickname
                FriendsStore.shared.profileImageFriend = friendProfileImage
                FriendsStore.shared.chatRoomId = chatId
                FriendsStore.shared.navigateToChatDetail = true
                FriendsStore.shared.friendId = friendId
            }
        } else {
            print("Missing keys in notification payload")
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveNotification = Notification.Name("didReceiveNotification")
}

// 파이어베이스 MessagingDelegate 설정
extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken ?? ""))")
        
        // UserDefaults로 저장하여 authManager.authenticationState == .authenticated 일 때 UserInfo에 토큰 저장
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
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
    @StateObject private var friendsStore = FriendsStore()
    @StateObject private var photoStore = PhotoManagerStore()
    
    @State private var timer: Timer?
    @State private var url: URL?
    
    var body: some Scene {
        WindowGroup {
            AuthView(url: $url)
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
                .environmentObject(friendsStore)
                .environmentObject(photoStore)
                .onOpenURL { url in
                    if url.scheme == "azit", let userID = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host {
                        authManager.deepUserID = userID
                        print("QR 코드로부터 받은 User ID:", userID)
                    } else {
                        if let userID = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host {
                            userInfoStore.widgetUserID = userID
                            print("위젯으로부터 받은 User ID:", userID)
                        }
                    }
                }
        }
    }
}

extension Notification.Name {
    static let didReceiveURL = Notification.Name("didReceiveURL")
}
