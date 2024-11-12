//
//  LikesSheetView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/12/24.
//

import SwiftUI

struct LikesSheetView: View {
    @Binding var friends: [UserInfo]
    
    var body: some View {
        VStack() {
            Text("Likes")
                .padding([.top, .bottom], 30)
            
            Spacer()
            
            if friends.count == 0 {
                Text("좋아요를 누른 친구가 없습니다.")
            } else {
                Divider()
                
                ScrollView {
                    ForEach(friends) { friend in
                        HStack {
                            Circle()
                                .fill(.subColor4)
                                .overlay(
                                    Text(friend.profileImageName)
                                        .font(.headline)
                                )
                                .frame(width: 35)
                            
                            Text(friend.nickname)
                                .font(.headline)
                                .foregroundStyle(Color(UIColor.darkGray))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .bottom], 5)
                        
                        Divider()
                    }
                }
            }
            
            Spacer()
        }
        .padding([.leading, .trailing])
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
}
