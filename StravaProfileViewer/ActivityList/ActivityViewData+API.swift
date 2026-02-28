//
//  ActivityViewData+API.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
public extension ActivityViewData {
    nonisolated static func from(activity: ActivityInfoData) -> Self {
        // Distance (Meters to Miles)
        let miles = activity.distance / 1609.34
        let distanceStr = String(format: "%.1f mi", miles)
        
        // Time (Seconds to 1h 15m)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        let timeStr = formatter.string(from: TimeInterval(activity.movingTime)) ?? "0m"
        
        // Elevation (Meters to Feet)
        let feet = activity.totalElevationGain * 3.28084
        let elevationStr = String(format: "%.0f ft", feet)
        
        // Date Formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateStr = dateFormatter.string(from: activity.startDateLocal)
        
        // Map Sport Type to SF Symbol
        let icon: String
        if activity.sportType.contains("Bike") || activity.sportType == "Ride" {
            icon = "bicycle"
        } else if activity.sportType.contains("Run") {
            icon = "figure.run"
        } else if activity.sportType.contains("Swim") {
            icon = "figure.pool.swim"
        } else {
            icon = "figure.walk" // Fallback
        }
        
        // Clean up sport type string (e.g., "MountainBikeRide" -> "Mountain Bike Ride")
        let cleanSportType = activity.sportType.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        
        return ActivityViewData(
            id: activity.id,
            title: activity.name,
            dateAndType: "\(cleanSportType) • \(dateStr)",
            sportIcon: icon,
            distance: distanceStr,
            movingTime: timeStr,
            elevation: elevationStr,
            averagePower: activity.averageWatts.map { "\(Int($0)) W" },
            averageHeartRate: activity.averageHeartrate.map { "\(Int($0)) bpm" },
            sufferScore: activity.sufferScore.map { "\($0)" },
            kudosCount: "\(activity.kudosCount)"
        )
    }
}
