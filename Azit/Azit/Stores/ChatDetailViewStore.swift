import Foundation
import FirebaseStorage
import _PhotosUI_SwiftUI
import FirebaseFirestore
import Observation
import FirebaseAuth
import Combine
import SwiftUICore

class ChatDetailViewStore: ObservableObject {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Published private(set) var chatList: [Chat] = [] // 채팅 메시지 리스트
    @Published private(set) var lastMessageId: String = ""
    @Published private(set) var totalUnreadCount: Int = 0 // 전체 안 읽은 메시지 개수
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var imageSelection: PhotosPickerItem? = nil // 갤러리에서 선택한 이미지
    //@Published var selectedImage: UIImage? = nil          // 선택된 이미지를 UIImage로 변환
    @Published var isUploading: Bool = false              // 업로드 상태
    @Published var isLoadChatList: Bool = false           // 채팅방 리스트를 불러오는중인가?
    @Published var isChoicePhoto: Bool = false            // 사진에서 이미지를 선택했는가?
    
    // MARK: - 메시지를 날짜별로 그룹화
    func groupMessagesByDate(_ messages: [Chat]) -> [String: [Chat]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return Dictionary(grouping: messages) { chat in
            formatter.string(from: chat.createAt)
        }
    }
    
    // MARK: - 이미지 선택 및 처리
//    func handleImageSelection() async {
//        guard let selectedItem = imageSelection else { return }
//        
//        do {
//            // 선택한 이미지를 로드
//            if let data = try await selectedItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
//                // 이미지 크기 조정
//                self.selectedImage = resizeImage(image: uiImage, targetSize: CGSize(width: 300, height: 400))
//                print("이미지 로드 성공")
//            }
//        } catch {
//            print("이미지를 로드할 수 없습니다: \(error.localizedDescription)")
//        }
//    }
    
    // MARK: - 이미지 크기 조정
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // MARK: - Firebase Storage에 이미지 업로드
    func uploadImage(myId: String, friendId: String, selectedImage: UIImage?) async {
        guard let image = selectedImage else {
            print("업로드할 이미지가 없습니다.")
            return
        }

        isUploading = true

        // 이미지를 JPEG 데이터로 압축
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("이미지 압축 실패")
            isUploading = false
            return
        }
        
        let imageUUID: String = UUID().uuidString
        let storageRef = Storage.storage().reference().child("image/\(imageUUID)")

        do {
            // Firebase Storage에 데이터 업로드
            let _ = try await storageRef.putDataAsync(imageData, metadata: nil)

            // 업로드 성공: 다운로드 URL 가져오기
            let imageUrl = try await storageRef.downloadURL()

            print("이미지 업로드 성공, URL: \(imageUrl)")
            
            // Firestore에 이미지 메시지 전송
            await sendMessage(text: "사진", myId: myId, friendId: friendId, uploadImage: imageUUID)
        } catch {
            print("이미지 업로드 실패: \(error.localizedDescription)")
            isUploading = false
        }

