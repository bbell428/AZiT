//
//  MessageView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var viewModel: ChatListStore
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                MessageTopBar() // 상단바
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                
                MessageList() // 메시지 목록
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                    .refreshable {
                        // 메시지 새로 고침 로직
                    }
            }
            .onAppear {
                viewModel.fetchChatList()
            }
        }
    }
}

struct MessageTopBar: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                HStack {
                    // 첫 번째 영역 (왼쪽 빈 공간)
                    Color.clear
                        .frame(maxWidth: .infinity)
                    
                    // 가운데 텍스트 영역
                    Text("Messages")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // 세 번째 영역 (오른쪽 화살표)
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.right")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 30) // 우측 여백 추가
                    }
                }
            }
        }
    }
}

struct MessageList: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<100) { chatroom in
                        NavigationLink {
                            VStack {
                                Text("ㅎㅇ")
                            }
                        } label: {
                            HStack {
                                ZStack(alignment: .center) {
                                    Circle()
                                        .fill(.subColor3)
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                    
                                    Text("\u{1F642}")
                                        .font(.largeTitle)
                                }
                                .frame(alignment: .leading)
                                .padding(.leading, 20)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("박준영")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.black)
                                        Text("4:11 PM")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    Text("너 고양시 근처야 ?")
                                        .font(.subheadline)
                                        .fontWeight(.thin)
                                        .foregroundStyle(Color.black)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                
                                ZStack(alignment: .center) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                                    
                                    Text("1")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white)
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 20)
                                
                            }
                            .frame(height: geometry.size.height * 0.1)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MessageView()
            .environmentObject(ChatListStore())
    }
}
