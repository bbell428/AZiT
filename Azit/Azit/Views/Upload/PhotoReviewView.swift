//
//  PhotoReviewView.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct PhotoReviewView: View {
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var storyDraft: StoryDraft
    @EnvironmentObject var authManager: AuthManager
    @Binding var firstNaviLinkActive: Bool
    @Binding var isMainDisplay: Bool // MainView에서 전달받은 바인딩 변수
    
    var image: UIImage?
    @State private var showUploadView = false
    @State var isdisplayEmojiPicker: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                ProgressView(value: 2, total: 2)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                    .frame(height: 10)
                    .cornerRadius(6)
                    .padding()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                    //                    .scaledToFill()
                        .aspectRatio(3/4, contentMode: .fit)
                        .frame(width: 330, height: 440)
                } else {
                    Text("No Image Captured")
                }
                
                Spacer()
                
                // 임시저장된 스토리 불러오기
                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                    .stroke(Color.accentColor, lineWidth: 1)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Color.white))
                    .frame(width: 330, height: 80)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading) {
                                Text(storyDraft.emoji)
                                Text(storyDraft.content)
                            }
                            .padding()
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(storyDraft.latitude)")
                                // 공개 범위 text
                                
                                Button (action: {
                                    isdisplayEmojiPicker = true
                                }) {
                                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                                        .stroke(Color.accentColor, lineWidth: 1)
                                        .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                                            .fill(Color.white))
                                        .frame(width: 50, height: 40)
                                        .overlay(
                                            Text("편집")
                                                .font(.caption)
                                        )
                                }
                            }
                        }
                            .font(.headline)
                            .bold()
                            .padding()
                            .foregroundColor(Color.accentColor)
                    )
                
                // save 버튼
                Button(action: {
//                    savePhoto()
                    let newStory = Story(
                        userId: authManager.userID,
                        date: Date(),
                        latitude: storyDraft.latitude,
                        longitude: storyDraft.longitude,
                        emoji: storyDraft.emoji,
                        content: storyDraft.content,
                        publishedTargets: []
                    )
                    
                    Task {
                        await storyStore.addStory(newStory)
                    }
                    showUploadView = true
                    firstNaviLinkActive = false
                    isMainDisplay = false
                    
                }) {
                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .stroke(Color.accentColor, lineWidth: 1)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                            .fill(Color.white))
                        .frame(width: 330, height: 40)
                        .overlay(Text("Share")
                            .font(.headline)
                            .bold()
                            .padding()
                            .foregroundColor(Color.accentColor)
                        )
                }
                .padding(.bottom, 20)
            }
            if isdisplayEmojiPicker {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isdisplayEmojiPicker = false // 배경 터치 시 닫기
                        }
                    
                    EditStoryView(isdisplayEmojiPicker: $isdisplayEmojiPicker)
                }
            }
        }
        .navigationBarTitle("게시물 공유", displayMode: .inline)
    }
    
    // firebase storage에 저장
    func savePhoto() {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
