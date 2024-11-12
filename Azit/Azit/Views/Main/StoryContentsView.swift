//
//  StoryContentsView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct StoryContentsView: View {
    @Binding var story: Story?
    
    var body: some View {
        // story에 image가 있을 때
        if story?.image ?? "" != "" {
            HStack() {
                Text(story?.content ?? "")
                
                Spacer()
            }
            // UIImage로 storage에 있는 image 불러오기
            Image("")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture { }
        // story에 image가 없을 때
        } else {
            // story에 emoji가 있을 때
            if story?.emoji ?? "" != "" {
                // story에 content가 있을 때
                if story?.content ?? "" != "" {
                    HStack() {
                        SpeechBubbleView(text: story?.content ?? "")
                    }
                    .padding(.bottom, -10)
                }
                
                Text(story?.emoji ?? "")
                    .font(.system(size: 100))
            // story에 image가 없을 때
            } else {
                // story에 content가 있을 때
                if story?.content ?? "" != "" {
                    HStack() {
                        Text(story?.content ?? "")
                        Spacer()
                    }
                }
            }
        }
    }
}
