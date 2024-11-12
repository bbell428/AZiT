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
}
