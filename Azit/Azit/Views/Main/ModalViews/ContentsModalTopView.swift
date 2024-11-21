//
//  ContentsModalTopView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI
import Kingfisher

struct ContentsModalTopView: View {
    @Binding var story: Story?
    let emojiManager = EmojiManager()
    
    var selectedUserInfo: UserInfo
    
    var body: some View {
        HStack(spacing: 5) {
            if let codepoints = emojiManager.getCodepoints(forName: selectedUserInfo.previousState) {
                KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            }
            
            Text(selectedUserInfo.nickname)
                .font(.caption)
            
            Text(Utility.timeAgoSinceDate(story?.date ?? Date.now))
                .font(.caption)
                .foregroundStyle(.gray)
            
            Spacer()
            
            Image(systemName: "location")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 15, height: 15)
                .foregroundStyle(.accent)
            
            Text(story?.address ?? "")
                .font(.caption)
        }
    }
}
