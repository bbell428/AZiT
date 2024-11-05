//
//  ContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI

struct ContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    @Binding var isModalPresented: Bool
    @Binding var message: String
    @State private var isLiked: Bool = false
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 5) {
                Text("🥰")
                
                Text("혀누")
                    .font(.caption)
                
                Spacer()
                
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.accent)
                
                Text("경상북도 경산시")
                    .font(.caption)
            }
            
            HStack() {
                Text("아주 졸리다 그러니까")
                
                Spacer()
            }
            
            
            Image(.realToBed)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { }
            
            HStack {
                TextField("message", text: $message, prompt: Text("친구에게 메세지 보내기")
                    .font(.caption))
                .padding(3)
                .padding(.leading, 10)
                .frame(height: 30)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.accent, lineWidth: 1)
                )
                
                Spacer()
                
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.accent)
                        .frame(width: 30)
                        .fontWeight(.light)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.0
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.1
            }
        }
        .frame(width: (screenBounds?.width ?? 0) - 32)
    }
}

#Preview {
    MainView()
}
