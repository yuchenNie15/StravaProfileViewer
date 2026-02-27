//
//  ProfileViewData+Mocks.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import Tagged
extension ProfileViewData.GearRowData {
    static func createMock(
        id: String = "g12345678987655",
        name: String = "Default Gear",
        isPrimary: Bool = true,
        distanceDisplay: String = "0 mi"
    ) -> Self {
        return .init(
            id: .init(id),
            name: name,
            isPrimary: isPrimary,
            distanceDisplay: distanceDisplay
        )
    }
    
    static let mockBike = createMock(
        id: "b12345678987655",
        name: "EMC",
        isPrimary: true,
        distanceDisplay: "0 mi"
    )
    
    static let mockShoe = createMock(
        id: "g12345678987655",
        name: "adidas",
        isPrimary: true,
        distanceDisplay: "3.0 mi"
    )
}

extension ProfileViewData {
    static func createMock(
        fullName: String = "Marianne Teutenberg",
        location: String = "San Francisco, CA",
        profileImageURL: URL? = URL(string: "https://example.cloudfront.net/pictures/athletes/123456789/123456789/2/large.jpg"),
        followerCount: String = "5",
        followingCount: String = "5",
        isPremium: Bool = true,
        bikes: [GearRowData] = [.mockBike],
        shoes: [GearRowData] = [.mockShoe]
    ) -> Self {
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
    
    static let mock = createMock()
}
