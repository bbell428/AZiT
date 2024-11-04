//
//  UploadView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/1/24.
//

import SwiftUI

struct UploadView: View {
    var body: some View {
        GeometryReader { geometry in
                    Text("Hello, SwiftUI!")
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
    }
}

#Preview {
    UploadView()
}
