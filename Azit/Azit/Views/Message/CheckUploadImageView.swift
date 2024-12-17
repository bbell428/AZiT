//
//  CheckUploadImageView.swift
//  Azit
//
//  Created by 박준영 on 12/17/24.
//

import SwiftUI

// 업로드 전 선택한 이미지가 맞는지 선택하는 View
struct CheckUploadImageView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    
    var friendId: String // 상대방 ID
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    chatDetailViewStore.imageSelection = nil
                    chatDetailViewStore.selectedImage = nil
                    chatDetailViewStore.isChoicePhoto = false
                }
                .zIndex(2)
            
            VStack(spacing: 50) {
                Text("해당 사진을 업로드할까요?")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                Image(uiImage: chatDetailViewStore.selectedImage ?? UIImage())
                    .resizable()
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: 360, maxHeight: 480)
                    .cornerRadius(15)
                
                Button {
                    if (chatDetailViewStore.selectedImage != nil) {
                        Task {
                            chatDetailViewStore.isChoicePhoto = false
                            // 이미지 업로드
                            await chatDetailViewStore.uploadImage(myId: userInfoStore.userInfo?.id ?? "", friendId: friendId)
                            chatDetailViewStore.imageSelection = nil
                            chatDetailViewStore.selectedImage = nil
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.up.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                        
                        Text("업로드하기")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(width: 200, height: 50) // 원하는 크기로 조정
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)

                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .zIndex(3)
        }
        .onAppear {
            Task {
                // 이미지 처리
                await chatDetailViewStore.handleImageSelection()
            }
        }
    }
}
