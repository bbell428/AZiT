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
    @EnvironmentObject var firendsStore: FriendsStore
    @Environment(\.dismiss) var dismiss
    
    //    @Binding var currentIndex: Int
    @State var isPresented: Bool = false // 편집 뷰 띄움
    @State var showAllFriends = false // 친구 목록 더 보기
    @State var isQRPresented: Bool = false // QR 뷰
    @State var isEditFriend: Bool = false // 친구 편집 뷰
    @State var friendID: String = ""      // 친구 id 담을 곳
    @State var isLogout: Bool = false // 로그아웃 알럿
    @State var isResign: Bool = false // 회원탈퇴 알럿
    @State private var scale: CGFloat = 0.1
    
    @Binding var isShowingMyPageView: Bool // MyPageView 노출 판별 여부
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .center) {
                    HStack {
                        Color.clear
                            .frame(maxWidth: .infinity)
                        
                        Text("My Page")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            withAnimation(.easeInOut) {
                                isShowingMyPageView = false
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 25))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 20)
                        
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
                                Text("\(firendsStore.friendInfos.count)")
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
                                        .cornerRadius(15)
                                }
                            }
                            Divider()
                                .background(Color.oldAccent)
                            
                            VStack(alignment: .center) {
                                //MARK: 친구 목록
                                ForEach(showAllFriends ? firendsStore.friendInfos :  Array(firendsStore.friendInfos.prefix(3)), id: \.id) { friend in
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
                                            Image(systemName: "ellipsis")
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
                                
                                if firendsStore.friendInfos.count > 3 {
                                    Button {
                                        // withAnimation(.easeInOut(duration: 0.3)) { // 애니메이션을 추가, 자연스러운 느낌쓰
                                        showAllFriends.toggle()
                                        // }
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
                                isLogout = true
                            } label: {
                                HStack {
                                    Text("로그아웃")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.system(size: 15))
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 0.5))
                                .alert("로그아웃", isPresented: $isLogout, actions: {
                                    Button("예") {
                                        Task {
                                            // 로그아웃 시, 토근 값 빈문자열 + 알림배지 개수 0으로 초기화
                                            await userInfoStore.updateFCMToken(authManager.userID, fcmToken: "")
                                            sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: 0, myUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: "", viewType: "")
                                            
                                            authManager.signOut()
                                        }
                                        
                                        isLogout = false
                                    }
                                    
                                    Button("아니요", role: .cancel) {
                                        isLogout = false
                                    }
                                }, message: {
                                    Text("정말로 로그아웃을 하겠습니까?")
                                })
                            }
                            
                            
                            Button {
                                // 계정 탈퇴
                                isResign = true
                            } label: {
                                HStack {
                                    Text("계정 탈퇴")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.system(size: 15))
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 0.5))
                            }
                            .alert("계정 탈퇴", isPresented: $isResign, actions: {
                                Button("예") {
                                    Task {
                                        // 상대 친구 목록에 자신 삭제
                                        if let friends = userInfoStore.userInfo?.friends {
                                            for friend in friends {
                                                userInfoStore.removeFriend(friendID: friend, currentUserID: authManager.userID)
                                            }
                                        } else {
                                            print("친구 목록이 없습니다.")
                                        }
                                        await firendsStore.deleteChatUser(userId: authManager.userID) // Chat컬렉션에서 자신 전부 삭제
                                        await firendsStore.deleteStoryUser(userId: authManager.userID) // Story컬렉션에서 자신 전부 삭제
                                        try await userInfoStore.deleteUserInfo(userID: authManager.userID) // User컬렉션에서 자신 계정 삭제
                                        sendNotificationToServer(myNickname: "", message: "", fcmToken: userInfoStore.userInfo?.fcmToken ?? "", badge: 0, myUserInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0, longitude: 0, blockedFriends: [], fcmToken: ""), chatId: "", viewType: "")
                                        
                                        await authManager.deleteAccount() // Authentication에서 자신 계정 삭제
                                    }
                                    isResign = false
                                }
                                
                                Button("아니요", role: .cancel) {
                                    isResign = false
                                }
                            }, message: {
                                Text("정말로 계정 탈퇴 하겠습니까?")
                            })
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
                    // Firestore 실시간 리스너 설정
                    firendsStore.listenToFriendsUpdates(userID: authManager.userID)
                }
            }
            .onDisappear {
                // 리스너 제거
                firendsStore.removeListener()
            }
            .navigationBarBackButtonHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .transition(.move(edge: .leading)) // 왼쪽에서 오른쪽으로 전환
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -100 { // 왼쪽으로 스와이프 -> 메인 화면으로 복귀
                        withAnimation(.easeInOut) {
                            isShowingMyPageView = false
                        }
                    }
                }
        )
    }
}

//#Preview {
//    MyPageView()
//}
