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
    @Published var blockedFriends: [UserInfo] = []
    
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
                "longitude": user.longitude,
                "blockedFriends": user.blockedFriends,
                "fcmToken": user.fcmToken
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
                "longitude": user.longitude,
                "blockedFriends": user.blockedFriends,
                "fcmToken": user.fcmToken
                
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
            let blockedFriends: [String] = docData["blockedFriends"] as? [String] ?? []
            let fcmToken: String = docData["fcmToken"] as? String ?? ""
            
            // `userInfoStore` 업데이트
            self.userInfo = UserInfo(
                id: id,
                email: authManager.email,
                nickname: nickname,
                profileImageName: profileImageName,
                previousState: previousState,
                friends: friends,
                latitude: latitude,
                longitude: longitude,
                blockedFriends: blockedFriends,
                fcmToken: fcmToken
            )
            
            print("userinfo: \(String(describing: self.userInfo))")
            
            //loadFriendsInfo(friendsIDs: userInfo?.friends ?? [])
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
            _ = document.data()
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

    //MARK: 친구 추가 (QR받은 ID, 현재 내 ID)
    func addFriend(receivedID: String, currentUserID: String) {
        let db = Firestore.firestore()
        
        // 현재 ID
        let currentUserRef = db.collection("User").document(currentUserID)
        
        // 받아온 ID
        let receivedUserRef = db.collection("User").document(receivedID)
        
        // 나의 친구배열에 받아온 id 추가
        currentUserRef.updateData([
            "friends": FieldValue.arrayUnion([receivedID])
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                print("나의 친구배열에 친구 추가 성공")
            }
        }
        
        // 친구배열에 나의 id 추가
        receivedUserRef.updateData([
            "friends": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                print("친구배열에 나를 추가 성공")
            }
        }
    }
    
    // MARK: - 사용자 ID 값으로 사용자 이름 불러오기
    @MainActor
    func getUserNameById(id: String) async throws -> String {
        let db = Firestore.firestore()
        
        var user: UserInfo = UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0, blockedFriends: [], fcmToken: "")
        
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
    
    // MARK: - 사용자 ID로 UserInfo 가져오기
    func getUserInfoById(id: String) async throws -> UserInfo? {
        let db = Firestore.firestore()
        
        do {
            let document = try await db.collection("User").document(id).getDocument()
            
            guard let docData = document.data() else {
                print("No user data found for id: \(id)")
                return nil
            }
            
            let id = docData["id"] as? String ?? ""
            let email = docData["email"] as? String ?? ""
            let nickname = docData["nickname"] as? String ?? ""
            let profileImageName = docData["profileImageName"] as? String ?? ""
            let previousState = docData["previousState"] as? String ?? ""
            let friends = docData["friends"] as? [String] ?? []
            let latitude = docData["latitude"] as? Double ?? 0.0
            let longitude = docData["longitude"] as? Double ?? 0.0
            let blockedFriends = docData["blockedFriends"] as? [String] ?? []
            let fcmToken = docData["fcmToken"] as? String ?? ""
            
            let userInfo = UserInfo(
                id: id,
                email: email,
                nickname: nickname,
                profileImageName: profileImageName,
                previousState: previousState,
                friends: friends,
                latitude: latitude,
                longitude: longitude,
                blockedFriends: blockedFriends,
                fcmToken: fcmToken
            )
            
            return userInfo
        } catch {
            print("Error fetching user info by id: \(error)")
            return nil
        }
    }
    
    // MARK: - 친구 목록에 특정 ID가 있는지 확인
    func isFriend(id: String) -> Bool {
        guard let currentUserFriends = self.userInfo?.friends else {
            return false
        }
        
        return currentUserFriends.contains(id)
    }
    
    // MARK: - 차단 목록에 특정 ID가 있는지 확인
    func isBlockedFriend(id: String) -> Bool {
        guard let currentUserFriends = self.userInfo?.blockedFriends else {
            return false
        }
        
        return currentUserFriends.contains(id)
    }
    
    // MARK: - 상대의 blockedFriends 배열에서 내 ID가 있는지 확인
    func isBlockedByFriend(friendID: String, myID: String) async -> Bool {
        let db = Firestore.firestore()

        do {
            // 상대방의 사용자 문서를 가져옴
            let document = try await db.collection("User").document(friendID).getDocument()
            
            guard let docData = document.data() else {
                print("No user data found for id: \(friendID)")
                return false
            }

            // blockedFriends 배열을 가져옴
            let blockedFriends = docData["blockedFriends"] as? [String] ?? []

            // blockedFriends 배열에 내 ID가 있는지 확인
            return blockedFriends.contains(myID)
        } catch {
            print("Error checking if blocked by friend: \(error)")
            return false
        }
    }
    
    // MARK: - story 데이터 UserDefault에 전달
    func updateSharedUserDefaults(user: UserInfo) {
        if let sharedDefaults = UserDefaults(suiteName: "group.benear.azit.group") {
            // User 객체를 Data로 변환
            do {
                let encoder = JSONEncoder()
                let encodedStory = try encoder.encode(user)
                sharedDefaults.set(encodedStory, forKey: "userInfo")
                print("유저 디폴트에 유저 데이터를 저장하였습니다.")
            } catch {
                print("스토리 인코딩 실패: \(error)")
            }
        }
    }
    
    // MARK: - 친구 목록에서 특정 ID 삭제
    func removeFriend(friendID: String, currentUserID: String) {
        let db = Firestore.firestore()
        
        // 현재 사용자의 친구 목록에서 id 제거
        let currentUserRef = db.collection("User").document(currentUserID)
        currentUserRef.updateData([
            "friends": FieldValue.arrayRemove([friendID])
        ]) { error in
            if let error = error {
                print("나의 친구 목록에 유저 없움: \(error)")
                return
            }
            print("친구목록에 친구 삭제 완료")
        }
        
        // 상대방의 친구 목록에서 현재 사용자 제거
        let friendUserRef = db.collection("User").document(friendID)
        friendUserRef.updateData([
            "friends": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            if let error = error {
                print("친구목록에 나 자신이 없움: \(error)")
                return
            }
            print("친구목록에 나 자신을 삭제함")
        }
    }
    
    // MARK: - 차단 목록에서 특정 ID 삭제
    func removeBlockedFriend(friendID: String, currentUserID: String) {
        let db = Firestore.firestore()
        
        // 현재 사용자의 차단 목록에서 id 제거
        let currentUserRef = db.collection("User").document(currentUserID)
        currentUserRef.updateData([
            "blockedFriends": FieldValue.arrayRemove([friendID])
        ]) { error in
            if let error = error {
                print("나의 친구 목록에 유저 없움: \(error)")
                return
            }
            print("차단목록에 친구 삭제 완료")
        }
    }
    
    // MARK: - 로그인 후, 전용 디바이스 토큰으로 업데이트
    func updateFCMToken(_ userId: String, fcmToken: String) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(userId).setData([
                "fcmToken": fcmToken
                
            ], merge: true) // 기존 데이터에 덮어쓰기
            print("Document successfully updated!")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    //MARK: Chat문서 읽지 않은 값 전부 긁어오기
    func sumIntegerValuesContainingUserID(userID: String) async -> Int {
        let db = Firestore.firestore()
        var totalSum = 0
        
        do {
            // Chat 컬렉션의 문서 가져오기
            let querySnapshot = try await db.collection("Chat").getDocuments()
            
            for document in querySnapshot.documents {
                // `unreadCount` 필드가 Map인지 확인
                if let unreadCountMap = document.data()["unreadCount"] as? [String: Int] {
                    // Map에서 특정 userID에 해당하는 값 추출
                    if let userUnreadCount = unreadCountMap[userID] {
                        totalSum += userUnreadCount
                    }
                }
            }
            
            print("Total sum of integer values for userID \(userID): \(totalSum)")
        } catch {
            print("Error calculating sum of integer values: \(error)")
        }
        
        return totalSum
    }
}
