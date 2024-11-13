//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MainView: View {
    @State private var isMainExposed: Bool = true
    @State private var isMyModalPresented: Bool = false
    @State private var isFriendsModalPresented: Bool = false
    @State private var isPassed24Hours: Bool = false
    
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
//    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var locationManager: LocationManager
    
    @State var isdisplayEmojiPicker: Bool = false
    //    @State private var navigateToRoot = false
    @State var selectedEmoji: String = ""
    @State private var message: String = ""
    @State private var userInfo: UserInfo = UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0)
    
    // EmojiView 애니메이션
    @State private var scale: CGFloat = 0.1
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    var body: some View {
        NavigationStack() {
            ZStack {
                // 메인 화면일 때 타원 뷰
                if isMainExposed {
                    RotationView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isdisplayEmojiPicker: $isdisplayEmojiPicker, isPassed24Hours: $isPassed24Hours)
                        .frame(width: 300, height: 300)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isdisplayEmojiPicker ? 2 : 1) // 모디파이어 따로 빼기
                    
                // 맵 화면일 때 맵 뷰
                } else {
                    MapView(isMyModalPresented: $isMyModalPresented, isFriendsModalPresented: $isFriendsModalPresented, isdisplayEmojiPicker: $isdisplayEmojiPicker, isPassed24Hours: $isPassed24Hours)
                        .zIndex(isMyModalPresented
                                || isFriendsModalPresented
                                || isdisplayEmojiPicker ? 2 : 1)
                }
                
                // 메인 화면의 메뉴들
                MainTopView(isMainExposed: $isMainExposed)
                    .zIndex(1)
                
                if isdisplayEmojiPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isdisplayEmojiPicker = false // 배경 터치 시 닫기
                        }
                        .zIndex(2)
                    
                    EmojiView(isdisplayEmojiPicker: $isdisplayEmojiPicker)
                        .scaleEffect(scale)
                        .onAppear {
                            if let location = locationManager.currentLocation {
                                fetchAddress()
                            } else {
                                print("위치 정보가 아직 준비되지 않았습니다.")
                            }
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scale = 1.0
                            }
                        }
                        .onDisappear {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scale = 0.1
                            }
                        }
                        .zIndex(3)
//                        .frame(width: (screenBounds?.width ?? 0) - 50)
                }
            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                
                if let userInfo = userInfoStore.userInfo {
                    self.userInfo = userInfo
                }
            }
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

struct MainTopView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    @Binding var isMainExposed: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if isMainExposed == false {
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white]),
                                             startPoint: .bottom,
                                             endPoint: .top))
                }
                
                HStack() {
                    Text("AZiT")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .bold()
                        .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        //                        Button {
                        //                            // 게시글 리로드
                        //                        } label: {
                        //                            Image(systemName: "arrow.clockwise")
                        //                                .resizable()
                        //                                .aspectRatio(contentMode: .fit)
                        //                                .frame(width: 25)
                        //                        }
                        //                        .disabled(isModalPresented ? true : false)
                        
                        NavigationLink {
                            MessageView()
                        } label: {
                            Image(systemName: "ellipsis.message.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                        }
                        
                        NavigationLink {
                            AlbumView()
                        } label: {
                            Image(systemName: "photo.stack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                        }
                        
                        NavigationLink {
                            MyPageView()
                        } label: {
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                        }
                    }
                    .frame(width: 150, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                }
                .foregroundStyle(.accent)
            }
            .frame(maxHeight: (screenBounds?.height ?? 0) * 0.25)
            .ignoresSafeArea()
            
            Spacer()
            
            HStack{
                Spacer()
                
                Button {
                    isMainExposed.toggle()
                } label: {
                    Image(systemName: isMainExposed ? "map" : "house")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                }
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.accent, lineWidth: 2) // 원하는 색상과 선 두께로 설정
                )
            }
            .padding()
            
        }
    }
}

//#Preview {
//}
