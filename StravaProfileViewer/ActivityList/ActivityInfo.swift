//
//  ActivityInfo.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
// MARK: - API Models

public struct ActivityInfoData: Decodable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let distance: Double
    public let movingTime: Int
    public let elapsedTime: Int
    public let totalElevationGain: Double
    public let type: String
    public let sportType: String
    public let workoutType: Int?
    public let startDate: Date
    public let startDateLocal: Date
    public let timezone: String
    public let utcOffset: Int
    public let locationCity: String?
    public let locationState: String?
    public let locationCountry: String?
    public let map: ActivityMapData?
    public let deviceName: String?
    
    // Stats
    public let achievementCount: Int
    public let kudosCount: Int
    public let commentCount: Int
    public let athleteCount: Int
    public let photoCount: Int
    public let prCount: Int
    public let totalPhotoCount: Int
    public let sufferScore: Int?
    
    // Flags
    public let trainer: Bool
    public let commute: Bool
    public let manual: Bool
    public let `private`: Bool // Escaped because 'private' is a Swift keyword
    public let flagged: Bool
    public let hasHeartrate: Bool
    public let deviceWatts: Bool?
    
    // Performance Metrics
    public let averageSpeed: Double?
    public let maxSpeed: Double?
    public let averageCadence: Double?
    public let averageWatts: Double?
    public let weightedAverageWatts: Int?
    public let maxWatts: Int?
    public let kilojoules: Double?
    public let averageHeartrate: Double?
    public let maxHeartrate: Double?
}

public struct ActivityMapData: Decodable, Sendable, Equatable {
    public let id: String
    public let summaryPolyline: String?
    public let resourceState: Int
}
