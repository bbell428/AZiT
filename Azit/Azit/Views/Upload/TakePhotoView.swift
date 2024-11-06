//
//  CameraView.swift
//  Azit
//
//  Created by 홍지수 on 11/1/24.
//
import SwiftUI
import AVFoundation
import PhotosUI

struct TakePhotoView: View {
    @StateObject var cameraService = CameraService()
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
                .padding([.leading, .bottom])
                .sheet(isPresented: $isGalleryPresented) {
                    // 사진 가져와서 capturedImage에 담아야 함.
                    PhotoPicker(image: $cameraService.capturedImage) // 갤러리 뷰 표시
                        .onChange(of: cameraService.capturedImage){
                            self.isPhotoTaken = true
                        }
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
                    Button(action: {}) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.clear)
                    }
                    .padding([.trailing, .bottom])
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
            
            NavigationLink(
                destination: PhotoReviewView(image: cameraService.capturedImage),
                isActive: $isPhotoTaken,
                label: { EmptyView() }
            )
            
        }
        .navigationBarTitle("사진 촬영", displayMode: .inline)
        .onChange(of: cameraService.capturedImage) { image in
            Task {
                if image != nil {
                    self.isPhotoTaken = true
                }
            }
        }
    }
}

#Preview {
    TakePhotoView()
}
