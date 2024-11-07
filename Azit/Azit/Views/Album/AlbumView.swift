//
//  AlbumView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI
import UIKit

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    @State private var items = Array(0..<10)
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 가운데 텍스트 영역
                    Text("Album")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Color.clear
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 100)
                .padding(.horizontal, 30)
                
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
                                    
                                    Text("🤣") // 프로필 이미지가 문자열로 설정된 경우
                                        .font(.largeTitle)
                                }
                                .frame(alignment: .leading)
                                .padding(.leading, 10)
                            }
                            
                        }
                    }
                }
                .frame(height: 50)
                
                VStack(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .frame(width: 50, height: 30)
                    .background(.subColor4)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 16))
                    
                    // 시간대별로 묶어서 for문으로 만들고 처리
                    ScrollView {
                        VStack(alignment: .leading) {
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
                                            // Check if it's the last item based on the index
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
                    
                }
                .frame(maxHeight: .infinity)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // 하단으로 내려갔을때, 다음 데이터를 가져오는 로직
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
