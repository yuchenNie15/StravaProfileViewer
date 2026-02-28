//
//  StravaClient.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import ComposableArchitecture


struct StravaClient: Sendable {
    var fetchAthlete: @Sendable () async -> Result<ProfileViewData, DataLoadingError>
    var fetchActivities: @Sendable (_ page: Int) async -> Result<[ActivityViewData], DataLoadingError>
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
                components.queryItems = [
                    URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "per_page", value: "30")
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
        }
    )

    public static let testValue = Self(
        fetchAthlete: { .failure(DataLoadingError.networkError) },
        fetchActivities: { _ in .failure(DataLoadingError.networkError) }
    )

    public static let previewValue = Self(
        fetchAthlete: { await .success(.mock) },
        fetchActivities: { _ in await .success(ActivityViewData.createMocks()) }
    )
}
