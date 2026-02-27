//
//  ProfileViewData.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import Tagged

struct ProfileViewData: Equatable, Sendable {
    let fullName: String
    let location: String
    let profileImageURL: URL?
    let followerCount: String
    let followingCount: String
    let isPremium: Bool
    let bikes: [GearRowData]
    let shoes: [GearRowData]
    
    struct GearRowData: Equatable, Identifiable, Sendable {
            let id: Tagged<Self, String>
            let name: String
            let isPrimary: Bool
            let distanceDisplay: String
        }
}
