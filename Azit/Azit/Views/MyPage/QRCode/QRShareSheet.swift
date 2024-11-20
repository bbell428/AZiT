//
//  QRShareSheet.swift
//  Azit
//
//  Created by 김종혁 on 11/14/24.

//MARK: 다른 곳에 공유할 수 있는 시트를 보여줌

import SwiftUI
import UIKit

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
