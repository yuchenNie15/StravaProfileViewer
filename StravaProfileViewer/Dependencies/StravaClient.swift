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
}

extension DependencyValues {
    var stravaClient: StravaClient {
        get { self[StravaClient.self] }
        set { self[StravaClient.self] = newValue }
    }
}

extension StravaClient: DependencyKey {
    public static let liveValue = Self(
        fetchAthlete: {
            do {
                let url = URL(string: "https://www.strava.com/api/v3/athlete")!
                var request = URLRequest(url: url)
                
                let token = await stravaAccessTokenKey
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let http = response as? HTTPURLResponse else {
                    return .failure(DataLoadingError.badResponse("Invalid response type"))
                }

                guard http.statusCode == 200 else {
                    let error = DataLoadingError.errorWithStatusCode(http.statusCode)
                    return .failure(error)
                }

                // Wrap the decoding in MainActor.run to satisfy the compiler's isolation demands
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

        }
    )
    
    // 3. Manually provide a testValue since we removed the macro
    public static let testValue = Self(
        fetchAthlete: {
            // In tests, this will fail if you don't explicitly override it
            .failure(DataLoadingError.networkError)
        }
    )

    public static let previewValue = Self(
        // Assuming ProfileViewData.mock is a static property, you don't need 'await' here
        fetchAthlete: { await .success(.mock) }
    )
}
