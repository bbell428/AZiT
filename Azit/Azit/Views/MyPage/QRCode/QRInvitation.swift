//
//  QRInvitation.swift
//  Azit
//
//  Created by 김종혁 on 11/15/24.

//MARK: QR 혹은 링크로 초대장을 받게되어 앱에 접속했을 때, 초대장 뷰
// RotationView.swift에서 이용할 초대장 뷰

import SwiftUI

struct QRInvitation: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    
    @State var otherFriend: UserInfo?
    
    @Binding var isShowInvaitaion: Bool // QR초대장으로 앱 실행 시 뷰 띄움 true
    @Binding var isShowYes: Bool        // 초대장에서 Yes 누르면 친구 다시 불러옴
    @State var isBlockedByFriend: Bool = false  // 상대의 blockedFriends 배열에서 내 ID가 있는지 확인
    
    var body: some View {
        ZStack {
            Image("QRBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.95)
            
            VStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 200, height: 200)
                    
                    Text("\(otherFriend?.profileImageName ?? "")")
                        .font(.system(size: 120))
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 1, y: 3)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                VStack(spacing: 10) { // 코드가 이게 맞나? 다른 방법이 있을려나..
                    HStack(spacing: 5) {
                        Text("\(otherFriend?.nickname ?? "")")
                            .bold()
                        if userInfoStore.isFriend(id: authManager.deepUserID) {
                            Text("님은")
                        } else {
                            Text("님을")
                        }
                    }
                                 
                    if otherFriend?.id == authManager.userID || isBlockedByFriend || userInfoStore.isBlockedFriend(id: authManager.deepUserID) {
                        Text("친구로 추가 할 수 없습니다.")
                    } else if userInfoStore.isFriend(id: authManager.deepUserID) {
                        Text("이미 친구입니다.")
                    } else {
                        Text("친구 추가하시겠습니까?")
                    }
                }
                .onAppear {
                    Task {
                        isBlockedByFriend = await userInfoStore.isBlockedByFriend(friendID: authManager.deepUserID, myID: authManager.userID)
                    }
                }
                
                Spacer()
                
                Divider()
                    .background(Color.accentColor)
                
                // 순서대로: 나의 친구배열에 친구 없어야함, 스스로 친구추가X, 상대방 차단배열에 내가 있는지, 나의 차단배열에 친구가 있는지 확인
                if !userInfoStore.isFriend(id: authManager.deepUserID) && otherFriend?.id != authManager.userID && !isBlockedByFriend && !userInfoStore.isBlockedFriend(id: authManager.deepUserID) {
                    HStack(spacing: 65) {
                        Button {
                            // yes
                            userInfoStore.addFriend(receivedID: authManager.deepUserID, currentUserID: authManager.userID)
                            authManager.deepUserID = ""
                            isShowYes = true
                            isShowInvaitaion.toggle()
                        } label: {
                            Text("YES")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        Divider()
                            .background(Color.accentColor)
                            .padding(.top, -8)
                            .frame(height: 100)
                        
                        Button {
                            // NO
                            authManager.deepUserID = "" // No 선택 시 deepUserID를 초기화하여 알림이 반복되지 않도록 함
                            
                            isShowInvaitaion.toggle()
                        } label: {
                            Text("NO")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    Button {
                        authManager.deepUserID = "" // No 선택 시 deepUserID를 초기화하여 알림이 반복되지 않도록 함
                        isShowInvaitaion.toggle()
                    } label: {
                        Text("Cancel")
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color.black)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 40)
                }
            }
            .frame(width: 330)
        }
        .frame(maxWidth: 350, maxHeight: 450)
        .onAppear {
            userInfoStore.getUserInfoByIdWithCompletion(id: authManager.deepUserID) { userInfo in
                if let userInfo = userInfo {
                    DispatchQueue.main.async {
                        self.otherFriend = userInfo
                        print("Updated User Info: \(userInfo.nickname)")
                    }
                } else {
                    print("No user data available or error occurred.")
                }
            }
        }
    }
}

//#Preview {
//    QRInvitation()
//}
