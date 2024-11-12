//
//  UserInfoStore.swift
//  Azit
//
//  Created by 김종혁 on 11/5/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore
import SwiftUICore

@MainActor
class UserInfoStore: ObservableObject {
    private var authManager: AuthManager = .init()
    @Published var userInfo: UserInfo? = nil
    @Published var friendInfo: [String: UserInfo] = [:] // UID를 키로 사용하는 딕셔너리 형태
    @Published var friendInfos: [UserInfo] = []
    
    // MARK: - 사용자 정보 Firestore에 추가
    func addUserInfo(_ user: UserInfo) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(user.id).setData([
                "id": user.id,
                "email": user.email,
                "nickname": user.nickname,
                "profileImageName": user.profileImageName,
                "previousState": user.previousState,
                "friends": user.friends,
                "latitude": user.latitude,
                "longitude": user.longitude
            ])
            
            print("Document successfully written!")
        } catch {
            print("Error writing document: \(error)")
        }
    }
    
    // MARK: - 사용자 정보 업데이트 (위치나 상태 변경 등)
    func updateUserInfo(_ user: UserInfo) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(user.id).setData([
                "id": user.id,
                "email": user.email,
                "nickname": user.nickname,
                "profileImageName": user.profileImageName,
                "previousState": user.previousState,
                "friends": user.friends,
                "latitude": user.latitude,
                "longitude": user.longitude
            ], merge: true) // 기존 데이터에 덮어쓰기
            print("Document successfully updated!")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    // MARK: - 사용자 정보 로드
    func loadUserInfo(userID: String) async {
        do {
            let db = Firestore.firestore()
            let document = try await db.collection("User").document(userID).getDocument()
            
            guard let docData = document.data() else {
                print("No user data found for email: \(userID)")
                return
            }
            
            let id: String = docData["id"] as? String ?? ""
            let nickname: String = docData["nickname"] as? String ?? ""
            let profileImageName: String = docData["profileImageName"] as? String ?? ""
            let previousState: String = docData["previousState"] as? String ?? ""
            let friends: [String] = docData["friends"] as? [String] ?? []
            let latitude: Double = docData["latitude"] as? Double ?? 0.0
            let longitude: Double = docData["longitude"] as? Double ?? 0.0
            
            // `userInfoStore` 업데이트
            self.userInfo = UserInfo(
                id: id,
                email: authManager.email,
                nickname: nickname,
                profileImageName: profileImageName,
                previousState: previousState,
                friends: friends,
                latitude: latitude,
                longitude: longitude
            )
            
            print("userinfo: \(String(describing: self.userInfo))")
            
            loadFriendsInfo(friendsIDs: userInfo?.friends ?? [])
        } catch {
            print("Error loading user info: \(error)")
        }
    }
    
    func loadFriendsInfo(friendsIDs: [String]) {
        let db = Firestore.firestore()
        
        guard !friendsIDs.isEmpty else {
            print("친구가 없습니다.")
            return
        }
        
        db.collection("User")
            .whereField(FieldPath.documentID(), in: friendsIDs)
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                self.friendInfo = documents.reduce(into: [String: UserInfo]()) { dict, document in
                    if let userInfo = try? document.data(as: UserInfo.self) {
                        dict[document.documentID] = userInfo
                    } else {
                        print("친구를 불러오는데 오류가 발생했습니다 : \(document.documentID)")
                    }
                }
                
                self.friendInfos = Array(self.friendInfo.values).sorted { $0.nickname < $1.nickname }
                
                print("친구 : \(self.friendInfo)")
            }
    }
    
    // MARK: - userID에 따른 사용자 정보 목록 로드
    func loadUsersInfoByEmail(userID: [String]) async throws -> [UserInfo] {
        guard !userID.isEmpty else {
            return []
        }
        
        let db = Firestore.firestore()
        
        let querySnapshot = try await db.collection("User")
            .whereField(FieldPath.documentID(), in: userID) // 배열로 변경
            .getDocuments()
        
        var usersInfo: [UserInfo] = []
        
        for document in querySnapshot.documents {
            let data = document.data()
            let userInfo = try await UserInfo(document: document)
            usersInfo.append(userInfo)
        }
        
        return usersInfo
    }
    
    // MARK: - 중복된 nickname 확인
    func isNicknameExists(_ nickname: String) async -> Bool {
        let db = Firestore.firestore()
               
               do {
                   let querySnapshot = try await db.collection("User")
                       .whereField("nickname", isEqualTo: nickname)
                       .getDocuments()
                   
                   return !querySnapshot.isEmpty // 쿼리 결과가 비어 있지 않으면 닉네임이 존재함
               } catch {
                   print("Error checking nickname existence: \(error)")
                   return false
               }
    }
    
    // MARK: - 사용자 정보 제거
    func deleteUserInfo(userID: String) async throws {
        let db = Firestore.firestore()
        
        do {
            try await db.collection("User").document(userID).delete()
        } catch {
            throw error
        }
    }
    
    // MARK: - 사용자 ID 값으로 사용자 이름 불러오기
    @MainActor
    func getUserNameById(id: String) async throws -> String {
        let db = Firestore.firestore()
        
        var user: UserInfo = UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0)
        
        do {
            let querySnapshot = try await db.collection("User")
                .whereField("id", isEqualTo: id).getDocuments()
            
            for document in querySnapshot.documents {
                do {
                    user = try await UserInfo(document: document)
                                        
                } catch {
                    print("Init User after loadUser error: \(error.localizedDescription)")
                    
                    return ""
                }
            }
            
        } catch {
            print("loadUser error: \(error.localizedDescription)")
            
            return ""
        }
        
        return user.nickname
    }
}
