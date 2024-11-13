//
//  ContentsModalTopView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct ContentsModalTopView: View {
    @Binding var story: Story?
    
    var selectedUserInfo: UserInfo
    
    var body: some View {
        HStack(spacing: 5) {
            Text(selectedUserInfo.previousState)
            
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
            
            Text("경상북도 경산시")
                .font(.caption)
        }
    }
}
