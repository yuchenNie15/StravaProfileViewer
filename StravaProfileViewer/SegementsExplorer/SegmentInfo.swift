//
//  SegmentInfo.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation

//struct SegmentsInfo: Decodable {
//    let segments: [SegmentInfo]
//}
//
//struct SegmentInfo: Decodable {
//    let id: Int
//    let name: String
//    let climbCategory: Int
//    let climbCategoryDesc: String
//    let avgGrade: Double
//    let startLatlng: [Double]
//    let endLatlng: [Double]
//    let elevDifference: Double
//    let distance: Double
//    let points: String
//    let starred: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case climbCategory = "climb_category"
//        case climbCategoryDesc = "climb_category_desc"
//        case avgGrade = "avg_grade"
//        case startLatlng = "start_latlng"
//        case endLatlng = "end_latlng"
//        case elevDifference = "elev_difference"
//        case distance
//        case points
//        case starred
//    }
//}

struct SegmentsInfo: Codable {
    let segments: [SegmentInfo]
}

struct SegmentInfo: Codable {
    let id: Int
    let resourceState: Int
    let name: String
    let climbCategory: Int
    let climbCategoryDesc: String
    let avgGrade: Double
    let startLatlng: [Double]
    let endLatlng: [Double]
    let elevDifference: Double
    let distance: Double
    let points: String
    let starred: Bool
    let elevationProfile: String
    let localLegendEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case resourceState = "resource_state"
        case name
        case climbCategory = "climb_category"
        case climbCategoryDesc = "climb_category_desc"
        case avgGrade = "avg_grade"
        case startLatlng = "start_latlng"
        case endLatlng = "end_latlng"
        case elevDifference = "elev_difference"
        case distance
        case points
        case starred
        case elevationProfile = "elevation_profile"
        case localLegendEnabled = "local_legend_enabled"
    }
}
