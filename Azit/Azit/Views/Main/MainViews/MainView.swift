//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import BackgroundTasks
import AlertToast
import WidgetKit

struct MainView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @Environment(\.scenePhase) private var scenePhase
    
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
    @State private var isShowToast = false
    @State private var isTappedWidget = false // 위젯이 클릭 되었는지 확인
    @State private var isAnimatingForStroke = false // 글이 써졌는지 확인 후 애니메이션을 위함
    
    @State private var isShowingMessageView = false
    @State private var isShowingMyPageView = false
    @State private var offset: CGFloat = 0.0 // 스와이프 감지를 위한 값
    
    @State private var navigateToChatDetail = false
    @State private var chatRoomId: String?
    @State private var profileImageFriend: String?
    @State private var nicknameFriend: String?
    
    var body: some View {
        if !isShowingMessageView && !isShowingMyPageView {
            NavigationStack() {
                ZStack {
                    // 메인 화면일 때 타원 뷰
                    if isMainExposed {
                        RotationView(isMainExposed: $isMainExposed, isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isSendFriendStoryToast: $isShowToast, isTappedWidget: $isTappedWidget, isAnimatingForStroke: $isAnimatingForStroke)
                            .frame(width: 300, height: 300)
                            .zIndex(isMyModalPresented
                                    || isFriendsModalPresented
                                    || isDisplayEmojiPicker
                                    || isTappedWidget ? 2 : 1)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation.width
                                    }
                                    .onEnded { value in
                                        if offset < -100 { // 왼쪽으로 스와이프
                                            withAnimation(.easeInOut) {
                                                isShowingMessageView = true
                                            }
                                        } else if offset > 100 { // 오른쪽으로 스와이프
                                            withAnimation(.easeInOut) {
                                                isShowingMyPageView = true
                                            }
                                        }
                                        offset = 0 // 초기화
                                    }
                            )
                        // 맵 화면일 때 맵 뷰
                    } else {
                        MapView(isMainExposed: $isMainExposed, isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isDisplayEmojiPicker: $isDisplayEmojiPicker, isPassed24Hours: $isPassed24Hours, isSendFriendStoryToast: $isShowToast, isAnimatingForStroke: $isAnimatingForStroke)
                            .zIndex(isMyModalPresented
                                    || isFriendsModalPresented
                                    || isDisplayEmojiPicker
                                    || isTappedWidget ? 2 : 1)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation.width
                                    }
                                    .onEnded { value in
                                        if offset < -100 { // 왼쪽으로 스와이프
                                            withAnimation(.easeInOut) {
                                                isShowingMessageView = true
                                            }
                                        } else if offset > 100 { // 오른쪽으로 스와이프
                                            withAnimation(.easeInOut) {
                                                isShowingMyPageView = true
                                            }
                                        }
                                        offset = 0 // 초기화
                                    }
                            )
                    }
                    
                    // 메인 화면의 메뉴들
                    MainTopView(isMainExposed: $isMainExposed, isSendFriendStoryToast: $isShowToast)
                        .zIndex(1)
                }
                // 메인 뷰에서 알림을 받을 시, 해당 채팅방으로 이동
                .navigationDestination(isPresented: $navigateToChatDetail) {
                    if let roomId = chatRoomId {
                        MessageDetailView(
                            friend: UserInfo(
                                id: roomId,
                                email: "", // Replace with actual data
                                nickname: "", // Replace with actual data
                                profileImageName: "", // Default profile image
                                previousState: "",
                                friends: [],
                                latitude: 0.0,
                                longitude: 0.0,
                                blockedFriends: [],
                                fcmToken: ""
                            ),
                            isSendFriendStoryToast: $isShowToast,
                            roomId: roomId,
                            nickname: nicknameFriend ?? "",
                            friendId: roomId,
                            profileImageName: profileImageFriend ?? ""
                        )
                        .onDisappear {
                            FriendsStore.shared.navigateToChatDetail = false
                        }
                    }
                }
            }
            .toast(isPresenting: $isShowToast, alert: {
                AlertToast(displayMode: .banner(.pop), type: .systemImage("envelope.open", Color.white), title: "전송 완료", style: .style(backgroundColor: .subColor1, titleColor: Color.white))
            })
            // 포그라운드 상태에서 알림을 받아 클릭 시, 알림에서 받아온 값들을 할당
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveNotification)) { notification in
                if let userInfo = notification.userInfo,
                   let viewType = userInfo["viewType"] as? String,
                   let friendNickname = userInfo["friendNickname"] as? String,
                   let friendProfileImage = userInfo["friendProfileImage"] as? String,
                   let chatId = userInfo["chatId"] as? String,
                   
                    viewType == "chatDetail" {
                    self.nicknameFriend = friendNickname
                    self.profileImageFriend = friendProfileImage
                    self.chatRoomId = chatId
                    self.navigateToChatDetail = true
                }
            }
            // 백그라운드에서 알림을 클릭 시, 앱 처음 실행하여 알림에서 얻게 된 값들을 할당하여 뷰 이동
            .onAppear {
                if ((FriendsStore.shared.nicknameFriend?.isEmpty) != nil) {
                    self.navigateToChatDetail = FriendsStore.shared.navigateToChatDetail
                    self.nicknameFriend = FriendsStore.shared.nicknameFriend
                    self.profileImageFriend = FriendsStore.shared.profileImageFriend
                    self.chatRoomId = FriendsStore.shared.chatRoomId
                }
            }

            .onChange(of: scenePhase) {
                switch scenePhase {
                case .background:
                    userInfoStore.updateSharedUserDefaults(user: userInfoStore.userInfo!)
                    WidgetCenter.shared.reloadTimelines(ofKind: "AzitWidget")
                    print("background")
                case .active:
                    print("active")
                case .inactive:
                    print("inactive")
                @unknown default:
                    break
                }
            }
        }
        // MessageView
        if isShowingMessageView {
            MessageView(isSendFriendStoryToast: $isShowToast, isShowingMessageView: $isShowingMessageView)
        }
        
        // MyPageView
        if isShowingMyPageView {
            MyPageView(isShowingMyPageView: $isShowingMyPageView)
        }
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
}

