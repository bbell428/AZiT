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
import Combine
import SwiftUICore

class ChatListStore: ObservableObject {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Published private(set) var chatRoomList: [ChatRoom] = [] // 채팅방 리스트
    private var db = Firestore.firestore() // 파이어베이스
    private var timer: AnyCancellable? // startTimer()를 주기적으로 호출하기 위한 타이머
    private var listener: ListenerRegistration? // 리스너 저장용 변수
    
    //    init() {
    //        fetchChatRooms()
    //    }
    
    deinit {
        timer?.cancel()
    }
    
    // 채팅방 데이터 불러오기
    func fetchChatRooms(userId: String) {
        print("채팅방 데이터 불러오기")
        
        // 기존 리스너가 있으면 제거
        listener?.remove()
        
        // 새로운 리스너 등록
        listener = db.collection("Chat")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                self.chatRoomList = documents.compactMap { document -> ChatRoom? in
                    do {
                        return try document.data(as: ChatRoom.self)
                    } catch {
                        print("채팅방 디코딩 오류: \(error)")
                        return nil
                    }
                }
                
                // 최신 메시지 기준으로 정렬
                self.chatRoomList.sort { $0.lastMessageAt > $1.lastMessageAt }
                print("채팅방 목록: \(self.chatRoomList)")
            }
    }
    
    // 리스너 중단 메서드
    func removeChatRoomsListener() {
        listener?.remove()
        listener = nil
    }
    
    // 날짜를 포맷하는 함수
    func formatDate(_ date: Date, currentDate: Date) -> String {
        let calendar = Calendar.current
        
        // 날짜 차이 계산
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: currentDate)
        
        if let dayDifference = components.day, dayDifference >= 1 {
            // 하루 이상 차이가 나면 "n일 전" 형식으로 표시
            return "\(dayDifference)일 전"
        } else if let hourDifference = components.hour, hourDifference >= 1 {
            // 1시간 이상 차이가 나면 "n시간 전" 형식으로 표시
            return "\(hourDifference)시간 전"
        } else if let minuteDifference = components.minute {
            // 1시간 미만 차이
            if minuteDifference >= 1 {
                // 1분 이상 차이가 나면 "n분 전" 형식으로 표시
                return "\(minuteDifference)분 전"
            } else {
                // 1분 미만일 경우
                return "방금 전" // 또는 원하는 다른 형식으로 표시
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        dateFormatter.dateFormat = "a h:mm" // 예시, "오후 1:10"
        return dateFormatter.string(from: date)
    }
    
    // 타이머 시작
    func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send() // 변경 사항을 알림
            }
    }
    
    // 타이머 중지
    func stopTimer() {
        timer?.cancel() // 타이머 취소
        timer = nil // 타이머를 nil로 설정하여 메모리 해제
    }
}
