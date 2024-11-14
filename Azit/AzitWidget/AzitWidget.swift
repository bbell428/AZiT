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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), userInfo: loadUserInfo() )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), userInfo: loadUserInfo() )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, userInfo: loadUserInfo() )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func loadUserInfo() -> UserInfo {
        let userDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget")
        if let data = userDefaults?.data(forKey: "widgetData"),
           let widgetData = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return widgetData
        }
        return UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0)
    }
    
//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let userInfo: UserInfo
}

struct AzitWidgetEntryView : View {
    @StateObject var userInfoStore: UserInfoStore = UserInfoStore()
    @StateObject var albumStore: AlbumStore = AlbumStore()
    
    @State var recentStory: Story?
    
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.userInfo.nickname)
            
            Text("emoji")
            Text(recentStory?.emoji ?? "")
        }
        .onAppear {
            Task {
                await userInfoStore.loadUserInfo(userID: entry.userInfo.id)
                await albumStore.loadStorysByIds(ids: userInfoStore.userInfo?.friends ?? [])
                
                recentStory = albumStore.storys.sorted { $0.date > $1.date }.first
                
                print("***********\(recentStory?.id ?? "")***********")
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    AzitWidget()
} timeline: {
    SimpleEntry(date: .now, userInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0) )
    SimpleEntry(date: .now, userInfo: UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0) )
}
