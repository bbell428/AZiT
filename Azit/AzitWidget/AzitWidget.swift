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
        AzitWidgetEntry(date: Date(), recentStory: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AzitWidgetEntry) -> Void) {
        let currentDate = Date.now
        
        // 유저 디폴트에서 스토리 데이터 불러오기
        let recentStory = loadStory()
        
        // 위젯에 표시할 데이터 항목을 생성합니다.
        let entry = AzitWidgetEntry(date: currentDate, recentStory: recentStory)
        
        completion(entry)
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AzitWidgetEntry>) -> Void) {
        let currentDate = Date.now
        // 유저 디폴트에서 스토리 데이터 불러오기
        let recentStory = loadStory()
        
        // 15분 후 시간 설정
        let nextRefreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        // 위젯에 표시할 데이터
        let entry = AzitWidgetEntry(date: currentDate, recentStory: recentStory)
        
        // 15분마다 리프레시되는 타임라인 설정
        let timeline = Timeline(entries: [entry], policy: .after(nextRefreshDate))
        
        // 컴플리션 핸들러로 넘기기
        completion(timeline)
        
        // 타임라인이 갱신된 후 위젯 리프레시
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func loadUserInfo() -> UserInfo {
        let userDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget")
        if let data = userDefaults?.data(forKey: "widgetData"),
           let widgetData = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return widgetData
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
    
    // 데이터 불러오기 함수 (Firestore에서 비동기적으로 데이터를 불러옴)
    func fetchData(userInfo: UserInfo, albumStore: AlbumStore, completion: @escaping ([Story]) -> Void) {
        // Firestore 또는 다른 소스에서 데이터를 비동기적으로 불러오는 코드
        
        Task {
            await albumStore.loadStorysByIds(ids: userInfo.friends)
        }
    }
}

struct AzitWidgetEntry: TimelineEntry {
    let date: Date
    let recentStory: Story?
}

struct AzitWidgetEntryView : View {
    @StateObject var albumStore = AlbumStore()
    
    @State var recentStory: Story?
    
    @State var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("emoji")
            Text(recentStory?.emoji ?? "")
        }
        .onAppear {
            // 위젯 내에서 albumStore로 데이터를 로드
            recentStory = entry.recentStory
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    AzitWidget()
} timeline: {
    AzitWidgetEntry(date: .now, recentStory: nil)
}
