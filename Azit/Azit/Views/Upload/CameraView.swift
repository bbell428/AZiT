//
//  CameraView.swift
//  Azit
//
//  Created by 홍지수 on 11/1/24.
//
import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @ObservedObject var cameraService = Camera()
    @State private var isPhotoTaken = false
    @State private var isGalleryPresented = false
    
    var body: some View {
        VStack {
            ProgressView(value: 1, total: 2)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(x: 1, y: 3, anchor: .center)
                .frame(height: 10)
                .cornerRadius(6)
                .padding()
            
            CameraPreview(session: cameraService.session)
                .onAppear { cameraService.startSession() }
                .onDisappear { cameraService.stopSession() }
                .aspectRatio(3/4, contentMode: .fit)
            
            Spacer()
            
            HStack {
                Button(action: {
                    isGalleryPresented = true
                }) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $isGalleryPresented) {
                    PhotoPicker(image: $cameraService.capturedImage) // 갤러리 뷰 표시
                }
                Spacer()
                
                Button(action: {
                    cameraService.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 6)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .onReceive(cameraService.$capturedImage) { image in
                    if image != nil {
                        self.isPhotoTaken = true
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            
            NavigationLink(
                destination: PhotoReviewView(image: cameraService.capturedImage),
                isActive: $isPhotoTaken,
                label: { EmptyView() }
            )
        }
        .navigationBarTitle("사진 촬영", displayMode: .inline)
    }
}

#Preview {
    CameraView()
}
