//
//  SegmentedControlButtonView.swift
//  Azit
//
//  Created by 박준영 on 12/11/24.
//

import SwiftUI

struct SegmentedControlButtonView: View {
    @EnvironmentObject var albumstore: AlbumStore
    @Binding private var selectedIndex: Int
    @Binding private var frames: [CGRect]
    @Binding private var backgroundFrame: CGRect
    //@Binding private var isScrollable: Bool
    
    private let titles: [UserInfo]
    //let checkIsScrollable: (() -> Void)
    
    init(selectedIndex: Binding<Int>, frames: Binding<[CGRect]>, backgroundFrame: Binding<CGRect>, titles: [UserInfo])
    {
        _selectedIndex = selectedIndex
        _frames = frames
        _backgroundFrame = backgroundFrame
        //_isScrollable = isScrollable
        
        //self.checkIsScrollable = checkIsScrollable
        self.titles = titles
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 20, height: 1)
                .foregroundStyle(Color.white)
            
            ForEach(titles.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                    albumstore.filterUserID = titles[index].id
                    print("\(titles[index].nickname)의 id : \(titles[index].id)")
                } label: {
                    VStack(alignment: .center) {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(selectedIndex == index ? .accent.opacity(0.5) : .subColor4)
                                .frame(width: 70, height: 70)
                            
                            if titles[index].id != "000AzitALLFriends" {
                                Text(titles[index].profileImageName)
                                    .font(.largeTitle)
                            } else {
                                Image(systemName: "person.3.fill")
                                    .frame(width: 40, height: 40)  // Image 크기 명시
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.bottom, 5)
                        
                        HStack(alignment: .center) {
                            Text(titles[index].nickname)
                                .font(.caption2)
                                .foregroundStyle(selectedIndex == index ? .black : .gray)
                        }
                        .padding(.bottom, 5)
                    }
                }
                .buttonStyle(CustomSegmentButtonStyle())
                .background(
                    GeometryReader { geoReader in
                        Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                            .onPreferenceChange(RectPreferenceKey.self) {
                                self.setFrame(index: index, frame: $0)
                            }
                    }
                )
            }
            
            Spacer()
        }
        .modifier(UnderlineModifier(selectedIndex: selectedIndex, frames: frames))
    }
    
    private func setFrame(index: Int, frame: CGRect) {
        self.frames[index] = frame
        
        //checkIsScrollable()
    }
}

private struct CustomSegmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(5)
            .background(configuration.isPressed ? Color(red: 0.808, green: 0.831, blue: 0.855, opacity: 0.5): Color.clear)
    }
}
