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
                .padding()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No Image Captured")
            }
            
            Spacer()
            
            Button(action: {
                savePhoto()
                showUploadView = true
            }) {
                Text("Share")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
            
            NavigationLink(
                destination: UploadView(),
                isActive: $showUploadView,
                label: { EmptyView() }
            )
        }
        .navigationBarTitle("", displayMode: .inline)
    }
    
    func savePhoto() {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
