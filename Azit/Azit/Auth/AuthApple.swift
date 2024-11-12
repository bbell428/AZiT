//
//  AuthApple.swift
//  Azit
//
//  Created by 김종혁 on 11/12/24.
//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

class AuthApple: ObservableObject {
    @Published var currentNonce: String?
    @Published var isSignedIn = false // 로그인 상태 확인
    @Published var userEmail: String? // 이메일 저장

    func prepareRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAuthorization(_ result: Result<ASAuthorization, Error>, completion: @escaping () -> Void) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                // Firebase 인증을 위한 Apple Credential 생성
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                
                // Firebase 로그인
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Error Apple sign in: \(error.localizedDescription)")
                        return
                    }
                    print("Apple 로그인 성공")
                    
                    Task { @MainActor in
                        // 로그인 성공 시 이메일 저장 및 화면 전환
                        self.userEmail = authResult?.user.email
                        // 로그인 상태를 업데이트
                        self.isSignedIn = true
                        
                        // isSignedIn, userEmail 업데이트 후 completion 호출
                        completion()
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple errored: \(error.localizedDescription)")
            completion()
        }
    }
    
    // Helper functions for Apple Sign-In nonce generation
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { byte in charset[Int(byte) % charset.count] })
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
