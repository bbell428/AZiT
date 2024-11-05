//
//  RotationView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/4/24.
//

import SwiftUI



struct RotationView: View {
    @State private var rotation: Double = 270.0
    @Binding var isModalPresented: Bool
    @State private var message: String = ""
    @State var sortedUsers: [UserInfo] = []
    let angles: [(Double, Double)] = [
        (0, 60),
        (-60, 0),
        (60, 120),
        (-120, -60),
        (120, 180),
        (-180, -120),
        (180, 240),
        (-240, -180),
        (240, 300),
        (-300, -240),
        (300, 360),
        (-360, -300),
        (360, 420),
        (-420, -360),
        (420, 480),
        (-480, -420),
        (480, 540),
        (-540, -480),
        (540, 600),
        (-600, -540),
        (600, 660),
        (-660, -600),
        (660, 720),
        (-720, -660),
        (720, 780),
        (-780, -720),
        (780, 840),
        (-840, -780),
        (840, 900),
        (-900, -840),
        (900, 960),
        (-960, -900),
        (960, 1020),
        (-1020, -960),
        (1020, 1080),
        (-1080, -1020),
        (1080, 1140),
        (-1140, -1080),
        (1140, 1200),
        (-1200, -1140),
        (1200, 1260),
        (-1260, -1200),
        (1260, 1320),
        (-1320, -1260),
        (1320, 1380),
        (-1380, -1320),
        (1380, 1440),
        (-1440, -1380),
        (1440, 1500),
        (-1500, -1440)
    ]
    private let ellipses: [(width: CGFloat, height: CGFloat)] = [
        (1260, 1008), (967, 774), (674, 540), (285, 225)
    ]
    
    @State private var numberOfCircles: Int = 0
    
    let sampleMyInfo: UserInfo = UserInfo(id: "10", email: "user10@example.com", nickname: "혀누", profileImageName: "😲", previousState: "😕", friends: ["9"], latitude: 34.0522, longitude: -118.2437)

    @State var sampleUserInfos: [UserInfo] = [
        UserInfo(id: "1", email: "user1@example.com", nickname: "준영", profileImageName: "😊", previousState: "😄", friends: ["2", "3"], latitude: 37.5665, longitude: 126.978),
        UserInfo(id: "2", email: "user2@example.com", nickname: "종혁", profileImageName: "😎", previousState: "🤔", friends: ["1", "4"], latitude: 34.0522, longitude: -118.2437),
        UserInfo(id: "3", email: "user3@example.com", nickname: "지수", profileImageName: "😇", previousState: "😌", friends: ["1"], latitude: 51.5074, longitude: -0.1278),
        UserInfo(id: "4", email: "user4@example.com", nickname: "차나핑", profileImageName: "😋", previousState: "😓", friends: ["2"], latitude: 48.8566, longitude: 2.3522),
        UserInfo(id: "5", email: "user5@example.com", nickname: "좀하디", profileImageName: "😃", previousState: "😊", friends: ["6", "7"], latitude: 35.6895, longitude: 139.6917),
        UserInfo(id: "6", email: "user6@example.com", nickname: "주녕란보", profileImageName: "😏", previousState: "😌", friends: ["5"], latitude: -33.8688, longitude: 151.2093),
        UserInfo(id: "7", email: "user7@example.com", nickname: "홈지수", profileImageName: "😜", previousState: "😃", friends: ["5", "8"], latitude: 55.7558, longitude: 37.6173),
        UserInfo(id: "8", email: "user8@example.com", nickname: "잠온다", profileImageName: "😆", previousState: "😝", friends: ["7", "9"], latitude: 40.7128, longitude: -74.0060),
        UserInfo(id: "9", email: "user9@example.com", nickname: "나도잠와", profileImageName: "😍", previousState: "😌", friends: ["8", "10"], latitude: 39.9042, longitude: 116.4074)
    ]

    var body: some View {
        VStack {
            ZStack {
                Button {
                    
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .frame(width: 100, height: 100)
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(.white, lineWidth: 3)
                                    Text(sampleMyInfo.previousState)
                                        .font(.system(size: 80))
                                }
                            )
                                                    
                        Circle()
                            .fill(.white)
                            .frame(width: 25, height: 25)
                            .overlay(
                                Text("+")
                                    .fontWeight(.black)
                            )
                            .offset(y: 50)
                    }
                }
                .zIndex(1)
                .offset(y: 250)
            
