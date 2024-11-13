//
//  LocationManager.swift
//  Azit
//
//  Created by 홍지수 on 11/11/24.
//
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    // 권한 허용 상태
    @Published var status: CLAuthorizationStatus?

    override init() {
        super.init()
        locationManager.delegate = self
        // 정확도 설정 (필요에 따라 조정)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 위치 업데이트 시작
        locationManager.startUpdatingLocation()
    }

    // 권한 허용 check
    func checkAuthorization() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .restricted, .denied:
                // 위치 접근이 거부된 경우 처리
                break
            @unknown default:
                break
            }
        }
    
    // 위치 업데이트 시 호출되는 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else { return }
        currentLocation = locations.first
        // 위치 업데이트 중지 (한 번만 가져오려면)
        locationManager.stopUpdatingLocation()
    }

    // 오류 처리 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}


// 위도와 경도를 주소로 변환
func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
        if let error = error {
            print("역지오코딩 오류: \(error.localizedDescription)")
            completion(nil)
            return
        }

        if let placemark = placemarks?.first {
            // 원하는 주소 형식으로 구성, placemark.administrativeArea,
            let address = [placemark.locality, placemark.name]
                .compactMap { $0 }
                .joined(separator: " ")
            completion(address)
        } else {
            completion(nil)
        }
    }
}
