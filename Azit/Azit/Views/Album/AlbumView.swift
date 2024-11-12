//
//  AlbumView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import UIKit

extension Story {
    func isWithin(minutes: Int) -> Bool {
        guard let diff = Calendar.current.dateComponents([.minute], from: self.date, to: Date()).minute else {
            return false
        }
        return diff < minutes
    }
    
    func isWithin(hours: Int) -> Bool {
        guard let diff = Calendar.current.dateComponents([.hour], from: self.date, to: Date()).hour else {
            return false
        }
        return diff < hours
    }
    
    func isWithin(days: Int) -> Bool {
        guard let diff = Calendar.current.dateComponents([.day], from: self.date, to: Date()).day else {
            return false
        }
        return diff < days
    }
}

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct AlbumView: View {
    @EnvironmentObject var albumstore: AlbumStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Environment(\.dismiss) var dismiss
    @State private var offsetY: CGFloat = .zero
    @State private var lastOffsetY: CGFloat = .zero // 마지막 스크롤 위치 저장
    @State private var items = Array(0..<10)
    @State private var isShowHorizontalScroll = true
    @State var selectedIndex: Int = 0
    @State private var isLoading = false
    @State var isOpenCalendar: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .topLeading) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 30)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                        
                        // 가운데 텍스트 영역
                        Text("Album")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                        
                        Button {
                            isOpenCalendar = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.system(size: 25))
                        }
                        .padding(.horizontal, 30)
                        
                    }
                    .zIndex(3)
                    .frame(height: 70)
                    .background(Color.white)
                    
                    if isShowHorizontalScroll {
                        FriendSegmentView(selectedIndex: $selectedIndex, titles: userInfoStore.friendInfos)
                            .zIndex(2)
                            .transition(.move(edge: .top).combined(with: .opacity)) // 애니메이션 효과
                            .animation(.easeInOut(duration: 0.3), value: isShowHorizontalScroll)
                            .padding(.top, 60)
                            .background(Color.white)
                    }
                    
                    ScrollView {
                        Rectangle()
                            .frame(height: 180)
                            .foregroundStyle(Color.white)
                        
                        GeometryReader { proxy in
                            let offsetY = proxy.frame(in: .global).origin.y
                            
                            DispatchQueue.main.async {
                                // 현재 스크롤 위치와 마지막 위치의 차이가 50 이상일 때만 showHorizontalScroll을 업데이트
                                if abs(offsetY - lastOffsetY) > 120 && lastOffsetY < 400 {
                                    withAnimation {
                                        isShowHorizontalScroll = offsetY > lastOffsetY
                                    }
                                    lastOffsetY = offsetY // 마지막 위치 업데이트
                                }
                            }
                            
                            return Color.clear
                                .preference(
                                    key: ScrollPreferenceKey.self,
                                    value: offsetY
                                )
                        }
                        .frame(height: 0)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), alignment: .leading) {
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 1) }) {
                                Section(header: HStack { Text("1분 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 1) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 5) && !$0.isWithin(minutes: 1) }) {
                                Section(header: HStack { Text("5분 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 5) && !$0.isWithin(minutes: 1) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 10) && !$0.isWithin(minutes: 5) }) {
                                Section(header: HStack { Text("10분 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 10) && !$0.isWithin(minutes: 5) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 30) && !$0.isWithin(minutes: 10) }) {
                                Section(header: HStack { Text("30분 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(minutes: 30) && !$0.isWithin(minutes: 10) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(hours: 1) && !$0.isWithin(minutes: 30) }) {
                                Section(header: HStack { Text("1시간 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(hours: 1) && !$0.isWithin(minutes: 30) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(hours: 3) && !$0.isWithin(hours: 1) }) {
                                Section(header: HStack { Text("3시간 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(hours: 3) && !$0.isWithin(hours: 1) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID && $0.isWithin(days: 1) && !$0.isWithin(hours: 3) }) {
                                Section(header: HStack { Text("1일 전").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter { $0.userId == albumstore.filterUserID && $0.isWithin(days: 1) && !$0.isWithin(hours: 3) }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                            
                            if albumstore.storys.contains(where: {
                                $0.userId == albumstore.filterUserID &&
                                !$0.isWithin(days: 1)
                            }) {
                                Section(header: HStack { Text("이전 날짜").font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.gray)
                                    Spacer() }) {
                                        ForEach(albumstore.storys.filter {
                                            $0.userId == albumstore.filterUserID &&
                                            !$0.isWithin(days: 1)
                                        }) { story in
                                            StoryView(story: story)
                                        }
                                    }
                            }
                        }
                        
                    }
                    .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
                        self.offsetY = value
                    })
                    .zIndex(1)
                }
            }
            .onAppear {
                Task {
                    // 친구 게시물 가져오기
                    await albumstore.loadStorysByIds(ids: userInfoStore.userInfo?.friends ?? [])
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func loadMoreItems() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newItems = Array(items.count..<(items.count + 10))
            items.append(contentsOf: newItems)
            isLoading = false
        }
    }
}

struct StoryView: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Album")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(15)
                .frame(width: 120, height: 160)
            Text(story.content)
        }
    }
}

#Preview {
    AlbumView()
}
