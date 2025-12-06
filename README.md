# WeatherApp

Simple real-time iOS weather app using MVVM-C, SwiftUI + UIKit, and URLSession.

## Requirements

- iOS app using MVVM-C, SwiftUI + UIKit, no storyboards
- URLSession only
- Search US city → fetch weather → show icon, temp, description
- Ask for location permission and auto-fetch by GPS
- Cache last searched city and auto-load on app start
- Error handling, loading states, orientation support
- Unit tests for ViewModel and Model

## Setup

1. Open Xcode on macOS.
2. Create a new iOS App project named `WeatherApp` without storyboard.
3. Delete the generated SwiftUI `App` file if present and use `AppDelegate` + `SceneDelegate`.
4. Add the contents of `WeatherApp/WeatherApp` into the app target.
5. Add `WeatherApp/WeatherAppTests` to the test target.
6. In target Info, include `Info.plist` from `WeatherApp/WeatherApp/Resources/Info.plist`.
7. Configure `OPENWEATHER_API_KEY` securely:
   - Build Settings → add User-Defined `OPENWEATHER_API_KEY = <your key>`; or
   - Scheme → Run → Environment Variables → `OPENWEATHER_API_KEY = <your key>`.
   - `Info.plist` expands `$(OPENWEATHER_API_KEY)` and runtime falls back to env.
8. Ensure `NSLocationWhenInUseUsageDescription` is present.

## Run

- Build and run on simulator or device.
- Grant location permission when prompted to auto-fetch local weather.
- Enter a US city and tap Search to fetch by city.

## Testing

- Run unit tests: Product → Test. Tests cover model decoding and ViewModel.
 - Additional tests cover service error mapping and icon URL.
 - Add a macOS CI workflow to run tests on every push; see `.github/workflows/ios-ipa.yml`.

## Architecture & Standards

- MVVM-C with dependency injection via `AppContainer`.
- Separation of concerns: services, models, view models, views, coordinator.
- Networking abstraction `NetworkClient` with timeouts for resilience.
- Error handling with displayable messages and loading states.
- Orientation support via `Info.plist` settings.
- Localization scaffolding via `Localizable.strings` and `LocalizedStringKey`.
- Accessibility labels for key UI controls.
- Image caching via `NSCache`.
- No third-party libraries; only native frameworks.

## CI and .ipa

- macOS GitHub Actions workflow `.github/workflows/ios-ipa.yml` builds and exports a signed `.ipa`.
- Provide Apple signing assets as repo secrets and update `WeatherApp/exportOptions.plist`.

- Weather fetched via OpenWeatherMap Geocoding + Weather endpoints.
- Icons loaded from `https://openweathermap.org/img/wn/{code}@2x.png` with simple cache.