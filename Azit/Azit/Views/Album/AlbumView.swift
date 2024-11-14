//
//  AlbumView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import UIKit

extension Story {
    func isWithin(hours: Int) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // 게시물 생성 시간이 현재 시간과 얼마나 차이가 나는지 계산
        let diffInHours = calendar.dateComponents([.hour], from: self.date, to: now).hour ?? 0
        return diffInHours < hours
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
    @State private var lastOffsetY: CGFloat = .zero
    @State private var items = Array(0..<10)
    @State private var isShowHorizontalScroll = true
    @State private var isLoading = false
    @State var isOpenCalendar: Bool = false
    @State var isFriendsContentModalPresented: Bool = false
    @State var message: String = ""
    
    @State private var selectedDate: Date = Date()
    @State var selectedIndex: Int = 0
    @State var selectedAlbum: Story?
    
    @State var userInfo: UserInfo = UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0)
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .top) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                        
                        Text("Album")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "calendar")
                                .font(.system(size: 25))
                        }
                        .padding(.horizontal, 20)
                        
                    }
                    .zIndex(4)
                    .frame(height: 70)
                    .background(Color.white)
                    
                    // 게시물을 클릭했을때, 상세정보
                    if isFriendsContentModalPresented {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isFriendsContentModalPresented = false
                                }
                                .zIndex(6)
                            
                            FriendsContentsModalView(message: $message, selectedUserInfo: $userInfo, story: selectedAlbum)
                                .zIndex(7)
                                .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    // 스크롤이 내려가지 않았거나, 위로 올렸을경우 (친구 리스트)
                    if isShowHorizontalScroll {
                        ZStack(alignment: .bottomLeading) {
                            FriendSegmentView(selectedIndex: $selectedIndex, titles: userInfoStore.friendInfos)
                                .animation(.easeInOut(duration: 0.3), value: isShowHorizontalScroll)
                            //.padding(.leading, 20)
                            //.background(Color.white)
                                .zIndex(3)
                            
                            VStack {
                                Rectangle()
                                    .fill(.subColor2)
                                    .frame(height: 1, alignment: .bottomLeading)
                                    .padding(.bottom, 1)
                            }
                            .zIndex(2)
                        }
                        .background(Color.white)
                        .padding(.top, 70)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(3)
                    }
                    
                    // 선택된 친구가 storys 값에 포함되고 있을경우 (= 게시물이 있을 경우)
                    if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID }) {
                        ScrollView {
                            Rectangle()
                                .frame(height: 160)
                                .foregroundStyle(Color.white)
                            
                            GeometryReader { proxy in
                                let offsetY = proxy.frame(in: .global).origin.y
                                
                                DispatchQueue.main.async {
                                    if abs(offsetY - lastOffsetY) > 120 && lastOffsetY < 400 {
                                        withAnimation {
                                            isShowHorizontalScroll = offsetY > lastOffsetY
                                        }
                                        lastOffsetY = offsetY
                                    }
                                }
                                
                                return Color.clear
                                    .preference(
                                        key: ScrollPreferenceKey.self,
                                        value: offsetY
                                    )
                            }
                            .frame(height: 0)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), alignment: .leading, spacing: 5) {
                                ForEach(getTimeGroupedStories(), id: \.title) { group in
                                    Section(header: HStack {
                                        Text(group.title)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.gray)
                                        Spacer()
                                    }
                                        .padding(.top, 20)
                                    ) {
                                        ForEach(group.stories) { story in
                                            VStack(alignment: .leading) {
                                                Button {
                                                    selectedAlbum = story
                                                    isFriendsContentModalPresented = true
                                                } label: {
                                                    Image("Album")
                                                        .resizable()
                                                    //.aspectRatio(contentMode: .fill)
                                                        .cornerRadius(15)
                                                        .frame(maxWidth: 120, maxHeight: 160)
                                                    //Text(story.content)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
                            self.offsetY = value
                        })
                        .zIndex(1)
                    } else {
                        VStack(alignment: .center) {
                            Spacer()  // 위쪽 Spacer
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.gray)
                                .padding(.bottom, 10)
                            Text("현재 올라온 게시물이 없습니다.")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            Spacer()  // 아래쪽 Spacer
                        }
                        .frame(maxHeight: .infinity)  // 화면 중앙에 오도록 설정
                    }
                }
            }
            .onAppear {
                Task {
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
    
    
    func getTimeGroupedStories() -> [(title: String, stories: [Story])] {
        let timeGroups: [(String, (Story) -> Bool)] = [
            ("최근", { $0.isWithin(hours: 24) }),  // 오늘: 24시간 이내
            ("1일 전", { $0.isWithin(hours: 48) && !$0.isWithin(hours: 24) }),  // 1일 전: 24~48시간 이내
            ("2일 전", { $0.isWithin(hours: 72) && !$0.isWithin(hours: 48) }),  // 2일 전: 48~72시간 이내
            ("3일 전", { $0.isWithin(hours: 96) && !$0.isWithin(hours: 72) }),  // 3일 전: 72~96시간 이내
            ("4일 전", { $0.isWithin(hours: 120) && !$0.isWithin(hours: 96) }),  // 4일 전: 96~120시간 이내
            ("5일 전", { $0.isWithin(hours: 144) && !$0.isWithin(hours: 120) }),  // 5일 전: 120~144시간 이내
            ("6일 전", { $0.isWithin(hours: 168) && !$0.isWithin(hours: 144) }),  // 6일 전: 144~168시간 이내
            ("1주일 전", { $0.isWithin(hours: 336) && !$0.isWithin(hours: 168) }),  // 1주일 전: 168~336시간 이내
            ("2주일 전", { $0.isWithin(hours: 672) && !$0.isWithin(hours: 336) }),  // 2주일 전: 336~672시간 이내
            ("3주일 전", { $0.isWithin(hours: 1008) && !$0.isWithin(hours: 672) }),  // 3주일 전: 672~1008시간 이내
            ("4주일 전", { $0.isWithin(hours: 1344) && !$0.isWithin(hours: 1008) }),  // 4주일 전: 1008~1344시간 이내
            ("그 외", { !$0.isWithin(hours: 1344) })  // 4주 이상: 1344시간 이상
        ]
        
        return timeGroups.compactMap { group in
            let filteredStories = albumstore.storys.filter { story in
                return story.userId == albumstore.filterUserID && group.1(story)
            }
            
            return filteredStories.isEmpty ? nil : (group.0, filteredStories)
        }
    }
}

#Preview {
    AlbumView()
}
