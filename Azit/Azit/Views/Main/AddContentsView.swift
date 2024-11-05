//
//  AddContentsView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI

struct AddContentsView: View {
    @Binding var contentText: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "location")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                        
                        Text("경상북도 경산시")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                        
                        NavigationLink {
                            
                        } label: {
                            Text("전체 공개")
                                .font(.caption)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.right")
                        }
                        
                        
                    }
                }
                
                // 이모지 선택 창 불러와야 함 (이모지 피커)
                
                TextField("message", text: $contentText, prompt: Text("텍스트를 입력해주세요.")
                    .font(.caption))
                .padding(10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Button {
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(height: 40)
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 25)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview {
    AddContentsView(contentText: .constant(""))
}
