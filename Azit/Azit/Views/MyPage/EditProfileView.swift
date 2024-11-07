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
            .padding(.top, 30)
            .frame(maxWidth: 180)
            
            VStack {
                HStack {
                    TextField("", text: $nickname)
                        .font(.title)
                        .foregroundStyle(Color.accentColor)
                        .multilineTextAlignment(.center)
                        .disabled(!isEditingNickname)
                        .onAppear {
                            if nickname.isEmpty {
                                nickname = userInfoStore.userInfo?.nickname ?? ""
                            }
                        }
                        .onChange(of: nickname) {
                            if nickname != userInfoStore.userInfo?.nickname ?? "" {
                                isCancelEdit = true
                            } else if nickname == userInfoStore.userInfo?.nickname {
                                isCancelEdit = false
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
                .frame(maxWidth: 180)
                
                Divider()
            }
            .padding(.top, -50)
            .padding(.vertical, 20)
            .frame(maxWidth: 180)
            
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
                            longitude: userInfoStore.userInfo?.longitude ?? 0.0))
                        
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
            .frame(maxWidth: 180, maxHeight: 35)
            .background(Color.accentColor)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
    }
}
