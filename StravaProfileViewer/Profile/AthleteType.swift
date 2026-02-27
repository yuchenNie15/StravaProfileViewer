//
//  AthleteType.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

public enum AthleteType: Int, Equatable, CaseIterable {
    case cyclist = 0
    case runner = 1
    case climber = 2
    case triathlete = 3
    case other = 4

    var displayName: String {
        switch self {
        case .cyclist: return "Cyclist"
        case .runner: return "Runner"
        case .climber: return "Climber"
        case .triathlete: return "Triathlete"
        case .other: return "Athlete"
        }
    }
}
