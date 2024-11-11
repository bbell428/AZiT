//
//  ContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI

struct ContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    @State var story: Story?
    @StateObject var storyStore: StoryStore = StoryStore()
    @Binding var isModalPresented: Bool
    @Binding var message: String
    @Binding var selectedUserInfo: UserInfo
    @State private var isLiked: Bool = false
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack(spacing: 5) {
                Text(selectedUserInfo.previousState)
                
                Text(selectedUserInfo.nickname)
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
            
            if story?.image != "" {
                HStack() {
                    Text(story?.content ?? "")
                    
                    Spacer()
                }
                
                Image("asdf")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { }
            } else {
                if story?.emoji ?? "" != "" {
                    if story?.content ?? "" != "" {
                        HStack() {
                            SpeechBubbleView(text: story?.content ?? "")
                        }
                        .padding(.bottom, -10)
                    }
                    
                    Text(story?.emoji ?? "")
                        .font(.system(size: 100))
                } else {
                    if story?.content ?? "" != "" {
                        HStack() {
                            Text(story?.content ?? "")
                            Spacer()
                        }
                    }
                }
            }
            
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
        .background(.subColor4)
        .cornerRadius(8)
        .scaleEffect(scale)
        .onAppear {
            Task {
                try await story = storyStore.loadStorysByIds(ids: [selectedUserInfo.id])[0]
            }
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

// 추 후 컴포넌트로 빼기
struct SpeechBubbleView: View {
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .padding(5)
                .padding([.leading, .trailing], 10)
                .foregroundStyle(.white)
        }
        .background(
            SpeechBubbleTail()
                .stroke(Color.accent, lineWidth: 2)
                .background(SpeechBubbleTail().fill(Color.accent))
        )
    }
}

struct SpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 8, height: 8))
        
        path.move(to: CGPoint(x: rect.midX - 3, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + 8))
        path.addLine(to: CGPoint(x: rect.midX + 3, y: rect.maxY))
        
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    MainView()
}
