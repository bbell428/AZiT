//
//  RotationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI
import EmojiPicker

struct RotationView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var isMyModalPresented: Bool // 사용자 자신의 모달 컨트롤
    @Binding var isFriendsModalPresented: Bool // 친구의 모달 컨트롤
    @Binding var isDisplayEmojiPicker: Bool  // 사용자 자신의 게시글 작성 모달 컨트롤
    @Binding var isPassed24Hours: Bool // 사용자 자신의 게시글 작성 후 24시간에 대한 판별 여부
    
    @State private var rotation: Double = 270.0
    @State private var sortedUsers: [UserInfo] = [] // 거리 순 친구 정렬
    @State private var selectedIndex: Int = 0 // 선택 된 친구 스토리
    @State private var message: String = "" // 친구에게 보낼 메세지
    @State private var scale: CGFloat = 1.0 // 확대, 축소를 위한 스케일
    @State private var previousScale: CGFloat = 1.0 // 이전 스케일을 보존
    @State private var friendsStories: [Story] = [] // 친구들의 story
    @State private var numberOfCircles: Int = 0 // 친구 story 개수

    var body: some View {
        ZStack {
            ZStack {
                // 사용자 본인의 Circle Button
                Button {
                    if isPassed24Hours {
                        isDisplayEmojiPicker = true
                    } else {
                        isMyModalPresented = true
                    }
                } label: {
                    MyContentEmojiView(isPassed24Hours: $isPassed24Hours, previousState: userInfoStore.userInfo?.previousState ?? "")
                }
                .zIndex(1)
                .offset(y: 250)
            
                // 타원 생성
                EllipsesView()
                
                // 친구들의 스토리 Circle
                if numberOfCircles > 0 {
                    ForEach(0..<numberOfCircles, id: \.self) { index in
                        let startEllipse = Constants.ellipses[3]
                        let endEllipse = Constants.ellipses[0]
                        let randomAngleOffset = Double.random(in: Constants.angles[index % 6].0..<Constants.angles[index % 6].1) // 세팅 된 Constants 내의 랜덤값으로 랜덤 Offset 설정

                        let interpolationRatio: CGFloat = numberOfCircles > 1 ? CGFloat(index) / CGFloat(numberOfCircles - 1) : 0

                        FriendsContentEmojiView(userInfo: $sortedUsers[index],
                                             rotation: $rotation,
                                             isFriendsModalPresented: $isFriendsModalPresented,
                                             selectedIndex: $selectedIndex,
                                             randomAngleOffset: randomAngleOffset,
                                             index: index,
                                             startEllipse: startEllipse,
                                             endEllipse: endEllipse,
                                             interpolationRatio: interpolationRatio)
                    }
                }
            }
            // 타원 위의 Circle들 각도 설정
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 속도 설정 부
                        rotation += Double(value.translation.width) * 0.02
                    }
            )
            // 뷰의 크기 확대, 축소
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = previousScale * value
                        
                        if newScale > 0.3 && newScale < 2.0 {
                            scale = newScale
                        }
                    }
                    .onEnded { value in
                        previousScale = scale
                    }
            )
            .scaleEffect(scale)
            .padding()
            
            // Modal 분기
            ModalIdentificationView(isMyModalPresented: $isMyModalPresented,
                                    isFriendsModalPresented: $isFriendsModalPresented,
                                    isDisplayEmojiPicker: $isDisplayEmojiPicker,
                                    isPassed24Hours: $isPassed24Hours,
                                    users: $sortedUsers,
                                    message: $message,
                                    selectedIndex: $selectedIndex)
        }
        .onAppear {
            Task {
                // 사용자 본인의 정보 받아오기
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                // 사용자 본인의 친구 받아오기
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                var tempUsers: [UserInfo] = []
                // 스토리가 있는 친구들 분류
                for friend in userInfoStore.userInfo?.friends ?? [] {
                    do {
                        let tempStory = try await storyStore.loadRecentStoryById(id: friend)
                        
                        if tempStory.id != "" {
                            try await tempUsers.append(userInfoStore.loadUsersInfoByEmail(userID: [friend])[0])
                        }
                    } catch { }
                }
                
                // 사용자 본인의 친구들을 거리를 바탕으로 정렬
                sortedUsers = Utility.sortUsersByDistance(from: userInfoStore.userInfo!, users: tempUsers)
                // 친구들의 최근 story 개수
                numberOfCircles = sortedUsers.count
                // 사용자 본인의 최근 story 불러오기
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                // 24시간이 지났는 지 판별
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
    }
}
