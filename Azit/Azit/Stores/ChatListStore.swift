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

class ChatListStore: ObservableObject {
    private var db = Firestore.firestore() // 파이어베이스
    @Published private(set) var chatList: [ChatRoom] = [] // 채팅방 리스트
    var useruid: String = "parkjunyoung" // 사용자 uid (이후 Auth.uid로 대체 예정)
    private var timer: AnyCancellable? // startTimer()를 주기적으로 호출하기 위한 타이머
    
    init() {
        fetchChatRooms()
    }
    
    deinit {
        timer?.cancel()
    }
    
    // 채팅방 데이터 불러오기
    func fetchChatRooms() {
        //        guard let userUid = Auth.auth().currentUser?.uid else {
        //                    print("로그인 상태 아님")
        //                    return
        //                }
        
        // 채팅collection 에서 로그인한 사용자 uid값이 포함된 문서(= 채팅방)만 가져오게 함
        db.collection("Chat")
        /// participants: 채팅방에 참여된 사용자 uid를 기록하는 배열 공간,
        /// 해당 배열값에서 원하는 uid를 검색해서 참여중인 채팅방을 필터링하기 위함.
            .whereField("participants", arrayContains: "parkjunyoung")
        // 정보 갱신을 위한 리스너
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.chatList = document.compactMap { document -> ChatRoom? in
                    do {
                        return try document.data(as: ChatRoom.self)
                    } catch {
                        print("메시지 문서를 디코딩하는데 오류가 발생했습니다 : \(error)")
                        return nil
                    }
                }
                
                // 이름순서대로 정렬
                // self.chatList.sort { $0.participants.first! < $1.participants.first! }
                
                // 가장 최근에 받은 메시지대로 정렬
                self.chatList.sort { $0.lastMessageAt > $1.lastMessageAt }
                
                //                document.documentChanges.forEach { diff in
                //                    do {
                //                        let chatRoom = try diff.document.data(as: ChatRoom.self)
                //                        switch diff.type {
                //                        case .added: print("New : \(diff.document.data())")
                //                        case .modified: print("Modified : \(diff.document.data())")
                //                        case .removed: print("Removed : \(diff.document.data())")
                //                        }
                //                    } catch {
                //                        print("디코딩 실패")
                //                    }
                //                }
            }
        print("메시지 : \(self.chatList)")
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
