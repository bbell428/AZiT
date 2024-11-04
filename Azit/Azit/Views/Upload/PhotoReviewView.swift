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
    var image: UIImage?
    @State private var showUploadView = false
    
    var body: some View {
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
            
            Button(action: {
                savePhoto()
                showUploadView = true
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
        .navigationBarTitle("게시물 공유", displayMode: .inline)
    }
    
    // firebase storage에 저장
    func savePhoto() {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
