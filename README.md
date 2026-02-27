# StravaProfileViewer

A SwiftUI app built with [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) that displays your Strava athlete profile.

## Getting a Strava Access Token

The app requires a Strava access token to fetch your profile. Since full OAuth is not yet implemented, you can obtain a token manually from the Strava developer portal:

1. Go to [https://www.strava.com/settings/api](https://www.strava.com/settings/api) and create an application (or use an existing one).
2. Navigate to [https://developers.strava.com/playground](https://developers.strava.com/playground).
3. Click **Authorize** and grant the `profile:read_all` scope.
4. After authorizing, the playground will display your **Access Token** in the response.

## Setting the Token in the App

Once you have the token, store it in `UserDefaults` before launching the app. The easiest way is to add a one-time call in `StravaProfileViewerApp.swift` during development:

```swift
UserDefaults.standard.set("YOUR_ACCESS_TOKEN_HERE", forKey: "strava_access_token")
```

Remove this line once a proper OAuth flow is in place.

> **Note:** Tokens obtained from the Strava playground expire after 6 hours. Repeat the steps above to get a fresh token when needed.

## Requirements

- Xcode 16+
- iOS 18+
- A Strava account and API application
