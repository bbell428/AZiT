//
//  ChatListStore.swift
//  Azit
//
//  Created by 박준영 on 11/3/24.
//

import Foundation
import FirebaseFirestore
import Observation
import FirebaseAuth

class ChatListStore: ObservableObject {
    private var db = Firestore.firestore()
    @Published var chatList: [ChatRoom] = []
    //private var auth = Auth.auth()
    
    func fetchChatList() {
//        guard let currentUserID = auth.currentUser?.uid else {
//            print("User is not logged in.")
//            return
//        }
        
        db.collection("Chat")
            .whereField("participants", arrayContains: "parkjunyoung")
            .order(by: "timestamp", descending: true) // 최신 메시지 순으로 정렬
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching chat list: \(error.localizedDescription)")
                    return
                }
                
                // 문서 배열을 ChatRoom 객체로 변환하여 chatList 배열에 저장
                self.chatList = querySnapshot?.documents.compactMap { document in
                    let chatRoomID = document.documentID
                    if chatRoomID.contains("parkjunyoung") {
                        return try? document.data(as: ChatRoom.self)
                    }
                    return nil
                } ?? []
                
                print("채팅방 리스트 : \(chatList)")
            }
    }
}
