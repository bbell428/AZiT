//
//  AlbumNavigationBarView.swift
//  Azit
//
//  Created by 박준영 on 12/11/24.
//

import SwiftUI

struct AlbumNavigationBarView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isShowCalendar: Bool
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 30)
            
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
            .padding(.horizontal, 30)
            
        }
        .frame(height: 70)
        .background(Color.white)
    }
}


