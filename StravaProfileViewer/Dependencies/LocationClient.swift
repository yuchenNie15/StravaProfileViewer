//
//  LocationClient.swift
//  StravaProfileViewer
//

import Foundation
import CoreLocation
import ComposableArchitecture

struct LocationClient: Sendable {
    var requestLocation: @Sendable () async -> Result<CLLocationCoordinate2D, DataLoadingError>
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

extension LocationClient: DependencyKey {
    @MainActor static let _liveDelegate = LocationManagerHelper()

    static let liveValue = Self(
        requestLocation: { await _liveDelegate.requestLocation() }
    )

    static let testValue = Self(
        requestLocation: { .failure(.networkError) }
    )

    static let previewValue = Self(
        requestLocation: { .success(CLLocationCoordinate2D(latitude: 39.5400, longitude: -104.9600)) }
    )
}

@MainActor
final class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    private let clManager = CLLocationManager()
    private var continuation: CheckedContinuation<Result<CLLocationCoordinate2D, DataLoadingError>, Never>?

    override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() async -> Result<CLLocationCoordinate2D, DataLoadingError> {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            switch clManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                clManager.requestLocation()
            case .notDetermined:
                clManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                finish(.failure(.unknown("Location access denied. Please enable location access in Settings.")))
            @unknown default:
                clManager.requestWhenInUseAuthorization()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            clManager.requestLocation()
        case .denied, .restricted:
            finish(.failure(.unknown("Location access denied. Please enable location access in Settings.")))
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        finish(.success(location.coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(.failure(.badResponse(error.localizedDescription)))
    }

    private func finish(_ result: Result<CLLocationCoordinate2D, DataLoadingError>) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
