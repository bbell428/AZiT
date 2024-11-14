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
    
    @State var isShowCalendar: Bool = false
    @State private var selectedDate: Date = Date()
    @State var selectedIndex: Int = 0
    @State var selectedAlbum: Story?
    
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
                            isShowCalendar = true
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
                                message = ""
                            }
                            .zIndex(6)
                        
                        FriendsContentsModalView(message: $message, selectedUserInfo: $userInfoStore.friendInfos[selectedIndex], story: selectedAlbum)
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
                                    .fill(.accent)
                                    .frame(height: 0.2, alignment: .bottomLeading)
                                    .padding(.bottom, 1.4)
                            }
                            .zIndex(2)
                        }
                        .background(Color.white)
                        .padding(.top, 70)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(3)
                    }
                    
                    // 선택된 친구가 storys 값에 포함되고 있을경우 (= 게시물이 있을 경우)
                    if albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID }) && !getTimeGroupedStories().isEmpty {
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
                            Text("올라온 게시물이 없습니다.")
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
            .sheet(isPresented: $isShowCalendar) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .padding()
                    .background(Color.clear)
                    .presentationDetents([.height(400)])
                    .presentationBackground(.subColor4.opacity(0.95))
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
            ("최근", { $0.isWithin(hours: 24) }),
            ("1일 전", { $0.isWithin(hours: 48) && !$0.isWithin(hours: 24) }),
            ("2일 전", { $0.isWithin(hours: 72) && !$0.isWithin(hours: 48) }),
            ("3일 전", { $0.isWithin(hours: 96) && !$0.isWithin(hours: 72) }),
            ("4일 전", { $0.isWithin(hours: 120) && !$0.isWithin(hours: 96) }),
            ("5일 전", { $0.isWithin(hours: 144) && !$0.isWithin(hours: 120) }),
            ("6일 전", { $0.isWithin(hours: 168) && !$0.isWithin(hours: 144) }),
            ("1주일 전", { $0.isWithin(hours: 336) && !$0.isWithin(hours: 168) }),
            ("2주일 전", { $0.isWithin(hours: 672) && !$0.isWithin(hours: 336) }),
            ("3주일 전", { $0.isWithin(hours: 1008) && !$0.isWithin(hours: 672) }),
            ("4주일 전", { $0.isWithin(hours: 1344) && !$0.isWithin(hours: 1008) }),
            ("그 외", { !$0.isWithin(hours: 1344) })
        ]
        
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(selectedDate)
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        let selectedDayEnd = calendar.date(byAdding: .day, value: 1, to: selectedDayStart) ?? selectedDayStart

        return timeGroups.compactMap { group in
            let filteredStories: [Story]
            
            // 만약 날짜가 오늘이라면, 최근/1일/1주일.. 로직
            if isToday {
                filteredStories = albumstore.storys.filter { story in
                    story.userId == albumstore.filterUserID && group.1(story)
                }
                // 만약 날짜가 오늘이 아니라면, 해당하는 날짜만 가져오기
            } else {
                filteredStories = albumstore.storys.filter { story in
                    story.userId == albumstore.filterUserID &&
                    (selectedDayStart...selectedDayEnd).contains(story.date)
                }
            }

            let title: String
            if isToday {
                title = group.0
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "YYYY년 M월 d일"
                title = formatter.string(from: selectedDate)
            }
            
            return filteredStories.isEmpty ? nil : (title, filteredStories.sorted(by: { $0.date > $1.date }))
        }
    }
}

#Preview {
    AlbumView()
}
