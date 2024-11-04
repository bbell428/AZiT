////
////  PhotoPicker.swift
////  Azit
////
////  Created by 홍지수 on 11/4/24.
////
//
//import SwiftUI
//import AVFoundation
//import PhotosUI
//// 사진 선택기
//struct PhotoPicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        config.selectionLimit = 1
//        
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController,
//                                context: Context) {}
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        let parent: PhotoPicker
//        
//        init(_ parent: PhotoPicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController,
//                    didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            guard let provider = results.first?.itemProvider,
//                  provider.canLoadObject(ofClass: UIImage.self) else { return }
//            
//            provider.loadObject(ofClass: UIImage.self) { image, error in
//                DispatchQueue.main.async {
//                    self.parent.image = image as? UIImage
//                }
//            }
//        }
//    }
//}
