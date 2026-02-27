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
    @ObservableState
    struct State: Equatable {
        var label: String = "Hello, Activity List!"
    }
    
    enum Action {
        case placeholder
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

struct ActivityListView: View {
    @Bindable var store: StoreOf<ActivityList>
    
    var body: some View {
        Text(store.label)
    }
}
