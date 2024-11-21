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
    @Environment(\.dismiss) var dismiss
    @State private var offsetY: CGFloat = .zero
    @State private var lastOffsetY: CGFloat = .zero
    @State private var items = Array(0..<10)
    @State private var isShowHorizontalScroll = true
    @State private var isLoading = false
    @State var isOpenCalendar: Bool = false
    @State var isFriendsContentModalPresented: Bool = false // 게시물 선택시,
    @State var message: String = ""
    
    @State var isShowCalendar: Bool = false
    @State var selectedIndex: Int = 0
    @State var selectedAlbum: Story?
    
    @Binding var isShowToast: Bool
    
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
                    
                    // 스토리 클릭시, 상세 정보
                    if isFriendsContentModalPresented {
                        AlbumDetailView(isFriendsContentModalPresented: $isFriendsContentModalPresented, message: $message, selectedIndex: $selectedIndex, isShowToast: $isShowToast, selectedAlbum: selectedAlbum)
                            .zIndex(7)
                    }
                    
                    // 이미지를 불러오는중이라면
                    if albumstore.loadingImage {
                        Color.gray.opacity(0.5)
                            .ignoresSafeArea()
                            .padding(.top, 70)
                            .zIndex(4)
                        
                        VStack(alignment: .center) {
                            Spacer()
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("스토리 불러오는중...")
                                    .foregroundStyle(Color.white)
                            }
                            .padding(15)
                            .background(Color.accent.opacity(0.8))
                            .cornerRadius(15)
                            .frame(width: 250, height: 150)
                            Spacer()
                        }
                        .zIndex(4)
                    }
                    
                    // 스크롤이 내려가지 않았거나, 위로 올렸을경우 (친구 리스트)
                    if isShowHorizontalScroll {
                        AlbumFriendListView(isShowHorizontalScroll:
                                                $isShowHorizontalScroll, selectedIndex: $selectedIndex)
                        .background(Color.white)
                        .padding(.top, 70)
                        .zIndex(3)
                    }
                    
                    // 만약 친구가 없으면,
                    if userInfoStore.friendInfos.isEmpty {
                        VStack(alignment: .center) {
                            Spacer()  // 위쪽 Spacer
                            Image(systemName: "photo.badge.plus.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.gray)
                                .padding(.bottom, 10)
                            Text("친구를 초대해서 공유 앨범을 시작해보세요!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            Spacer()  // 아래쪽 Spacer
                        }
                        .frame(maxHeight: .infinity)  // 화면 중앙에 오도록 설정
                    } else {
                        // 선택된 친구가 storys 값에 포함되고 있을경우 (= 스토리가 있을 경우)
                        if (albumstore.storys.contains(where: { $0.userId == albumstore.filterUserID }) && !albumstore.getTimeGroupedStories().isEmpty) || albumstore.filterUserID == "000AzitALLFriends" {
                            AlbumScrollView(lastOffsetY: $lastOffsetY, isShowHorizontalScroll: $isShowHorizontalScroll, isFriendsContentModalPresented: $isFriendsContentModalPresented, selectedAlbum: $selectedAlbum)
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
            }
            .onAppear {
                Task {
                    await albumstore.loadStorysByIds(ids: userInfoStore.userInfo?.friends ?? [])
                    albumstore.filterUserID = "000AzitALLFriends"
                }
            }
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
    
    func loadMoreItems() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newItems = Array(items.count..<(items.count + 10))
            items.append(contentsOf: newItems)
            isLoading = false
        }
    }
}

//#Preview {
//    AlbumView()
//}
