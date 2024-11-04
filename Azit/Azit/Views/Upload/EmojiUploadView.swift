//
//  EmojiUploadView.swift
//  Azit
//
//  Created by 홍지수 on 11/4/24.
//

import SwiftUI

struct EmojiUploadView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: CameraView()) {
                    Text("Open Camera")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .navigationBarTitle("Init View", displayMode: .inline)
        }
    }
}
