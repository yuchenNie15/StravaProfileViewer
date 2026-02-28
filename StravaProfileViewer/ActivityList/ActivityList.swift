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
    static let pageSize: Int = 30
    @Dependency(\.stravaClient) var stravaClient
    
    @ObservableState
    struct State: Equatable {
        // Changed name for clarity, and removed explicit @MainActor
        var activityData: ViewDataState<IdentifiedArrayOf<ActivityViewData>> = .loading
        var canLoadNextPage: Bool = true
        var page: Int = 1
    }

    enum Action {
        case onAppear
        case activitiesResponse(Result<[ActivityViewData], DataLoadingError>)
        case nextPageLoaded(Result<[ActivityViewData], DataLoadingError>)
        case loadNextPage
        case retry
    }

    var nextPageLoader: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadNextPage:
                if !state.canLoadNextPage { return .none }
                return .run { [page = state.page] send in
                    let result = await stravaClient.fetchActivities(page)
                    await send(.nextPageLoaded(result))
                }
            case .nextPageLoaded(.success(let newActivityData)):
                guard var currentList = state.activityData.data else { return .none }
                let identifiedActivities = IdentifiedArray(uniqueElements: newActivityData)
                currentList.append(contentsOf: identifiedActivities)
                
                state.canLoadNextPage = determineIfNextPageCanBeLoaded(
                    from: state.page,
                    currentElements: currentList
                )
                state.activityData = .dataLoaded(currentList)
                state.page += 1
                return .none
            case .nextPageLoaded(.failure(let error)):
                // ideally this should show a toast message and log error
                print("Next Page failed to load with error: \(error.localizedDescription)")
                return .none
            default:
                return .none
            }
        }

    }
    
    var body: some Reducer<State, Action> {
        CombineReducers {
            nextPageLoader
            
            Reduce { state, action in
                switch action {
                case .onAppear:
                    if case .dataLoaded = state.activityData { return .none }
                    return loadInitialActivities()
                case .retry:
                    state.page = 1
                    return loadInitialActivities()
                case .activitiesResponse(.success(let activities)):
                    let identifiedActivities = IdentifiedArray(uniqueElements: activities)
                    state.activityData = .dataLoaded(identifiedActivities)
                    state.canLoadNextPage = determineIfNextPageCanBeLoaded(
                        from: state.page,
                        currentElements: identifiedActivities
                    )
                    state.page += 1
                    return .none
                case .activitiesResponse(.failure(let error)):
                    state.activityData = .error(error)
                    return .none
                default:
                    return .none
                    
                }
            }
        }
    }
    
    private func loadInitialActivities() -> Effect<Action> {
        return .run { send in
            let result = await stravaClient.fetchActivities(1)
            await send(.activitiesResponse(result))
        }
    }
    
    private func determineIfNextPageCanBeLoaded(
        from pageNumber: Int,
        currentElements: IdentifiedArrayOf<ActivityViewData>
    ) -> Bool {
        let numberOfExpectedElements = pageNumber * Self.pageSize
        return currentElements.count == numberOfExpectedElements
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
            if store.canLoadNextPage {
                VStack {
                    Spacer()
                    ProgressView()
                        .task {
                            store.send(.loadNextPage)
                        }
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Activities")
    }
}

// MARK: - Previews

#Preview("Loaded") {
    ActivityListView(store: Store(
        initialState: ActivityList.State(
            activityData: .dataLoaded(IdentifiedArray(uniqueElements: ActivityViewData.createMocks()))
        )
    ) {
        ActivityList()
    } withDependencies: {
        $0.stravaClient = .previewValue
    })
}
