//
//  SearchView.swift
//  Azit
//
//  Created by 홍지수 on 11/6/24.
//

import SwiftUI

enum field {
    case search
}

struct SearchView: View {
    @Binding var search: String
    @Binding var searchEnabled: Bool
    @FocusState var focusField: field?
    @FocusState private var isSearchFieldFocused: Bool
    // 검색 결과
    @State private var searchResults: [Emoji] = []
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 0.5)
                                .background(Color.white)
                                .foregroundStyle(Color.white)
                                .frame(width: 340, height: 40)
                            HStack {
                                Image(systemName:"magnifyingglass")
                                    .foregroundStyle(.accent)
                                    .padding(.leading, 10)
                                TextField("이모지 검색", text: $search)
                                    .focused($focusField, equals: .search)
                                    .autocorrectionDisabled()
                                    .onChange(of: search) { value in
                                        if !value.isEmpty {
                                            searchEnabled = true
                                        }
                                    }
                                if !search.isEmpty {
                                    clearTextButton()
                                        .foregroundStyle(.accent)
                                        .padding(.trailing, 16)
                                }
                            }
                            .frame(width: 340, height: 40)
                        }
                        
                    }
                    .frame(width: proxy.size.width)
                }
            }
            .toolbarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                    Button("완료") {
                        isSearchFieldFocused = false // 키보드 숨기기
                    }
                }
            }
        }
    }
}

extension SearchView {
    
    @ViewBuilder
    private func clearTextButton() -> some View {
        Button {
            self.search = ""
        } label : {
            Image(systemName: "x.circle.fill")
        }
    }
}

