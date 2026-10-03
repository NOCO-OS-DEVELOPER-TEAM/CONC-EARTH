# Technical decisions & deviations

## Architecture

- SwiftUI + MVVM-style `AppCoordinator` + service objects
- XcodeGen (`project.yml`) instead of hand-maintained `pbxproj` so the project can be authored on Windows and generated on macOS/CI
- Local persistence via JSON FlightLog + UserDefaults for the active session

## Map / flight

- Great-circle interpolation with a mild arc offset for route visuals
- Camera modes: Route / Follow / Window (Window only if a window seat is selected)
- Window View = MapKit follow camera + atmospheric SwiftUI frame overlay (not a separate 3D engine)

## App blocking

- Not implemented (no Screen Time / Family Controls entitlement in this MVP)
- In-flight “Stay focused” hint + Live Activity only

## Audio

- System sound IDs for boarding / takeoff / landing cues
- Optional looping cabin noise if `cabin_noise.m4a` / `.mp3` is later added to the app bundle

## Live Activities

- ActivityKit attributes shared with the widget extension
- Dynamic Island supported on capable devices
- Gracefully no-ops if the user disabled Live Activities

## IPA

- CI always attempts an unsigned Release compile
- Signed IPA export runs only when Apple signing secrets are present
