//
//  SignWith.swift
//  Azit
//
//  Created by 김종혁 on 12/19/24.
//

import SwiftUI

func signInWithEmailPassword(authManager: AuthManager, dismiss: DismissAction) {
    Task {
        if await authManager.signInWithEmailPassword() == true {
            await dismiss()
        }
    }
}

func signInWithGoogle(authManager: AuthManager, dismiss: DismissAction) {
    Task {
        if await authManager.signInWithGoogle() == true {
            await dismiss()
        }
    }
}
