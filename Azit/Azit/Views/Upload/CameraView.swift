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
    @ObservedObject var cameraService = CameraService()
    @State private var isPhotoTaken = false
    
    var body: some View {
        VStack {
            ProgressView(value: 1, total: 2)
                .padding()
            
            CameraPreview(session: cameraService.session)
                .onAppear { cameraService.startSession() }
                .onDisappear { cameraService.stopSession() }
                .aspectRatio(3/4, contentMode: .fit)
            
            Spacer()
            
            Button(action: {
                cameraService.capturePhoto()
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                    )
            }
            .padding(.bottom, 20)
            .onReceive(cameraService.$capturedImage) { image in
                if image != nil {
                    self.isPhotoTaken = true
                }
            }
            
            NavigationLink(
                destination: PhotoReviewView(image: cameraService.capturedImage),
                isActive: $isPhotoTaken,
                label: { EmptyView() }
            )
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

#Preview {
    CameraView()
}
