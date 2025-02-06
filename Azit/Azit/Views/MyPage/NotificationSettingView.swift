//
//  NotificationSettingView.swift
//  Azit
//
//  Created by 김종혁 on 2/7/25.
//

import SwiftUI

struct NotificationSettingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isNotificationsEnabled = true // 버튼 클릭 시
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                
                Text("Notification")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Color.clear
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 70)
            .background(Color.white)
            
            VStack {
                Toggle(isOn: $isNotificationsEnabled) {
                    Text("전체 알림")
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))  // 초록색 ON (true)
                .padding()
            }
            Spacer()
        }
        .frame(width: 370)
        .navigationBarBackButtonHidden(true)
    }
}
