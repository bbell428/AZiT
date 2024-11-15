//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import BackgroundTasks

struct MainView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
//    @Environment(\.scenePhase) private var scenePhase
  
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var isMainExposed: Bool = true // 메인 화면인지 맵 화면인지
    @State private var isMyModalPresented: Bool = false // 사용자 자신의 모달 컨트롤
    @State private var isFriendsModalPresented: Bool = false // 친구의 모달 컨트롤
    @State private var isDisplayEmojiPicker: Bool = false // 사용자 자신의 게시글 작성 모달 컨트롤
    @State private var isPassed24Hours: Bool = false // 사용자 자신의 게시글 작성 후 24시간에 대한 판별 여부
    @State private var scale: CGFloat = 0.1 // EmojiView 애니메이션
    
    var body: some View {
        NavigationStack() {
            ZStack {
                // 메인 화면일 때 타원 뷰
                if isMainExposed {
                    RotationView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours)
                        .frame(width: 300, height: 300)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                // 맵 화면일 때 맵 뷰
                } else {
                    MapView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isDisplayEmojiPicker ? 2 : 1)
                }
                
                // 메인 화면의 메뉴들
                MainTopView(isMainExposed: $isMainExposed)
                    .zIndex(1)
            }
        }
//        .onAppear {
//            self.scheduler()
//        }
        
//        .onChange(of: scenePhase) { _, newPhase in
//            if newPhase == .active {
//                cancelBackgroundTasks()
//            }
//        }
    }
    
    private func fetchAddress() {
        if let location = locationManager.currentLocation {
            reverseGeocode(location: location) { addr in
                storyDraft.address = addr ?? ""
            }
        } else {
            print("위치를 가져올 수 없습니다.")
        }
    }
    
//    private func scheduler() {
//        let request = BGAppRefreshTaskRequest(identifier: "education.techit.Azit.widgetRefresh")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15분마다 실행
////        request.earliestBeginDate = Date(timeIntervalSinceNow: 3) // 15분마다 실행
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("scheduler error: \(error)")
//        }
//    }
//    
//    static func handleAppRefresh(task: BGAppRefreshTask) {
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//        }
//        
//        Task {
//            print("***** background test *****")
////            await userInfoStore.loadUserInfo(userID: authManager.userID)
////            
////            let story: Story = try await storyStore.loadFriendsRecentStoryByIds(ids: userInfoStore.userInfo?.friends ?? [])
////            
////            storyStore.updateSharedUserDefaults(recentStory: story)
//                
//            task.setTaskCompleted(success: true)
//        }
//    }
//    
//    private func cancelBackgroundTasks() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//        print("Background tasks have been canceled.")
//    }
}
