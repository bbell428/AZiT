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
    @State private var showHorizontalScroll = true
    @State private var offsetY: CGFloat = .zero
    @State private var lastOffsetY: CGFloat = .zero // 마지막 스크롤 위치 저장
    @Environment(\.dismiss) var dismiss
    @State private var items = Array(0..<10)
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .topTrailing) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 30)
                        
                        // 가운데 텍스트 영역
                        Text("Album : \(lastOffsetY)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Color.clear
                            .frame(maxWidth: .infinity)
                    }
                    .zIndex(3)
                    .frame(height: 70)
                    .background(Color.white)
                    
                    //                    HStack {
                    //                        Spacer()
                    //
                    //                        Button {
                    //                            // 날짜 선택
                    //                        } label: {
                    //                            Image(systemName: "line.3.horizontal.decrease")
                    //                        }
                    //                        .frame(width: 50, height: 30)
                    //                        .background(.subColor4)
                    //                        .cornerRadius(15)
                    //                        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 16))
                    //                    }
                    
                    
                    if showHorizontalScroll {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(0..<10) { _ in
                                    Button {
                                        // 사용자 상태 클릭 시,
                                    } label: {
                                        ZStack(alignment: .center) {
                                            Circle()
                                                .fill(.subColor4)
                                                .frame(width: 70, height: 70)
                                            
                                            Text("🤣")
                                                .font(.largeTitle)
                                        }
                                        .frame(alignment: .leading)
                                        .padding([.leading, .bottom], 10)
                                    }
                                }
                            }
                            .frame(height: 100)
                        }
                        .zIndex(2)
                        .transition(.move(edge: .top).combined(with: .opacity)) // 애니메이션 효과
                        .animation(.easeInOut(duration: 0.3), value: showHorizontalScroll)
                        .padding(.top, 70)
                        .background(Color.white)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 150)
                                .foregroundStyle(Color.white)
                            
                            GeometryReader { proxy in
                                let offsetY = proxy.frame(in: .global).origin.y
                                
                                DispatchQueue.main.async {
                                    // 현재 스크롤 위치와 마지막 위치의 차이가 50 이상일 때만 showHorizontalScroll을 업데이트
                                    if abs(offsetY - lastOffsetY) > 120 && lastOffsetY < 400 {
                                        withAnimation {
                                            showHorizontalScroll = offsetY > lastOffsetY
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
                            
                            Text("1시간 전")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                                ForEach(0..<1) { _ in
                                    VStack(alignment: .leading) {
                                        Image("Album")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(15)
                                            .frame(width: 120, height: 180)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        
                        VStack(alignment: .leading) {
                            Text("2시간 전")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                                ForEach(items.indices, id: \.self) { index in
                                    VStack(alignment: .leading) {
                                        Image("Album")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(15)
                                            .frame(width: 120, height: 180)
                                    }
                                    .onAppear {
                                        if index == items.count - 1 {
                                            Task {
                                                loadMoreItems()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
                        self.offsetY = value
                    })
                    .zIndex(1)
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

#Preview {
    AlbumView()
}
