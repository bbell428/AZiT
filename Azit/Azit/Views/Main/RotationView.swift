//
//  RotationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI
import EmojiPicker

struct RotationView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var storyStore: StoryStore
    
    @State private var selectedIndex: Int = 0
    @State private var message: String = ""
    @State private var scale: CGFloat = 1.0
    @State private var previousScale: CGFloat = 1.0
    @State private var numberOfCircles: Int = 0
    @State private var rotation: Double = 270.0
    @State var sortedUsers: [UserInfo] = []
    @State private var isShowAlert = false // QR로 앱 -> 알림 띄움 (친구추가)
    @State private var isShowYes = false // QR로 인해 친구추가 알림에서 Yes를 누를 경우
    
    @State var selectedEmoji: Emoji?
    
    @Binding var isMyModalPresented: Bool
    @Binding var isFriendsModalPresented: Bool
    @Binding var isDisplayEmojiPicker: Bool
    @Binding var isPassed24Hours: Bool
    
    var body: some View {
        ZStack {
            ZStack {
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
                
                ForEach(0..<4, id: \.self) { index in
                    Ellipse()
                        .fill(Utility.createGradient(index: index, width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234))))
                        .frame(width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234)))
                        .overlay(
                            Ellipse()
                                .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        )
                        .offset(y: 250)
                        .zIndex(0)
                }
                
                if numberOfCircles > 0 {
                    ForEach(0..<numberOfCircles, id: \.self) { index in
                        let startEllipse = Constants.ellipses[3]
                        let endEllipse = Constants.ellipses[0]
                        let randomAngleOffset = Double.random(in: Constants.angles[index % 6].0..<Constants.angles[index % 6].1)
                        
                        let interpolationRatio: CGFloat = numberOfCircles > 1 ? CGFloat(index) / CGFloat(numberOfCircles - 1) : 0
                        
                        MainContentEmojiView(userInfo: $sortedUsers[index], rotation: $rotation, isFriendsModalPresented: $isFriendsModalPresented, selectedIndex: $selectedIndex, index: index, startEllipse: startEllipse, endEllipse: endEllipse, interpolationRatio: interpolationRatio, randomAngleOffset: randomAngleOffset)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        rotation += Double(value.translation.width) * 0.01
                    }
            )
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
            
            if isFriendsModalPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFriendsModalPresented = false
                    }
                    .zIndex(2)
                
                FriendsContentsModalView(isModalPresented: $isFriendsModalPresented, message: $message, selectedUserInfo: $sortedUsers[selectedIndex])
                    .zIndex(3)
            }
            
            if isPassed24Hours {
                if isDisplayEmojiPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isDisplayEmojiPicker = false
                        }
                        .zIndex(2)
                    EmojiView(isDisplayEmojiPicker: $isDisplayEmojiPicker)
                        .zIndex(3)
                }
            } else {
                if isMyModalPresented {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isMyModalPresented = false
                        }
                        .zIndex(2)
                    MyContentsModalView(isMyModalPresented: $isMyModalPresented, selectedUserInfo: userInfoStore.userInfo!)
                        .zIndex(3)
                }
            }
        }
        .onAppear {
            Task {
                if !authManager.deepUserID.isEmpty {
                    isShowAlert = true
                }
                
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                sortedUsers = try await Utility.sortUsersByDistance(from: userInfoStore.userInfo!, users: userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? []))
                numberOfCircles = userInfoStore.userInfo?.friends.count ?? 0 // 친구가 아니라 친구의 게시글이 numberOfCircle이 되어야 함
                
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("친구 추가"),
                message: Text("친구를 추가하겠습니까?"),
                primaryButton: .default(Text("Yes"), action: {
                    userInfoStore.addFriend(receivedUID: authManager.deepUserID, currentUserUID: authManager.userID)
                    authManager.deepUserID = ""
                    isShowYes = true
                }),
                secondaryButton: .cancel(Text("No"), action: {
                    authManager.deepUserID = "" // No 선택 시 deepUserID를 초기화하여 알림이 반복되지 않도록 함
                })
            )
        }
        .onChange(of: authManager.deepUserID) {
            Task {
                if !authManager.deepUserID.isEmpty {
                    isShowAlert = true
                }
                
                guard isShowYes else { return }
                
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                sortedUsers = try await Utility.sortUsersByDistance(from: userInfoStore.userInfo!, users: userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? []))
                numberOfCircles = userInfoStore.userInfo?.friends.count ?? 0 // 친구가 아니라 친구의 게시글이 numberOfCircle이 되어야 함
                
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
                
            }
        }
    }
}

struct MyContentEmojiView: View {
    @Binding var isPassed24Hours: Bool
    var previousState: String = ""
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.clear)
                .frame(width: 100, height: 100)
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createCircleGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 3)
                        
                        Text(previousState)
                            .font(.system(size: 80))
                    }
                )
            if isPassed24Hours {
                Circle()
                    .fill(.white)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Text("+")
                            .fontWeight(.black)
                    )
                    .offset(y: 50)
            }
        }
    }
}

//#Preview {
//    RotationView(isModalPresented: .constant(false), isdisplayEmojiPicker: .constant(false), isPassed24Hour: .constant(false))
//}
