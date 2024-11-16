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
    @State private var emojiPrevious: String = "" // 이전 이모지
    @State private var nickname: String = ""
    
    @State private var isEditingNickname = false // 닉네임 수정
    @State var isSheetEmoji = false // 이모지 뷰
    @State var isCancelEdit = false // 수정완료 버튼
    @State var isNicknameExists = false // 중복 닉네임 확인
    @State var isMyNickname: Bool = false // 나의 닉네임은 중복메시지 안뜨게 함
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
                    if emoji.count > 1 {
                        emoji = String(emoji.suffix(1))
                        isCancelEdit = true
                    }
                }
                .offset(x: 40, y: 60)
            }
            .padding(.top, 40)
            .frame(maxWidth: 220)
            
            VStack {
                if isNicknameExists && isMyNickname {
                    Text("이미 사용중인 닉네임입니다.")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                }
                HStack {
                    TextField("", text: $nickname)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .multilineTextAlignment(.center)
                        .disabled(!isEditingNickname)
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
                            if nickname.count > 1 && nickname.count < 9 && !hasSingleConsonantOrVowel {
                                Task {
                                    if await userInfoStore.isNicknameExists(nickname) { // 닉네임 중복 확인
                                        isCancelEdit = false
                                        isNicknameExists = true
                                    } else {
                                        isCancelEdit = true
                                        isNicknameExists = false
                                    }
                                    
                                    // 입력할때마다 변화, 나의 닉네임이라면 true바꾸어 중복메시지 안뜸
                                    isMyNickname = nickname != userInfoStore.userInfo?.nickname
                                }
                            } else {
                                isCancelEdit = false
                                isNicknameExists = false
                            }
                        }
                        .padding(.leading, 30)
                    Spacer()
                    
                    Button {
                        isEditingNickname.toggle()
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color.accentColor)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: 220)
                
                Divider()
                
                Text("2~8자로 입력해주세요.")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.top, -50)
            .padding(.vertical, 20)
            .frame(maxWidth: 220, maxHeight: 100)
            
            Button {
                if isCancelEdit {
                    Task {
                        await userInfoStore.updateUserInfo(UserInfo(
                            id: authManager.userID,
                            email: authManager.email,
                            nickname: nickname,
                            profileImageName: emoji,
                            previousState: emojiPrevious,
                            friends: userInfoStore.userInfo?.friends ?? [""],
                            latitude: userInfoStore.userInfo?.latitude ?? 0.0,
                            longitude: userInfoStore.userInfo?.longitude ?? 0.0,
                            blockedFriends: [])
                        )
                        
                        emojiPrevious = emoji
                        
                        isPresented.toggle()
                    }
                } else {
                    isPresented.toggle()
                }
            } label: {
                EditButton(buttonName: isCancelEdit ? "수정 완료" : "cancel")
            }
        }
        .sheet(isPresented: $isSheetEmoji) { // 시트로 이모지 뷰 띄움
            EmojiSheetView(show: $isSheetEmoji, txt: $emoji)
                .presentationDetents([.fraction(0.4)])
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.endTextEditing()
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: authManager.userID)
                emoji = userInfoStore.userInfo?.profileImageName ?? ""
                
                emojiPrevious = emoji
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .frame(maxWidth: 220, maxHeight: 40)
            .background(Color.accentColor)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
    }
}
