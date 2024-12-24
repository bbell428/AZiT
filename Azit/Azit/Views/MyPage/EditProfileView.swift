//
//  EditProfile.swift
//  Azit
//
//  Created by 김종혁 on 11/6/24.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    
    @State var emoji: String = "" // 현재 이모지
//    @State private var emojiPrevious: String = "" // 이전 이모지
    @State private var nickname: String = ""
    
    @State var isSheetEmoji = false // 이모지 뷰
    @State var isCancelEdit = false // 수정완료 버튼
    @State var isNicknameExists = false // 중복 닉네임 확인
    @State var isMyNickname: Bool = false // 나의 닉네임은 중복메시지 안뜨게 함
    @State var isNicknameColor = false
    @Binding var isPresented: Bool // 편집 뷰
    
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Circle()
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 2)
                    )
                    .frame(width: 150, height: 150)
                
                Text(emoji)
                    .font(.system(size: 100))
            }
            .overlay {
                Button {
                    isSheetEmoji.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.subColor4)
                            .stroke(
                                Color.accentColor,
                                style: StrokeStyle(lineWidth: 2)
                            )
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "pencil")
                            .foregroundStyle(Color.accentColor)
                            .font(.headline)
                    }
                }
                .onChange(of: emoji) {
                    // 이모지가 여러 개 입력된 경우 첫 번째 문자만 유지
                    if emoji != userInfoStore.userInfo?.profileImageName ?? "" {
                        isCancelEdit = true
                    } else {
                        isCancelEdit = false
                    }
                }
                .offset(x: 40, y: 60)
            }
            .padding(.top, 40)
            
            VStack {
                HStack {
                    TextField("", text: $nickname)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(isNicknameColor ? .red : .black)
                        .onAppear {
                            if nickname.isEmpty {
                                nickname = userInfoStore.userInfo?.nickname ?? ""
                            }
                        }
                        .onChange(of: nickname) {
                            // 특수문자와 공백을 제외한 문자열로 필터링
                            let filteredNickname = nickname.filter { $0.isLetter || $0.isNumber }
                            
                            // 필터링된 결과로 업데이트
                            if filteredNickname != nickname {
                                nickname = filteredNickname
                            }
                            
                            // 한글 자음/모음만 입력된 경우 확인
                            let hasSingleConsonantOrVowel = nickname.contains { char in
                                let scalar = char.unicodeScalars.first!
                                return (0x3131...0x318E).contains(scalar.value) // 한글 자음 및 모음 범위
                            }
                            
                            // 닉네임 길이 조건에 따라 isShowNickname 설정
                            guard nickname.count > 0 && nickname.count < 9 else {
                                isNicknameColor = true
                                return isCancelEdit = false
                            }
                            
                            // 입력한 닉네임이 현재 나의 닉네임인 경우
                            guard nickname != userInfoStore.userInfo?.nickname else {
                                isCancelEdit = false
                                return isMyNickname = true
                            }
                            
                            // 한글 자음/모음 입력된 경우
                            guard !hasSingleConsonantOrVowel else {
                                isNicknameExists = false
                                isNicknameColor = false
                                return isCancelEdit = false
                            }
                            
                            Task {
                                // 닉네임 중복 확인
                                if await userInfoStore.isNicknameExists(nickname) {
                                    isMyNickname = false
                                    isCancelEdit = false
                                    isNicknameExists = true
                                    isNicknameColor = true
                                } else {
                                    isNicknameExists = false
                                    isCancelEdit = true
                                    isNicknameColor = false
                                }
                            }
                            
                        }
                        .padding(.leading, 30)
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.accentColor)
                        .font(.headline)
                }
                Divider()
                
                if isNicknameExists && !isMyNickname {
                    Text("이미 사용중인 닉네임입니다.")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                } else if nickname.count > 8 {
                    Text("8자 이하로 입력 가능합니다.")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, -40)
            .frame(height: 10)
            
            Button {
                if isCancelEdit {
                    Task {
                        await userInfoStore.updateUserInfo(UserInfo(
                            id: authManager.userID,
                            email: authManager.email,
                            nickname: nickname,
                            profileImageName: emoji,
                            previousState: userInfoStore.userInfo?.previousState ?? "",
                            friends: userInfoStore.userInfo?.friends ?? [""],
                            latitude: userInfoStore.userInfo?.latitude ?? 0.0,
                            longitude: userInfoStore.userInfo?.longitude ?? 0.0,
                            blockedFriends: [],
                            fcmToken: userInfoStore.userInfo?.fcmToken ?? "")
                        )
                        
//                        emojiPrevious = emoji
                        
                        isPresented.toggle()
                    }
                } else {
                    isPresented.toggle()
                }
            } label: {
                EditButton(buttonName: "저장")
            }
            .disabled(!isCancelEdit)
            .padding(.top, 10)
        }
        .sheet(isPresented: $isSheetEmoji) { // 시트로 이모지 뷰 띄움
            EmojiSheetView(show: $isSheetEmoji, txt: $emoji)
                .presentationDetents([.fraction(0.4)])
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                emoji = userInfoStore.userInfo?.profileImageName ?? ""
                
//                emojiPrevious = emoji
            }
        }
        .frame(maxWidth: 220, maxHeight: .infinity)
    }
}
//
//#Preview {
//    EditProfileView()
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//}


struct EditButton: View {
    var buttonName: String
    
    var body: some View {
        Text("\(buttonName)")
            .font(.title2)
            .bold()
            .frame(width: 220, height: 40)
            .background(Color.accentColor)
            .foregroundStyle(Color.white)
            .cornerRadius(15)
    }
}
