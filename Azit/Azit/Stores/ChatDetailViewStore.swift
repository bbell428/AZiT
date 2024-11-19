import Foundation
import FirebaseFirestore
import Observation
import FirebaseAuth
import Combine
import SwiftUICore

class ChatDetailViewStore: ObservableObject {
    @EnvironmentObject var authManager: AuthManager
    @Published private(set) var chatList: [Chat] = [] // 채팅방 리스트
    @Published private(set) var lastMessageId: String = ""
    private var db = Firestore.firestore() // 파이어베이스
    private var listener: ListenerRegistration?
    
    // 메시지 리스너 제거
    func removeChatMessagesListener() {
        listener?.remove()
        listener = nil
    }
    
    func getChatMessages(roomId: String, userId: String, friendId: String) {
        // 기존 리스너 해제
        listener?.remove()
        
        // 새 리스너 등록
        listener = db.collection("Chat")
            .document(roomId)
            .collection("Messages")
            .order(by: "createAt")
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                var messageIdsToUpdate: [String] = []  // 읽음 상태 업데이트용 ID 리스트
                var unreadCount = 0                   // 읽지 않은 메시지 카운트
                var newLastMessageId: String?         // 가장 최근 메시지 ID
                
                self.chatList = documents.compactMap { document -> Chat? in
                    do {
                        var chat = try document.data(as: Chat.self)
                        
                        // 읽지 않은 메시지 처리
                        if !chat.readBy.contains(userId) {
                            chat.readBy.append(userId)
                            messageIdsToUpdate.append(chat.id ?? "")
                        }
                        
                        // 읽지 않은 메시지 카운트 증가
                        if !chat.readBy.contains(friendId) {
                            unreadCount += 1
                        }
                        
                        newLastMessageId = chat.id
                        return chat
                    } catch {
                        print("메시지 디코딩 오류: \(error)")
                        return nil
                    }
                }
                
                // 읽음 상태 업데이트 (배치 처리)
                if !messageIdsToUpdate.isEmpty {
                    self.updateReadStatus(roomId: roomId, messageIds: messageIdsToUpdate, userId: userId)
                }
                
                // Firestore의 notReadCount 업데이트
                self.updateNotReadCount(roomId: roomId, userId: friendId, count: unreadCount)
                
                // 메시지 리스트 정렬
                self.chatList.sort { $0.createAt < $1.createAt }
                
                // 마지막 메시지 ID 업데이트
                if let id = newLastMessageId {
                    self.lastMessageId = id
                }
            }
    }

    func updateReadStatus(roomId: String, messageIds: [String], userId: String) {
        let batch = db.batch()
        for messageId in messageIds {
            let messageRef = db.collection("Chat")
                .document(roomId)
                .collection("Messages")
                .document(messageId)
            batch.updateData(["readBy": FieldValue.arrayUnion([userId])], forDocument: messageRef)
        }
        batch.commit { error in
            if let error = error {
                print("읽음 상태 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("\(messageIds.count)개의 메시지가 읽음 처리되었습니다.")
            }
        }
    }

    func updateNotReadCount(roomId: String, userId: String, count: Int) {
        let chatRoomDocumentPath = db.collection("Chat").document(roomId)
        
        // 바로 업데이트 또는 병합 (읽기 요청 제거)
        chatRoomDocumentPath.setData([
            "notReadCount": [userId: count]
        ], merge: true) { error in
            if let error = error {
                print("notReadCount 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("notReadCount 업데이트 성공")
            }
        }
    }
    
    // MARK: - 메시지 전송
    func sendMessage(text: String, myId: String, friendId: String, storyId: String = "") {
        let newMessageId = UUID().uuidString
        let chatRoomId = generateChatRoomId(userId1: myId, userId2: friendId)
        let messageDocumentPath = db.collection("Chat").document(chatRoomId).collection("Messages").document(newMessageId)
        let chatRoomDocumentPath = db.collection("Chat").document(chatRoomId)
        
        let newMessage = Chat(id: newMessageId, createAt: Date(), message: text, sender: myId, readBy: [myId], storyId: storyId)
        
        do {
            // 1. 메시지 저장
            try messageDocumentPath.setData(from: newMessage)
            
            // 2. 채팅방의 마지막 메시지 및 notReadCount 업데이트
            chatRoomDocumentPath.getDocument { document, error in
                if let error = error {
                    print("문서 확인 중 오류 발생: \(error)")
                    return
                }
                
                let fieldKey = "notReadCount.\(friendId)"
                var updateData: [String: Any] = [
                    "lastMessage": text,
                    "lastMessageAt": Date(),
                    "participants": [myId, friendId],
                    "roomId": chatRoomId
                ]
                
                if let document = document, document.exists {
                    // 문서가 이미 존재하는 경우 -> updateData
                    chatRoomDocumentPath.updateData(updateData) { error in
                        if let error = error {
                            print("업데이트 실패: \(error)")
                        } else {
                            // 존재하는 경우에는 friendId의 notReadCount 값을 +1 증가
                            chatRoomDocumentPath.updateData([
                                fieldKey: FieldValue.increment(Int64(1))
                            ]) { error in
                                if let error = error {
                                    print("notReadCount 업데이트 실패: \(error)")
                                } else {
                                    print("notReadCount가 증가되었습니다.")
                                }
                            }
                        }
                    }
                } else {
                    // 문서가 존재하지 않는 경우 -> setData
                    updateData["notReadCount"] = [friendId: 1, myId: 0] // 초기화
                    chatRoomDocumentPath.setData(updateData) { error in
                        if let error = error {
                            print("새 문서 생성 실패: \(error)")
                        } else {
                            print("새 문서 생성 및 notReadCount 초기화 완료.")
                        }
                    }
                }
            }
        } catch {
            print("메시지 전송 실패: \(error)")
        }
    }
    
    // MARK: - 대화방 ID 이름 결정
    func generateChatRoomId(userId1: String, userId2: String) -> String {
        return userId1 < userId2 ? "\(userId1)_\(userId2)" : "\(userId2)_\(userId1)"
    }
}
