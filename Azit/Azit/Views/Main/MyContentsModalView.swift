//
//  MyContentsModalView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

struct MyContentsModalView: View {
    let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    @State var story: Story?
    @StateObject var storyStore: StoryStore = StoryStore()
    @Binding var isMyModalPresented: Bool
    @State private var scale: CGFloat = 0.1
    var selectedUserInfo: UserInfo
    
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
            
            if story?.image ?? "" != "" {
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
                Button(action: {
                    // isPresentedLikedSheet
                }) {
                    Image(systemName: "heart.fill")
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

