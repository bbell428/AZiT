//
//  Emoji.swift
//  Azit
//
//  Created by 홍지수 on 11/21/24.
//

import Foundation

public struct Emoji: Identifiable, Hashable {
    public let id = UUID()
    public let code: [String] // 유니코드 코드포인트 배열
    public let name: String
    public let emoji: String // 유니코드 코드포인트를 변환하여 생성된 이모지 문자
    
    public init(code: [String], name: String) {
        self.code = code
        self.name = name
        self.emoji = Emoji.constructEmoji(from: code)
    }
    
    // 유니코드 코드포인트를 이모지 문자로 변환
    public static func constructEmoji(from codes: [String]) -> String {
        let scalars = codes.compactMap { UInt32($0, radix: 16) }.compactMap { UnicodeScalar($0) }
        return String(String.UnicodeScalarView(scalars))
    }
}

public struct Icons: Codable {
    public let prefix: String
    public let icons: [String: Icon]
}

public struct Icon: Codable {
    public let body: String
}

public class EmojiManager {
    // 단축 코드(shortcode)와 코드포인트(codepoints) 매핑
    private var shortcodeToCodepoints: [String: [String]] = [:]
    
    public init() {
        loadCharJSON()
    }
    
    // chars.json 파일을 로드하여 shortcodeToCodepoints 매핑 생성
    private func loadCharJSON() {
        guard let charURL = Bundle.main.url(forResource: "chars", withExtension: "json") else {
            print("chars.json 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            let data = try Data(contentsOf: charURL)
            let charMap = try JSONDecoder().decode([String: String].self, from: data)
            
            // 코드포인트를 통해 단축 코드 매핑을 역전시켜 shortcode -> [codepoints] 매핑 생성
            for (codepoint, shortcode) in charMap {
                if shortcodeToCodepoints[shortcode] != nil {
                    shortcodeToCodepoints[shortcode]?.append(codepoint)
                } else {
                    shortcodeToCodepoints[shortcode] = [codepoint]
                }
            }
        } catch {
            print("chars.json 파일을 로드하거나 파싱하는 도중 오류가 발생했습니다: \(error)")
        }
    }
    
    // 이모지 이름으로부터 코드포인트 배열을 반환하는 함수
    public func getCodepoints(forName name: String) -> [String]? {
        // 이름을 단축 코드로 변환 (공백을 하이픈으로 대체하고 소문자로 변환)
        let shortcode = name.lowercased().replacingOccurrences(of: " ", with: "-")
        
        return shortcodeToCodepoints[shortcode]
    }
    
    // MARK: - twemoji 불러오는 함수

    public static func getTwemojiURL(for codes: [String]) -> String {
        let unicodeHex = codes.map { $0.lowercased() }.joined(separator: "-")
        // 우선 jsDelivr 최신 버전 시도
        let jsDelivrURL = "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/72x72/\(unicodeHex).png"
        // 만약 jsDelivr에 이미지가 없으면 unpkg 시도
        // let unpkgURL = "https://unpkg.com/twemoji@latest/assets/72x72/\(unicodeHex).png"
        // 이중 CDN 시도 방식은 Swift 코드에서는 직접 구현하기 어렵지만, 우선 jsDelivr를 사용하고 대체 처리를 통해 unpkg를 시도할 수 있습니다.
        return jsDelivrURL
    }
}
