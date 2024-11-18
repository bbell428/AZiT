//
//  AlbumStore.swift
//  Azit
//
//  Created by 박준영 on 11/12/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore
import SwiftUICore
import FirebaseStorage

class AlbumStore: ObservableObject {
    @Published var storys: [Story] = []
    @Published var filterUserID: String = ""
    @Published var selectedDate: Date = Date()
    @Published var cacheImages: [String: UIImage] = [:]
    
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
            
            self.storys = stories.sorted { $0.userId > $1.userId }
            print("친구 게시물 : \(storys)")
            
            filterUserID = self.storys.first?.userId ?? ""
            print("첫번째 친구 : \(filterUserID)")
        } catch {
            print("loadStories error: \(error.localizedDescription)")
        }
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
            
            // 만약 날짜가 오늘이라면, 최근/1일/1주일.. 로직
            if isToday {
                filteredStories = storys.filter { story in
                    story.userId == filterUserID && group.1(story)
                }
                // 만약 날짜가 오늘이 아니라면, 해당하는 날짜만 가져오기
            } else {
                filteredStories = storys.filter { story in
                    story.userId == filterUserID &&
                    (selectedDayStart...selectedDayEnd).contains(story.date)
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
