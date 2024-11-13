//
//  MapView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/6/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var isMyModalPresented: Bool
    @Binding var isFriendsModalPresented: Bool
    @Binding var isDisplayEmojiPicker: Bool
    @Binding var isPassed24Hours: Bool
    
    @State private var region = MKCoordinateRegion()
    @State var users: [UserInfo] = []
    @State var selectedEmoji: Emoji?
    @State private var selectedIndex: Int = 0
    @State private var message: String = ""
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: $users) { $user in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                    if user.id == userInfoStore.userInfo?.id {
                        Button {
                            if isPassed24Hours {
                                isDisplayEmojiPicker = true
                            } else {
                                isMyModalPresented = true
                            }
                        } label: {
                            ZStack {
                                MyContentEmojiView(isPassed24Hours: $isPassed24Hours,
                                                   previousState: userInfoStore.userInfo?.previousState ?? "",
                                                   width: 50,
                                                   height: 50)
                                    .zIndex(3)
                            }                            
                        }
                    } else {
                        MapContentEmojiView(user: $user,
                                            isFriendsModalPresented: $isFriendsModalPresented,
                                            selectedIndex: $selectedIndex,
                                            region: region,
                                            index: users.firstIndex(where: { $0.id == user.id }) ?? 0)
                            .onTapGesture {
                                if let index = users.firstIndex(where: { $0.id == user.id }) {
                                    selectedIndex = index
                                }
                            }
                            .zIndex(1)
                    }
                }
            }
            
            // Modal 분기
            ModalIdentificationView(isMyModalPresented: $isMyModalPresented,
                                    isFriendsModalPresented: $isFriendsModalPresented,
                                    isDisplayEmojiPicker: $isDisplayEmojiPicker,
                                    isPassed24Hours: $isPassed24Hours,
                                    users: $users,
                                    message: $message,
                                    selectedIndex: $selectedIndex)
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                if users.isEmpty {
                    // 사용자 본인의 정보 받아오기
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    // 사용자 본인의 친구 받아오기
                    userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                    // 사용자 본인의 정보 users 배열에 넣기, 본인의 위칙를 기반으로 Circle을 표시하기 위함
                    if let user = userInfoStore.userInfo {
                        users.append(user)
                    }
                    
                    var tempUsers: [UserInfo] = []
                    // 스토리가 있는 친구들 분류
                    for friend in userInfoStore.userInfo?.friends ?? [] {
                        do {
                            let tempStory = try await storyStore.loadRecentStoryById(id: friend)
                            
                            if tempStory.id != "" && (tempStory.publishedTargets.contains(userInfoStore.userInfo?.id ?? "") || tempStory.publishedTargets.isEmpty) {
                                try await tempUsers.append(userInfoStore.loadUsersInfoByEmail(userID: [friend])[0])
                            }
                        } catch { }
                    }
                    
                    // 친구들을 users 배열에 추가
                    users += tempUsers
                    
                    // 사용자 본인의 위도, 경도 값을 변수에 저장
                    let userLat = userInfoStore.userInfo?.latitude ?? 0
                    let userLng = userInfoStore.userInfo?.longitude ?? 0
                    
                    // Map에서의 기본 위치와 확대, 축소 수준 설정
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: userLat,
                            longitude: userLng
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    // 사용자 본인의 story
                    let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                    // 24시간이 지났는 지 판별
                    isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
                }
            }
        }
    }
}
