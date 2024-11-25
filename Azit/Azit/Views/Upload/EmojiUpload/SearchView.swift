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
    @State private var searchResults: [Emoji] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 0.5)
                            .background(Color.white)
                            .foregroundStyle(Color.white)
                            .frame(width: 340, height: 40)
                        HStack {
                            Image(systemName:"magnifyingglass")
                                .foregroundStyle(.accent)
                                .padding(.leading, 10)
                            TextField("이모지 검색", text: $search)
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
                .frame(width: 340, height: 40)
            }
        }
        .toolbarTitleDisplayMode(.automatic)
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

