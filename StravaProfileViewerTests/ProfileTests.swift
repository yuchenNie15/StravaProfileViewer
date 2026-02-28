//
//  ProfileTests.swift
//  StravaProfileViewerTests
//
//  Created by Yuchen Nie on 2/27/26.
//

import Testing
import ComposableArchitecture
@testable import StravaProfileViewer

@MainActor
struct ProfileTests {

    @Test
    func onAppear_fetchesProfile_onSuccess() async {
        let store = TestStore(initialState: Profile.State()) {
            Profile()
        } withDependencies: {
            $0.stravaClient.fetchAthlete =
            { .success(.mock) }
        }

        await store.send(.onAppear)
        await store.receive(\.profileResponse) {
            $0.profileData = .dataLoaded(.mock)
        }
    }

    @Test
    func onAppear_setsError_onFailure() async {
        let store = TestStore(initialState: Profile.State()) {
            Profile()
        } withDependencies: {
            $0.stravaClient.fetchAthlete = { .failure(.networkError) }
        }

        await store.send(.onAppear)
        await store.receive(\.profileResponse) {
            $0.profileData = .error(.networkError)
        }
    }

    @Test
    func onAppear_doesNothing_whenAlreadyLoaded() async {
        let store = TestStore(initialState: Profile.State(profileData: .dataLoaded(.mock))) {
            Profile()
        } withDependencies: {
            $0.stravaClient.fetchAthlete = { .success(.mock) }
        }

        await store.send(.onAppear)
    }
    @Test
    func retry_fetchesProfile_onSuccess() async {
        let store = TestStore(initialState: Profile.State(profileData: .error(.networkError))) {
            Profile()
        } withDependencies: {
            $0.stravaClient.fetchAthlete = { .success(.mock) }
        }

        await store.send(.retry)
        await store.receive(\.profileResponse) {
            $0.profileData = .dataLoaded(.mock)
        }
    }

    @Test
    func retry_setsError_onFailure() async {
        let store = TestStore(initialState: Profile.State(profileData: .error(.networkError))) {
            Profile()
        } withDependencies: {
            $0.stravaClient.fetchAthlete = { .failure(.errorWithStatusCode(500)) }
        }

        await store.send(.retry)
        await store.receive(\.profileResponse) {
            $0.profileData = .error(.errorWithStatusCode(500))
        }
    }
}
