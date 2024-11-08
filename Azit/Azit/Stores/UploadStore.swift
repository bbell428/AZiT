//
//  StoryStore.swift
//  Azit
//
//  Created by 홍지수 on 11/7/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore

@MainActor
class UploadStore: ObservableObject {
    @Published var uploads: [Story] = []
    
    func addStory(_ story: Story) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("Story").document(story.id).setData([
                "id": story.id,
                "userId": story.userId,
                "likes": story.likes,
                "date": Timestamp(date: story.date),
                "latitude": story.latitude,
                "longitude": story.longitude,
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
            var uploads: [Story] = []
            
            for document in querySnapshot.documents {
                do {
                    let upload = try await Story(document: document)
                    uploads.append(upload)
                } catch {
                    print("loadMemos error: \(error.localizedDescription)")
                    return []
                }
            }
            self.uploads = uploads
            
        } catch {
            print("loadMemos error: \(error.localizedDescription)")
            return []
        }
        return uploads
    }
    
    
    // 업로드
    func updateUpload(upload: Story) async {
        let db = Firestore.firestore()
        do {
            try await db.collection("Story").document(upload.id).setData([
                "id": upload.id,
                "userId": upload.userId,
                "likes": upload.likes,
                "date": Timestamp(date: upload.date),
                "latitude": upload.latitude,
                "longitude": upload.longitude,
                "emoji": upload.emoji,
                "image": upload.image,
                "content": upload.content,
                "publishedTargets": upload.publishedTargets,
                "readUsers": upload.readUsers
            ])
            print("업로드 콘텐츠가 성공적으로 수정되었습니다.")
        } catch {
            print("업로드 수정 중 오류 발생: \(error)")
        }
    }
}
