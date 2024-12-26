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
            let emojiComponents = selectedUserInfo.previousState.components(separatedBy: "*")
            if let codepoints = emojiManager.getCodepoints(forName: emojiComponents[0]) {
                let urlString = EmojiManager.getTwemojiURL(for: codepoints)
                
                KFImage(URL(string: urlString))
                    .placeholder {
                            if emojiComponents.count > 1 {
                                Text(emojiComponents[1])
                                    .font(.system(size: 15))
                            } else {
                                Text("User")
                            }
                        }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
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
