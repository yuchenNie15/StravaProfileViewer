//
//  SegmentExploreView.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import SwiftUI
import ComposableArchitecture
import MapKit

struct SegmentExploreView: View {
    @Bindable var store: StoreOf<SegmentExplore>
    
    var body: some View {
        VStack(spacing: 0) {
            // Map view
            segmentMapView
                .frame(height: 300)
            
            // Filter controls
            filterSection
            
            // Segment list
            segmentListView
        }
        .navigationTitle("Explore Segments")
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
                }
                .tag(segment.id)
                
                // Draw the full route using the polyline
                MapPolyline(coordinates: segment.polyline)
                    .stroke(
                        climbCategoryColor(for: segment.climbCategory),
                        lineWidth: store.selectedSegmentId == segment.id ? 5 : 3
                    )
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Starred filter
                FilterButton(
                    title: "Starred",
                    systemImage: "star.fill",
                    isSelected: store.filterStarredOnly
                ) {
                    store.send(.toggleStarredFilter)
                }
                
                Divider()
                    .frame(height: 20)
                
                // Climb category filters
                ForEach([
                    SegmentViewData.ClimbCategory.hc,
                    .category1,
                    .category2,
                    .category3,
                    .category4
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
    private var segmentListView: some View {
        switch store.segments {
        case .loading:
            LoadingView()
            
        case .error(let error):
            ErrorView(
                error: error,
                retry: { store.send(.retry) }
            )
            
        case .dataLoaded:
            if store.filteredSegments.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(store.filteredSegments) { segment in
                        SegmentRowView(segment: segment)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.selectSegment(segment.id))
                            }
                            .listRowBackground(
                                store.selectedSegmentId == segment.id ?
                                Color.accentColor.opacity(0.1) : Color.clear
                            )
                    }
                }
                .listStyle(.plain)
            }
            
        case .empty:
            emptyStateView
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Segments Found",
            systemImage: "map",
            description: Text("Try adjusting your filters or check back later")
        )
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

// MARK: - Supporting Views

struct SegmentAnnotationView: View {
    let segment: SegmentViewData
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(categoryColor)
                .frame(width: isSelected ? 24 : 16, height: isSelected ? 24 : 16)
                .shadow(radius: isSelected ? 4 : 2)
            
            if segment.starred {
                Image(systemName: "star.fill")
                    .font(.system(size: isSelected ? 10 : 8))
                    .foregroundStyle(.white)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
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

struct SegmentRowView: View {
    let segment: SegmentViewData
    
    var body: some View {
        HStack(spacing: 12) {
            // Climb category indicator
            VStack {
                Image(systemName: "mountain.2.fill")
                    .font(.title2)
                    .foregroundStyle(categoryColor)
                
                if !segment.climbCategory.shortName.isEmpty {
                    Text(segment.climbCategory.shortName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(segment.name)
                        .font(.headline)
                    
                    if segment.starred {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
                
                HStack(spacing: 12) {
                    Label(segment.distanceText, systemImage: "ruler")
                    Label(segment.elevationText, systemImage: "arrow.up")
                    Label(segment.gradeText, systemImage: "percent")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
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

struct FilterButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? .accentColor : .gray)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading segments...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: DataLoadingError
    let retry: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("Failed to Load", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Retry", systemImage: "arrow.clockwise") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        SegmentExploreView(
            store: Store(
                initialState: SegmentExplore.State(segments: .loading)
            ) {
                SegmentExplore()
            }
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        SegmentExploreView(
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

#Preview("Error") {
    NavigationStack {
        SegmentExploreView(
            store: Store(
                initialState: SegmentExplore.State(
                    segments: .error(.networkError)
                )
            ) {
                SegmentExplore()
            }
        )
    }
}

#Preview("With Selection") {
    NavigationStack {
        SegmentExploreView(
            store: Store(
                initialState: SegmentExplore.State(
                    segments: .dataLoaded(
                        IdentifiedArray(uniqueElements: SegmentViewData.createMocks())
                    ),
                    selectedSegmentId: 20201
                )
            ) {
                SegmentExplore()
            }
        )
    }
}

#Preview("With Filters") {
    NavigationStack {
        SegmentExploreView(
            store: Store(
                initialState: SegmentExplore.State(
                    segments: .dataLoaded(
                        IdentifiedArray(uniqueElements: SegmentViewData.createMocks())
                    ),
                    filterStarredOnly: true,
                    filterClimbCategories: [.hc, .category1]
                )
            ) {
                SegmentExplore()
            }
        )
    }
}
