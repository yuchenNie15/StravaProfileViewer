//
//  Profile.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct Profile {
    @ObservableState
    struct State: Equatable {
        var label: String = "Hello, Profile!"
    }
    
    enum Action: BindableAction { // Add this
        case binding(BindingAction<State>)
        case placeholder
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer() // Add this to handle bindings automatically
        Reduce { state, action in
            return .none
        }
    }
}
struct ProfileView: View {
    @Bindable var store: StoreOf<Profile>
    
    var body: some View {
        Text(store.label)
    }
}