                ForEach(0..<4, id: \.self) { index in
                    Ellipse()
                        .fill(createGradient(index: index, width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234))))
                        .frame(width: CGFloat(1260 - index * 293), height: CGFloat(1008 - CGFloat(index * 234)))
                        .overlay(
                            Ellipse()
                                .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        )
                        .offset(y: 250)
                        .zIndex(0)
                }
                
                if numberOfCircles > 0 {
                    ForEach(0..<numberOfCircles, id: \.self) { index in
                        let startEllipse = ellipses[3]
                        let endEllipse = ellipses[0]
                        let randomAngleOffset = Double.random(in: angles[index % 6].0..<angles[index % 6].1)

                        let interpolationRatio: CGFloat = numberOfCircles > 1 ? CGFloat(index) / CGFloat(numberOfCircles - 1) : 0

                        ContentEmojiView(userInfo: $sortedUsers[index], rotation: $rotation, isModalPresented: $isModalPresented, index: index, startEllipse: startEllipse, endEllipse: endEllipse, interpolationRatio: interpolationRatio, randomAngleOffset: randomAngleOffset, num : index)
                    }
                }
                if isModalPresented {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isModalPresented = false
                        }
                        .zIndex(1)
                    
                    ContentsModalView(isModalPresented: $isModalPresented, message: $message)
                        .zIndex(3)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        rotation += Double(value.translation.width) * 0.05
                    }
            )
            .padding()
        }
        .onAppear {
            sortedUsers = sortUsersByDistance(from: sampleUserInfos[0], users: sampleUserInfos)
            numberOfCircles = sampleUserInfos.count
        }
    }

    private func createGradient(index: Int, width: CGFloat, height: CGFloat) -> RadialGradient {
        let colors: [Color] = [.subColor4, .subColor3, .subColor2, .subColor1]
        let startColor: Color = colors[index]
        
        return RadialGradient(
            gradient: Gradient(colors: [startColor.opacity(1), .clear]),
            center: .center,
            startRadius: 0,
            endRadius: 150 + height / 2
        )
    }
    
    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let r = 6371.0 // 지구의 반지름 (킬로미터)

        let lat1Rad = lat1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let deltaLat = (lat2 - lat1) * .pi / 180.0
        let deltaLon = (lon2 - lon1) * .pi / 180.0

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon / 2) * sin(deltaLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return r * c // 거리 (킬로미터)
    }

    func sortUsersByDistance(from user: UserInfo, users: [UserInfo]) -> [UserInfo] {
        return users.sorted { (user1, user2) -> Bool in
            let distance1 = haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user1.latitude, lon2: user1.longitude)
            let distance2 = haversineDistance(lat1: user.latitude, lon1: user.longitude, lat2: user2.latitude, lon2: user2.longitude)
            return distance1 < distance2
        }
    }
}

struct ContentEmojiView: View {
    @Binding var userInfo: UserInfo
    @Binding var rotation: Double
    @Binding var isModalPresented: Bool
    var index: Int
    var startEllipse: (width: CGFloat, height: CGFloat)
    var endEllipse: (width: CGFloat, height: CGFloat)
    var interpolationRatio: CGFloat
    @State var randomAngleOffset: Double
    var num = 0
    
    var body: some View {
        let majorAxis = startEllipse.width / 2 * (1 - interpolationRatio) + endEllipse.width / 2 * interpolationRatio
        let minorAxis = startEllipse.height / 2 * (1 - interpolationRatio) + endEllipse.height / 2 * interpolationRatio
        let angle = (rotation + randomAngleOffset) * .pi / 180
        
        Button {
            isModalPresented = true
        } label: {
            VStack {
                Text("\(userInfo.nickname)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding(.top, -40)
                
                ZStack {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]),
                                             center: .center,
                                             startRadius: 0,
                                             endRadius: 20))
                    
                    Circle()
                        .fill(.clear)
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                Text(userInfo.previousState)
                                    .font(.system(size: 35))
                            }
                            
                        )
                        .offset(x: 0, y: -30)
                        .frame(width: 50, height: 50)
                }
            }
        }
        .frame(width: 50, height: 50)
        .offset(x: majorAxis * cos(angle), y: minorAxis * sin(angle) + 250)
        .animation(.easeInOut(duration: 0.5), value: rotation)
    }
}

#Preview {
    MainView()
}
