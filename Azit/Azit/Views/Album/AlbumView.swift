//
//  AlbumView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import UIKit


struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct AlbumView: View {
    @EnvironmentObject var albumstore: AlbumStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @State private var offsetY: CGFloat = .zero
    @State private var lastOffsetY: CGFloat = .zero
    @State private var items = Array(0..<10)
    @State private var isShowVerticalScroll = true // 밑으로 스크롤되어서 화면이 숨겨져 있는가?
    @State private var isLoading = false
    @State var isOpenCalendar: Bool = false
    @State var isFriendsContentModalPresented: Bool = false // 게시물 선택시,
    @State var message: String = ""
    @State var isShowCalendar: Bool = false
    @State var selectedIndex: Int = 0 // 선택된 친구 (순서, index)
    
    @State var selectedAlbum: Story?
    
    @Binding var isSendFriendStoryToast: Bool
    
    // 계산형 프로퍼티로 친구 리스트 생성
    private var friendList: [String] {
        guard let userInfo = userInfoStore.userInfo else { return [] }
        var list = userInfo.friends
        list.append(userInfo.id)
        return list
    }
    
    private var combinedFriendList: [UserInfo] {
        var list = userInfoStore.friendInfos
        if let user = userInfoStore.userInfo {
            list.append(user)
        }
        return list
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .top) {
                    // MARK: 앨범 상단바
                    AlbumNavigationBarView(isShowCalendar: $isShowCalendar)
                        .zIndex(4)
                    
                    // 스토리 클릭시, 상세 정보
                    if isFriendsContentModalPresented {
                        // MARK: 스토리 상세 View
                        AlbumDetailView(isFriendsContentModalPresented: $isFriendsContentModalPresented, message: $message, selectedIndex: $selectedIndex, isSendFriendStoryToast: $isSendFriendStoryToast, selectedAlbum: selectedAlbum, list: combinedFriendList)
                            .zIndex(7)
                    }
                    
                    // 이미지를 불러오는중이라면, 로딩화면이 뜨게 함
                    if albumstore.loadingImage {
                        Color.gray.opacity(0.5)
                            .ignoresSafeArea()
                            .zIndex(4)
                        
                        VStack(alignment: .center) {
                            Spacer()
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }
                            .padding(30)
                            .background(Color.black.opacity(0.5))
                            .background(
                                BlurView(style: .systemMaterial) // 사각형 블러
                            )
                            .cornerRadius(15)
                            .frame(width: 250, height: 150)
                            Spacer()
                        }
                        .zIndex(9)
                    }
                    
                    // 스크롤이 내려가지 않았거나, 위로 올렸을경우 (친구 리스트)
                    if isShowVerticalScroll {
                        // MARK: 친구 리스트
                        AlbumFriendListView(isShowVerticalScroll:
                                                $isShowVerticalScroll, selectedIndex: $selectedIndex, combinedFriendList: combinedFriendList)
                        .zIndex(3)
                    }
                    
                    // 만약 친구가 없으면,
                    if userInfoStore.friendInfos.isEmpty {
                        VStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "photo.badge.plus.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.gray)
                                .padding(.bottom, 10)
                            Text("친구를 초대해서 공유 앨범을 시작해보세요!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        // 선택된 친구가 storys 값에 포함되고 있을경우 (= 스토리가 있을 경우)
                    } else {
                        if (albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID }) && !albumstore.getTimeGroupedStories().isEmpty) || albumstore.filterUserID == "000AzitALLFriends" {
                            // MARK: 친구 스토리 리스트
                            AlbumScrollView(lastOffsetY: $lastOffsetY, isShowVerticalScroll: $isShowVerticalScroll, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedStory: $selectedAlbum)
                                .padding(.horizontal, 20)
                                .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
                                    self.offsetY = value
                                })
                                .zIndex(1)
                            // 친구는 있지만, 친구가 올린 게시물이 없을경우
                        } else {
                            VStack(alignment: .center) {
                                Spacer()
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.gray)
                                    .padding(.bottom, 10)
                                Text("올라온 게시물이 없습니다.")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.gray)
                                Spacer()
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    
                }
            }
            .onAppear {
                Task {
                    await albumstore.loadStorysByIds(ids: friendList)
                    albumstore.filterUserID = "000AzitALLFriends" // 처음에 전체를 보여주게 함
                    // 000AzitALLFriends = "전체" 를 의미합니다.
                }
            }
            // MARK: 특정 날짜 선택
            .sheet(isPresented: $isShowCalendar) {
                DatePicker("Select Date", selection: $albumstore.selectedDate, displayedComponents: [.date])
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
    
    // 현재로써는 아직 사용하지 않음.
    // 스크롤 할때마다 리스트를 추가해서 보여주는 함수
    //    func loadMoreItems() {
    //        isLoading = true
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //            let newItems = Array(items.count..<(items.count + 10))
    //            items.append(contentsOf: newItems)
    //            isLoading = false
    //        }
    //    }
}
