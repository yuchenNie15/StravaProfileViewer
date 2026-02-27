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
    @Dependency(\.stravaClient) var stravaClient
    
    @ObservableState
    @MainActor
    struct State: Equatable {
        var profileData: ViewDataState<ProfileViewData>

        init(profileData: ViewDataState<ProfileViewData> = .loading) {
            self.profileData = profileData
        }
    }

    enum Action {
        case onAppear
        // Updated to use your specific error type
        case profileResponse(Result<ProfileViewData, DataLoadingError>)
        case retry
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.profileData.isDataLoaded else { return .none }
                state.profileData = .loading
                return .run { send in
                    let result = await stravaClient.fetchAthlete()
                    await send(.profileResponse(result))
                }

            case .retry:
                return .run { send in
                    let result = await stravaClient.fetchAthlete()
                    await send(.profileResponse(result))
                }

            case .profileResponse(.success(let profile)):
                state.profileData = .dataLoaded(profile)
                return .none

            case .profileResponse(.failure(let error)):
                // Since the Action now expects DataLoadingError, you can pass it directly
                state.profileData = .error(error)
                return .none
            }
        }
    }
}

struct ProfileView: View {
    @Bindable var store: StoreOf<Profile>
    
    var body: some View {
        NavigationStack {
            Group {
                switch store.profileData {
                case .loading:
                    ProgressView()
                case .dataLoaded(let profile):
                    dataView(profile: profile)
                case .error(let error):
                    FullPageErrorView(error: error) {
                        store.send(.retry)
                    }
                case .empty:
                    EmptyView()
                }
            }
            .navigationTitle("Profile")
        }
        .task { store.send(.onAppear) }
    }
    
    @ViewBuilder
    private func dataView(profile: ProfileViewData) -> some View {
        List {
            headerSection(profile)
            
            Section("Stats") {
                HStack {
                    Label("\(profile.followerCount) Followers", systemImage: "person.2")
                    Spacer()
                    Label("\(profile.followingCount) Following", systemImage: "person.badge.plus")
                }
                .font(.subheadline)
            }
            
            if !profile.bikes.isEmpty {
                Section("Bikes") {
                    ForEach(profile.bikes) { bike in
                        gearRow(bike, icon: "bicycle")
                    }
                }
            }
            
            if !profile.shoes.isEmpty {
                Section("Shoes") {
                    ForEach(profile.shoes) { shoe in
                        gearRow(shoe, icon: "shoeprints.fill")
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    private func headerSection(_ profile: ProfileViewData) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: profile.profileImageURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.orange, lineWidth: 2))
            
            VStack {
                Text(profile.fullName)
                    .font(.title2).bold()
                
                Text(profile.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if profile.isPremium {
                Text("PREMIUM")
                    .font(.caption2).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private func gearRow(_ gear: ProfileViewData.GearRowData, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(gear.name)
                Text(gear.distanceDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if gear.isPrimary {
                Text("Primary")
                    .font(.caption)
                    .padding(4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
}
