//
//  ActivityRowView.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import SwiftUI

struct ActivityRowView: View {
    let activity: ActivityViewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: activity.sportIcon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(activity.dateAndType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            HStack(spacing: 24) {
                MetricView(title: "Distance", value: activity.distance)
                MetricView(title: "Time", value: activity.movingTime)
                MetricView(title: "Elevation", value: activity.elevation)
                Spacer()
            }
            
            if activity.averagePower != nil || activity.averageHeartRate != nil {
                HStack(spacing: 16) {
                    if let power = activity.averagePower {
                        Label(power, systemImage: "bolt.fill")
                            .foregroundStyle(.yellow)
                    }
                    
                    if let hr = activity.averageHeartRate {
                        Label(hr, systemImage: "heart.fill")
                            .foregroundStyle(.red)
                    }
                    
                    if let suffer = activity.sufferScore {
                        Label(suffer, systemImage: "flame.fill")
                            .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    Label(activity.kudosCount, systemImage: "hand.thumbsup.fill")
                        .foregroundStyle(.secondary)
                }
                .font(.caption.bold())
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview("Full List Context") {
    List {
        ForEach(ActivityViewData.createMocks()) { mock in
            ActivityRowView(activity: mock)
                // Replicating the exact insets from your ActivityListView
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
    }
    .listStyle(.plain)
}

#Preview("Single Row - All Stats", traits: .sizeThatFitsLayout) {
    // Shows a ride with power, heart rate, and suffer score
    ActivityRowView(activity: .createMock())
        .padding()
}

#Preview("Single Row - Missing Optionals", traits: .sizeThatFitsLayout) {
    // Shows a run where power and suffer score are nil to test the UI fallback
    ActivityRowView(activity: .createMock(
        title: "Track Intervals",
        dateAndType: "Run • Feb 26, 2026",
        sportIcon: "figure.run",
        averagePower: nil,
        sufferScore: nil
    ))
    .padding()
}
