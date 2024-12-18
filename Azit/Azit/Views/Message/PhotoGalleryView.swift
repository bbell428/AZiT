//
//  PhotoGalleryView.swift
//  Azit
//
//  Created by 박준영 on 12/18/24.
//

import SwiftUI
import Photos

// Custom PhotoPicker View
struct PhotoGalleryView: View {
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var photoStore: PhotoManagerStore

    @State private var selectedImage: UIImage? // 선택된 이미지 저장
    
    @Binding var isOpenGallery: Bool // 갤러리 열림 상태
    var friendId: String // 상대방 ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            ZStack(alignment: .bottom) {
                photoGridView
                
                if selectedImage != nil {
                    sendButtonBar
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            Task {
                await photoStore.requestPhotos()
            }
        }
    }
    
    private var headerView: some View {
        Text("업로드할 이미지 선택")
            .font(.title3)
            .fontWeight(.bold)
            .padding([.leading, .top], 20)
    }
    
    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3),
                spacing: 3
            ) {
                ForEach(photoStore.photos, id: \.self) { image in
                    ZStack(alignment: .topTrailing) {
                        Button {
                            selectedImage = image
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: (UIScreen.main.bounds.width - 12) / 3,
                                       height: (UIScreen.main.bounds.width - 12) / 3)
                                .clipped()
                                .cornerRadius(5)
                                .overlay(
                                    selectedImage == image
                                    ? Color.black.opacity(0.3)
                                    : Color.clear
                                )
                        }
                        
                        if selectedImage == image {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .padding(7)
                        }
                    }
                }
            }
            .padding(3)
        }
    }
    
    private var sendButtonBar: some View {
        BlurView(style: .systemMaterial)
            .frame(height: 80)
            .overlay(
                HStack {
                    Spacer()
                    Button {
                        isOpenGallery = false
                        Task {
                            await sendSelectedImage()
                        }
                    } label: {
                        Text("이미지 전송")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            )
    }
    
    private func sendSelectedImage() async {
        guard let selectedImage = selectedImage else { return }
        let myId = userInfoStore.userInfo?.id ?? ""
        await chatDetailViewStore.uploadImage(myId: myId, friendId: friendId, selectedImage: selectedImage)
    }
}
