//
//  ContentView.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import SwiftUI

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {

    @ObservableState
    struct State: Equatable {
        var auth = AuthFeature.State()
        var profile = Profile.State()
        var activityList = ActivityList.State()
        var selectedTab: Tab = .activities
    }

    enum Tab: String, CaseIterable {
        case activities
        case profile

        var title: String {
            switch self {
            case .activities: return "Activities"
            case .profile: return "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .activities: return "bicycle.circle.fill"
            case .profile: return "person.fill"
            }
        }
    }

    enum Action {
        case tabSelected(Tab)
        case auth(AuthFeature.Action)
        case profile(Profile.Action)
        case activityList(ActivityList.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }

        Scope(state: \.profile, action: \.profile) {
            Profile()
        }

        Scope(state: \.activityList, action: \.activityList) {
            ActivityList()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .auth(.logoutTapped):
                state.profile = Profile.State()
                state.activityList = ActivityList.State()
                return .none

            case .auth:
                return .none

            case .profile:
                return .none

            case .activityList:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        Group {
            let authStore = store.scope(state: \.auth, action: \.auth)
            switch store.auth.phase {
            case .checkingAuth:
                ProgressView()
            case .unauthenticated, .authenticating:
                AuthView(store: authStore)
            case .authenticated:
                mainTabView
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Logout") {
                                store.send(.auth(.logoutTapped))
                            }
                        }
                    }
            }
        }.task {
            store.send(.auth(.onAppear))
        }

    }

    @ViewBuilder
    private var mainTabView: some View {
        TabView(selection: Binding(
            get: { store.selectedTab },
            set: { store.send(.tabSelected($0)) }
        )) {
            ActivityListView(
                store: store.scope(state: \.activityList, action: \.activityList)
            )
            .tabItem {
                Label(AppFeature.Tab.activities.title, systemImage: AppFeature.Tab.activities.systemImage)
            }
            .tag(AppFeature.Tab.activities)

            ProfileView(
                store: store.scope(state: \.profile, action: \.profile)
            )
            .tabItem {
                Label(AppFeature.Tab.profile.title, systemImage: AppFeature.Tab.profile.systemImage)
            }
            .tag(AppFeature.Tab.profile)
        }
    }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(auth: AuthFeature.State(phase: .authenticated))
        ) {
            AppFeature()
        } withDependencies: {
            $0.authClient = .previewValue
            $0.stravaClient = .previewValue
        }
    )
}
