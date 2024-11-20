//
//  AlbumStore.swift
//  Azit
//
//  Created by 박준영 on 11/12/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class AlbumStore: ObservableObject {
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @Published var storys: [Story] = []
    @Published var filterUserID: String = ""
    @Published var selectedDate: Date = Date()
    @Published var cacheImages: [String: UIImage] = [:] // 이미지 캐싱
    @Published var loadingImage: Bool = false
    
    @MainActor
    func loadStorysByIds(ids: [String]) async {
        guard !ids.isEmpty else {
            print("친구가 없습니다")
            return
        }

        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("Story")
                .whereField("userId", in: ids).getDocuments()
            
            var stories: [Story] = []
            
            for document in querySnapshot.documents {
                do {
                    let story = try await Story(document: document)
                    stories.append(story)
                } catch {
                    print("loadStories error: \(error.localizedDescription)")
                }
            }
            
            self.storys = stories
            print("친구 게시물 : \(storys)")
            
//            if let firstStory = userInfoStore.friendInfos.first {
//                filterUserID = firstStory.id
//                        print("첫번째 친구 : \(filterUserID)")
//                    }
            
            // 이미지 캐싱 시작
            await cacheStoryImages(stories: self.storys)
        } catch {
            print("loadStories error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func cacheStoryImages(stories: [Story]) async {
        // 로딩 상태 시작
            self.loadingImage = true
        
        let storage = Storage.storage()
        
        for story in stories {
            let imageKey = story.image
            guard !imageKey.isEmpty else { continue }
            
            // 이미 캐싱된 경우 스킵
            if cacheImages[imageKey] != nil { continue }
            
            do {
                // Firebase Storage 참조
                let imageRef = storage.reference().child("image/\(imageKey)")
                let data = try await imageRef.data(maxSize: 1_000_000) // 최대 이미지 크기
                if let image = UIImage(data: data) {
                    // 메인 스레드에서 업데이트
                        self.cacheImages[imageKey] = image
                    print("이미지 캐싱 성공: \(imageKey)")
                } else {
                    print("이미지 변환 실패: \(imageKey)")
                }
            } catch {
                print("이미지 다운로드 실패: \(error.localizedDescription)")
            }
        }
        
        // 로딩 상태 완료
            self.loadingImage = false
    }
    
    func getTimeGroupedStories() -> [(title: String, stories: [Story])] {
        let timeGroups: [(String, (Story) -> Bool)] = [
            ("최근", { $0.isWithin(hours: 24) }),
            ("1일 전", { $0.isWithin(hours: 48) && !$0.isWithin(hours: 24) }),
            ("2일 전", { $0.isWithin(hours: 72) && !$0.isWithin(hours: 48) }),
            ("3일 전", { $0.isWithin(hours: 96) && !$0.isWithin(hours: 72) }),
            ("4일 전", { $0.isWithin(hours: 120) && !$0.isWithin(hours: 96) }),
            ("5일 전", { $0.isWithin(hours: 144) && !$0.isWithin(hours: 120) }),
            ("6일 전", { $0.isWithin(hours: 168) && !$0.isWithin(hours: 144) }),
            ("1주일 전", { $0.isWithin(hours: 336) && !$0.isWithin(hours: 168) }),
            ("2주일 전", { $0.isWithin(hours: 672) && !$0.isWithin(hours: 336) }),
            ("3주일 전", { $0.isWithin(hours: 1008) && !$0.isWithin(hours: 672) }),
            ("4주일 전", { $0.isWithin(hours: 1344) && !$0.isWithin(hours: 1008) }),
            ("그 외", { !$0.isWithin(hours: 1344) })
        ]

        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(selectedDate)
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        let selectedDayEnd = calendar.date(byAdding: .day, value: 1, to: selectedDayStart) ?? selectedDayStart

        return timeGroups.compactMap { group in
            let filteredStories: [Story]

            if isToday {
                if filterUserID == "000AzitALLFriends" {
                    // 모든 storys 반환 (오늘의 이야기만 시간 그룹으로 필터)
                    filteredStories = storys.filter { story in
                        group.1(story)
                    }
                } else {
                    // 특정 사용자의 storys만 필터링
                    filteredStories = storys.filter { story in
                        story.userId == filterUserID && group.1(story)
                    }
                }
            } else {
                if filterUserID == "000AzitALLFriends" {
                    // 모든 storys 중 특정 날짜만 반환
                    filteredStories = storys.filter { story in
                        (selectedDayStart...selectedDayEnd).contains(story.date)
                    }
                } else {
                    // 특정 사용자의 storys 중 특정 날짜만 반환
                    filteredStories = storys.filter { story in
                        story.userId == filterUserID &&
                        (selectedDayStart...selectedDayEnd).contains(story.date)
                    }
                }
            }

            let title: String
            if isToday {
                title = group.0
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "YYYY년 M월 d일"
                title = formatter.string(from: selectedDate)
            }

            return filteredStories.isEmpty ? nil : (title, filteredStories.sorted(by: { $0.date > $1.date }))
        }
    }
}
