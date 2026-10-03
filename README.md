# CONC EARTH

**Concentration Earth** — *Focus takes you somewhere.*

A native iOS focus app that turns deep-work sessions into virtual flights. Choose a route, pick a seat, board, and watch your plane travel while you stay focused.

Built with **Swift**, **SwiftUI**, **MapKit**, **Core Location**, and **ActivityKit**.

---

## Features

- Immersive focus flights with boarding → takeoff → cruise → landing
- Signature **Window Seat Experience** (MapKit + calm atmosphere)
- Take me somewhere · focus purpose · collectible boarding passes
- Expandable airport catalog with quiet unlocks + flight miles
- Your World map · Journey summary · discreet milestones
- Dynamic atmosphere (clear / clouds / rain / sunrise / day / sunset / night)
- Live Activities + Dynamic Island
- No fake app-blocking · no loud gamification

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
