import SwiftUI

struct UnderlineModifier: ViewModifier {
    var selectedIndex: Int
    let frames: [CGRect]
    
    func body(content: Content) -> some View
    {
        content
            .background(
                Rectangle()
                    .fill(.accent)
                    .frame(width: frames[selectedIndex].width, height: 3)
                    .cornerRadius(12)
                    .offset(x: frames[selectedIndex].minX - frames[0].minX), alignment: .bottomLeading
            )
        //            .background(
        //                Rectangle()
        //                    .fill(Color.gray)
        //                    .frame(height: 1), alignment: .bottomLeading
        //            )
            .animation(.default)
    }
}

struct RectPreferenceKey: PreferenceKey {
    typealias Value = CGRect
    
    static var defaultValue = CGRect.zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect)
    {
        value = nextValue()
    }
}

struct FriendSegmentView: View {
    @Binding private var selectedIndex: Int
    
    @State private var frames: Array<CGRect>
    @State private var backgroundFrame = CGRect.zero
    @State private var isScrollable = true
    
    private let titles: [UserInfo]
    
    init(selectedIndex: Binding<Int>, titles: [UserInfo]) {
        self._selectedIndex = selectedIndex
        self.titles = titles
        frames = Array<CGRect>(repeating: .zero, count: titles.count)
    }
    
    var body: some View {
        VStack {
            if isScrollable {
                ScrollView(.horizontal, showsIndicators: false) {
                    SegmentedControlButtonView(selectedIndex: $selectedIndex, frames: $frames, backgroundFrame: $backgroundFrame, isScrollable: $isScrollable, checkIsScrollable: checkIsScrollable, titles: titles)
                }
            } else {
                SegmentedControlButtonView(selectedIndex: $selectedIndex, frames: $frames, backgroundFrame: $backgroundFrame, isScrollable: $isScrollable, checkIsScrollable: checkIsScrollable, titles: titles)
            }
        }
        .background(
            GeometryReader { geoReader in
                Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                    .onPreferenceChange(RectPreferenceKey.self) {
                        self.setBackgroundFrame(frame: $0)
                    }
            }
        )
    }
    
    private func setBackgroundFrame(frame: CGRect)
    {
        backgroundFrame = frame
        checkIsScrollable()
    }
    
    private func checkIsScrollable()
    {
        if frames[frames.count - 1].width > .zero
        {
            var width = CGFloat.zero
            
            for frame in frames
            {
                width += frame.width
            }
            
            if isScrollable && width <= backgroundFrame.width
            {
                isScrollable = false
            }
            else if !isScrollable && width > backgroundFrame.width
            {
                isScrollable = true
            }
        }
    }
}

private struct SegmentedControlButtonView: View {
    @Binding private var selectedIndex: Int
    @Binding private var frames: [CGRect]
    @Binding private var backgroundFrame: CGRect
    @Binding private var isScrollable: Bool
    
    private let titles: [UserInfo]
    let checkIsScrollable: (() -> Void)
    
    init(selectedIndex: Binding<Int>, frames: Binding<[CGRect]>, backgroundFrame: Binding<CGRect>, isScrollable: Binding<Bool>, checkIsScrollable: (@escaping () -> Void), titles: [UserInfo])
    {
        _selectedIndex = selectedIndex
        _frames = frames
        _backgroundFrame = backgroundFrame
        _isScrollable = isScrollable
        
        self.checkIsScrollable = checkIsScrollable
        self.titles = titles
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(titles.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                    print("\(titles[index].nickname)의 id : \(titles[index].id)")
                } label: {
                    VStack(alignment: .center) {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(selectedIndex == index ? .accent : .subColor4)
                                .frame(width: 70, height: 70)
                            
                            Text(titles[index].profileImageName)
                                .font(.largeTitle)
                        }
                        .padding(.bottom, 5)
                        
                        HStack(alignment: .center) {
                            Text(titles[index].nickname)
                                .font(.caption2)
                                .foregroundStyle(selectedIndex == index ? .black : .gray)
                        }
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
        
        checkIsScrollable()
    }
}

private struct CustomSegmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(EdgeInsets(top: 14, leading: 10, bottom: 14, trailing: 10))
            .background(configuration.isPressed ? Color(red: 0.808, green: 0.831, blue: 0.855, opacity: 0.5): Color.clear)
    }
}

//#Preview {
//    FriendSegmentView(selectedIndex: .constant(0), titles: [])
//}
