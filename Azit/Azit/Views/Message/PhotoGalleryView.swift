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
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Divider()
                    .frame(width: 50, height: 5)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(15)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
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
            Text("사진")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.leading, 20)
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
        .overlay(
            ProgressView("사진 불러오는 중...")
                .opacity(photoStore.photos.isEmpty ? 1 : 0)
        )
        .background(Color.picker)
    }
    
    private var sendButtonBar: some View {
        BlurView(style: .systemMaterial)
            .frame(height: 80)
            .opacity(0.1)
            .overlay(
                HStack {
                    Spacer()
                    Button {
                        isOpenGallery = false
                        Task {
                            await sendSelectedImage()
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.white)
                                .padding(10)
                            Text("전송")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                        }
                        .background(.accent)
                        .cornerRadius(20)
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
