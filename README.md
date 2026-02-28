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

<img width="568" height="1084" alt="Screenshot 2026-02-28 at 6 25 59 AM" src="https://github.com/user-attachments/assets/243c9d30-00ac-41fd-800d-07b8e55d4cc1" />

## Profile

The Profile module, the personal dashboard in StravaProfileViewer, also uses TCA and SwiftUI but focuses on fetching a single, detailed user object. 

The Profile Reducer uses a ViewDataState wrapper for loading/error state management. onAppear initiates an asynchronous fetch via stravaClient, guarded against redundancy. It includes a retry mechanism via a pull-to-refresh. The ProfileView dynamically renders: a ProgressView during initial fetch transitions to a structured List. 

The layout features a header with a circular profile image, name, and location. It details Stats (follower/following counts) and iterates through Bikes and Shoes, showing distance and marking primary equipment. The .refreshable modifier allows users to sync latest data via pull-to-refresh.

<img width="568" height="1084" alt="Screenshot 2026-02-28 at 6 26 15 AM" src="https://github.com/user-attachments/assets/8ff8ca78-d513-4572-8168-c61c9f12fe7c" />

## Unit Tests

The ActivityListTests include test cases for the TCA reducer of an ActivityList. The tests use a TestStore with a mocked stravaClient and four mock activities. 
Key behaviors tested for the ActivityList include:
1. onAppear: Successful fetching of the first page, population of the list, setting the next page to 2, and disabling further loading if the data is a partial page. It also covers failure (transitioning to an error state) and preventing redundant fetches if data is already loaded (no-op).
2. retry: Resets the page counter to 1 before fetching. Success after an error state repopulates the list and resets the state for future loading. Failure updates the error state.
3. loadNextPage: Successfully appends new activities (from page 2), advances the page number, and disables further loading on a partial page. It is a no-op when loading is disabled. A fetch failure during this action is a "silent error," preserving the existing list and making no state changes.

The test cases for the Profile TCA reducer, which utilizes TestStore and mocks the stravaClient.fetchAthlete dependency, are grouped by the action that triggers the state change.
The provided text outlines the test case strategy for the Profile TCA reducer, which manages state changes for a user's profile view. The tests use TestStore and mock the stravaClient.fetchAthlete dependency. The tests are grouped by the triggering action:
1. Initial Profile Load (onAppear): Ensures success (data loaded), failure (sets .error state), and redundancy prevention (no re-fetch if already loaded).
2. Profile Data Retry (retry): Covers attempts to load data after a previous failure, checking for both successful recovery and failure with a new error.
