# CONC EARTH

**Concentration Earth** — *Focus takes you somewhere.*

A native iOS focus app that turns deep-work sessions into virtual flights. Choose a route, pick a seat, board, and watch your plane travel while you stay focused.

Built with **Swift**, **SwiftUI**, **MapKit**, **Core Location**, and **ActivityKit**.

---

## Features (MVP)

- Home map with suggested / home airport
- 8 airports + expandable route catalog
- Focus duration + scenario selection (Calm, Night, Sunset, Morning, Storm, Long Haul)
- Seat map with window-seat → Window View unlock
- Animated digital ticket + boarding sequence
- In-flight Route / Follow / Window cameras on MapKit
- Pause / resume with progress restoration after relaunch
- FlightLog + stats
- Live Activities + Dynamic Island
- No fake app-blocking claims

---

## Project layout

```
CONCEarth/           App sources (MVVM modules)
CONCEarthWidget/     Live Activity widget extension
project.yml          XcodeGen project definition
Scripts/             Project generation helpers
Docs/                Signing, IPA, technical notes
.github/workflows/   macOS CI build + optional IPA export
```

---

## Build on macOS

Requirements: Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen), iOS 17 SDK.

```bash
brew install xcodegen
./Scripts/generate_project.sh
open CONCEarth.xcodeproj
```

Select your Development Team in Xcode, then Run on a simulator or device.

---

## GitHub Actions / IPA

Push to GitHub → workflow **iOS Build** runs on `macos-14`.

- Always: Release compile verification
- With signing secrets: Ad Hoc IPA artifact `CONCEarth-IPA`

Full instructions: [Docs/SIGNING_AND_IPA.md](Docs/SIGNING_AND_IPA.md)

---

## Brand

| | |
|--|--|
| Name | CONC EARTH |
| Subtitle | Concentration Earth |
| Promise | Focus takes you somewhere. |

Design direction: calm travel / flight-tracker energy, immersive satellite maps, glass controls, premium dark tickets — inspired by modern focus-flight UX, with original branding and UI.