        isUploading = false
    }
    
    // MARK: 이미지를 사진 앨범에 저장하는 함수
    func saveImageToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: - 메시지 리스너 제거
    func removeChatMessagesListener() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - 메시지 가져오기
    func getChatMessages(roomId: String, userId: String) {
        // 기존 리스너 제거
        listener?.remove()
        self.isLoadChatList = true
        
        listener = db.collection("Chat")
            .document(roomId)
            .collection("Messages")
            .order(by: "createAt")
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var newLastMessageId: String?
                var messageIdsToUpdate: [String] = [] // Firestore에 업데이트할 메시지 ID 저장
                var readByUpdatedMessages: [Chat] = [] // 읽음 처리할 메시지 리스트
                
                self.chatList = documents.compactMap { document -> Chat? in
                    do {
                        var chat = try document.data(as: Chat.self)
                        
                        // 메시지 읽음 처리 로직
                        if chat.id != self.lastMessageId, !chat.readBy.contains(userId) {
                            chat.readBy.append(userId)
                            messageIdsToUpdate.append(chat.id ?? "")
                            readByUpdatedMessages.append(chat)
                        }
                        
                        newLastMessageId = chat.id // 마지막 메시지 ID 업데이트
                        return chat
                    } catch {
                        print("메시지 문서를 디코딩하는데 오류가 발생했습니다: \(error)")
                        return nil
                    }
                }
                
                // Firestore에 읽음 처리 업데이트
                if !messageIdsToUpdate.isEmpty {
                    self.updateReadStatus(roomId: roomId, messageIds: messageIdsToUpdate, userId: userId)
                }
                
                // 메시지 리스트를 시간순으로 정렬
                self.chatList.sort { $0.createAt < $1.createAt }
                
                // 마지막 메시지 ID 업데이트
                if let id = newLastMessageId {
                    self.lastMessageId = id
                }
                
                self.isLoadChatList = false
            }
    }
    
    // MARK: - 메시지 전송
    func sendMessage(text: String, myId: String, friendId: String, storyId: String = "", uploadImage: String = "", replyMessage: String = "") async {
        let newMessageId = UUID().uuidString
        let roomId = generateChatRoomId(userId1: myId, userId2: friendId)
        
        do {
            let newMessage = Chat(id: newMessageId, createAt: Date(), message: text, sender: myId, readBy: [myId], storyId: storyId, uploadImage: uploadImage, replyMessage: replyMessage)
            
            let batch = db.batch()
            
            let messageRef = db.collection("Chat").document(roomId).collection("Messages").document(newMessageId)
            let chatRoomRef = db.collection("Chat").document(roomId)
            
            // 메시지 저장
            try batch.setData(from: newMessage, forDocument: messageRef)
            
            // 채팅방 정보 업데이트 (merge: true)
            let chatRoomSnapshot = try await chatRoomRef.getDocument()  // 현재 채팅방 정보를 가져옴
            var unreadCount = chatRoomSnapshot.data()?["unreadCount"] as? [String: Int] ?? [String: Int]()
            
            // 상대방이 이미 메시지를 읽었는지 확인
            if unreadCount[friendId] == nil {
                unreadCount[friendId] = 0 // 상대방의 unreadCount 초기화
            }
            
            // 읽지 않은 경우만 카운트 증가
            if !newMessage.readBy.contains(friendId) {
                unreadCount[friendId] = (unreadCount[friendId] ?? 0) + 1
            }
            
            // 채팅방 정보 업데이트 (merge: true)
            batch.setData([
                "lastMessage": text,
                "lastMessageAt": Date(),
                "participants": [myId, friendId],
                "roomId": roomId,
                "unreadCount": unreadCount
            ], forDocument: chatRoomRef, merge: true)
            
            batch.commit { error in
                if let error = error {
                    print("메시지 전송 실패: \(error)")
                } else {
                    print("메시지 전송 성공!")
                }
            }
        } catch {
            print("메시지 전송 실패: \(error)")
        }
    }
    
    // MARK: - 메시지 읽음 처리
    private func updateReadStatus(roomId: String, messageIds: [String], userId: String) {
        let batch = db.batch()
        let roomRef = db.collection("Chat").document(roomId)
        var unreadCountToReduce = 0
        
        messageIds.forEach { messageId in
            let messageRef = db.collection("Chat").document(roomId).collection("Messages").document(messageId)
            unreadCountToReduce += 1
            
            // 읽음 처리
            batch.updateData(["readBy": FieldValue.arrayUnion([userId])], forDocument: messageRef)
        }
        
        // 내 unreadCount 감소
        batch.updateData([
            "unreadCount.\(userId)": FieldValue.increment(Int64(-unreadCountToReduce))
        ], forDocument: roomRef)
        
        batch.commit { error in
            if let error = error {
                print("읽음 처리 실패: \(error.localizedDescription)")
            } else {
                print("읽음 처리 완료: \(messageIds.count)개의 메시지")
            }
        }
    }
    
    // MARK: - 채팅방 리스트 가져오기
    func fetchChatRooms(userId: String) {
        db.collection("Chat")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let chatRooms = documents.compactMap { document -> ChatRoom? in
                    do {
                        return try document.data(as: ChatRoom.self)
                    } catch {
                        print("채팅방 디코딩 실패: \(error)")
                        return nil
                    }
                }
                
                // 내 unreadCount만 계산
                let totalUnreadCount = chatRooms.reduce(0) { $0 + ($1.unreadCount[userId] ?? 0) }
                
                DispatchQueue.main.async {
                    self.totalUnreadCount = totalUnreadCount
                }
            }
    }
    
    // MARK: - 대화방 ID 생성
    func generateChatRoomId(userId1: String, userId2: String) -> String {
        return userId1 < userId2 ? "\(userId1)_\(userId2)" : "\(userId2)_\(userId1)"
    }
}
