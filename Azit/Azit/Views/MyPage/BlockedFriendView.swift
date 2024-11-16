//
//  BlockedFriendView.swift
//  Azit
//
//  Created by 김종혁 on 11/16/24.
//

import SwiftUI

struct BlockedFriendView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State var blockedFriends: [UserInfo] = []
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                
                Text("Blocked")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Color.clear
                    .frame(maxWidth: .infinity)
                
            }
            .frame(height: 70)
            .background(Color.white)
            
            
            ScrollView(.vertical, showsIndicators: false) {
                //MARK: 친구 리스트
                VStack(alignment: .leading) {
                    HStack {
                        Text("차단 친구 리스트")
                            .font(.headline)
                        Text("\(blockedFriends.count)")
                            .font(.headline)
                            .padding(.leading, 6)
                    }
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 10)
                    
                    VStack(alignment: .center) {
                        //MARK: 친구 목록
                        ForEach(blockedFriends, id: \.id) { blockedFriends in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.subColor4)
                                        .frame(width: 45, height: 45)
                                    Text(blockedFriends.profileImageName)
                                        .font(.system(size: 30))
                                        .bold()
                                }
                                Text(blockedFriends.nickname)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Spacer()
                                }
                            Divider()
                            }
                            .padding(.vertical, 1)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                blockedFriends = try await userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.blockedFriends ?? [])
            }
        }
    }
}

#Preview {
    BlockedFriendView()
}
