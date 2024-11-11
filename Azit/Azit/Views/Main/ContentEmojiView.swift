//
//  ContentEmojiView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/11/24.
//

import SwiftUI

struct ContentEmojiView: View {
    @EnvironmentObject var storyStore: StoryStore
    @Binding var userInfo: UserInfo
    @Binding var rotation: Double
    @Binding var isModalPresented: Bool
    @Binding var selectedIndex: Int
    var index: Int
    var startEllipse: (width: CGFloat, height: CGFloat)
    var endEllipse: (width: CGFloat, height: CGFloat)
    var interpolationRatio: CGFloat
    @State var randomAngleOffset: Double
    @State private var isPassed24Hours: Bool = false
    var num = 0
    
    var body: some View {
        let majorAxis = startEllipse.width / 2 * (1 - interpolationRatio) + endEllipse.width / 2 * interpolationRatio
        let minorAxis = startEllipse.height / 2 * (1 - interpolationRatio) + endEllipse.height / 2 * interpolationRatio
        let angle = (rotation + randomAngleOffset) * .pi / 180
        
        Button {
            selectedIndex = index
            isModalPresented = true
        } label: {
            VStack {
                Text("\(userInfo.nickname)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(UIColor.darkGray))
                    .frame(minWidth: 100)
                    .padding(.top, -40).scaleEffect(1)
                
                ZStack {
                    Ellipse()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                             center: .center,
                                             startRadius: 0,
                                             endRadius: 20))
                        .frame(width: 20 * (1.5 - interpolationRatio), height: 10 * (1.5 - interpolationRatio))
                    
                    Circle()
                        .fill(.clear)
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(isPassed24Hours ? AnyShapeStyle(Color.white) : AnyShapeStyle(Utility.createCircleGradient()), lineWidth: 3)
                                Text(userInfo.previousState)
                                    .font(.system(size: 25 * (1.5 - interpolationRatio)))
                            }
                            
                        )
                        .offset(x: 0, y: -30)
                        .frame(width: 40 * (1.5 - interpolationRatio), height: 40 * (1.5 - interpolationRatio))
                }
            }
        }
        .frame(width: 50, height: 50)
        .offset(x: majorAxis * cos(angle), y: minorAxis * sin(angle) + 250)
        .animation(.easeInOut(duration: 0.5), value: rotation)
        .onAppear {
            Task {
                let story = try await storyStore.loadRecentStoryById(id: userInfo.id)
                
                isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
            }
            
        }
    }
}

//#Preview {
//    ContentEmojiView()
//}
