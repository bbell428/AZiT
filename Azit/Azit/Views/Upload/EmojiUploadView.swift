//
//  EmojiUploadView.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//

import SwiftUI

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

struct EmojiUploadView: View {
    
    @State var txt = ""
    @State var show = false
    @State var message = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                GeometryReader{_ in
                    VStack{
                        HStack(spacing: 15){
                            TextField("Message", text: self.$txt)
                            Button(action: {
                                UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
                                self.show.toggle()
                            }) {
                                Image(systemName: "smiley").foregroundColor(Color.black.opacity(0.5))
                            }
                        }.padding(12)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }.padding()
                }
                VStack {
                    EmojiView(show: self.$show, txt: self.$txt, message: self.$message)
                        .offset(y: self.show ?  (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! : UIScreen.main.bounds.height)
                }
            }
            
        }
        .background(Color("Color").edgesIgnoringSafeArea(.all))
            .animation(.default)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (_) in
                    self.show = false
                }
            }
    }
}



#Preview {
    EmojiUploadView()
}


//struct EmojiView : View {
//    
//    @Binding var show : Bool
//    @Binding var txt : String
//    @State var message = ""
//    
//    var body : some View{
//        ZStack(alignment: .topLeading) {
//            VStack {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 25){
//                        ForEach(self.getEmojiList(),id: \.self){i in
//                            VStack(spacing: 15){
//                                ForEach(i,id: \.self){j in
//                                    Button(action: {
//                                        self.txt += String(UnicodeScalar(j)!)
//                                    }) {
//                                        if (UnicodeScalar(j)?.properties.isEmoji)!{
//                                            Text(String(UnicodeScalar(j)!)).font(.system(size: 55))
//                                        }
//                                        else{
//                                            Text("")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding(.top)
//                    
//                }.frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height / 3)
//                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
//                    .background(Color.white)
//                    .cornerRadius(25)
//                
//                // 메시지 입력
//                TextField("메시지를 입력하세요.", $message)
//                
//                
//                // camera button
//                NavigationLink(destination: CameraView()) {
//                    RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
//                        .background(RoundedRectangle(cornerSize: CGSize(width: 12.0, height: 12.0))
//                            .fill(Color.accentColor))
//                        .frame(width: 330, height: 40)
//                        .overlay(Image(systemName: "camera.fill")
//                            .padding()
//                            .foregroundColor(Color.white)
//                        )
//                }
//                .padding(.bottom, 20)
//            }
//            
////            Button(action: {
////                self.show.toggle()
////            }) {
////                Image(systemName: "xmark").foregroundColor(.black)
////            }.padding()
//        }
//    }
//    
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
//}
//
