# CONC EARTH — Signing, IPA & Sideloading

## Goal

Produce a real iOS `.ipa` that you can download on Windows and install on your iPhone (sideload).

Windows cannot compile iOS apps. The IPA is always built on macOS (locally or via GitHub Actions).

---

## How the IPA is built

### A) GitHub Actions (recommended)

1. Push to `main` / `master` (or run **iOS Build** manually).
2. Workflow `.github/workflows/ios-build.yml`:
   - installs XcodeGen
   - generates `CONCEarth.xcodeproj`
   - builds Release for `generic/platform=iOS`
   - **if signing secrets are present**: archives + exports an Ad Hoc IPA
   - uploads artifact **`CONCEarth-IPA`**

### B) Mac locally

```bash
./Scripts/generate_project.sh
open CONCEarth.xcodeproj
# In Xcode: select your Team → Product → Archive → Distribute App → Ad Hoc / Development
```

---

## Required Apple configuration

You need an **Apple Developer Program** membership (paid) for a device-installable IPA that lasts longer than free 7-day signing.

### Identifiers

| Target | Bundle ID |
|--------|-----------|
| App | `com.concearth.app` |
| Widget / Live Activity | `com.concearth.app.widget` |

Enable **Live Activities** capability for the app ID in the Apple Developer portal if you distribute outside automatic Xcode signing.

### Secrets for GitHub Actions

Repository → Settings → Secrets and variables → Actions:

| Secret | Description |
|--------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Base64 of your `.p12` distribution/development certificate |
| `P12_PASSWORD` | Password for that `.p12` |
| `PROVISIONING_PROFILE_BASE64` | Base64 of the `.mobileprovision` (Ad Hoc recommended for sideload) |
| `KEYCHAIN_PASSWORD` | Any random password for the temporary CI keychain |
| `DEVELOPMENT_TEAM` | Your 10-character Team ID |

Encode files on macOS:

```bash
base64 -i Certificates.p12 | pbcopy
base64 -i CONCEarth_AdHoc.mobileprovision | pbcopy
```

**Never commit certificates or profiles.**

Without these secrets, CI still compiles the app (unsigned verification) but **does not** produce a sideloadable IPA. That is intentional — no fake signing.

---

## Where to download the IPA

1. Open the GitHub repo → **Actions**
2. Open the latest successful **iOS Build** run
3. Download artifact **`CONCEarth-IPA`**
4. Unzip — you get `CONCEarth.ipa`

---

## Windows → iPhone sideload

After you have a **properly signed** IPA:

1. Install a sideload tool, e.g. **Sideloadly** or **AltStore / SideStore** (with AltServer).
2. Connect the iPhone (USB) or follow the tool’s wireless flow.
3. Sign in with the **same Apple ID** used for the certificate / provisioning (or the tool’s signing flow).
4. Install `CONCEarth.ipa`.
5. On iPhone: **Settings → General → VPN & Device Management** → trust the developer if prompted.

### Notes

- Free Apple ID signing typically expires after **7 days**.
- Ad Hoc profiles require the device UDID registered in the Developer portal.
- App Store Connect / TestFlight is an alternative distribution path (not automated in this repo yet).

---

## What this project does *not* do

- No fake credentials
- No cracked signing
- No claim that unsigned CI products are installable on a real iPhone

If CI only uploads `CONCEarth-Release-Product` (`.app`), that confirms the build compiled — it is **not** an IPA for sideloading until signing secrets are configured.
