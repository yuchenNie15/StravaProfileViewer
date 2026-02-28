# StravaProfileViewer

A SwiftUI app built with [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) that displays your Strava athlete profile.

## Running the Application
To get the application running, you must first register it with Strava's developer API.

### Steps for App Registration:

1. Navigate to the Strava developer site: https://developers.strava.com/.
2. Follow the instructions there to create your new App.

### Retrieving API Credentials:
**Once the app is created:**
1. Go to your Strava API settings page: https://www.strava.com/settings/api.
2. Retrieve your Client ID and Client Secret. You may optionally retrieve the Refresh Token as well.
3. Within the Project, locate the `StravaClientID.swift` file and update the corresponding fields with the values you just retrieved.

## Authentication

Implementing the Strava OAuth flow with the AuthenticationServices framework required significant assistance from AI tools. I utilized Claude to generate the initial version of the Auth Client. 

However, as is often the case with AI-generated code, it wasn't functional initially and necessitated manual debugging to resolve multiple failures from the logs that the Strava API provided. 

Furthermore, the first iteration stored the access and refresh tokens in UserDefault storage rather than the more secure keychain.

## Activities List

The ActivityList uses TCA and SwiftUI for a paginated feed, separating UI state from Strava API side effects. Its State uses an IdentifiedArray for performance, tracking activities, page index, and fetch availability. 

The nextPageLoader manages infinite scrolling, fetching the next page via loadNextPage and appending data. The determineIfNextPageCanBeLoaded helper prevents unnecessary calls when a partial page is returned (less than the pageSize of 30). 

The ActivityListView updates dynamically via a switch statement. Pagination is managed by a ProgressView at the list's end, dispatching loadNextPage on viewport entry via .task. onAppear prevents redundant fetches by only loading if the list is empty.

## Profile

The Profile module, the personal dashboard in StravaProfileViewer, also uses TCA and SwiftUI but focuses on fetching a single, detailed user object. 

The Profile Reducer uses a ViewDataState wrapper for loading/error state management. onAppear initiates an asynchronous fetch via stravaClient, guarded against redundancy. It includes a retry mechanism via a pull-to-refresh. The ProfileView dynamically renders: a ProgressView during initial fetch transitions to a structured List. 

The layout features a header with a circular profile image, name, and location. It details Stats (follower/following counts) and iterates through Bikes and Shoes, showing distance and marking primary equipment. The .refreshable modifier allows users to sync latest data via pull-to-refresh.
