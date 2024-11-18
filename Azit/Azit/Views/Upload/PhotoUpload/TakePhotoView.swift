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
    @EnvironmentObject var cameraService : CameraService
    @State var isPhotoTaken = false
    @State private var isGalleryPresented = false
    @Binding var firstNaviLinkActive: Bool
    @Binding var isMainDisplay: Bool // MainView에서 전달받은 바인딩 변수
    @Binding var isMyModalPresented: Bool // 내 스토리에 대한 모달
    @State private var progressValue: Double = 1.0
    let totalValue: Double = 2.0
    
    var body: some View {
        VStack {
            // 프로그래스 뷰
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 360, height: 15)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor, Color.gradation12]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 360 * (progressValue / totalValue), height: 15)
            }
            .padding()
            
            // 카메라 프리뷰
            CameraPreview(session: cameraService.session)
                .onAppear { cameraService.startSession() }
                .onDisappear { cameraService.stopSession() }
                .aspectRatio(3/4, contentMode: .fit)
            Spacer()
            
            // 갤러리 버튼 + 촬영 버튼
            HStack {
                // 갤러리 버튼
                Button(action: {
                    isGalleryPresented = true
                }) {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom)
                .padding(.leading, 35)
                .sheet(isPresented: $isGalleryPresented) {
                    PhotoPicker(image: $cameraService.capturedImage)
                        .onChange(of: cameraService.capturedImage){
                            self.isPhotoTaken = true
                        }
                }
                Spacer()
                
                // 촬영 버튼
                Button(action: {
                    cameraService.capturePhoto()
                }) {
                    Circle()
                        .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
                        .frame(width: 55, height: 55)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 45, height: 45)
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
                .padding([.trailing, .bottom], 35)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
            
            // PhotoReviewView 전환
            NavigationLink(
                destination: PhotoReviewView(firstNaviLinkActive: $firstNaviLinkActive,isMainDisplay: $isMainDisplay , isMyModalPresented: $isMyModalPresented, isPhotoTaken: $isPhotoTaken, image: cameraService.capturedImage),
                isActive: $isPhotoTaken,
                label: { EmptyView() }
            )
            
        }
        .onAppear {
            cameraService.capturedImage = nil
        }
        .navigationBarTitle("사진 촬영", displayMode: .inline)
    }
}

//#Preview {
//    NavigationStack {
//        TakePhotoView()
//    }
//}
