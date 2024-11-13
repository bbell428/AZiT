//
//  EmojiView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI
//import EmojiPicker

struct EmojiView : View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var locationManager: LocationManager
    
    @Binding var isDisplayEmojiPicker: Bool // MainView에서 전달받은 바인딩 변수
  
    @State var publishedTargets: [String] = []
    @State var isShowingsheet: Bool = false
    @State var isPicture:Bool = false
    @State var firstNaviLinkActive = false
    @State private var isLimitExceeded: Bool = false
    private let characterLimit = 20
    // FocusState 변수를 선언하여 TextEditor의 포커스 상태를 추적
    @FocusState private var isTextEditorFocused: Bool
    
    var isShareEnabled: Bool {
        return storyDraft.emoji.isEmpty && storyDraft.content.isEmpty
    }
    
    var body : some View{
        VStack {
            NavigationStack {                
                // 상단 바
                HStack {
                    // 위치
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.accentColor)
                        Text(storyDraft.address)
                            .font(.caption2)
                    }
                    Spacer()
                    
                    // 공개 범위
                    Button(action: {
                        isShowingsheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "person")
                            if storyDraft.publishedTargets.isEmpty {
                                Text("ALL")
                            } else if storyDraft.publishedTargets.count == 1 {
                                Text("\(storyDraft.publishedTargets[0])")
                            } else {
                                Text("\(storyDraft.publishedTargets[0]) 외 \(storyDraft.publishedTargets.count)명")
                            }
                            Text(">")
                        }
                        .font(.caption2)
                    }
                }
                .padding([.horizontal, .bottom])
                
                // 이모지피커 뷰 - 서치 바와 리스트
                EmojiPickerView(selectedEmoji: $storyDraft.emoji, searchEnabled: false,  selectedColor: Color.accent)
                    .background(Color.subColor4)
                
            }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height * 1.1 / 3)
                .padding(.bottom)
            
            // 메시지 입력
            TextField("상태 메시지를 입력하세요.", text: $storyDraft.content)
                .padding(.leading, 10)
                .frame(width: 340, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.subColor1, lineWidth: 0.5)
                        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
                )
                .padding(.bottom, 5)
                .onChange(of: storyDraft.content) { newValue in
                    if newValue.count >= characterLimit {
                        storyDraft.content = String(newValue.prefix(characterLimit))
                        isLimitExceeded = true
                    } else {
                        isLimitExceeded = false
                    }
                }
            
            if isLimitExceeded {
                Text("최대 20자까지 입력할 수 있습니다.")
                    .font(.caption2)
                    .foregroundColor(.red)
//                    .padding(.vertical, 2)
            }
            
            // 카메라 촬영 버튼
            NavigationLink(destination: TakePhotoView(firstNaviLinkActive: $firstNaviLinkActive, isMainDisplay: $isDisplayEmojiPicker), isActive: $firstNaviLinkActive) {
                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
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
                // 공유 버튼
                Button (action:{
                    let newStory = Story(
                        userId: authManager.userID,
                        date: Date(),
                        latitude: storyDraft.latitude,
                        longitude: storyDraft.longitude,
                        address: storyDraft.address,
                        emoji: storyDraft.emoji,
                        content: storyDraft.content,
                        publishedTargets: []
                    )
                    Task {
                        await storyStore.addStory(newStory)
                    }
                    resetStory()
                    isDisplayEmojiPicker = false
                    
                    // 유저의 위경도 값 저장
                    if let location = locationManager.currentLocation {
                        userInfoStore.userInfo?.latitude = location.coordinate.latitude
                        userInfoStore.userInfo?.longitude = location.coordinate.longitude
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
//                .disabled(isShareEnabled)
            }
            
            
        }
        .padding()
        .frame(width: 365, height: 550) // 팝업창 크기
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.subColor4)
                .stroke(Color.accentColor, lineWidth: 0.5)
                .shadow(radius: 10)
        )
        .sheet(isPresented: $isShowingsheet) {
            PublishScopeView()
                .presentationDetents([.medium])
        }
        .toolbar {
            // 키보드 위에 '완료' 버튼 추가
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                    Button("완료") {
                        isTextEditorFocused = false // 키보드 숨기기
                    }
                }
            }
        }
        .contentShape(Rectangle()) // 전체 뷰가 터치 가능하도록 설정
        .onTapGesture {
            isTextEditorFocused = false // 다른 곳을 클릭하면 포커스 해제
        }
    }
    
    // 저장 후 초기화 함수
    func resetStory() {
        storyDraft.content = ""
        storyDraft.emoji = ""
    }
    //    func getEmojiList()->[[Int]] {
    //        var emojis : [[Int]] = []
    //        for i in stride(from: 0x1F601, to: 0x1F64F, by: 4){
    //            var temp : [Int] = []
    //            for j in i...i+3{
    //                temp.append(j)
    //            }
    //            emojis.append(temp)
    //        }
    //        return emojis
    //    }
}

