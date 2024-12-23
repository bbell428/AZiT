//
//  ResignStore.swift
//  Azit
//
//  Created by 김종혁 on 11/25/24.
//MARK: 삭제 관련 스토어

import Observation
import FirebaseCore
import FirebaseFirestore
import SwiftUI

@MainActor
class FriendsStore: ObservableObject {
    static let shared = FriendsStore() // 단일 클래스로 바꿈
    
    @Published var nicknameFriend: String?
    @Published var profileImageFriend: String?
    @Published var chatRoomId: String?
    @Published var navigateToChatDetail: Bool = false
    @Published var friendId: String?
    
    @Published var friendInfos: [UserInfo] = [] // 친구 정보 목록
        private var listener: ListenerRegistration? // Firestore 리스너
        
        // 실시간 친구 목록 리스너
        func listenToFriendsUpdates(userID: String) {
            let db = Firestore.firestore()
            let userDocRef = db.collection("User").document(userID)

            // 기존 리스너 제거 (중복 방지)
            listener?.remove()

            // 새 리스너 설정
            listener = userDocRef.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Firestore 친구 업데이트 오류: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data(),
                      let friends = data["friends"] as? [String], !friends.isEmpty else {
                    print("친구 데이터를 가져오지 못했습니다.")
                    DispatchQueue.main.async {
                        self.friendInfos = []
                    }
                    return
                }

                // 비동기 작업으로 친구 정보 가져오기
                Task {
                    do {
                        let querySnapshot = try await db.collection("User")
                            .whereField(FieldPath.documentID(), in: friends)
                            .getDocuments()

                        var usersInfo: [UserInfo] = []
                        
                        for document in querySnapshot.documents {
                            _ = document.data()
                            let userInfo = try await UserInfo(document: document)
                            usersInfo.append(userInfo)
                        }
                        

                        // 업데이트 및 정렬
                        DispatchQueue.main.async {
                            self.friendInfos = usersInfo.sorted { $0.id > $1.id }
                            print("실시간 친구 목록 업데이트 완료: \(self.friendInfos)")
                        }
                    } catch {
                        print("친구 정보 로드 중 오류 발생: \(error.localizedDescription)")
                    }
                }
            }
        }

        // 리스너 제거
        func removeListener() {
            listener?.remove()
            listener = nil
        }
    
    // Story 컬렉션에서 필드에 있는 userId가 포함된 문서를 모두 삭제
    func deleteStoryUser(userId: String) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Story")
        
        do {
            // `userId`를 포함하는 문서 쿼리
            let querySnapshot = try await collectionRef
                .whereField("userId", isEqualTo: userId) // userId 필드를 기준으로 검색
                .getDocuments()
            
            // 검색된 문서 삭제
            for document in querySnapshot.documents {
                let documentId = document.documentID
                try await collectionRef.document(documentId).delete()
                print("문서 \(documentId) 삭제 완료")
            }
            
            print("모든 문서를 성공적으로 삭제했습니다.")
            
        } catch {
            print("문서 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    // Chat 컬렉션 문서에 특정 문자열인 userId가 포함된 문서를 모두 삭제
    func deleteChatUser(userId: String) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("Chat")
        
        do {
            // Chat 컬렉션의 모든 문서 가져오기
            let querySnapshot = try await collectionRef.getDocuments()
            
            // 문서 ID에 특정 userId 문자열이 포함된 경우 삭제
            for document in querySnapshot.documents {
                let documentId = document.documentID
                if documentId.contains(userId) {
                    // Messages 하위 컬렉션 삭제
                    try await deleteMessages(inChat: documentId)
                    
                    // 상위 Chat 문서 삭제
                    try await collectionRef.document(documentId).delete()
                    print("문서 \(documentId) 삭제 완료")
                }
            }
            
            print("모든 관련 문서를 성공적으로 삭제했습니다.")
            
        } catch {
            print("문서 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }
    // Messages 하위 컬렉션 삭제 함수
    private func deleteMessages(inChat chatId: String) async throws {
        let db = Firestore.firestore()
        let messagesCollectionRef = db.collection("Chat").document(chatId).collection("Messages")
        
        do {
            // Messages 하위 컬렉션의 모든 문서 가져오기
            let querySnapshot = try await messagesCollectionRef.getDocuments()
            
            // Messages 하위 컬렉션의 모든 문서 삭제
            for message in querySnapshot.documents {
                try await messagesCollectionRef.document(message.documentID).delete()
                print("Messages 문서 \(message.documentID) 삭제 완료")
            }
        } catch {
            print("Messages 하위 컬렉션 삭제 중 오류 발생: \(error.localizedDescription)")
            throw error
        }
    }
}

extension Binding {
    init<T>(_ keyPath: ReferenceWritableKeyPath<T, Value>, on object: T) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
