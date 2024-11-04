//
//  AuthenticationStore+Email.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import Foundation

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

extension AuthManager {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        }
        catch  {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword(_ fullEmail: String) async -> Bool {
        email = fullEmail // 로그인 화면으로 돌아갈 때 그대로 가져옴
        authenticationState = .authenticating
        do  {
            try await Auth.auth().createUser(withEmail: fullEmail, password: password)
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
}
