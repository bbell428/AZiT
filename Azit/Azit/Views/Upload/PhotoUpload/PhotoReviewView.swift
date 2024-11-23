//
//  PhotoReviewView.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//

import SwiftUI
import AVFoundation
import PhotosUI
import Kingfisher

struct PhotoReviewView: View {
    @EnvironmentObject var cameraService: CameraService
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var photoImageStore: PhotoImageStore
    @Environment(\.dismiss) var dismiss
    @Binding var firstNaviLinkActive: Bool
    @Binding var isMainDisplay: Bool // MainView에서 전달받은 바인딩 변수
    @Binding var isMyModalPresented: Bool // 내 스토리에 대한 모달
    @Binding var isPhotoTaken: Bool
    var image: UIImage?
    let emojiManager = EmojiManager()
    
    @State private var showUploadView = false
    @State var isDisplayEmojiPicker: Bool = false
    @State private var progressValue: Double = 2.0
    let totalValue: Double = 2.0
    
    @State var friendID: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                
                // 프로그래스 뷰
                ZStack(alignment: .leading) {
                    // 회색 배경
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 360, height: 15)
                    // 진행 바 - 그라디언트
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradation12, Color.gradation1]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 360 * (progressValue / totalValue), height: 15)
                }
                .padding()
                
                // 스토리 이미지
                if let image = cameraService.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                    //                    .scaledToFill()
                        .aspectRatio(3/4, contentMode: .fit)
                        .frame(width: 360, height: 480)
                } else {
                    Text("No Image Captured")
                }
                Spacer()
                
                // MARK: - 임시저장된 스토리 불러오기
                RoundedRectangle(cornerSize: CGSize(width: 15.0, height: 15.0))
                    .stroke(Color.accentColor, lineWidth: 1)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Color.subColor4))
                    .frame(width: 360, height: 110)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading) {
                                // 이모지 + 매시지
                                HStack{
                                    if let codepoints = emojiManager.getCodepoints(forName: storyDraft.emoji) {
                                        KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    }
                                    Text(storyDraft.content)
                                }
                                .padding([.leading, .bottom], 5)
                                
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(Color.accentColor)
                                    Text(storyDraft.address)
                                }
                                .padding([.leading, .bottom], 5)
                                
                                // 공개 범위
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color.accentColor)
                                    
                                    if storyDraft.publishedTargets.count == userInfoStore.userInfo?.friends.count {
                                        Text("ALL")
                                    } else if storyDraft.publishedTargets.count == 1 {
                                        Text("\(friendID)")
                                    } else {
                                        Text("\(friendID) 외 \(storyDraft.publishedTargets.count - 1)명")
                                    }
                                }
                                .onAppear() {
                                    Task {
                                        friendID = try await userInfoStore.getUserNameById(id: storyDraft.publishedTargets[0])
                                    }
                                }
                                .padding([.leading, .bottom], 5)
                            }
                            Spacer()
                            
                            // 스토리 편집 버튼
                            Button (action: {
                                isDisplayEmojiPicker = true
                            }) {
                                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                                        .fill(Color.accentColor))
                                    .frame(width: 50, height: 40)
                                    .overlay(
                                        Text("편집")
                                            .foregroundStyle(Color.white)
                                            .font(.caption)
                                    )
                            }
                        }
                            .font(.subheadline)
                            .bold()
                            .padding()
                            .foregroundColor(Color.accentColor)
                    )
                
                // save 버튼
                Button(action: {
//                    savePhoto()
                    shareStory()
                }) {
                    RoundedRectangle(cornerSize: CGSize(width: 15.0, height: 15.0))
                        .stroke(Color.accentColor, lineWidth: 1)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                            .fill(Color.white))
                        .frame(width: 360, height: 40)
                        .overlay(Text("Share")
                            .font(.headline)
                            .bold()
                            .padding()
                            .foregroundColor(Color.accentColor)
                        )
                }
                .padding(.bottom, 20)
            }
            if isDisplayEmojiPicker {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isDisplayEmojiPicker = false // 배경 터치 시 닫기
                        }
                    EditStoryView(isDisplayEmojiPicker: $isDisplayEmojiPicker, isMyModalPresented: $isMyModalPresented)
                }
            }
        }
//        .onAppear {
//            isPhotoTaken = false
//        }
        .navigationBarTitle("게시물 공유", displayMode: .inline)
    }
    
    
    // MARK: - 함수들
    
    // firebase storage에 저장
    func savePhoto() {
        guard let image = image else { return }
        // 찐 앨범에 저장
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func shareStory() {
        // 스토리 객체 생성
        let newStory = Story(
            id: storyDraft.id,
            userId: authManager.userID,
            date: Date(),
            latitude: storyDraft.latitude,
            longitude: storyDraft.longitude,
            address: storyDraft.address,
            emoji: storyDraft.emoji,
            image: storyDraft.id,
            content: storyDraft.content,
            publishedTargets: []
        )
//        isDisplayEmojiPicker = false
        // 유저의 새로운 상태, 위경도 값 저장
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
            
            if let image = cameraService.capturedImage {
                photoImageStore.UploadImage(image: image, imageName: newStory.image)
            }
            await userInfoStore.updateUserInfo(userInfoStore.userInfo!)
            isDisplayEmojiPicker = false
            showUploadView = true
            firstNaviLinkActive = false
            isMainDisplay = false
            isMyModalPresented = false
            resetStory()
//            cameraService.capturedImage = nil
        }
//        showUploadView = true
//        firstNaviLinkActive = false
//        isMainDisplay = false
        
//        cameraService.capturedImage = nil
    }
    
    func resetStory() {
        storyDraft.id = UUID().uuidString
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
        cameraService.capturedImage = nil
    }
}
