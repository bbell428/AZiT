//
//  NavigationExtension.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import Foundation
import UIKit

// NavigationTitle를 숨겨도, 뒤로가는 제스처(Swipe)는 그대로 유지하기 위한 용도
// 모든 NavigationStack에 적용됨.
extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

//struct CustomNavigationView<Content: View>: UIViewControllerRepresentable {
//    var content: Content
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    func makeUIViewController(context: Context) -> UINavigationController {
//        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: content))
//        return navigationController
//    }
//    
//    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
//        uiViewController.setViewControllers([UIHostingController(rootView: content)], animated: false)
//    }
//}
