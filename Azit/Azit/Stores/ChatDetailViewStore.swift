//
//  ChatDetailViewStore.swift
//  Azit
//
//  Created by 박준영 on 11/4/24.
//

import Foundation
import FirebaseFirestore
import Observation
import FirebaseAuth
import Combine
import SwiftUICore

class ChatDetailViewStore: ObservableObject {
    @EnvironmentObject var authManager: AuthManager
    private var db = Firestore.firestore() // 파이어베이스
    @Published private(set) var chatList: [Chat] = [] // 채팅방 리스트
    @Published private(set) var lastMessageId: String = ""
    var useruid: String = "parkjunyoung" // 사용자 uid (이후 Auth.uid로 대체 예정)
    private var listener: ListenerRegistration?
    
    func getChatMessages(roomId: String, userId: String) {
            // 이전 리스너가 있으면 해제
            listener?.remove()
            
            listener = db.collection("Chat")
                .document(roomId)
                .collection("Messages")
                .addSnapshotListener { documentSnapshot, error in
                    guard let documents = documentSnapshot?.documents else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    
                    self.chatList = documents.compactMap { document -> Chat? in
                        do {
                            return try document.data(as: Chat.self)
                        } catch {
                            print("메시지 문서를 디코딩하는데 오류가 발생했습니다 : \(error)")
                            return nil
                        }
                    }
                    
                    self.chatList.sort { $0.createAt < $1.createAt }
                    
                    if let id = self.chatList.last?.id {
                        self.lastMessageId = id
                        print("마지막 id = \(self.lastMessageId)")
                    }
                    
//                    let batch = self.db.batch()
//                    
//                    for document in documents {
//                        let messageRef = document.reference
//                        batch.updateData(["readBy": FieldValue.arrayUnion([userId])], forDocument: messageRef)
//                    }
//                    
//                    batch.commit { error in
//                        if let error = error {
//                            print("Batch update failed: \(error)")
//                        } else {
//                            print("User \(userId) added to readBy array in all messages")
//                        }
//                    }
                }
        }
        
        func removeChatMessagesListener() {
            listener?.remove()
            listener = nil
        }
    
    // 메시지 전송
    func sendMessage(text: String, roomId: String, userId: String) {
        let newMessageId = UUID().uuidString // Generate unique ID
        do {
            let newMessage = Chat(id: newMessageId, createAt: Date(), message: text, sender: userId, readBy: [userId])
            try db.collection("Chat").document(roomId).collection("Messages").document(newMessageId).setData(from: newMessage)
            db.collection("Chat").document(roomId)
                .updateData(["lastMessageAt": Date(),
                             "lastMessage": text])
        } catch {
            print("메시지 전송하는데 실패했습니다. \(error)")
        }
    }
}
