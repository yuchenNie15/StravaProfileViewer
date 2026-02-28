//
//  TokenResponse.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

struct TokenResponse: Decodable {
    let tokenType: String
    let expiresAt: Int
    let expiresIn: Int
    let refreshToken: String
    let accessToken: String
}
