//
//  ProfileInfoData.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

public struct ProfileInfoData: Decodable, Sendable, Equatable {
    let id: Int
        // Usernames can sometimes be null in Strava
    let username: String?
    let resourceState: Int
    let firstname: String
    let lastname: String
    let city: String?
    let state: String?
    let country: String?
    let sex: String?
    let premium: Bool
    let createdAt: Date
    let updatedAt: Date
    let badgeTypeId: Int
    let profileMedium: String?
    let profile: String?
        
        // MARK: - Optionals
        // These fields are missing in your JSON response, so they MUST be optional
    let followerCount: Int?
    let friendCount: Int?
    let mutualFriendCount: Int?
    let athleteType: Int?
    let datePreference: String?
    let measurementPreference: String?
    let ftp: Int?
    let weight: Double?
    let bikes: [Equipment]?
    let shoes: [Equipment]?
}

struct Equipment: Decodable, Sendable, Equatable {
    let id: String
    let primary: Bool
    let name: String
    let resourceState: Int
    let distance: Double
}
