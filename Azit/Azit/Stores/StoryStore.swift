//
//  StoryStore.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore
import SwiftUICore
import FirebaseStorage

class StoryStore: ObservableObject {
    @Published var storys: [Story] = []
    @Published var createdStory: Story?
    
    func addStory(_ story: Story) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("Story").document(story.id).setData([
                "userId": story.userId,
                "likes": story.likes,
                "date": Timestamp(date: story.date),
                "latitude": story.latitude,
                "longitude": story.longitude,
                "address": story.address,
                "emoji": story.emoji,
                "image": story.image,
                "content": story.content,
                "publishedTargets": story.publishedTargets,
                "readUsers": story.readUsers
            ])
            
            print("Story successfully written!")
        } catch {
            print("Error writing story: \(error)")
        }
    }
    
    @MainActor
    func loadStorysByIds(ids: [String]) async throws -> [Story] {
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
                    
                    return []
                }
            }
            
            self.storys = stories.sorted { $0.date > $1.date }
        } catch {
            print("loadStories error: \(error.localizedDescription)")
            
            return []
        }
        
        return storys
    }
    
    @MainActor
    func loadRecentStoryById(id: String) async throws -> Story {
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("Story")
                .whereField("userId", isEqualTo: id)
                .order(by: "date", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            if let document = querySnapshot.documents.first {
                return try await Story(document: document)
            } else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Story not found"])
            }
            
        } catch {
            print("loadStories error: \(error.localizedDescription)")
            throw error
        }
    }
}

// 메인 뷰에서 작성된 story 임시 저장 class
class StoryDraft: ObservableObject {
    @Published var id: String = UUID().uuidString
    @Published var userId: String = "" // 작성자 uid
    
    @Published var likes: [String] = [] // 좋아요를 누른 사람 (유저 uid)
    @Published var date: Date = Date() // 작성날짜
    @Published var latitude: Double = 0.0 // 위도
    @Published var longitude: Double = 0.0 // 경도
    @Published var address: String = "" // 주소
    
    @Published var emoji: String = "" // 이모지
    @Published var image: String = "" // 이미지
    @Published var content: String = "" // 작성글
    
    @Published var publishedTargets: [String] = [] // 공개 대상 (유저 uid)
    @Published var readUsers: [String] = [] // 게시글을 읽은 사람 (유저 uid)
}
