//
//  CameraModel.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//
import SwiftUI
import AVFoundation

// MARK: - Camera Service to handle camera functionality
class Camera: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    
    var session: AVCaptureSession
    private var photoOutput: AVCapturePhotoOutput
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    override init() {
        session = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        super.init()
        checkPermission()
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.configureSession()
                }
            }
        default:
            print("Camera access denied")
        }
    }
    
    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Add video input
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), self.session.canAddInput(videoDeviceInput) else { return }
            self.session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            self.session.commitConfiguration()
            self.startSession()
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - Capture Photo Delegate
extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        sessionQueue.async {
            guard let imageData = photo.fileDataRepresentation() else { return }
            DispatchQueue.main.async {
                self.capturedImage = UIImage(data: imageData)
            }
        }
    }
}
