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
    @Environment(\.dismiss) var dismiss
    
    @State var isPresented: Bool = false // 편집 뷰 띄움
    @State var showAllFriends = false // 친구 목록 더 보기
    @State var isQRPresented: Bool = false // QR 뷰
    @State var isEditFriend: Bool = false // 친구 편집 뷰
    @State var friendID: String = ""      // 친구 id 담을 곳
    
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        ZStack {
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
                    
                    Text("My Page")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Color.clear
                        .frame(maxWidth: .infinity)
                    
                }
                .frame(height: 70)
                .background(Color.white)
                
                VStack(alignment: .center) {
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
                                .padding(.vertical, 6)
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
                                .presentationDetents([.fraction(0.45)])
                                .presentationDragIndicator(.visible)
                        }
                    }
                    .padding(.top, -50)
                    .padding(.leading, 60)
                }
                .padding(.top, -10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    //MARK: 친구 리스트
                    VStack(alignment: .leading) {
                        HStack {
                            Text("친구 리스트")
                                .font(.headline)
                            Text("\(userInfoStore.friendInfos.count)")
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
                            
                            //MARK: 초대하기 QR
                            Button {
                                isQRPresented.toggle()
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
                            .background(Color.oldAccent)
                        
                        VStack(alignment: .center) {
                            //MARK: 친구 목록
                            ForEach(showAllFriends ? userInfoStore.friendInfos :  Array(userInfoStore.friendInfos.prefix(3)), id: \.id) { friend in
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
                                        isEditFriend.toggle()
                                        friendID = friend.id
                                    } label: {
                                        Image(systemName: "line.horizontal.3")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 20)
                                            .font(.title3)
                                    }
                                    .overlay {
                                        if isEditFriend && friendID == friend.id {
                                            EditFriend(friendID: friendID, friendNickname: friend.nickname, isEditFriend: $isEditFriend)
                                                .scaleEffect(scale)
                                                .onAppear {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        scale = 1.0
                                                    }
                                                }
                                                .onDisappear {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        scale = 0.1
                                                    }
                                                }
                                                .padding(.leading, -40)
                                        }
                                    }
                                }
                                .padding(.vertical, 1)
                                .zIndex(5)
                                
                                Divider()
                            }
                            
                            if userInfoStore.friendInfos.count > 3 {
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
                                .background(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 0.5))
                            }
                            
                            // 차단 유저 목록
                            NavigationLink {
                                BlockedFriendView()
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
            .frame(width: 370)
            .onTapGesture {
                isEditFriend = false // 아무 곳 터치 시, 친구 뷰 안보이게
            }
            
            if isQRPresented {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isQRPresented.toggle()
                    }
                
                QRCodeView()
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scale = 1.0
                        }
                    }
                    .onDisappear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scale = 0.1
                        }
                    }
            }
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                userInfoStore.friendInfos = try await userInfoStore.loadUsersInfoByEmail(userID: userInfoStore.userInfo?.friends ?? [])
                
                userInfoStore.friendInfos = userInfoStore.friendInfos.sorted { $0.id > $1.id } // 오름차순
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
