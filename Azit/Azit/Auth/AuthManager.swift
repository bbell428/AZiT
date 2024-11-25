//
//  AuthenticationStore.swift
//  Azit
//
//  Created by 김종혁 on 11/1/24.
//

import Foundation

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore

// 인증 처리 상태
enum AuthenticationState {
    case splash             // 스플래쉬
    case unauthenticated    // 인증 안됨
    case authenticating     // 인증 진행중
    case profileExist       // 프로필 입력 뷰
    case authenticated      // 인증 완료
}

// 현재 보이는 인증 화면의 상태
enum AuthenticationFlow {
    case login  // 로그인 화면
    case signUp // 회원가입 화면
}

// 인증 오류를 처리를 위한 타입
enum AuthenticationError: Error {
    case tokenError(message: String)
}

@MainActor
class AuthManager: ObservableObject {
    @Published var name: String = "unkown"
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid: Bool  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var userID: String = ""
    
    @Published var deepUserID: String = "" // QR로 받아온 친구 UID값
    
    
    init() {
        authenticationState = .splash
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - 사용자 nickname 존재 확인
    // 닉네임이 없으면 프로필디테일로 아니라면 메인홈으로 가기 위한 함수
    func isNicknameExists(for userID: String) async -> Bool {
        let db = Firestore.firestore()
        let documentRef = db.collection("User").document(userID)
        
        do {
            let document = try await documentRef.getDocument()
            
            // 문서가 존재, nickname필드가 존재하면 true
            if let data = document.data(), data["nickname"] != nil {
                return true
            } else {
                return false
            }
        } catch {
            print("Error checking nickname existence: \(error)")
            return false
        }
    }
    
    // 자동로그인
    func registerAuthStateHandler() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.authStateHandler == nil {
                self.authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                    Task {
                        self.user = user
                        
                        self.authenticationState = user == nil ? .unauthenticated : await self.isNicknameExists(for: user?.uid ?? "") ? .authenticated : .profileExist
                        
                        self.email = user?.email ?? ""
                        self.userID = user?.uid ?? ""
                    }
                }
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch { }
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
}

// 인증 수단마다 처리할 방법을 추가로 제시한다
extension AuthManager {
    func signOut() {
        do {
            try Auth.auth().signOut()
            authenticationState = .unauthenticated
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        do {
            try await user?.delete()
            
            authenticationState = .unauthenticated
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
}
