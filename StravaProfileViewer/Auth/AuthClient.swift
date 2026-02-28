//
//  AuthClient.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import AuthenticationServices
import ComposableArchitecture
import Foundation

@DependencyClient
struct AuthClient: Sendable {
    var authenticate: @Sendable () async throws -> Void
    var refreshIfNeeded: @Sendable () async throws -> Void
    var logout: @Sendable () async -> Void
    var isAuthenticated: @Sendable () -> Bool = { false }
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: DependencyKey {
    static let liveValue = Self(
        authenticate: {
            let code = try await Task { @MainActor in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    let authURL = buildAuthURL()
                    let session = ASWebAuthenticationSession(
                        url: authURL,
                        callbackURLScheme: "strava206412"
                    ) { callbackURL, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        guard
                            let callbackURL,
                            let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                        else {
                            continuation.resume(throwing: DataLoadingError.unknown("Missing auth code in callback"))
                            return
                        }
                        continuation.resume(returning: code)
                    }
                    session.presentationContextProvider = AuthPresentationAnchor.shared
                    session.prefersEphemeralWebBrowserSession = false
                    session.start()
                }
            }.value

            let response = try await exchangeCode(code)
            TokenStore.save(response)
        },
        refreshIfNeeded: {
            guard TokenStore.isExpired(), let refreshToken = TokenStore.refreshToken() else { return }
            let response = try await refreshAccessToken(refreshToken)
            TokenStore.save(response)
        },
        logout: {
            TokenStore.clear()
        },
        isAuthenticated: {
            TokenStore.hasValidToken()
        }
    )

    static let testValue = Self(
        authenticate: {},
        refreshIfNeeded: {},
        logout: {},
        isAuthenticated: { false }
    )

    static let previewValue = Self(
        authenticate: {},
        refreshIfNeeded: {},
        logout: {},
        isAuthenticated: { true }
    )
}

// MARK: - Internal helpers (accessible to StravaClient in same module)

func exchangeCode(_ code: String) async throws -> TokenResponse {
    var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token")!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    var components = URLComponents()
    components.queryItems = [
        URLQueryItem(name: "client_id", value: stravaClientID),
        URLQueryItem(name: "client_secret", value: stravaClientSecret),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "grant_type", value: "authorization_code"),
    ]
    request.httpBody = components.query?.data(using: .utf8)

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
        throw DataLoadingError.badResponse("Token exchange failed")
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(TokenResponse.self, from: data)
}

func refreshAccessToken(_ refreshToken: String) async throws -> TokenResponse {
    var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token")!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    var components = URLComponents()
    components.queryItems = [
        URLQueryItem(name: "client_id", value: stravaClientID),
        URLQueryItem(name: "client_secret", value: stravaClientSecret),
        URLQueryItem(name: "refresh_token", value: refreshToken),
        URLQueryItem(name: "grant_type", value: "refresh_token"),
    ]
    request.httpBody = components.query?.data(using: .utf8)

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
        throw DataLoadingError.badResponse("Token refresh failed")
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(TokenResponse.self, from: data)
}

private func buildAuthURL() -> URL {
    var components = URLComponents(string: "https://www.strava.com/oauth/mobile/authorize")!
    components.queryItems = [
        URLQueryItem(name: "client_id", value: stravaClientID),
        URLQueryItem(name: "redirect_uri", value: "strava206412://auth"),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "approval_prompt", value: "auto"),
        URLQueryItem(name: "scope", value: "activity:read_all,profile:read_all"),
    ]
    return components.url!
}

// MARK: - Presentation anchor

@MainActor
private class AuthPresentationAnchor: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthPresentationAnchor()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
