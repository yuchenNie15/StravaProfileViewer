//
//  StravaClient.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import CoreLocation
import ComposableArchitecture

struct SegmentBounds: Sendable, Equatable {
    let swLat: Double
    let swLng: Double
    let neLat: Double
    let neLng: Double

    static func from(center: CLLocationCoordinate2D, radiusMiles: Double = 10) -> Self {
        let radiusKm = radiusMiles * 1.60934
        let latDelta = radiusKm / 111.11
        let lonDelta = radiusKm / (111.11 * cos(center.latitude * .pi / 180))
        return Self(
            swLat: center.latitude - latDelta,
            swLng: center.longitude - lonDelta,
            neLat: center.latitude + latDelta,
            neLng: center.longitude + lonDelta
        )
    }
}

struct StravaClient: Sendable {
    var fetchAthlete: @Sendable () async -> Result<ProfileViewData, DataLoadingError>
    var fetchActivities: @Sendable (_ page: Int) async -> Result<[ActivityViewData], DataLoadingError>
    var fetchSegments: @Sendable (_ bounds: SegmentBounds) async -> Result<[SegmentViewData], DataLoadingError>
}

extension DependencyValues {
    var stravaClient: StravaClient {
        get { self[StravaClient.self] }
        set { self[StravaClient.self] = newValue }
    }
}

private func validToken() async throws -> String {
    if TokenStore.isExpired(), let refresh = TokenStore.refreshToken() {
        let response = try await refreshAccessToken(refresh)
        TokenStore.save(response)
    }
    guard let token = TokenStore.accessToken() else {
        throw DataLoadingError.unknown("Not authenticated. Please log in.")
    }
    return token
}

extension StravaClient: DependencyKey {
    public static let liveValue = Self(
        fetchAthlete: {
            do {
                let url = URL(string: "https://www.strava.com/api/v3/athlete")!
                var request = URLRequest(url: url)

                let token = try await validToken()
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    return .failure(DataLoadingError.badResponse("Invalid response type"))
                }

                guard http.statusCode == 200 else {
                    return .failure(DataLoadingError.errorWithStatusCode(http.statusCode))
                }

                let profileInfo = try await MainActor.run {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(ProfileInfoData.self, from: data)
                }

                return .success(ProfileViewData.from(profile: profileInfo))
            } catch {
                return .failure(.badResponse(error.localizedDescription))
            }
        },
        fetchActivities: { page in
            do {
                var components = URLComponents(string: "https://www.strava.com/api/v3/athlete/activities")!
                let pageSize = ActivityList.pageSize
                components.queryItems = [
                    URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "per_page", value: "\(pageSize)")
                ]
                var request = URLRequest(url: components.url!)

                let token = try await validToken()
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    return .failure(DataLoadingError.badResponse("Invalid response type"))
                }

                guard http.statusCode == 200 else {
                    return .failure(DataLoadingError.errorWithStatusCode(http.statusCode))
                }

                let activities = try await MainActor.run {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode([ActivityInfoData].self, from: data)
                }

                return .success(activities.map { ActivityViewData.from(activity: $0) })
            } catch {
                return .failure(.badResponse(error.localizedDescription))
            }
        },
        fetchSegments: { bounds in
            do {
                var components = URLComponents(string: "https://www.strava.com/api/v3/segments/explore")!

                components.queryItems = [
                    URLQueryItem(name: "bounds", value: "\(bounds.swLat),\(bounds.swLng),\(bounds.neLat),\(bounds.neLng)"),
                    URLQueryItem(name: "activity_type", value: "cycling")
                ]
                
                var request = URLRequest(url: components.url!)
                
                let token = try await validToken()
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    return .failure(DataLoadingError.badResponse("Invalid response type"))
                }

                guard http.statusCode == 200 else {
                    return .failure(DataLoadingError.errorWithStatusCode(http.statusCode))
                }

                let segments = try await MainActor.run {
                    let decoder = JSONDecoder()
                    let segmentResponse = try decoder.decode(SegmentsInfo.self, from: data)
                    return segmentResponse.segments.map { $0.toViewData() }
                }
                return .success(segments)
            } catch {
                return .failure(.badResponse(error.localizedDescription))
            }
        }
    )

    public static let testValue = Self(
        fetchAthlete: { .failure(DataLoadingError.networkError) },
        fetchActivities: { _ in .failure(DataLoadingError.networkError) },
        fetchSegments: { _ in .failure(DataLoadingError.networkError) }
    )

    public static let previewValue = Self(
        fetchAthlete: { await .success(.mock) },
        fetchActivities: { _ in await .success(ActivityViewData.createMocks()) },
        fetchSegments: { _ in await .success(SegmentViewData.createMocks()) }
    )
}
