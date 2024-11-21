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
import Kingfisher

@MainActor
class WidgetViewModel: ObservableObject {
    @Published var widgetData: AzitWidgetData?
    private var listener: ListenerRegistration? // 리스너를 저장할 변수
    
    private var userInfoStore: UserInfoStore
    private var photoImageStore: PhotoImageStore
    
    init(userInfoStore: UserInfoStore, photoImageStore: PhotoImageStore) {
        self.userInfoStore = userInfoStore
        self.photoImageStore = photoImageStore
    }
    
    func loadUserInfo() -> UserInfo {
        let userDefaults = UserDefaults(suiteName: "group.education.techit.Azit.AzitWidget")
        if let data = userDefaults?.data(forKey: "userInfo"),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return userInfo
        }
        return UserInfo(id: "", email: "", nickname: "", profileImageName: "", previousState: "", friends: [], latitude: 0.0, longitude: 0.0, blockedFriends: [])
    }

    // 사용자 정보 로드 및 실시간 데이터 업데이트
    func loadRecentStoryByIds() async throws -> AzitWidgetData {
        // 기존 리스너 제거
        
        await userInfoStore.loadUserInfo(userID: loadUserInfo().id)
        
        listener?.remove()
        
        let db = Firestore.firestore()
        var stories: [Story] = []
        var hasCalledContinuation = false // Continuation 중복 호출 방지 플래그

        // 새 리스너 등록
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AzitWidgetData, Error>) in
            
            guard let friends = userInfoStore.userInfo?.friends, !friends.isEmpty else {
                continuation.resume(throwing: NSError(domain: "InvalidInput", code: -1, userInfo: [NSLocalizedDescriptionKey: "IDs array is empty or nil."]))
                return
            }
            
            listener = db.collection("Story")
                .whereField("userId", in: userInfoStore.userInfo?.friends as [Any])
                .addSnapshotListener { documentSnapshot, error in
                    if hasCalledContinuation { return } // Continuation이 이미 호출된 경우 실행하지 않음
                    
                    if let error = error {
                        hasCalledContinuation = true
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let documents = documentSnapshot?.documents else {
                        hasCalledContinuation = true
                        continuation.resume(throwing: NSError(domain: "NoDocuments", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found for the given IDs."]))
                        return
                    }
                    
                    Task {
                        do {
                            for document in documents {
                                let story = try await Story(document: document)
                                stories.append(story)
                            }
                            
                            // 최신 메시지 기준으로 정렬
                            stories.sort { $0.date > $1.date }
                            
                            if let recentStory = stories.first {
                                var azitWidgetData = AzitWidgetData() // 반환할 데이터 객체 생성
                                azitWidgetData.recentStory = recentStory
                                print("최신의 스토리 : \(recentStory.id)")
                                
                                // 사용자 정보 가져오기
                                if let userInfo = try await self.userInfoStore.loadUsersInfoByEmail(userID: [recentStory.userId]).first {
                                    azitWidgetData.userInfo = userInfo
                                    print("최신의 유저 : \(userInfo.id)")
                                } else {
                                    hasCalledContinuation = true
                                    continuation.resume(throwing: NSError(domain: "UserInfoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load user info."]))
                                    return
                                }
                                
                                if recentStory.image != "" {
                                    // 이미지 가져오기
                                    let image = await self.photoImageStore.loadImageAsync(imageName: recentStory.id)
                                    azitWidgetData.image = image
                                    print("최신의 이미지 : \(image)")
                                } else {
                                    azitWidgetData.image = UIImage(systemName: "WidgetBackImage")
                                }
                                hasCalledContinuation = true
                                self.widgetData = azitWidgetData
                                continuation.resume(returning: azitWidgetData)
                                
                            } else {
                                hasCalledContinuation = true
                                continuation.resume(throwing: NSError(domain: "NoRecentStory", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recent story found."]))
                            }
                        } catch {
                            hasCalledContinuation = true
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }

    // 리스너를 제거하는 메서드
    func removeListener() {
        listener?.remove()
    }
}


struct Provider: TimelineProvider {
    @ObservedObject var widgetViewModel: WidgetViewModel
    var albumStore: AlbumStore = AlbumStore()
    
    @State var widgetData = AzitWidgetData()
    
    init(userInfoStore: UserInfoStore, photoImageStore: PhotoImageStore) {
        _widgetViewModel = ObservedObject(wrappedValue: WidgetViewModel(userInfoStore: userInfoStore, photoImageStore: photoImageStore))
    }
    
    func placeholder(in context: Context) -> AzitWidgetEntry {
        return AzitWidgetEntry(date: Date(), widgetData: widgetData)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AzitWidgetEntry) -> Void) {
        let currentDate = Date()
        
        // 비동기 작업 실행
        Task {
            let temp = try await widgetViewModel.loadRecentStoryByIds()
            
            let entry = AzitWidgetEntry(date: currentDate, widgetData: temp)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AzitWidgetEntry>) -> Void) {
        Task {
            do {
                let widgetData = try await widgetViewModel.loadRecentStoryByIds()
                
                let currentDate = Date.now
                let nextRefreshDate = Calendar.current.date(byAdding: .second, value: 15, to: currentDate)!
                
                // 새로 가져온 데이터로 엔트리 생성
                let entry = AzitWidgetEntry(date: currentDate, widgetData: widgetData)
                
                // 타임라인에 엔트리 추가
                let timeline = Timeline(entries: [entry], policy: .after(nextRefreshDate))
                
                // 위젯 타임라인 갱신
                completion(timeline)
            } catch {
                print("Error loading recent story: \(error)")
            }
        }
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
   
}

struct AzitWidgetEntry: TimelineEntry {
    var date: Date
    
    var widgetData: AzitWidgetData?
}

struct AzitWidgetEntryView : View {
    @StateObject private var widgetViewModel: WidgetViewModel
    
    @StateObject var userInfoStore: UserInfoStore = UserInfoStore()
    @StateObject var storyStore: StoryStore = StoryStore()
    @StateObject var photoImageStore: PhotoImageStore = PhotoImageStore()
    
    @State private var hasAppeared = false
    
    @State private var recentStory: Story?
    @State private var userInfo: UserInfo?
    @State private var image: UIImage?
    
    @State var entry: Provider.Entry
    let emojiManager = EmojiManager()
    
    init(entry: Provider.Entry, userInfoStore: UserInfoStore, photoImageStore: PhotoImageStore) {
        _widgetViewModel = StateObject(wrappedValue: WidgetViewModel(userInfoStore: userInfoStore, photoImageStore: photoImageStore))
        _entry = State(initialValue: entry) // entry 초기화
    }
    
    var body: some View {
        ZStack {
            if let widgetImage = entry.widgetData?.image ?? UIImage(named: "WidgetBackImage") {
                Image(uiImage: widgetImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height)
                    .zIndex(0)
            }

            VStack {
                if entry.widgetData?.recentStory?.image ?? "" == "" {
                    if entry.widgetData?.recentStory?.content ?? "" != "" {
                        SpeechBubbleView(text: entry.widgetData?.recentStory?.content ?? "")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(width: 150)
                            .padding(.top, 40)
                    } else {
                        Text("")
                            .padding(.top, 40)
                    }

                    if entry.widgetData?.userInfo?.previousState ?? "" != "" {
                        if let codepoints = emojiManager.getCodepoints(forName: entry.widgetData?.userInfo?.previousState ?? "") {
                            KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
//                        Text(entry.widgetData?.userInfo?.previousState ?? "")
//                            .padding(.top, -5)
//                            .font(.system(size: 80))
                    }

                    Text(entry.widgetData?.userInfo?.nickname ?? "")
                        .foregroundStyle(.accent)
                        .font(.caption2)
                        .padding(.top, -50)
                } else {
                    Spacer()

                    HStack {
                        HStack {
                            if let codepoints = emojiManager.getCodepoints(forName: entry.widgetData?.userInfo?.previousState ?? "") {
                                KFImage(URL(string: EmojiManager.getTwemojiURL(for: codepoints)))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                            }
                            Text(entry.widgetData?.userInfo?.nickname ?? "")
                                .foregroundStyle(.accent)
                        }
                        .padding(5)
                        .padding([.leading, .trailing], 5)
                        .background(Capsule().fill(.subColor4))
                        
                        Spacer()
                    }
                    .padding([.leading, .bottom], 10)
                    .font(.caption)
                    .offset(y: -350) // 나중에 %로 계산
                }
            }
            .zIndex(1)
        }
    }
}

struct AzitWidget: Widget {
    let kind: String = "AzitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(userInfoStore: UserInfoStore(), photoImageStore: PhotoImageStore())) { entry in
            if #available(iOS 17.0, *) {
                AzitWidgetEntryView(entry: entry, userInfoStore: UserInfoStore(), photoImageStore: PhotoImageStore())
                //AzitWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AzitWidgetEntryView(entry: entry, userInfoStore: UserInfoStore(), photoImageStore: PhotoImageStore())
                    .padding()
                    .background()
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
