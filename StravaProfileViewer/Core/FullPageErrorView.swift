//
//  FullPageErrorView.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation
import SwiftUI

/// A full-page error state with an optional injected task to refetch data.
public struct FullPageErrorView: View {
    private let message: String
    private let refetch: () async -> Void

    public init(
        message: String? = nil,
        error: DataLoadingError? = nil,
        refetch: @escaping () async -> Void
    ) {
        self.message = message ?? error?.localizedDescription ?? "Something went wrong."
        self.refetch = refetch
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Unable to load", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(message)
        } actions: {
            Button("Try again") {
                Task { await refetch() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
