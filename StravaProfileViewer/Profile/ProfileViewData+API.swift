//
//  ProfileViewData+API.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import Tagged

extension ProfileViewData {
    // A helper initializer to transform the raw API model
    nonisolated static func from(profile: ProfileInfoData) -> Self {
        let fullName = "\(profile.firstname) \(profile.lastname)"
        
        let city = profile.city ?? ""
        let state = profile.state ?? ""
        let location = (city.isEmpty || state.isEmpty) ? "\(city)\(state)" : "\(city), \(state)"
        
        let profileImageURL = URL(string: profile.profile ?? "")
        let followerCount = "\(profile.followerCount ?? 0)"
        let followingCount = "\(profile.friendCount ?? 0)"
        let isPremium = profile.premium
        
        
        let bikes: [GearRowData] = profile.bikes?.map { GearRowData.from(gear: $0) } ?? []
        let shoes: [GearRowData] = profile.shoes?.map { GearRowData.from(gear: $0) } ?? []
        return .init(
            fullName: fullName,
            location: location,
            profileImageURL: profileImageURL,
            followerCount: followerCount,
            followingCount: followingCount,
            isPremium: isPremium,
            bikes: bikes,
            shoes: shoes
        )
    }
}

extension ProfileViewData.GearRowData {
    nonisolated static func from(gear: Equipment) -> Self {
        let id = gear.id
        let name = gear.name
        let isPrimary = gear.primary
        // Format distance (meters to miles/km calculation could go here)
        let distanceDisplay = "\(Int(gear.distance / 1000)) km"
        
        return .init(
            id: Tagged<ProfileViewData.GearRowData, String>(rawValue: id),
            name: name,
            isPrimary: isPrimary,
            distanceDisplay: distanceDisplay
        )
    }
}
