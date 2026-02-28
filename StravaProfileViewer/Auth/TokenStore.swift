//
//  TokenStore.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import Security

enum TokenStore {
    private static let accessTokenKey = "strava_access_token"
    private static let refreshTokenKey = "strava_refresh_token"
    private static let expiresAtKey = "strava_token_expires_at"

    static func save(_ response: TokenResponse) {
        set(response.accessToken, forKey: accessTokenKey)
        set(response.refreshToken, forKey: refreshTokenKey)
        set(String(response.expiresAt), forKey: expiresAtKey)
    }

    static func accessToken() -> String? {
        get(forKey: accessTokenKey)
    }

    static func refreshToken() -> String? {
        get(forKey: refreshTokenKey)
    }

    static func isExpired() -> Bool {
        guard let raw = get(forKey: expiresAtKey), let expiresAt = Int(raw), expiresAt > 0 else {
            return true
        }
        return Date.now.timeIntervalSince1970 >= Double(expiresAt)
    }

    static func hasValidToken() -> Bool {
        guard accessToken() != nil else { return false }
        return !isExpired()
    }

    static func clear() {
        delete(forKey: accessTokenKey)
        delete(forKey: refreshTokenKey)
        delete(forKey: expiresAtKey)
    }

    // MARK: - Keychain helpers

    private static func set(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
        ]
        let attributes: [CFString: Any] = [kSecValueData: data]
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = data
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    private static func get(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }

    private static func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
