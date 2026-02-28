//
//  ActivityViewData.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

public struct ActivityViewData: Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let dateAndType: String
    public let sportIcon: String
    
    // Primary Stats
    public let distance: String
    public let movingTime: String
    public let elevation: String
    
    // Performance Metrics (Optionals, as they aren't always present)
    public let averagePower: String?
    public let averageHeartRate: String?
    public let sufferScore: String?
    public let kudosCount: String

    
}
