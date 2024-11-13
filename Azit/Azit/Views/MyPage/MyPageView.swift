//
//  MyPageView.swift
//  Azit
//
//  Created by 김종혁 on 11/5/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var authManager: AuthManager
    
    @State var isShowEmoji = false
    @State var isPresented: Bool = false
    @State var showAllFriends = false // 친구 목록 더 보기
    
    @State var friends: [UserInfo] = []
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                //MARK: 내 프로필이미지, 닉네임
                ZStack {
                    Circle()
                        .fill(Color.subColor4)
                        .frame(width: 150, height: 150)
                    Text("\(userInfoStore.userInfo?.profileImageName ?? "")")
                        .font(.system(size: 100))
                }
                HStack {
                    Text("\(userInfoStore.userInfo?.nickname ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("편집")
                            .font(.caption)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                            .foregroundColor(.accentColor)
                            .padding(.leading, 10)
                    }
                    .sheet(isPresented: $isPresented, onDismiss: {
                        // 닉네임, 이모지 업데이트
                        Task {
                            await userInfoStore.loadUserInfo(userID: authManager.userID)
                        }
                    }) {
                        EditProfileView(isPresented: $isPresented)
                            .presentationDetents([.fraction(4/9)])
                            .presentationDragIndicator(.visible)
                    }
                }
                .padding(.top, -50)
                .padding(.leading, 60)
            }
            .padding(.top, 30)
            
            ScrollView {
                //MARK: 친구 리스트
                VStack(alignment: .leading) {
                    HStack {
                        Text("친구 리스트")
                            .font(.headline)
                        Text("\(friends.count)")
                            .font(.headline)
                            .padding(.leading, 6)
                    }
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 10)
                    
                    // 친구 항목
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.subColor4)
                                .frame(width: 45, height: 45)
                            
                            Image(systemName: "person.fill")
                                .foregroundColor(.accentColor)
                        }
                        Text("NEW")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        NavigationLink {
                            QRCodeView()
                        } label: {
                            Text("초대하기")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 13)
                                .padding(.vertical, 6)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    Divider()
                        .foregroundStyle(Color.accentColor)
                    
                    VStack(alignment: .center) {
                        //MARK: 친구 목록
                        ForEach(showAllFriends ? friends : Array(friends.prefix(3)), id: \.id) { friend in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.subColor4)
                                        .frame(width: 45, height: 45)
                                    Text(friend.profileImageName)
                                        .font(.system(size: 30))
                                        .bold()
                                }
                                Text(friend.nickname)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.gray)
                                
                                Spacer()
                                
                                Button {
                                    //
                                } label: {
                                    Image(systemName: "line.horizontal.3")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                        .font(.title3)
                                }
                            }
                            .padding(.vertical, 1)
                            
                            Divider()
                        }
                        if friends.count > 3 {
                            Button {
                                withAnimation { // 애니메이션을 추가, 자연스러운 느낌쓰
                                    showAllFriends.toggle()
                                }
                            } label: {
                                Image(systemName: showAllFriends ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 7)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                    )
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
                
                //MARK: 일반 설정
                VStack(alignment: .leading) {
                    Text("일반 설정")
                        .foregroundStyle(Color.gray)
                        .bold()
                        .padding(.bottom, 15)
                    
                    VStack(spacing: 15) {
                        Button {
                            // 알림 설정
                        } label: {
                            HStack {
                                Text("알림 설정")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 15))
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5))
                        }
                        
                        Button {
                            // 차단 유저 목록
                        } label: {
                            HStack {
                                Text("차단 유저 목록")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 15))
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5))
                        }
                        
                        Button {
                            authManager.signOut()
                        } label: {
                            HStack {
                                Text("로그아웃")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 15))
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5))
                        }
                        
                        Button {
                            // 계정 탈퇴
                        } label: {
                            HStack {
                                Text("계정 탈퇴")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 15))
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5))
                        }
                        
                        Button {
                            // 고객 지원
                        } label: {
                            HStack {
                                Text("고객 지원")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 15))
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5))
                        }
                    }
                    .foregroundStyle(Color.black)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, -10)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            Task {                
                // 친구 uid 긁어옴
                let friendIDs = userInfoStore.userInfo?.friends ?? []
                
                // 그 친구 uid를 비교하며 순서대로 가져옴
                friends = friendIDs.compactMap { userInfoStore.friendInfo[$0] }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
