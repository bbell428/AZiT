//
//  Untitled.swift
//  Azit
//
//  Created by 김종혁 on 12/29/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // 채팅방에 들어갈 때, 해당 유저가 채팅방에 들어와 있는 지 확인
    func updateChatStatus(userId: String, chatId: String, isActive: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://deafening-delinda-bbell428-f7f2eaff.koyeb.app/update-chat-status") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ChatStatusRequest(userId: userId, chatId: chatId, isActive: isActive)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Server error", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success("Status updated successfully"))
        }.resume()
    }
    
    // 채팅방 상태를 확인하는 함수 (Bool 반환)
    func checkChatStatus(userId: String, chatId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://deafening-delinda-bbell428-f7f2eaff.koyeb.app/check-chat-status?userId=\(userId)&chatId=\(chatId)") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            
            // 서버 응답 확인
            if let data = data, let statusResponse = try? JSONDecoder().decode([String: Bool].self, from: data),
               let isActive = statusResponse["isActive"] {
                completion(isActive)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    // 채팅방 상태를 확인하고, 조건에 맞으면 false를 반환하는 함수
    func updateChatStatusIfNeeded(userId: String, chatId: String, completion: @escaping (Bool) -> Void) {
        checkChatStatus(userId: userId, chatId: chatId) { isActive in
            DispatchQueue.main.async {
                if isActive {
                    print("User is active in chat")
                    // 상대방이 채팅방에 접속 중이면 true를 반환
                    completion(true)
                } else {
                    print("User is not active in chat")
                    // 상대방이 채팅방에 접속 중이 아니면 false 반환
                    completion(false)
                }
            }
        }
    }
}
