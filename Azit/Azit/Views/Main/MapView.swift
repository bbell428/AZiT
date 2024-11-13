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
    @State private var region = MKCoordinateRegion()
    @State var users: [UserInfo] = []
    @State var selectedEmoji: Emoji?
    @State private var selectedIndex: Int = 0
    @State private var message: String = ""
    @Binding var isMyModalPresented: Bool
    @Binding var isFriendsModalPresented: Bool
    @Binding var isDisplayEmojiPicker: Bool
    @Binding var isPassed24Hours: Bool
    
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
                                MyContentEmojiView(isPassed24Hours: $isPassed24Hours, previousState: userInfoStore.userInfo?.previousState ?? "")
                                    .zIndex(3)
                            }
                            
                        }
                    } else {
                        MapContentEmojiView(user: $user, region: region, isFriendsModalPresented: $isFriendsModalPresented, selectedIndex: $selectedIndex, index: users.firstIndex(where: { $0.id == user.id }) ?? 0)
                            .onTapGesture {
                                if let index = users.firstIndex(where: { $0.id == user.id }) {
                                    selectedIndex = index
                                }
                            }
                            .zIndex(1)
                    }
                }
            }
            
            if isFriendsModalPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFriendsModalPresented = false
                    }
                    .zIndex(2)
                
                if !users.isEmpty {
                    FriendsContentsModalView(isModalPresented: $isFriendsModalPresented, message: $message, selectedUserInfo: $users[selectedIndex])
                        .zIndex(3)
                }
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
        .ignoresSafeArea()
        .onAppear {
            Task {
                if users.isEmpty {
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                    
                    if let user = userInfoStore.userInfo {
                        users.append(user)
                    }
                    
                    users += try await userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? [])
                    
                    let userLat = userInfoStore.userInfo?.latitude ?? 0
                    let userLng = userInfoStore.userInfo?.longitude ?? 0
                    
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: userLat,
                            longitude: userLng
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    
                    let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                    
                    isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
                }
            }
        }
    }
}

struct MapContentEmojiView: View {
    @EnvironmentObject var storyStore: StoryStore
    @Binding var user: UserInfo
    var region: MKCoordinateRegion
    @Binding var isFriendsModalPresented: Bool
    @Binding var selectedIndex: Int
    @State var isPassed24Hours: Bool = false
    var index: Int
    
    var body: some View {
        VStack {
            Text(user.nickname)
                .font(.caption)
                .foregroundStyle(.black)
                .padding(.top, max(-40, min(-20, -40 * (1.0 / (region.span.latitudeDelta * 12.5)))))
            
            Button {
                isFriendsModalPresented = true
                selectedIndex = index
            } label: {
                ZStack {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                             center: .center,
                                             startRadius: 0,
                                             endRadius: 20))
                    
                    Circle()
                        .fill(.white.opacity(0.7))
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createCircleGradient(colors: [.accent, .gradation1, .gradation2])), lineWidth: 3)
                                Text(user.previousState)
                                    .font(.system(size: 45))
                            }
                        )
                        .offset(x: 0, y: -30)
                        .frame(width: 60, height: 60)
                }
            }
            .scaleEffect(max(0.5, min(1.0, 1.0 / (region.span.latitudeDelta * 12.5))))
        }
        .onAppear {
            Task {
                let story = try await storyStore.loadRecentStoryById(id: user.id)
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
        }
    }
}
