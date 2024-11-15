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
    @Published var createdStory: Story?
    
    // MARK: - 게시물 추가
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
    
    // MARK: - User ID로 최근 게시물 받아오기
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
    
    // MARK: - 사용자 본인의 ID를 가지고 친구들의 story중 가장 최신글 1개를 가져오기
    @MainActor
    func loadFriendsRecentStoryByIds(ids: [String]) async throws -> Story {
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("Story")
                .whereField("userId", in: ids)
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
    
    // MARK: - story 데이터 UserDefault에 전달
    func updateSharedUserDefaults(recentStory: Story) {
        if let sharedDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget") {
            // Story 객체를 Data로 변환
            do {
                let encoder = JSONEncoder()
                let encodedStory = try encoder.encode(recentStory)
                sharedDefaults.set(encodedStory, forKey: "recentStory")
                print("유저 디폴트에 스토리 데이터를 저장하였습니다.")
            } catch {
                print("스토리 인코딩 실패: \(error)")
            }
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
