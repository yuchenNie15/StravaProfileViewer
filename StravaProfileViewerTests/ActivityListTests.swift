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

    @Test
    func onAppear_usesCurrentPage() async {
        var capturedPage: Int?
        let store = TestStore(initialState: ActivityList.State(page: 3)) {
            ActivityList()
        } withDependencies: {
            $0.stravaClient.fetchActivities = { page in
                capturedPage = page
                return .success(Self.mocks)
            }
        }

        await store.send(.onAppear)
        await store.receive(\.activitiesResponse) {
            $0.activityData = .dataLoaded(Self.identifiedMocks)
        }
        #expect(capturedPage == 3)
    }
}
