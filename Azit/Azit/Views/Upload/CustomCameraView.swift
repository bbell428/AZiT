//
//  CameraView.swift
//  Azit
//
//  Created by 홍지수 on 11/1/24.
//
import SwiftUI
import AVFoundation
import PhotosUI

struct CustomCameraView: View {
    @StateObject private var camera = CameraModel()
    @State private var isGalleryPresented = false // 갤러리 열기 상태
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 카메라 미리보기 (실제 카메라 화면을 대체)
                CameraPreview(camera: camera)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                VStack {
                    // 상단 진행 바와 텍스트
                    VStack(spacing: 8) {
                        Text("사진 촬영")
                            .font(.headline)
                            .foregroundColor(.accent)
                        
                        ProgressView(value: 0.5)
                            .progressViewStyle(LinearProgressViewStyle(tint: .accent))
                            .frame(width: geometry.size.width * 0.8)
                    }
                    .padding(.top, geometry.size.height * 0.05)
                    
                    Spacer()
                    
                    // 하단 버튼들
                    HStack {
                        Button(action: {
                            // 갤러리 열기 기능 (추가 구현 필요)
                            isGalleryPresented = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            camera.takePhoto()
                        }) {
                            Image(systemName: "camera.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // 설정 버튼 추가 (필요에 따라 구현)
                        }) {
                            Image(systemName: "gearshape")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.bottom, geometry.size.height * 0.05)
                }
            }
            .onAppear {
                camera.checkPermissions()
            }
        }
    }
}

// Camera Preview 설정
struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()
        camera.setupSession(for: viewController.view)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

// 카메라 모델
class CameraModel: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    
    override init() {
        super.init()
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
    }
    
    func checkPermissions() {
         switch AVCaptureDevice.authorizationStatus(for: .video) {
         case .authorized:
             setupSession()
         case .notDetermined:
             AVCaptureDevice.requestAccess(for: .video) { granted in
                 if granted {
                     self.setupSession()
                 }
             }
         default:
             break
         }
     }
    
    func setupSession(for view: UIView) {
        guard let captureSession = captureSession else { return }
        captureSession.beginConfiguration()
        
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        if captureSession.canAddOutput(photoOutput!) {
            captureSession.addOutput(photoOutput!)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
        // 촬영한 이미지 처리 코드 추가 (예: 이미지 저장 또는 미리보기 표시)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, error in
                if let uiImage = image as? UIImage {
                    // 선택한 이미지에 대한 처리 (예: 이미지 미리보기, 저장 등)
                    print("Selected image: \(uiImage)")
                }
            }
        }
    }
}
