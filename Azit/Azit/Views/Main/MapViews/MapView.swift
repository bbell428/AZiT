//
//  MapView.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/6/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var storyStore: StoryStore
    
    @Binding var isMainExposed: Bool
    @Binding var isMyModalPresented: Bool
    @Binding var isFriendsModalPresented: Bool
    @Binding var isDisplayEmojiPicker: Bool
    @Binding var isPassed24Hours: Bool
    @Binding var isShowToast: Bool
    
    @State private var region = MKCoordinateRegion()
    @State var users: [UserInfo] = []
    @State var selectedEmoji: Emoji?
    @State private var selectedIndex: Int = 0
    @State private var message: String = ""
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: $users) { $user in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                    if user.id == userInfoStore.userInfo?.id {
                        Button {
                            if isPassed24Hours {
                                isDisplayEmojiPicker = true
                            } else {
                                isMyModalPresented = true
                            }
                        } label: {
                            ZStack {
                                MyContentEmojiView(isMainExposed: $isMainExposed,
                                                   isPassed24Hours: $isPassed24Hours,
                                                   previousState: userInfoStore.userInfo?.previousState ?? "",
                                                   width: 120,
                                                   height: 120)
                                    .zIndex(3)
                            }
                            .scaleEffect(max(0.5, min(1.0, 1.0 / (region.span.latitudeDelta * 12.5))))
                        }
                    } else {
                        MapContentEmojiView(user: $user,
                                            isFriendsModalPresented: $isFriendsModalPresented,
                                            selectedIndex: $selectedIndex,
                                            region: region,
                                            index: users.firstIndex(where: { $0.id == user.id }) ?? 0)
                            .onTapGesture {
                                if let index = users.firstIndex(where: { $0.id == user.id }) {
                                    selectedIndex = index
                                }
                            }
                            .zIndex(1)
                    }
                }
            }
            
            // Modal 분기
            ModalIdentificationView(isMyModalPresented: $isMyModalPresented,
                                    isFriendsModalPresented: $isFriendsModalPresented,
                                    isDisplayEmojiPicker: $isDisplayEmojiPicker,
                                    isPassed24Hours: $isPassed24Hours,
                                    users: $users,
                                    message: $message,
                                    selectedIndex: $selectedIndex,
                                    isShowToast: $isShowToast)
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                if users.isEmpty {
                    // 사용자 본인의 정보 받아오기
                    await userInfoStore.loadUserInfo(userID: authManager.userID)
                    // 사용자 본인의 친구 받아오기
                    userInfoStore.loadFriendsInfo(friendsIDs: userInfoStore.userInfo?.friends ?? [])
                    // 사용자 본인의 정보 users 배열에 넣기, 본인의 위칙를 기반으로 Circle을 표시하기 위함
                    if let user = userInfoStore.userInfo {
                        users.append(user)
                    }
                    
                    var tempUsers: [UserInfo] = []
                    // 스토리가 있는 친구들 분류
                    for friend in userInfoStore.userInfo?.friends ?? [] {
                        do {
                            let tempStory = try await storyStore.loadRecentStoryById(id: friend)
                            
                            if tempStory.id != "" && (tempStory.publishedTargets.contains(userInfoStore.userInfo?.id ?? "") || tempStory.publishedTargets.isEmpty) {
                                try await tempUsers.append(userInfoStore.loadUsersInfoByEmail(userID: [friend])[0])
                            }
                        } catch { }
                    }
                    
                    // 친구들을 users 배열에 추가
                    users += tempUsers
                    
                    // 사용자 본인의 위도, 경도 값을 변수에 저장
                    let userLat = userInfoStore.userInfo?.latitude ?? 0
                    let userLng = userInfoStore.userInfo?.longitude ?? 0
                    
                    // Map에서의 기본 위치와 확대, 축소 수준 설정
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: userLat,
                            longitude: userLng
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 4.5, longitudeDelta: 4.5)
                    )
                    // 사용자 본인의 story
                    let story = try await storyStore.loadRecentStoryById(id: userInfoStore.userInfo?.id ?? "")
                    // 24시간이 지났는 지 판별
                    isPassed24Hours = Utility.hasPassed24Hours(from: story.date)
                }
            }
        }
    }}

//struct ClusteredMapView: UIViewRepresentable {
//    @Binding var users: [UserInfo]
//    @Binding var region: MKCoordinateRegion
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        return mapView
//    }
//
//    func updateUIView(_ mapView: MKMapView, context: Context) {
//        mapView.removeAnnotations(mapView.annotations)
//        
//        let clusteredAnnotations = clusterAnnotations(users: users)
//        mapView.addAnnotations(clusteredAnnotations)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: ClusteredMapView
//
//        init(_ parent: ClusteredMapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            let identifier = "CustomAnnotation"
//            
//            if let annotation = annotation as? MKPointAnnotation {
//                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
//                if annotationView == nil {
//                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                }
//                annotationView?.markerTintColor = .red
//                annotationView?.glyphText = annotation.title
//                return annotationView
//            }
//            return nil
//        }
//    }
//    
//    // 클러스터링 로직
//    private func clusterAnnotations(users: [UserInfo]) -> [MKPointAnnotation] {
//        let clusteringDistance: Double = 0.05 // 클러스터링 범위 (latitude, longitude 단위)
//        var clusteredAnnotations: [MKPointAnnotation] = []
//        var usedIndices: Set<Int> = []
//        
//        for (i, user) in users.enumerated() {
//            guard !usedIndices.contains(i) else { continue }
//            
//            var cluster = [user]
//            let userLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
//            
//            for (j, otherUser) in users.enumerated() where i != j && !usedIndices.contains(j) {
//                let otherLocation = CLLocation(latitude: otherUser.latitude, longitude: otherUser.longitude)
//                let distance = userLocation.distance(from: otherLocation)
//                if distance < clusteringDistance * 1000 { // 거리 비교 (미터 단위)
//                    cluster.append(otherUser)
//                    usedIndices.insert(j)
//                }
//            }
//            
//            // 클러스터 대표 위치 계산
//            let clusterLatitude = cluster.map { $0.latitude }.reduce(0, +) / Double(cluster.count)
//            let clusterLongitude = cluster.map { $0.longitude }.reduce(0, +) / Double(cluster.count)
//            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: clusterLatitude, longitude: clusterLongitude)
//            annotation.title = cluster.count > 1 ? "\(cluster.count) Users" : cluster.first?.nickname
//            clusteredAnnotations.append(annotation)
//            usedIndices.insert(i)
//        }
//        return clusteredAnnotations
//    }
//}
