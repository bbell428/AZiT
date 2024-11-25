//
//  MainTopView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct MainTopView: View {
    private let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    
    @Binding var isMainExposed: Bool // 메인 화면인지 맵 화면인지
    @Binding var isShowToast: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if isMainExposed == false {
                    Rectangle()
                        .fill(Utility.createLinearGradient(colors: [Color.white, Color.clear]))
                }
                
                HStack() {
                    Text("AZiT")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .bold()
                        .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        //                        Button {
                        //                            // 게시글 리로드
                        //                        } label: {
                        //                            Image(systemName: "arrow.clockwise")
                        //                                .resizable()
                        //                                .aspectRatio(contentMode: .fit)
                        //                                .frame(width: 25)
                        //                        }
                        //                        .disabled(isModalPresented ? true : false)
//                        
//                        NavigationLink {
//                            MessageView(isShowToast: $isShowToast)
//                        } label: {
//                            Image(systemName: "ellipsis.message.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 30)
//                                .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
//                        }
                        
                        NavigationLink {
                            AlbumView(isShowToast: $isShowToast)
                        } label: {
                            Image(systemName: "photo.stack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
                        }
                        
//                        NavigationLink {
//                            MyPageView()
//                        } label: {
//                            Image(systemName: "person.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 30)
//                                .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
//                        }
                    }
                    .frame(width: 50, height: 50)
                    .background(isMainExposed ? Color.gray.opacity(0.1) : Color.subColor4.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                }
                .foregroundStyle(.accent)
            }
            .frame(maxHeight: (screenBounds?.height ?? 0) * 0.25)
            .ignoresSafeArea()
            
            Spacer()
            
            HStack{
                Spacer()
                
                Button {
                    isMainExposed.toggle()
                } label: {
                    if isMainExposed {
                        Image(.personPinCircle)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
                    } else {
                        Image(systemName: "house.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundStyle(Utility.createLinearGradient(colors: [.accent, .gradation1]))
                    }
                }
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .padding()            
        }
    }
}

