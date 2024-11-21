//
//  Twemoji.swift
//  Azit
//
//  Created by 홍지수 on 11/20/24.
//

import SwiftUI

/// Twemoji Helper: 유니코드 기반 Twemoji URL 생성
func getTwemojiURL(for unicode: String) -> String {
    let baseURL = "https://twemoji.maxcdn.com/v/latest/72x72/"
    return "\(baseURL)\(unicode).png"
}

/// Twemoji Helper: 문자열에서 이모지 추출
func extractEmojis(from text: String) -> [String] {
    var emojis: [String] = []
    for scalar in text.unicodeScalars {
        if scalar.properties.isEmoji {
            emojis.append(String(scalar))
        }
    }
    return emojis
}

/// 이모지 렌더링 SwiftUI 뷰
struct TwemojiRenderView: View {
    let text: String // 이모지가 포함된 텍스트
    @State private var twemojiImages: [String: UIImage] = [:] // 유니코드별 이미지 캐싱

    var body: some View {
        HStack {
            // 텍스트에서 추출한 이모지를 순회
            ForEach(extractEmojis(from: text), id: \.self) { emoji in
                if let unicode = emoji.unicodeScalars.first?.value {
                    let unicodeHex = String(format: "%x", unicode) // 유니코드 값을 16진수로 변환
                    if let image = twemojiImages[unicodeHex] {
                        // Twemoji 이미지를 로드했으면 표시
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        // 이미지가 로드되지 않았으면 텍스트로 표시
                        Text(emoji)
                            .font(.largeTitle)
                            .onAppear {
                                loadTwemojiImage(for: unicodeHex) { image in
                                    if let image = image {
                                        DispatchQueue.main.async {
                                            twemojiImages[unicodeHex] = image
                                        }
                                    }
                                }
                            }
                    }
                } else {
                    // 유니코드 값이 없는 경우 텍스트로 출력
                    Text(emoji)
                        .font(.largeTitle)
                }
            }
        }
    }

    /// Twitter CDN에서 Twemoji 이미지를 로드
    private func loadTwemojiImage(for unicode: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = getTwemojiURL(for: unicode)
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}
