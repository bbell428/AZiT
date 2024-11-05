//
//  MainView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MainView: View {
    @State private var isModalPresented: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                MainTopView(isModalPresented: $isModalPresented)
                Spacer()
            }
            
            if isModalPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .zIndex(1)
            }
            
            RotationView(isModalPresented: $isModalPresented)
                .frame(width: 300, height: 300)
                .zIndex(1)
            
            VStack {
                
                Spacer()
                HStack{
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .frame(width: 40, height: 40)
                        Button {
                            // 지도 화면으로 넘어가기
                        } label: {
                            Image(systemName: "map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                        }
                    }
                    .padding()
                }
            }
            .zIndex(1)
        }
    }
}

struct MainTopView: View {
    @Binding var isModalPresented: Bool
    
    var body: some View {
        HStack() {
            Text("AZiT")
                .font(.largeTitle)
                .fontWeight(.black)
                .bold()
                .padding()
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    // 게시글 리로드
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                }
                .disabled(isModalPresented ? true : false)
                
                Button {
                    // 앨범 리스트
                } label: {
                    Image(systemName: "photo.stack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                }
            }
            .padding()
        }
        .foregroundStyle(.accent)
    }
}

#Preview {
    MainView()
}
