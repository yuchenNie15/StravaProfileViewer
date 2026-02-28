//
//  ActivityViewData+Mocks.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
extension ActivityViewData {
    public static func createMock(
        id: Int = 10101,
        title: String = "Morning Ride",
        dateAndType: String = "Ride • Feb 27, 2026",
        sportIcon: String = "bicycle",
        distance: String = "15.5 mi",
        movingTime: String = "1h 15m",
        elevation: String = "850 ft",
        averagePower: String? = "175 W",
        averageHeartRate: String? = "140 bpm",
        sufferScore: String? = "82",
        kudosCount: String = "3"
    ) -> Self {
        return ActivityViewData(
            id: id,
            title: title,
            dateAndType: dateAndType,
            sportIcon: sportIcon,
            distance: distance,
            movingTime: movingTime,
            elevation: elevation,
            averagePower: averagePower,
            averageHeartRate: averageHeartRate,
            sufferScore: sufferScore,
            kudosCount: kudosCount
        )
    }
}

extension ActivityViewData {
    public static func createMocks() -> [Self] {
        return [
            .createMock(
                id: 10101,
                title: "Highlands Ranch Loop",
                dateAndType: "Ride • Feb 27, 2026",
                sportIcon: "bicycle",
                distance: "24.5 mi",
                movingTime: "1h 25m",
                elevation: "1,200 ft",
                averagePower: "185 W",
                averageHeartRate: "145 bpm",
                sufferScore: "65",
                kudosCount: "12"
            ),
            .createMock(
                id: 10102,
                title: "Morning Track Run",
                dateAndType: "Run • Feb 25, 2026",
                sportIcon: "figure.run",
                distance: "6.2 mi",
                movingTime: "45m 10s",
                elevation: "150 ft",
                averagePower: nil,
                averageHeartRate: "165 bpm",
                sufferScore: "85",
                kudosCount: "8"
            ),
            .createMock(
                id: 10103,
                title: "Endurance Swim",
                dateAndType: "Swim • Feb 23, 2026",
                sportIcon: "figure.pool.swim",
                distance: "1.2 mi",
                movingTime: "35m 20s",
                elevation: "0 ft",
                averagePower: nil,
                averageHeartRate: "130 bpm",
                sufferScore: "40",
                kudosCount: "5"
            ),
            .createMock(
                id: 10104,
                title: "Gazelle Medeo T10 Cruise",
                dateAndType: "Ride • Feb 21, 2026",
                sportIcon: "bicycle",
                distance: "12.0 mi",
                movingTime: "45m 00s",
                elevation: "400 ft",
                averagePower: "120 W",
                averageHeartRate: "115 bpm",
                sufferScore: "15",
                kudosCount: "3"
            )
        ]
    }
}
