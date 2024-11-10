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
            .order(by: "createAt")
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var updatedMessages: [Chat] = []
                var newLastMessageId: String?
                var messageIdsToUpdate: [String] = []  // Firestore에 일괄 업데이트할 메시지 ID 저장
                
                self.chatList = documents.compactMap { document -> Chat? in
                    do {
                        var chat = try document.data(as: Chat.self)
                        
                        // 마지막 읽은 메시지 이후의 새로운 메시지만 읽음 처리
                        if chat.id != self.lastMessageId, !chat.readBy.contains(userId) {
                            chat.readBy.append(userId)
                            updatedMessages.append(chat)
                            messageIdsToUpdate.append(chat.id ?? "")
                        }
                        
                        newLastMessageId = chat.id  // 메시지 ID를 최신으로 갱신
                        return chat
                    } catch {
                        print("메시지 문서를 디코딩하는데 오류가 발생했습니다 : \(error)")
                        return nil
                    }
                }
                
                // Firestore에 한 번에 업데이트
                if !messageIdsToUpdate.isEmpty {
                    let batch = self.db.batch()
                    
                    messageIdsToUpdate.forEach { messageId in
                        let messageRef = self.db.collection("Chat")
                            .document(roomId)
                            .collection("Messages")
                            .document(messageId)
                        
                        batch.updateData(["readBy": FieldValue.arrayUnion([userId])], forDocument: messageRef)
                    }
                    
                    batch.commit { error in
                        if let error = error {
                            print("읽음 상태 일괄 업데이트 오류: \(error.localizedDescription)")
                        } else {
                            print("\(messageIdsToUpdate.count)개의 메시지가 일괄 읽음 처리되었습니다.")
                        }
                    }
                }
                
                // 메시지 리스트를 시간순으로 정렬
                self.chatList.sort { $0.createAt < $1.createAt }
                
                // 마지막 메시지 ID를 업데이트
                if let id = newLastMessageId {
                    self.lastMessageId = id
                    print("마지막 id = \(self.lastMessageId)")
                }
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
