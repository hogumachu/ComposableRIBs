# SearchProtocolSample

This sample ports the TCA Search experience into ComposableRIBs using protocol-first dependency injection.

## What it shows
- Separate iOS app example with UIKit launch routing and SwiftUI feature rendering.
- Pure TCA reducer/view flow for debounced search and weather loading.
- No `@Dependency` usage; services are injected via RIB dependency contracts.
- In-app runtime mode switch between mock and live Open-Meteo services.
- Single root RIB module (`SearchBuilder` + `SearchRouter`) to focus on DI and feature flow.

## Run
1. Generate project files:
   ```bash
   cd Examples/SearchProtocolSample
   xcodegen generate
   ```
2. Open `SearchProtocolSample.xcodeproj`.
3. Select an iOS simulator (for example: iPhone 16, iOS 18.5).
4. Build and run `SearchProtocolSample`.

## Architecture Notes
- Dependency contracts live in `SearchProtocolSample/Shared/SearchDependencies.swift`.
- Weather service protocol and implementations live in `SearchProtocolSample/Shared/WeatherService.swift`.
- `SearchFeature` receives both services through initializer injection in `SearchBuilder`.
- `SearchRouter` is hosting-only and does not send feature actions directly.
