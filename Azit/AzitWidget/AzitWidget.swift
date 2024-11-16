//
//  AzitWidget.swift
//  AzitWidget
//
//  Created by Hyunwoo Shin on 11/14/24.
//

import WidgetKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AzitWidgetEntry {
        AzitWidgetEntry(date: Date(), recentStory: loadStory(), userInfo: loadUserInfo(), image: loadStoryImage())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AzitWidgetEntry) -> Void) {
        let currentDate = Date.now
        
        // 유저 디폴트에서 스토리 데이터 불러오기
        let recentStory = loadStory()
        
        // 위젯에 표시할 데이터 항목을 생성합니다.
        let entry = AzitWidgetEntry(date: currentDate, recentStory: recentStory, userInfo: loadUserInfo(), image: loadStoryImage())
        
        completion(entry)
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AzitWidgetEntry>) -> Void) {
        let currentDate = Date.now
        // 유저 디폴트에서 스토리 데이터 불러오기
        let recentStory = loadStory()
        
        let storyImage = loadStoryImage()
        
        // 15분 후 시간 설정
        let nextRefreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        // 위젯에 표시할 데이터
        let entry = AzitWidgetEntry(date: currentDate, recentStory: recentStory, userInfo: loadUserInfo(), image: storyImage)
        
        // 15분마다 리프레시되는 타임라인 설정
        let timeline = Timeline(entries: [entry], policy: .after(nextRefreshDate))
        
        // 컴플리션 핸들러로 넘기기
        completion(timeline)
        
        // 타임라인이 갱신된 후 위젯 리프레시
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func loadUserInfo() -> UserInfo {
        let userDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget")
        if let data = userDefaults?.data(forKey: "userInfo"),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return userInfo
        }
        return UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0, blockedFriends: [])
    }
    
    func loadStory() -> Story {
        let userDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget")
        if let data = userDefaults?.data(forKey: "recentStory"),
           let recentStory = try? JSONDecoder().decode(Story.self, from: data) {
            return recentStory
        }
        return Story(userId: "", date: Date())
    }
    
    func loadStoryImage() -> UIImage? {
        if let sharedDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget"),
           let imageData = sharedDefaults.data(forKey: "storyImage") {
            print("Loaded Image Data Size: \(imageData.count) bytes")
            return UIImage(data: imageData)
        }
        print("기본 이미지 반환")
        return UIImage(systemName: "arrow.clockwise")
    }
    
//    func loadStoryImage() -> UIImage? {
//        let imageData = UserDefaults.standard.object(forKey: "storyImage")
//        let image = UIImage(data: (imageData as! NSData) as Data)
//        
//        return image
//    }
}

struct AzitWidgetEntry: TimelineEntry {
    var date: Date
    
    let recentStory: Story?
    let userInfo: UserInfo?
    let image: UIImage?
}

struct AzitWidgetEntryView : View {
    @State var recentStory: Story?
    @State var userInfo: UserInfo?
    @State var image: UIImage?
    
    @State var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Image(uiImage: (image ?? UIImage(systemName: "xmark"))!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UIScreen.main.bounds.height)

            VStack {
                if recentStory?.image ?? "" == "" {
                    if recentStory?.content ?? "" != "" {
                        SpeechBubbleView(text: recentStory?.content ?? "")
                            .frame(width: 150)
                            .padding(.top, 40)
                    }

                    if recentStory?.emoji ?? "" != "" {
                        Text(recentStory?.emoji ?? "")
                            .padding(.top, -5)
                            .font(.system(size: 80))
                    }

                    Text(userInfo?.nickname ?? "")
                        .foregroundStyle(.accent)
                        .font(.caption2)
                        .padding(.top, -50)
                } else {
                    Spacer()

                    HStack {
                        Circle()
                            .fill(.subColor4)
                            .overlay(
                                Text(recentStory?.emoji ?? "")
                            )
                            .frame(width: 25)
                        
                        Text(userInfo?.nickname ?? "")
                        Spacer()
                    }
                    .padding([.leading, .bottom], 10)
                    .font(.caption)
                    .frame(maxWidth: .infinity) // HStack 너비를 화면 전체로 확장
                    .offset(y: -350) // 나중에 %로 계산
                }
            }
        }
        .onAppear {
            recentStory = entry.recentStory
            userInfo = entry.userInfo
            
            if recentStory?.image ?? "" == "" {
                print("이미지 비었을 때")
                image = UIImage(named: "WidgetBackImage")
            } else {
                print("이미지 있을 때")
                image = entry.image
            }
        }
    }
}

struct AzitWidget: Widget {
    let kind: String = "AzitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AzitWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AzitWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    AzitWidget()
} timeline: {
    AzitWidgetEntry(date: .now, recentStory: nil, userInfo: nil, image: nil)
}
