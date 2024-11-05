//
//  MyPageView.swift
//  Azit
//
//  Created by 김종혁 on 11/5/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var emoji: String = "🐶"
    @State var isShowEmoji = false
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.subColor4)
                        .frame(width: 150, height: 150)
                    Text(emoji)
                        .font(.system(size: 100))
                }
                HStack {
                    Text("지츄")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Button {
                        // 편집
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
                        Text("5")
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
                        
                        Button {
                            // 초대하기 액션
                        } label: {
                            Text("초대하기")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 13)
                                .padding(.vertical, 4)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    Divider()
                        .foregroundStyle(Color.accentColor)
                    
                    // 친구 항목 예시
                    ForEach(["박준영", "신현우", "김종혁"], id: \.self) { friend in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.subColor4)
                                    .frame(width: 45, height: 45)
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .bold()
                            }
                            Text(friend)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
