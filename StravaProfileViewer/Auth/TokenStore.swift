//
//  TokenStore.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

enum TokenStore {
    private static let accessTokenKey = "strava_access_token"
    private static let refreshTokenKey = "strava_refresh_token"
    private static let expiresAtKey = "strava_token_expires_at"

    static func save(_ response: TokenResponse) {
        let defaults = UserDefaults.standard
        defaults.set(response.accessToken, forKey: accessTokenKey)
        defaults.set(response.refreshToken, forKey: refreshTokenKey)
        defaults.set(response.expiresAt, forKey: expiresAtKey)
    }

    static func accessToken() -> String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }

    static func refreshToken() -> String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    static func isExpired() -> Bool {
        let expiresAt = UserDefaults.standard.integer(forKey: expiresAtKey)
        guard expiresAt > 0 else { return true }
        return Date.now.timeIntervalSince1970 >= Double(expiresAt)
    }

    static func hasValidToken() -> Bool {
        guard accessToken() != nil else { return false }
        return !isExpired()
    }

    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: refreshTokenKey)
        defaults.removeObject(forKey: expiresAtKey)
    }
}
