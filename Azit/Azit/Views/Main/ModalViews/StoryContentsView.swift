//
//  StoryContentsView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
import FirebaseStorage

struct StoryContentsView: View {
    let story: Story
    @State private var imageURL: URL?
    @State private var isLoadingImage = false
    @State private var loadFailed = false
    
    var body: some View {
        VStack {
            // 스토리에 이미지가 있을 경우
            if !story.image.isEmpty {
                if !story.content.isEmpty {
                    HStack {
                        Text(story.content)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                if let imageURL = imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 336, height: 448)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            PlaceholderView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 336, height: 448)
                } else if isLoadingImage {
                    ProgressView()
                        .frame(height: 200)
                } else {
                    PlaceholderView()
                }
            } else if !story.emoji.isEmpty {
                if !story.content.isEmpty {
                    HStack {
                        SpeechBubbleView(text: story.content)
                    }
                    .padding(.bottom, -50)
                }
                Text(story.emoji)
                    .font(.system(size: 100))
            } else if !story.content.isEmpty {
                HStack {
                    Text(story.content)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .onAppear {
            loadStoryImage()
        }
    }
    
    private func loadStoryImage() {
        guard !story.image.isEmpty else { return }
        isLoadingImage = true
        loadFailed = false
        
        let storage = Storage.storage()
        let imageRef = storage.reference().child("image/\(story.image)")
        
        imageRef.downloadURL { url, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("이미지 로드 실패: \(error.localizedDescription)")
                    loadFailed = true
                } else {
                    self.imageURL = url
                }
                isLoadingImage = false
            }
        }
    }
}
