//
//  KeyboardExtension.swift
//  Azit
//
//  Created by 박준영 on 12/6/24.
//

import Foundation
import UIKit

// 키보드 내리기 위한
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
