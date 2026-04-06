//
//  SegmentExplore+Advanced.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//
//  Advanced usage patterns and customizations
//

import SwiftUI
import ComposableArchitecture
import MapKit

// MARK: - Custom Map Styles

extension SegmentExploreView {
    /// Custom map style options
    enum MapStyle {
        case standard
        case hybrid
        case satellite
        case realistic
        
        var mapStyle: MapKit.MapStyle {
            switch self {
            case .standard:
                return .standard(elevation: .realistic)
            case .hybrid:
                return .hybrid(elevation: .realistic)
            case .satellite:
                return .imagery(elevation: .realistic)
            case .realistic:
                return .standard(elevation: .realistic, pointsOfInterest: .including([.park, .publicTransport]))
            }
        }
    }
}

// MARK: - Extended Segment Details View

struct SegmentDetailSheet: View {
    let segment: SegmentViewData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Map preview
                    Map(initialPosition: .region(mapRegion)) {
                        MapPolyline(coordinates: [segment.startCoordinate, segment.endCoordinate])
                            .stroke(categoryColor, lineWidth: 4)
                        
                        Marker("Start", coordinate: segment.startCoordinate)
                            .tint(.green)
                        
                        Marker("End", coordinate: segment.endCoordinate)
                            .tint(.red)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Distance", value: segment.distanceText, icon: "ruler")
                        DetailRow(label: "Elevation Gain", value: segment.elevationText, icon: "arrow.up")
                        DetailRow(label: "Average Grade", value: segment.gradeText, icon: "percent")
                        DetailRow(
                            label: "Climb Category",
                            value: segment.climbCategory.displayName,
                            icon: "mountain.2.fill"
                        )
                        DetailRow(
                            label: "Status",
                            value: segment.starred ? "Starred" : "Not Starred",
                            icon: segment.starred ? "star.fill" : "star"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(segment.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private var mapRegion: MKCoordinateRegion {
        let centerLat = (segment.startCoordinate.latitude + segment.endCoordinate.latitude) / 2
        let centerLon = (segment.startCoordinate.longitude + segment.endCoordinate.longitude) / 2
        let span = max(
            abs(segment.endCoordinate.latitude - segment.startCoordinate.latitude) * 2,
            abs(segment.endCoordinate.longitude - segment.startCoordinate.longitude) * 2
        )
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(span, 0.01), longitudeDelta: max(span, 0.01))
        )
    }
    
    private var categoryColor: Color {
        switch segment.climbCategory {
        case .hc: return .red
        case .category1: return .orange
        case .category2: return .yellow
        case .category3: return .green
        case .category4: return .blue
        case .none: return .gray
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Segment Statistics Summary

struct SegmentStatistics: View {
    let segments: [SegmentViewData]
    
    private var totalDistance: Double {
        segments.reduce(0) { $0 + $1.distance }
    }
    
    private var totalElevation: Double {
        segments.reduce(0) { $0 + $1.elevationGain }
    }
    
    private var averageGrade: Double {
        guard !segments.isEmpty else { return 0 }
        return segments.reduce(0) { $0 + $1.avgGrade } / Double(segments.count)
    }
    
    private var categoryCounts: [SegmentViewData.ClimbCategory: Int] {
        Dictionary(grouping: segments, by: { $0.climbCategory })
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                GridRow {
                    StatItem(label: "Total Segments", value: "\(segments.count)")
                    StatItem(label: "Starred", value: "\(segments.filter { $0.starred }.count)")
                }
                
                GridRow {
                    StatItem(
                        label: "Total Distance",
                        value: String(format: "%.1f km", totalDistance / 1000)
                    )
                    StatItem(
                        label: "Total Elevation",
                        value: String(format: "%.0f m", totalElevation)
                    )
                }
                
                GridRow {
                    StatItem(
                        label: "Avg Grade",
                        value: String(format: "%.1f%%", averageGrade)
                    )
                    StatItem(
                        label: "HC Climbs",
                        value: "\(categoryCounts[.hc] ?? 0)"
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Enhanced View with Statistics

struct EnhancedSegmentExploreView: View {
    @Bindable var store: StoreOf<SegmentExplore>
    @State private var showStatistics = false
    @State private var selectedForDetail: SegmentViewData?
    
    var body: some View {
        VStack(spacing: 0) {
            // Map view
            segmentMapView
                .frame(height: 300)
            
            // Statistics toggle
            if case .dataLoaded = store.segments {
                Toggle("Show Statistics", isOn: $showStatistics)
                    .padding()
                    .background(Color(.systemGroupedBackground))
            }
            
            // Statistics view
            if showStatistics, let segments = store.segments.data {
                ScrollView(.horizontal, showsIndicators: false) {
                    SegmentStatistics(segments: Array(segments))
                        .padding(.horizontal)
                }
            }
            
            // Filter section
            filterSection
            
            // List
            segmentList
        }
        .navigationTitle("Explore Segments")
        .sheet(item: $selectedForDetail) { segment in
            SegmentDetailSheet(segment: segment)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var segmentMapView: some View {
        Map(
            position: .constant(.region(store.mapRegion)),
            selection: Binding(
                get: { store.selectedSegmentId },
                set: { store.send(.selectSegment($0)) }
            )
        ) {
            ForEach(store.filteredSegments) { segment in
                Annotation(
                    segment.name,
                    coordinate: segment.startCoordinate,
                    anchor: .center
                ) {
                    SegmentAnnotationView(
                        segment: segment,
                        isSelected: store.selectedSegmentId == segment.id
                    )
                    .onTapGesture {
                        selectedForDetail = segment
                    }
                }
                .tag(segment.id)
                
                MapPolyline(coordinates: [segment.startCoordinate, segment.endCoordinate])
                    .stroke(climbCategoryColor(for: segment.climbCategory), lineWidth: 3)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: "Starred",
                    systemImage: "star.fill",
                    isSelected: store.filterStarredOnly
                ) {
                    store.send(.toggleStarredFilter)
                }
                
                Divider().frame(height: 20)
                
                ForEach([
                    SegmentViewData.ClimbCategory.hc,
                    .category1, .category2, .category3, .category4
                ], id: \.self) { category in
                    FilterButton(
                        title: category.shortName,
                        systemImage: "mountain.2.fill",
                        isSelected: store.filterClimbCategories.contains(category)
                    ) {
                        store.send(.toggleClimbCategoryFilter(category))
                    }
                }
                
                if store.filterStarredOnly || !store.filterClimbCategories.isEmpty {
                    Button("Clear", systemImage: "xmark.circle.fill") {
                        store.send(.clearFilters)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    private var segmentList: some View {
        switch store.segments {
        case .loading:
            LoadingView()
        case .error(let error):
            ErrorView(error: error, retry: { store.send(.retry) })
        case .dataLoaded:
            if store.filteredSegments.isEmpty {
                ContentUnavailableView(
                    "No Segments Found",
                    systemImage: "map",
                    description: Text("Try adjusting your filters")
                )
            } else {
                List {
                    ForEach(store.filteredSegments) { segment in
                        SegmentRowView(segment: segment)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedForDetail = segment
                            }
                    }
                }
                .listStyle(.plain)
            }
        case .empty:
            ContentUnavailableView(
                "No Segments",
                systemImage: "map",
                description: Text("Star some segments on Strava")
            )
        }
    }
    
    private func climbCategoryColor(for category: SegmentViewData.ClimbCategory) -> Color {
        switch category {
        case .hc: return .red
        case .category1: return .orange
        case .category2: return .yellow
        case .category3: return .green
        case .category4: return .blue
        case .none: return .gray
        }
    }
}

// MARK: - Previews

#Preview("Enhanced View") {
    NavigationStack {
        EnhancedSegmentExploreView(
            store: Store(
                initialState: SegmentExplore.State(
                    segments: .dataLoaded(
                        IdentifiedArray(uniqueElements: SegmentViewData.createMocks())
                    )
                )
            ) {
                SegmentExplore()
            }
        )
    }
}

#Preview("Segment Detail") {
    SegmentDetailSheet(segment: SegmentViewData.createMocks()[0])
}

#Preview("Statistics") {
    ScrollView {
        SegmentStatistics(segments: SegmentViewData.createMocks())
            .padding()
    }
}
