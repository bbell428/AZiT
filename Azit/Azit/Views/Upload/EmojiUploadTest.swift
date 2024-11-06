//
//  EmojiUploadView.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//

import SwiftUI
import EmojiPicker

//struct EmojiUploadView: View {
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Spacer()
//                NavigationLink(destination: CameraView()) {
//                    Text("Open Camera")
//                        .font(.title)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                Spacer()
//            }
//        }
//    }
//}

struct EmojiUploadTest: View {
    
    @State var message = ""
    @State var selectedEmoji: Emoji?
    @State var displayEmojiPicker: Bool = false
    @State var isUploading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 상태 업로드 버튼
                VStack {
                    Button(action: {
                        displayEmojiPicker = true
                    }) {
                        Text("Upload My Status")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                // 팝업창 모달
                if displayEmojiPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            displayEmojiPicker = false // 배경 터치 시 닫기
                        }
                    
                    EmojiView(message: $message, selectedEmoji: $selectedEmoji)
                }
            }
            .animation(.easeInOut, value: displayEmojiPicker)
        }
    }
}

#Preview {
    EmojiUploadTest()
}

