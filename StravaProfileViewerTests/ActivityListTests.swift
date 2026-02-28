//
//  ActivityListTests.swift
//  StravaProfileViewerTests
//
//  Created by Yuchen Nie on 2/27/26.
//

import Testing
import ComposableArchitecture
@testable import StravaProfileViewer

@MainActor
struct ActivityListTests {

    private static let mocks = ActivityViewData.createMocks()
    private static let identifiedMocks = IdentifiedArray(uniqueElements: mocks)

    // MARK: - onAppear

    @Test
    func onAppear_fetchesActivities_onSuccess() async {
        let store = TestStore(initialState: ActivityList.State()) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .success(Self.mocks) }
        }

        await store.send(.onAppear)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .dataLoaded(Self.identifiedMocks)
            $0.canLoadNextPage = false
            $0.page = 2
        }
    }

    @Test
    func onAppear_setsError_onFailure() async {
        let store = TestStore(initialState: ActivityList.State()) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .failure(.networkError) }
        }

        await store.send(.onAppear)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .error(.networkError)
        }
    }

    @Test
    func onAppear_doesNothing_whenAlreadyLoaded() async {
        let store = TestStore(
            initialState: ActivityList.State(activityData: .dataLoaded(Self.identifiedMocks))
        ) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .success(Self.mocks) }
        }

        await store.send(.onAppear)
    }

    // MARK: - retry

    @Test
    func retry_resetsPage_beforeFetching() async {
        let store = TestStore(
            initialState: ActivityList.State()
        ) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .failure(.networkError) }
        }

        await store.send(.retry)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .error(.networkError)
        }
    }

    @Test
    func retry_fetchesActivities_onSuccess() async {
        let store = TestStore(initialState: ActivityList.State(activityData: .error(.networkError))) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .success(Self.mocks) }
        }

        await store.send(.retry)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .dataLoaded(Self.identifiedMocks)
            $0.canLoadNextPage = false
            $0.page = 2
        }
    }

    @Test
    func retry_setsError_onFailure() async {
        let store = TestStore(initialState: ActivityList.State(activityData: .error(.networkError))) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .failure(.errorWithStatusCode(500)) }
        }

        await store.send(.retry)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .error(.errorWithStatusCode(500))
        }
    }

    // MARK: - loadNextPage

    @Test
    func loadNextPage_appendsActivities_onSuccess() async {
        let page2Mocks = [ActivityViewData.createMock(id: 99999, title: "Page 2 Activity")]
        let initialState = ActivityList.State(
            activityData: .dataLoaded(Self.identifiedMocks),
            canLoadNextPage: true,
            page: 2
        )

        let store = TestStore(initialState: initialState) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .success(page2Mocks) }
        }

        await store.send(.loadNextPage)
        await store.receive(\.nextPageLoaded) {
            var expected = Self.identifiedMocks
            expected.append(contentsOf: IdentifiedArray(uniqueElements: page2Mocks))
            $0.activityData = .dataLoaded(expected)
            $0.canLoadNextPage = false
            $0.page = 3
        }
    }

    @Test
    func loadNextPage_doesNothing_whenCannotLoadNextPage() async {
        let store = TestStore(
            initialState: ActivityList.State(
                activityData: .dataLoaded(Self.identifiedMocks),
                canLoadNextPage: false,
                page: 2
            )
        ) {
            ActivityList()
        }

        await store.send(.loadNextPage)
    }

    @Test
    func loadNextPage_doesNotUpdateState_onFailure() async {
        let store = TestStore(
            initialState: ActivityList.State(
                activityData: .dataLoaded(Self.identifiedMocks),
                canLoadNextPage: true,
                page: 2
            )
        ) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { _ in .failure(.networkError) }
        }

        await store.send(.loadNextPage)
        await store.receive(\.nextPageLoaded)
    }
}
