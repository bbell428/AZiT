//
//  EmojiSheetView.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

import SwiftUI

// 이모지 선택 뷰
struct EmojiSheetView: View {
    @Binding var show: Bool
    @Binding var txt: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(self.getEmojiList(), id: \.self) { row in
                        HStack(spacing: 25) {
                            ForEach(row, id: \.self) { codePoint in
                                Button(action: {
                                    let emoji = String(UnicodeScalar(codePoint)!)
                                    self.txt = emoji // 이모지를 바인딩에 전달
                                }) {
                                    ZStack {
                                        if let scalar = UnicodeScalar(codePoint),
                                           scalar.properties.isEmoji {
                                            Text(String(scalar))
                                                .font(.system(size: 55))
                                                .frame(width: 70, height: 70)
                                                .background(txt == String(scalar) ? Color.accentColor.opacity(0.2) : Color.clear) // 선택 상태 배경색
                                                .cornerRadius(10)
                                        } else {
                                            Text("")
                                                .frame(width: 70, height: 70)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 40)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
            .background(Color.white)
            .cornerRadius(25)
            
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
    
    func getEmojiList() -> [[Int]] {
        var emojis: [[Int]] = []
        for i in stride(from: 0x1F601, to: 0x1F64F, by: 4) {
            var temp: [Int] = []
            for j in i...i+3 {
                temp.append(j)
            }
            emojis.append(temp)
        }
        return emojis
    }
}
