//
//  qwer.swift
//  Azit
//
//  Created by 김종혁 on 11/20/24.
//

import SwiftUI

struct TestFCM: View {
    let title = "아지트"
    let body2 = "캬아~~ FC"
    @AppStorage("fcmToken") private var targetToken: String = ""
    
    var body: some View {
        Button {
            sendNotificationToServer(title: title, body: body2, token: targetToken)
        } label: {
            Text("qweeqw")
        }

    }
    func sendNotificationToServer(title: String, body: String, token: String) {
        // Node.js 서버 URL
        let url = URL(string: "https://deafening-delinda-bbell428-f7f2eaff.koyeb.app/send-notification")!
        
        // 요청 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문 설정
        let payload: [String: Any] = [
            "title": title,
            "body": body,
            "token": token
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        // HTTP 요청 실행
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
        }
        task.resume()
    }
}

