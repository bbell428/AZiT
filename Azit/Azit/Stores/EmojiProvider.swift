//
//  EmojiProvider.swift
//  Azit
//
//  Created by 홍지수 on 11/21/24.
//

import Foundation

// Emoji 배열을 전달하는 규칙 프로토콜
public protocol EmojiProvider {
    func getAll() -> [Emoji]
}

// EmojiPicker에 이모지 제공
public final class DefaultEmojiProvider: EmojiProvider {
    
    private let emojis: [Emoji]
    
    public init() {
        // icons.json 파싱 결과 name - icon 딕셔너리
        var nameToIconBody: [String: String] = [:]
        // icons.json 파싱
        if let iconsURL = Bundle.main.url(forResource: "icons", withExtension: "json"),
           let iconsData = try? Data(contentsOf: iconsURL),
           let icons = try? JSONDecoder().decode(Icons.self, from: iconsData) {
            nameToIconBody = icons.icons.mapValues { $0.body }
        } else {
            print("Failed to load or parse icons.json")
        }
        
        // chars.json 파싱 결과 code - name 딕셔너리
        var codeToName: [String: String] = [:]
        // chars.json 파싱
        if let charsURL = Bundle.main.url(forResource: "chars", withExtension: "json"),
           let charsData = try? Data(contentsOf: charsURL),
           let chars = try? JSONDecoder().decode([String: String].self, from: charsData) {
            codeToName = chars
        } else {
            print("Failed to load or parse chars.json")
        }
        
        // 이모지 목록 생성
        var tempEmojis: [Emoji] = []
        for (codePoint, name) in codeToName {
            // 코드포인트를 분리하여 배열로 변환 (복합 이모지 처리)
            let codes = codePoint.split(separator: "-").map { String($0) }
            let emoji = Emoji(code: codes, name: name)
            tempEmojis.append(emoji)
        }
        
        // 유니코드 순서대로 정렬
        tempEmojis.sort { (emoji1, emoji2) -> Bool in
            for (code1, code2) in zip(emoji1.code, emoji2.code) {
                if code1 < code2 { return false }
                if code1 > code2 { return true }
            }
            return emoji1.code.count < emoji2.code.count
        }
        
        self.emojis = tempEmojis
    }
    
    public func getAll() -> [Emoji] {
        return emojis
    }
}
