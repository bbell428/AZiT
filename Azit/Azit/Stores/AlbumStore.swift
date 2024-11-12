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
    
    @MainActor
    func loadStorysByIds(ids: [String]) async {
        guard !ids.isEmpty else {
            print("친구가 없습니다")
            return
        }
        
        let db = Firestore.firestore()
        
        // 기존 storys의 id 목록을 추출하여 중복 체크에 사용
        let existingStoryIds = Set(storys.map { $0.id })
        
        do {
            let querySnapshot = try await db.collection("Story")
                .whereField("userId", in: ids).getDocuments()
            
            var newStories: [Story] = []
            
            for document in querySnapshot.documents {
                do {
                    let story = try await Story(document: document)
                    
                    // 중복된 id가 아니라면 추가
                    if !existingStoryIds.contains(story.id) {
                        newStories.append(story)
                    }
                    
                } catch {
                    print("loadStories error: \(error.localizedDescription)")
                }
            }
            
            // 새로 추가된 storys만 결합 및 정렬
            self.storys.append(contentsOf: newStories)
            self.storys.sort { $0.date > $1.date }
            
        } catch {
            print("loadStories error: \(error.localizedDescription)")
        }
        
        print("친구 게시물 : \(storys)")
    }
}
