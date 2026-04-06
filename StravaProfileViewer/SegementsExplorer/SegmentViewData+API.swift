//
//  SegmentViewData+API.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation
import CoreLocation

extension SegmentInfo {
    func toViewData() -> SegmentViewData {
        let distanceInKm = distance / 1000.0
        let elevationInMeters = elevDifference
        
        let distanceText: String
        if distanceInKm < 1.0 {
            distanceText = String(format: "%.0f m", distance)
        } else {
            distanceText = String(format: "%.2f km", distanceInKm)
        }
        
        let elevationText = String(format: "%.0f m", elevationInMeters)
        let gradeText = String(format: "%.1f%%", avgGrade)
        
        // Parse coordinates from startLatlng and endLatlng arrays
        let startCoord: CLLocationCoordinate2D
        if startLatlng.count >= 2 {
            startCoord = CLLocationCoordinate2D(latitude: startLatlng[0], longitude: startLatlng[1])
        } else {
            startCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let endCoord: CLLocationCoordinate2D
        if endLatlng.count >= 2 {
            endCoord = CLLocationCoordinate2D(latitude: endLatlng[0], longitude: endLatlng[1])
        } else {
            endCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        return SegmentViewData(
            id: id,
            name: name,
            climbCategory: SegmentViewData.ClimbCategory(rawValue: climbCategory) ?? .none,
            avgGrade: avgGrade,
            elevationGain: elevationInMeters,
            distance: distance,
            distanceText: distanceText,
            elevationText: elevationText,
            gradeText: gradeText,
            starred: starred,
            startCoordinate: startCoord,
            endCoordinate: endCoord,
            polylineString: points
        )
    }
}

extension SegmentsInfo {
    func toViewData() -> [SegmentViewData] {
        segments.map { $0.toViewData() }
    }
}
