# StravaProfileViewer — Claude Instructions

## Project Overview
iOS SwiftUI app built with The Composable Architecture (TCA) that displays a Strava athlete's profile and activity feed.

## Architecture

### TCA Conventions
- Every feature uses `@Reducer` + `@ObservableState` + `@Dependency`
- Dependencies are declared as `@DependencyClient` structs with a `previewValue` for mock data in previews
- Effects return `Result<T, DataLoadingError>` and are sent back as response actions (e.g. `.activitiesResponse`, `.profileResponse`)
- Use `ViewDataState<T>` (in `Core/ViewDataState.swift`) to represent loading/loaded/error/empty states

### File Organization
```
StravaProfileViewer/
├── AppFeature.swift          # Root reducer + AppView
├── Auth/                     # OAuth flow
│   ├── AuthFeature.swift     # Auth reducer + AuthView
│   ├── AuthClient.swift      # ASWebAuthenticationSession-based OAuth client
│   ├── TokenStore.swift      # Keychain token persistence
│   ├── TokenResponse.swift   # Decodable OAuth token model
│   ├── StravaClientID.swift  # stravaClientID, stravaClientSecret, stravaRefreshToken (skip-worktree)
│   └── StravaAccessToken.swift
├── Core/
│   ├── ViewDataState.swift   # ViewDataState<T> + DataLoadingError
│   ├── FullPageErrorView.swift
│   └── SharedDataFormatter.swift
├── Dependencies/
│   └── StravaClient.swift    # Strava API client; fetchAthlete + fetchActivities
├── Profile/                  # Athlete profile feature
│   ├── Profile.swift         # Reducer + ProfileView
│   ├── ProfileViewData.swift
│   ├── ProfileViewData+API.swift
│   └── ProfileViewData+Mocks.swift
└── ActivityList/             # Paginated activity feed
    ├── ActivityList.swift    # Reducer + ActivityListView
    ├── ActivityViewData.swift
    ├── ActivityViewData+API.swift
    ├── ActivityViewData+Mocks.swift
    └── ActivityRowView.swift
```

### Key Patterns
- **No manual `project.pbxproj` edits** — project uses `PBXFileSystemSynchronizedRootGroup`; files added to disk are auto-compiled
- **Error conversion** — use `Error.asDataLoaderError` to convert thrown errors to `DataLoadingError`
- **Pagination** — `ActivityList` tracks `page` and `canLoadNextPage`; page size is `ActivityList.pageSize` (30)
- **Token refresh** — `validToken()` in `StravaClient.swift` silently refreshes expired tokens before API calls

## Credentials
`Auth/StravaClientID.swift` is protected with `git update-index --skip-worktree` and contains placeholder values in the repo. Do not remove this protection or commit real credentials.

To restore protection if lost:
```
git update-index --skip-worktree StravaProfileViewer/Auth/StravaClientID.swift
```

## Testing
- Framework: Swift Testing (`import Testing`) + TCA `TestStore`
- Test files live in `StravaProfileViewerTests/`
- Each reducer action group has its own `// MARK:` section in the test file
- Mock data comes from `createMock()` / `createMocks()` on the view data types
- Always assert all state changes in `TestStore` receive closures (page increments, `canLoadNextPage`, etc.)

## Workflow Preferences
- Do not auto-commit — only commit when explicitly asked
- Do not push unless explicitly asked
