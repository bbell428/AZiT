//
//  CameraModel.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//
import SwiftUI
import AVFoundation

// MARK: - Camera Service to handle camera functionality
class CameraService: NSObject, ObservableObject {
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
            if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    }
                } catch {
                    print("Error setting up video input: \(error)")
                }
            } else {
                print("No video device available")
            }
            
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
                guard let videoConnection = self.photoOutput.connection(with: .video) else {
                    print("No video connection available")
                    return
                }
                
                if videoConnection.isActive {
                    let settings = AVCapturePhotoSettings()
                    self.photoOutput.capturePhoto(with: settings, delegate: self)
                } else {
                    print("Video connection is not active")
                }
            }
    }
}

// MARK: - Capture Photo Delegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        sessionQueue.async {
            guard let imageData = photo.fileDataRepresentation() else { return }
            DispatchQueue.main.async {
                self.capturedImage = UIImage(data: imageData)
            }
        }
    }
}
