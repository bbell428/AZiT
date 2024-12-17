//
//  SelectedUploadImageView.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import SwiftUI

// 선택된 이미지 View
struct SelectedUploadImageView: View {
    @EnvironmentObject var chatDetailViewStore: ChatDetailViewStore
    
    @Binding var isSelectedImage: Bool
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isSelectedImage = false
                }
                .zIndex(2)
            
            VStack(spacing: 50) {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: 360, maxHeight: 480)
                    .cornerRadius(15)
                
                Button {
                    // 이미지 로컬에 저장
                    chatDetailViewStore.saveImageToPhotoLibrary(image: selectedImage!)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                        
                        Text("핸드폰에 저장")
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
    }
}

