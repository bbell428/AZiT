//
//  PublishScopeView.swift
//  Azit
//
//  Created by 홍지수 on 11/5/24.
//

import SwiftUI

struct PublishScopeView: View {
    var friend1: UserInfo = .init(id: "1", email: "",nickname: "Hong", profileImageName: "😋",previousState: "",friends: [], latitude: 0.0, longitude: 0.0)
    var friend2: UserInfo = .init(id: "2", email: "",nickname: "Hong", profileImageName: "🩵",previousState: "",friends: [], latitude: 0.0, longitude: 0.0)
    var friend3: UserInfo = .init(id: "3", email: "",nickname: "Hong", profileImageName: "🤩",previousState: "",friends: [], latitude: 0.0, longitude: 0.0)
    var friend4: UserInfo = .init(id: "4", email: "",nickname: "Hong", profileImageName: "🐼",previousState: "",friends: [], latitude: 0.0, longitude: 0.0)
    
    @State var isSelected: Bool = false
    @State var AllSelected: Bool = true
    
    var body: some View {
        var friends: [UserInfo] = [friend1, friend2, friend3, friend4]
        
        List {
            Button (action: {
                AllSelected = true
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.subColor4)
                        Image(systemName: "person")
                            .foregroundStyle(.accent)
                    }
                    Text("ALL")
                        .font(.title2)
                    Spacer()
                    if AllSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .padding(10)
            
            ForEach(friends) { friend in
                Button (action: {
                    isSelected.toggle()
                }) {
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.subColor4)
                            Text(friend.profileImageName)
                                .font(.title2)
                        }
                        Text(friend.nickname)
                            .font(.title2)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .padding(10)
            }
            .listStyle(PlainListStyle())
        }
    }
}

