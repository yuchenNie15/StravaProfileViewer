//
//  AuthFeature.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AuthFeature {
    @Dependency(\.authClient) var authClient

    enum Phase: Equatable {
        case checkingAuth
        case unauthenticated
        case authenticating
        case authenticated
    }

    @ObservableState
    struct State: Equatable {
        var phase: Phase = .checkingAuth
        var errorMessage: String? = nil
    }

    enum Action {
        case onAppear
        case loginTapped
        case authCompleted
        case authFailed(DataLoadingError)
        case logoutTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if authClient.isAuthenticated() {
                    state.phase = .authenticated
                } else {
                    state.phase = .unauthenticated
                }
                return .none

            case .loginTapped:
                state.phase = .authenticating
                state.errorMessage = nil
                return .run { send in
                    do {
                        try await authClient.authenticate()
                        await send(.authCompleted)
                    } catch {
                        await send(.authFailed(error.asDataLoaderError))
                    }
                }

            case .authCompleted:
                state.phase = .authenticated
                return .none

            case .authFailed(let error):
                state.phase = .unauthenticated
                switch error {
                case .unknown(let msg): state.errorMessage = msg
                case .badResponse(let msg): state.errorMessage = msg ?? "Authentication failed."
                case .errorWithStatusCode(let code): state.errorMessage = "Error \(code)"
                case .networkError: state.errorMessage = "Network error. Please try again."
                }
                return .none

            case .logoutTapped:
                state.phase = .unauthenticated
                state.errorMessage = nil
                return .run { _ in await authClient.logout() }
            }
        }
    }
}

// MARK: - AuthView

struct AuthView: View {
    let store: StoreOf<AuthFeature>

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                VStack(spacing: 8) {
                    Text("Strava Profile Viewer")
                        .font(.title).bold()
                    Text("Connect your Strava account to get started.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let error = store.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                if store.phase == .authenticating {
                    ProgressView("Connecting…")
                        .progressViewStyle(.circular)
                } else {
                    Button {
                        store.send(.loginTapped)
                    } label: {
                        Label("Connect with Strava", systemImage: "link")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer().frame(height: 32)
            }
        }
        .task { store.send(.onAppear) }
    }
}

// MARK: - Previews

#Preview("Login") {
    AuthView(store: Store(initialState: AuthFeature.State(phase: .unauthenticated)) {
        AuthFeature()
    } withDependencies: {
        $0.authClient = .previewValue
    })
}

#Preview("Authenticating") {
    AuthView(store: Store(initialState: AuthFeature.State(phase: .authenticating)) {
        AuthFeature()
    } withDependencies: {
        $0.authClient = .previewValue
    })
}

#Preview("Error") {
    AuthView(store: Store(
        initialState: AuthFeature.State(phase: .unauthenticated, errorMessage: "Access denied. Please try again.")
    ) {
        AuthFeature()
    } withDependencies: {
        $0.authClient = .previewValue
    })
}
