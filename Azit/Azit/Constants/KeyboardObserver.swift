//
//  KeyboardObserver.swift
//  Azit
//
//  Created by 박준영 on 11/19/24.
//

import Combine
import UIKit

class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = true
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
}
