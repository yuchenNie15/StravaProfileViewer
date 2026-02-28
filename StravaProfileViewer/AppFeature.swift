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
        case profile(Profile.Action)
        case activityList(ActivityList.Action)
    }

    var body: some Reducer<State, Action> {
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
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
}
