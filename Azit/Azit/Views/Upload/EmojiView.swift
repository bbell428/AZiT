//
//  EmojiView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI

struct EmojiView : View {
    
    @Binding var show : Bool
    @Binding var txt : String
    @Binding var message: String
    
    var body : some View{
        ZStack(alignment: .topLeading) {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25){
                        ForEach(self.getEmojiList(),id: \.self){i in
                            VStack(spacing: 15){
                                ForEach(i,id: \.self){j in
                                    Button(action: {
                                        self.txt += String(UnicodeScalar(j)!)
                                    }) {
                                        if (UnicodeScalar(j)?.properties.isEmoji)!{
                                            Text(String(UnicodeScalar(j)!)).font(.system(size: 55))
                                        }
                                        else{
                                            Text("")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                    
                }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height / 3)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                    .background(Color.white)
                    .cornerRadius(25)
                
                // 메시지 입력
//                TextField("메시지를 입력하세요.", $message)
                
                
                // camera button
                NavigationLink(destination: CameraView()) {
                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                        .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
                            .fill(Color.accentColor))
                        .frame(width: 330, height: 40)
                        .overlay(Image(systemName: "camera.fill")
                            .padding()
                            .foregroundColor(Color.white)
                        )
                }
                .padding(.bottom, 20)
            }
            
//            Button(action: {
//                self.show.toggle()
//            }) {
//                Image(systemName: "xmark").foregroundColor(.black)
//            }.padding()
        }
    }
    
    func getEmojiList()->[[Int]] {
        var emojis : [[Int]] = []
        for i in stride(from: 0x1F601, to: 0x1F64F, by: 4){
            var temp : [Int] = []
            for j in i...i+3{
                temp.append(j)
            }
            emojis.append(temp)
        }
        return emojis
    }
}

