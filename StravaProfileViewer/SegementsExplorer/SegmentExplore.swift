//
//  SegmentExplore.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import MapKit

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

@Reducer
struct SegmentExplore {
    @Dependency(\.stravaClient) var stravaClient
    
    @ObservableState
    struct State: Equatable, @unchecked Sendable {
        var segments: ViewDataState<IdentifiedArrayOf<SegmentViewData>> = .loading
        var selectedSegmentId: Int?
        var mapRegion: MKCoordinateRegion
        var filterStarredOnly: Bool = false
        var filterClimbCategories: Set<SegmentViewData.ClimbCategory> = []
        
        init(
            segments: ViewDataState<IdentifiedArrayOf<SegmentViewData>> = .loading,
            selectedSegmentId: Int? = nil,
            mapRegion: MKCoordinateRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.40, longitude: -122.20),
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            ),
            filterStarredOnly: Bool = false,
            filterClimbCategories: Set<SegmentViewData.ClimbCategory> = []
        ) {
            self.segments = segments
            self.selectedSegmentId = selectedSegmentId
            self.mapRegion = mapRegion
            self.filterStarredOnly = filterStarredOnly
            self.filterClimbCategories = filterClimbCategories
        }
        
        var filteredSegments: IdentifiedArrayOf<SegmentViewData> {
            guard let allSegments = segments.data else { return [] }
            
            var filtered = allSegments
            
            if filterStarredOnly {
                filtered = IdentifiedArray(
                    uniqueElements: filtered.filter { $0.starred }
                )
            }
            
            if !filterClimbCategories.isEmpty {
                filtered = IdentifiedArray(
                    uniqueElements: filtered.filter { filterClimbCategories.contains($0.climbCategory) }
                )
            }
            
            return filtered
        }
        
        var selectedSegment: SegmentViewData? {
            guard let selectedSegmentId else { return nil }
            return segments.data?[id: selectedSegmentId]
        }
    }
    
    enum Action: BindableAction {
        case onAppear
        case segmentsResponse(Result<[SegmentViewData], DataLoadingError>)
        case retry
        case selectSegment(Int?)
        case toggleStarredFilter
        case toggleClimbCategoryFilter(SegmentViewData.ClimbCategory)
        case clearFilters
        case updateMapRegion(MKCoordinateRegion)
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if case .dataLoaded = state.segments { return .none }
                state.segments = .loading
                return .run { send in
                    let result = await stravaClient.fetchSegments()
                    await send(.segmentsResponse(result))
                }
                
            case .retry:
                state.segments = .loading
                return .run { send in
                    let result = await stravaClient.fetchSegments()
                    await send(.segmentsResponse(result))
                }
                
            case .segmentsResponse(.success(let segments)):
                let identifiedSegments = IdentifiedArray(uniqueElements: segments)
                state.segments = .dataLoaded(identifiedSegments)
                
                // Update map region to fit all segments
                if !segments.isEmpty {
                    state.mapRegion = calculateMapRegion(for: segments)
                }
                
                return .none
                
            case .segmentsResponse(.failure(let error)):
                state.segments = .error(error)
                return .none
                
            case .selectSegment(let segmentId):
                state.selectedSegmentId = segmentId
                
                // If a segment is selected, center the map on it
                if let segmentId,
                   let segment = state.segments.data?[id: segmentId] {
                    state.mapRegion = MKCoordinateRegion(
                        center: segment.startCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                
                return .none
                
            case .toggleStarredFilter:
                state.filterStarredOnly.toggle()
                return .none
                
            case .toggleClimbCategoryFilter(let category):
                if state.filterClimbCategories.contains(category) {
                    state.filterClimbCategories.remove(category)
                } else {
                    state.filterClimbCategories.insert(category)
                }
                return .none
                
            case .clearFilters:
                state.filterStarredOnly = false
                state.filterClimbCategories = []
                return .none
                
            case .updateMapRegion(let region):
                state.mapRegion = region
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
    // Helper function to calculate map region that fits all segments
    private func calculateMapRegion(for segments: [SegmentViewData]) -> MKCoordinateRegion {
        guard !segments.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.40, longitude: -122.20),
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
        }
        
        var minLat = segments[0].startCoordinate.latitude
        var maxLat = segments[0].startCoordinate.latitude
        var minLon = segments[0].startCoordinate.longitude
        var maxLon = segments[0].startCoordinate.longitude
        
        for segment in segments {
            minLat = min(minLat, segment.startCoordinate.latitude, segment.endCoordinate.latitude)
            maxLat = max(maxLat, segment.startCoordinate.latitude, segment.endCoordinate.latitude)
            minLon = min(minLon, segment.startCoordinate.longitude, segment.endCoordinate.longitude)
            maxLon = max(maxLon, segment.startCoordinate.longitude, segment.endCoordinate.longitude)
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = (maxLat - minLat) * 1.3 // Add 30% padding
        let spanLon = (maxLon - minLon) * 1.3
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLon, 0.01))
        )
    }
}
