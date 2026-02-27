//
//  StravaProfileViewerApp.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct StravaProfileViewerApp: App {
    @MainActor
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
