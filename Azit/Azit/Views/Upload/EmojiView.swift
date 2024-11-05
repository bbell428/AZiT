//
//  EmojiView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI
//import EmojiPicker

struct EmojiView : View {
    @Binding var message: String
    @Binding var selectedEmoji: Emoji?
    @State var isShowingsheet: Bool = false
    
    var body : some View{
        VStack {
            NavigationStack {
                EmojiPickerView(selectedEmoji: $selectedEmoji, selectedColor: Color.accent)
                    .background(Color.subColor4)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(Color.accentColor)
                                
                                // 위치 데이터
                                Text("경기도 고양시")
                                    .font(.caption2)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isShowingsheet.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "person")
                                    Text("전체 공개")
                                        .font(.caption2)
                                    Text(">")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                
            }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height * 1.1 / 3)
                .padding(.bottom)
            
            // 메시지 입력
            TextField("상태 메시지를 입력하세요.", text: $message)
                .padding(.leading, 10)
                .frame(width: 340, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.subColor1, lineWidth: 0.5)
                        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
                )
                .padding(.bottom)
            
            // camera button
            NavigationLink(destination: CameraView()) {
                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Color.accentColor))
                    .frame(width: 340, height: 40)
                    .overlay(Image(systemName: "camera.fill")
                        .padding()
                        .foregroundColor(Color.white)
                    )
            }
            .padding(.bottom, 20)
            
            // 공유 버튼
//            Button (action:{
//                
//            }) {
//                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
//                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
//                        .fill(Color.white))
//                    .stroke(Color.accentColor, lineWidth: 0.5)
//                    .frame(width: 340, height: 40)
//                    .overlay(Text("Share")
//                        .padding()
//                        .foregroundColor(Color.accentColor)
//                    )
//                
//            }
        }
        .frame(width: 365, height: 500) // 팝업창 크기
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.subColor4)
                .stroke(Color.accentColor, lineWidth: 0.5)
                .shadow(radius: 10)
            
        )
        .padding()
        .sheet(isPresented: $isShowingsheet) {
            PublishScopeView()
                .presentationDetents([.medium])
        }
    }
    
    //    func getEmojiList()->[[Int]] {
    //        var emojis : [[Int]] = []
    //        for i in stride(from: 0x1F601, to: 0x1F64F, by: 4){
    //            var temp : [Int] = []
    //            for j in i...i+3{
    //                temp.append(j)
    //            }
    //            emojis.append(temp)
    //        }
    //        return emojis
    //    }
}

