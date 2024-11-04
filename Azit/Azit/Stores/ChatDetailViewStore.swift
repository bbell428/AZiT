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

class ChatDetailViewStore: ObservableObject {
    private var db = Firestore.firestore() // 파이어베이스
    @Published private(set) var chatList: [Chat] = [] // 채팅방 리스트
    var useruid: String = "chu" // 사용자 uid (이후 Auth.uid로 대체 예정)
    
//    init () {
//        getChatMessages(roomId: "god_parkjunyoung")
//    }
    
    func getChatMessages(roomId: String) {
        db.collection("Chat")
            .document(roomId)
            .collection("Messages")
            .order(by: "createAt", descending: false) // 오름차순 정렬
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
            }
    }
    
    // 메시지 전송
    func sendMessage(text: String, roomId: String) {
        do {
            let newMessage = Chat(id: "\(UUID())", createAt: Date(), message: text, sender: "chu")
            try db.collection("Chat").document(roomId).collection("Messages").document().setData(from: newMessage)
        } catch {
            print("메시지 전송하는데 실패했습니다. \(error)")
        }
    }
}
