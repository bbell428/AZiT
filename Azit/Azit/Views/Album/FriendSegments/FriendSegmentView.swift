import SwiftUI

// 친구 리스트
struct FriendSegmentView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Binding private var selectedIndex: Int
    
    @State private var frames: Array<CGRect>
    @State private var backgroundFrame = CGRect.zero
    
    private let friendList: [UserInfo]
    
    init(selectedIndex: Binding<Int>, titles: [UserInfo]) {
        self._selectedIndex = selectedIndex
        var modifiedTitles = titles
        
        // 만약, 친구 리스트가 한명이라도 있다면 "전체" 버튼 추가
        if !modifiedTitles.isEmpty {
            let dummyData = UserInfo(
                id: "000AzitALLFriends",
                email: "",
                nickname: "전체",
                profileImageName: "",
                previousState: "",
                friends: [],
                latitude: 0.0,
                longitude: 0.0,
                blockedFriends: [],
                fcmToken: ""
            )
            modifiedTitles.append(dummyData)
        }
        
        // id를 기준으로 정렬
        modifiedTitles.sort { $0.id < $1.id }
        
        self.friendList = modifiedTitles
        frames = modifiedTitles.isEmpty
        ? [CGRect(x: 0, y: 0, width: 100, height: 50)]
        : Array<CGRect>(repeating: .zero, count: modifiedTitles.count)  // 기본값 설정
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    // MARK: 각 친구의 버튼 View
                    SegmentedControlButtonView(selectedIndex: $selectedIndex, frames: $frames, backgroundFrame: $backgroundFrame, titles: friendList)
                    // 해당 친구를 선택시, 해당 위치로 스크롤되게 애니메이션 적용
                        .onChange(of: selectedIndex) { newIndex, _ in
                            withAnimation() {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                }
            }
        }
    }
    
    private func setBackgroundFrame(frame: CGRect)
    {
        backgroundFrame = frame
    }
}
