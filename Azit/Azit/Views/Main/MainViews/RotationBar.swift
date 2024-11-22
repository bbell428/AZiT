//
//  RotationBar.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/22/24.
//

import SwiftUI

struct RotationBar: View {
    @Binding var rotation: Double
    private let trackWidth: CGFloat = 150
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: trackWidth, height: 25)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(.accent)
                    .frame(width: max(CGFloat(rotation / 360) * trackWidth - 10, 0), height: 15)
                    .padding([.leading, .trailing], 5)
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newValue = min(max(0, value.location.x / trackWidth), 1) * 360
                        rotation = newValue
                    }
            )
            .onTapGesture { location in
                let newValue = min(max(0, location.x / trackWidth), 1) * 360
                rotation = newValue
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .onChange(of: rotation) { newValue in
            rotation = min(max(newValue, 0), 360)
        }
    }
}

//#Preview {
//    RotationBar()
//}
