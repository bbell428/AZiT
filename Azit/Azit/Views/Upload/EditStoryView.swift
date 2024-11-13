//
//  EditStoryView.swift
//  Azit
//
//  Created by 홍지수 on 11/8/24.
//

import SwiftUI
//import EmojiPicker

struct EditStoryView : View {
    @EnvironmentObject var storyStore: StoryStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var storyDraft: StoryDraft
    @Environment(\.dismiss) var dismiss
    
    // 작성될 때의 경도와 위도 값 받기 > 위치 변환하려면 api 받아야 하나
//    @State var currentLatitude: Double = 0
//    @State var currentLongitude: Double = 0
//    @Binding var message: String
//    @Binding var selectedEmoji: String
    @State var publishedTargets: [String] = []
    @Binding var isDisplayEmojiPicker: Bool
    
    @State var isShowingsheet: Bool = false
    @State var isPicture:Bool = false
    var isShareEnabled: Bool {
        return storyDraft.emoji.isEmpty || storyDraft.content.isEmpty
    }
    
    var body : some View{
        VStack() {
            NavigationStack {
                HStack {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.accentColor)
                        
                        // 위치 데이터
                        Text("경기도 고양시")
                            .font(.caption2)
                    }
                    Spacer()
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
                .padding(.horizontal)
                
                // 이모지피커 뷰 - 서치 바와 리스트
                EmojiPickerView(selectedEmoji: $storyDraft.emoji, searchEnabled: false,  selectedColor: Color.accent)
                    .background(Color.subColor4)

                
            }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height * 1.1 / 3)
                .padding(.bottom)
            
            // 메시지 입력
            TextField("상태 메시지를 입력하세요.", text: $storyDraft.content)
                .padding(.leading, 10)
                .frame(width: 340, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.subColor1, lineWidth: 0.5)
                        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
                )
                .padding(.bottom, 10)
            
            // 수정 완료 버튼
            Button (action:{
                isDisplayEmojiPicker = false
            }) {
                RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                    .stroke(Color.accentColor, lineWidth: 0.5)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .fill(Color.white))
                    .frame(width: 340, height: 40)
                    .overlay(Text("수정 완료")
                        .padding(.bottom, 10)
                        .foregroundColor(Color.accentColor)
                    )
            }
        }
        .frame(width: 365, height: 480) // 팝업창 크기
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

