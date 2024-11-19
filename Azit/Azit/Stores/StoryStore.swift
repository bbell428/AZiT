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
    @ObservedObject var userInfoStore: UserInfoStore = UserInfoStore()
    @ObservedObject var photoImageStore: PhotoImageStore = PhotoImageStore()
    
    @Published var createdStory: Story?
    
    private var listener: ListenerRegistration?
    
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
    
    // MARK: - Widget에서 사용 할 최신 story listener
    func loadRecentStoryByIds(ids: [String]) async throws -> AzitWidgetData {
        // 기존 리스너 제거
        listener?.remove()
        
        let db = Firestore.firestore()
        var stories: [Story] = []
        var hasCalledContinuation = false // Continuation 중복 호출 방지 플래그

        // 새 리스너 등록
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AzitWidgetData, Error>) in
            guard !ids.isEmpty else {
                continuation.resume(throwing: NSError(domain: "InvalidInput", code: -1, userInfo: [NSLocalizedDescriptionKey: "IDs array is empty."]))
                return
            }
            
            listener = db.collection("Story")
                .whereField("userId", in: ids as [Any])
                .addSnapshotListener { documentSnapshot, error in
                    if hasCalledContinuation { return } // Continuation이 이미 호출된 경우 실행하지 않음
                    
                    if let error = error {
                        hasCalledContinuation = true
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let documents = documentSnapshot?.documents else {
                        hasCalledContinuation = true
                        continuation.resume(throwing: NSError(domain: "NoDocuments", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found for the given IDs."]))
                        return
                    }
                    
                    Task {
                        do {
                            for document in documents {
                                let story = try await Story(document: document)
                                stories.append(story)
                            }
                            
                            // 최신 메시지 기준으로 정렬
                            stories.sort { $0.date > $1.date }
                            
                            if let recentStory = stories.first {
                                var azitWidgetData = AzitWidgetData() // 반환할 데이터 객체 생성
                                azitWidgetData.recentStory = recentStory
                                
                                // 사용자 정보 가져오기
                                if let userInfo = try await self.userInfoStore.loadUsersInfoByEmail(userID: [recentStory.userId]).first {
                                    azitWidgetData.userInfo = userInfo
                                } else {
                                    hasCalledContinuation = true
                                    continuation.resume(throwing: NSError(domain: "UserInfoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load user info."]))
                                    return
                                }
                                
                                if recentStory.image != "" {
                                    // 이미지 가져오기
                                    let image = await self.photoImageStore.loadImageAsync(imageName: recentStory.id)
                                    azitWidgetData.image = image
                                    
                                    hasCalledContinuation = true
                                    continuation.resume(returning: azitWidgetData) // 작업 완료 시 데이터 반환
                                } else {
                                    azitWidgetData.image = UIImage(systemName: "xmark.app")
                                }
                            } else {
                                hasCalledContinuation = true
                                continuation.resume(throwing: NSError(domain: "NoRecentStory", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recent story found."]))
                            }
                        } catch {
                            hasCalledContinuation = true
                            continuation.resume(throwing: error)
                        }
                    }
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


// 추 후 컴포넌트로 빼기
struct SpeechBubbleView: View {
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .padding(5)
                .padding([.leading, .trailing], 10)
                .foregroundStyle(.white)
        }
        .background(
            SpeechBubbleTail()
                .stroke(Color.accent, lineWidth: 2)
                .background(SpeechBubbleTail().fill(Color.accent))
                .padding(.horizontal, 10)
        )
    }
}

struct SpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 8, height: 8))
        
        path.move(to: CGPoint(x: rect.midX - 3, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + 8))
        path.addLine(to: CGPoint(x: rect.midX + 3, y: rect.maxY))
        
        path.closeSubpath()
        
        return path
    }
}
