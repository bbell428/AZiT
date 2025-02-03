//
//  EmojiView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI

struct EmojiView : View {
    // 프로젝트 상태 및 서비스 관리
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var locationManager: LocationManager
    
    // 스토리 데이터 관련 객체
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyDraft: StoryDraft // EmojiView에서 생성한 Story 임시 저장
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var isDisplayEmojiPicker: Bool // MainView에서 전달받은 바인딩 변수
    @Binding var isMyModalPresented: Bool // 내 스토리에 대한 모달
    @Binding var isAnimatingForStroke: Bool
  
    @State var isShowingsheet: Bool = false
    @State var isPicture: Bool = false
    @State var firstNaviLinkActive: Bool = false
    @State private var isLimitExceeded: Bool = false
    @State var friendID: String = ""
    @State private var scale: CGFloat = 0.1
    
    private let characterLimit = 25 // 메시지 입력 글자수 제한
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    var isShareEnabled: Bool {
        return storyDraft.emoji.isEmpty && storyDraft.content.isEmpty
    }
    
    var body : some View {
        VStack {
            NavigationStack {
                VStack {
                    // 상단 바
                    EmojiTopView(isShowingsheet: $isShowingsheet, friendID: $friendID)
                    
                    // 이모지피커 뷰 - 서치 바와 리스트
                    EmojiPickerView(selectedEmoji: $storyDraft.emoji, searchEnabled: false,  selectedColor: Color.accent)
                }
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height * 1.1 / 3)
                .padding(.bottom)
                
                // 메시지 입력
                TextField("상태 메시지를 입력하세요.", text: $storyDraft.content)
                    .frame(width: 340, height: 40)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.subColor1, lineWidth: 0.5)
                            .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 15)))
                    )
                    .onChange(of: storyDraft.content) { newValue in
                        if newValue.count >= characterLimit {
                            storyDraft.content = String(newValue.prefix(characterLimit))
                            isLimitExceeded = true
                        } else {
                            isLimitExceeded = false
                        }
                    }
                
                if isLimitExceeded {
                    Text("최대 25자까지 입력할 수 있습니다.")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                // 카메라 촬영 버튼
                NavigationLink(destination: TakePhotoView(firstNaviLinkActive: $firstNaviLinkActive, isMainDisplay: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented), isActive: $firstNaviLinkActive) {
                    RoundedRectangle(cornerSize: CGSize(width: 15.0, height: 15.0))
                        .background(RoundedRectangle(cornerSize: CGSize(width: 15.0, height: 15.0))
                            .fill(Color.accentColor))
                        .frame(width: 340, height: 40)
                        .overlay(Image(systemName: "camera.fill")
                            .padding()
                            .foregroundColor(Color.white)
                        )
                }
                .padding(.bottom, 10)
                
                // 공유 버튼
                if !isShareEnabled {
                    Button (action:{
                        isMyModalPresented = false
                        isAnimatingForStroke = true
                        
                        let newStory = Story(
                            userId: authManager.userID,
                            date: Date(),
                            latitude: storyDraft.latitude,
                            longitude: storyDraft.longitude,
                            address: storyDraft.address,
                            emoji: storyDraft.emoji,
                            content: storyDraft.content,
                            publishedTargets: storyDraft.publishedTargets
                        )
                        isDisplayEmojiPicker = false
                        if let location = locationManager.currentLocation {
                            userInfoStore.userInfo?.latitude = location.coordinate.latitude
                            userInfoStore.userInfo?.longitude = location.coordinate.longitude
                        }
                        Task {
                            await storyStore.addStory(newStory)
                            // 유저의 새로운 상태, 위경도 값 저장
                            if !(storyDraft.emoji == "") {
                                userInfoStore.userInfo?.previousState = storyDraft.emoji
                            }
                            print("변경된 이모지 : \(storyDraft.emoji)")
                            await userInfoStore.updateUserInfo(userInfoStore.userInfo!)
                            resetStory()
                        }
                    }) {
                        RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                            .stroke(Color.accentColor, lineWidth: 0.5)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                                .fill(Color.white))
                            .frame(width: 340, height: 40)
                            .overlay(Text("Share")
                                .padding()
                                .foregroundColor(Color.accentColor)
                            )
                    }
                    //MARK: - 디테일 사항
                }
            }
        }
        .padding()
        .frame(width: (screenBounds?.width ?? 0) - 32, height: isShareEnabled ? 500 : 550) // 팝업창 크기
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.subColor4)
//                .stroke(Color.accentColor, lineWidth: 0.5)
                .shadow(radius: 10)
        )
        .sheet(isPresented: $isShowingsheet) {
            PublishScopeView()
                .presentationDetents([.medium, .large])
                .onDisappear {
                    // 공개 범위 업데이트
                    if let firstTarget = storyDraft.publishedTargets.first {
                        friendID = userInfoStore.friendInfo[firstTarget]?.nickname ?? ""
                    }
                }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .contentShape(Rectangle()) // 전체 뷰가 터치 가능하도록 설정
        .scaleEffect(scale)
        .onAppear {
            if let location = locationManager.currentLocation {
                fetchAddress()
            } else {
                print("위치 정보가 아직 준비되지 않았습니다.")
            }
            // 공개 범위에 모두를 넣음
            storyDraft.publishedTargets = userInfoStore.userInfo?.friends ?? []
            
            Task {
                if storyDraft.publishedTargets.count > 0 {
                    friendID = try await userInfoStore.getUserNameById(id: storyDraft.publishedTargets[0])
                } else {
                    friendID = "All"
                }
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
    }
    
    // 저장 후 초기화 함수
    func resetStory() {
//        storyDraft.id = ""
//        storyDraft.userId = ""
        storyDraft.likes = []
        storyDraft.latitude = 0.0
        storyDraft.longitude = 0.0
        storyDraft.address = ""
        storyDraft.emoji = ""
        storyDraft.image = ""
        storyDraft.content = ""
        storyDraft.publishedTargets = []
        storyDraft.readUsers = []
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
