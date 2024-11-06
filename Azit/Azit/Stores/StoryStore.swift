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

class StoryStore: ObservableObject {
    @Published var stories: [Story] = []
    
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
                    print("loadMemos error: \(error.localizedDescription)")
                    
                    return []
                }
            }
            
            self.stories = stories
        } catch {
            print("loadMemos error: \(error.localizedDescription)")
            
            return []
        }
        
        return stories
    }
}
