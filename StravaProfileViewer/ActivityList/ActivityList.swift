//
//  ActivityList.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct ActivityList {
    @Dependency(\.stravaClient) var stravaClient
    
    @ObservableState
    struct State: Equatable {
        // Changed name for clarity, and removed explicit @MainActor
        var activityData: ViewDataState<IdentifiedArrayOf<ActivityViewData>> = .loading
        var page: Int = 1
    }

    enum Action {
        case onAppear
        case activitiesResponse(Result<[ActivityViewData], DataLoadingError>)
        case retry
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if case .dataLoaded = state.activityData { return .none }
                
                return .run { [page = state.page] send in
                    // Use the local 'client' instead of 'stravaClient'
                    let result = await stravaClient.fetchActivities(page)
                    await send(.activitiesResponse(result))
                }

            case .retry:
                return .run { [page = state.page] send in
                    let result = await stravaClient.fetchActivities(page)
                    await send(.activitiesResponse(result))
                }

            case .activitiesResponse(.success(let activities)):
                let identifiedActivities = IdentifiedArray(uniqueElements: activities)
                state.activityData = .dataLoaded(identifiedActivities)
                return .none

            case .activitiesResponse(.failure(let error)):
                state.activityData = .error(error)
                return .none
            }
        }
    }
}

struct ActivityListView: View {
    @Bindable var store: StoreOf<ActivityList>
    
    var body: some View {
        NavigationStack {
            Group {
                switch store.activityData {
                case .loading:
                    ProgressView()
                case .dataLoaded(let activities):
                    dataView(activites: activities)
                case .error(let error):
                    FullPageErrorView(error: error) {
                        store.send(.retry)
                    }
                case .empty:
                    EmptyView()
                }
            }
            .navigationTitle("Profile")
        }
        .task { store.send(.onAppear) }
    }
    
    @ViewBuilder
    private func dataView(activites: IdentifiedArrayOf<ActivityViewData>) -> some View {
        List {
            ForEach(activites) { activity in
                ActivityRowView(activity: activity)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
        .listStyle(.plain)
        .navigationTitle("Activities")
    }
}
