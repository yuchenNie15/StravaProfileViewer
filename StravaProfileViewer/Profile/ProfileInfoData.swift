//
//  ProfileInfoData.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

struct ProfileInfoData: Decodable {
    let id: Int
    let username: String
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
    let followerCount: Int
    let friendCount: Int
    let mutualFriendCount: Int
    let athleteType: Int
    let datePreference: String?
    let measurementPreference: String?
    let ftp: Int?
    let weight: Double
    let bikes: [Equipment]
    let shoes: [Equipment]

    enum CodingKeys: String, CodingKey {
        case id, username, firstname, lastname, city, state, country, sex, premium
        case resourceState = "resource_state"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case badgeTypeId = "badge_type_id"
        case profileMedium = "profile_medium"
        case profile
        case followerCount = "follower_count"
        case friendCount = "friend_count"
        case mutualFriendCount = "mutual_friend_count"
        case athleteType = "athlete_type"
        case datePreference = "date_preference"
        case measurementPreference = "measurement_preference"
        case ftp, weight, bikes, shoes
    }
}

struct Equipment: Decodable {
    let id: String
    let primary: Bool
    let name: String
    let resourceState: Int
    let distance: Double

    enum CodingKeys: String, CodingKey {
        case id, primary, name, distance
        case resourceState = "resource_state"
    }
}
