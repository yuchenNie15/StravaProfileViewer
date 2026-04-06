//
//  SegmentViewData.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation
import CoreLocation

struct SegmentViewData: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let climbCategory: ClimbCategory
    let avgGrade: Double
    let elevationGain: Double
    let distance: Double
    let distanceText: String
    let elevationText: String
    let gradeText: String
    let starred: Bool
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    let polylineString: String
    
    static func == (lhs: SegmentViewData, rhs: SegmentViewData) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.climbCategory == rhs.climbCategory &&
        lhs.avgGrade == rhs.avgGrade &&
        lhs.elevationGain == rhs.elevationGain &&
        lhs.distance == rhs.distance &&
        lhs.distanceText == rhs.distanceText &&
        lhs.elevationText == rhs.elevationText &&
        lhs.gradeText == rhs.gradeText &&
        lhs.starred == rhs.starred &&
        lhs.startCoordinate.latitude == rhs.startCoordinate.latitude &&
        lhs.startCoordinate.longitude == rhs.startCoordinate.longitude &&
        lhs.endCoordinate.latitude == rhs.endCoordinate.latitude &&
        lhs.endCoordinate.longitude == rhs.endCoordinate.longitude
    }
    
    var polyline: [CLLocationCoordinate2D] {
        PolylineDecoder.decode(polylineString)
    }
    
    enum ClimbCategory: Int, Equatable, Sendable {
        case none = 0
        case category4 = 1
        case category3 = 2
        case category2 = 3
        case category1 = 4
        case hc = 5
        
        var displayName: String {
            switch self {
            case .none: return "No Category"
            case .category4: return "Category 4"
            case .category3: return "Category 3"
            case .category2: return "Category 2"
            case .category1: return "Category 1"
            case .hc: return "Hors Catégorie"
            }
        }
        
        var shortName: String {
            switch self {
            case .none: return ""
            case .category4: return "Cat 4"
            case .category3: return "Cat 3"
            case .category2: return "Cat 2"
            case .category1: return "Cat 1"
            case .hc: return "HC"
            }
        }
    }
}
