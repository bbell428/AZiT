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
    
    var body: some View {
        NavigationStack {
            VStack() {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30) // 우측 여백 추가
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
                
                ScrollView(.horizontal) {
                    HStack {
                            ForEach(0..<10) { _ in
                                Rectangle()
                                    .frame(width: 50, height: 50)
                            }
                        }
                }
                .frame(height: 50)
                .padding([.leading, .trailing])
                
                VStack {
                    Button {
                        
                    } label: {
                        Text("필터")
                    }

                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            ForEach(0..<30) { _ in
                                Rectangle()
                                    .frame(width: 100, height: 100)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding([.leading, .trailing])
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AlbumView()
}
