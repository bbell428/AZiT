//
//  QRShareSheet.swift
//  Azit
//
//  Created by 김종혁 on 11/14/24.
//

import SwiftUI
import UIKit

// 공유할 수 있는 공유 시트
struct QRShareSheet: UIViewControllerRepresentable {
    var shareItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update the controller
    }
}
