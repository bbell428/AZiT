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
    
    @State private var rotation: Double = 270.0
    @Binding var isModalPresented: Bool
    @Binding var isdisplayEmojiPicker: Bool
    @Binding var isPassed24Hours: Bool
    @State var selectedEmoji: Emoji?
    @State var sortedUsers: [UserInfo] = []
    @State private var selectedIndex: Int = 0
    @State private var message: String = ""
    @State private var scale: CGFloat = 1.0
    @State private var previousScale: CGFloat = 1.0
  
    let angles: [(Double, Double)] = [
        (0, 60),
        (-60, 0),
        (60, 120),
        (-120, -60),
        (120, 180),
        (-180, -120),
        (180, 240),
        (-240, -180),
        (240, 300),
        (-300, -240),
        (300, 360),
        (-360, -300),
        (360, 420),
        (-420, -360),
        (420, 480),
        (-480, -420),
        (480, 540),
        (-540, -480),
        (540, 600),
        (-600, -540),
        (600, 660),
        (-660, -600),
        (660, 720),
        (-720, -660),
        (720, 780),
        (-780, -720),
        (780, 840),
        (-840, -780),
        (840, 900),
        (-900, -840),
        (900, 960),
        (-960, -900),
        (960, 1020),
        (-1020, -960),
        (1020, 1080),
        (-1080, -1020),
        (1080, 1140),
        (-1140, -1080),
        (1140, 1200),
        (-1200, -1140),
        (1200, 1260),
        (-1260, -1200),
        (1260, 1320),
        (-1320, -1260),
        (1320, 1380),
        (-1380, -1320),
        (1380, 1440),
        (-1440, -1380),
        (1440, 1500),
        (-1500, -1440)
    ]
    private let ellipses: [(width: CGFloat, height: CGFloat)] = [
        (1260, 1008), (967, 774), (674, 540), (285, 225)
    ]
    
    @State private var numberOfCircles: Int = 0

    var body: some View {
        ZStack {
            ZStack {
                Button {
                    isdisplayEmojiPicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .frame(width: 100, height: 100)
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createCircleGradient()), lineWidth: 3)
                                    
                                    Text(userInfoStore.userInfo?.previousState ?? "")
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
                        let startEllipse = ellipses[3]
                        let endEllipse = ellipses[0]
                        let randomAngleOffset = Double.random(in: angles[index % 6].0..<angles[index % 6].1)

                        let interpolationRatio: CGFloat = numberOfCircles > 1 ? CGFloat(index) / CGFloat(numberOfCircles - 1) : 0

                        ContentEmojiView(userInfo: $sortedUsers[index], rotation: $rotation, isModalPresented: $isModalPresented, selectedIndex: $selectedIndex, index: index, startEllipse: startEllipse, endEllipse: endEllipse, interpolationRatio: interpolationRatio, randomAngleOffset: randomAngleOffset, num : index)
                            .onTapGesture {
                                selectedIndex = index
                                print(selectedIndex)
                            }
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
            
            if isModalPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalPresented = false
                    }
                    .zIndex(2)
                
                ContentsModalView(isModalPresented: $isModalPresented, message: $message, selectedUserInfo: $sortedUsers[selectedIndex])
                    .zIndex(3)
            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                
                sortedUsers = try await sortUsersByDistance(from: userInfoStore.userInfo!, users: userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? []))
                numberOfCircles = userInfoStore.userInfo?.friends.count ?? 0
                
                let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
            
        }
    }    

    func sortUsersByDistance(from user: UserInfo, users: [UserInfo]) -> [UserInfo] {
        return users.sorted { (user1, user2) -> Bool in
            let distance1 = Utility.haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user1.latitude, lon2: user1.longitude)
            let distance2 = Utility.haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user2.latitude, lon2: user2.longitude)
            return distance1 < distance2
        }
    }
}

//#Preview {
//    RotationView(isModalPresented: .constant(false), isdisplayEmojiPicker: .constant(false), isPassed24Hour: .constant(false))
//}
