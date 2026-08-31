# HeliumPad

A native iPad web browser inspired by [Helium](https://helium.computer/)'s
privacy-first philosophy: SwiftUI + WKWebView, tabs, an address bar, and
built-in ad/tracker blocking via `WKContentRuleList` — no telemetry, no
account, no bloat.

## Important: this is not a port of Helium

Helium is a Chromium build (via ungoogled-chromium) for macOS/Linux/Windows.
Its actual browser engine (Blink/V8, C++ patches against Chromium) cannot
run on iOS/iPadOS at all — Apple requires every iOS browser to use
WebKit, so Chromium's own engine is disabled at the OS level regardless of
how it's packaged. There is no "porting" path from Helium's source to an
iPad app; the codebases are fundamentally incompatible.

What *was* reused from the uploaded `helium-main.zip`: the app icon
(`resources/branding/app_icon/raw.png`, GPL-3.0 per Helium's `LICENSE`) and
its general product philosophy (fast, private, ad-blocked, no bloat).
Everything else here — the UI, the tab/navigation model, and the block
list — is new code written for this app.

## What it does

- Multiple tabs, each with its own `WKWebView` (independent back/forward
  history, scroll position, etc.)
- Address bar with combined URL/search field (falls back to a DuckDuckGo
  search when the input isn't a URL)
- Ad/tracker blocking toggle, backed by a bundled `blocklist.json`
  (`WKContentRuleList` format) covering common ad networks and analytics/
  tracking domains
- iPad-only target (`TARGETED_DEVICE_FAMILY = 2`), supports all orientations

## What it doesn't do (yet)

- Bookmarks, history UI, downloads, find-in-page, settings screen
- Private/incognito tabs (the model has a hook for a non-persistent data
  store per tab, but the UI doesn't expose it yet)
- Extension support of any kind
- The block list is a small curated set, not a full EasyList/EasyPrivacy
  import — it stops most common ad/analytics domains but isn't as
  comprehensive as a real content-blocker extension

## Building the unsigned IPA via GitHub Actions

1. Push this repo to GitHub.
2. The workflow at `.github/workflows/build-unsigned-ipa.yml` runs on
   `macos-15` runners, builds with code signing disabled
   (`CODE_SIGNING_ALLOWED=NO`), and zips the resulting `.app` into
   `Payload/HeliumPad-unsigned.ipa`.
3. Trigger it manually from the Actions tab (`workflow_dispatch`) or by
   pushing to `main`. Download the `HeliumPad-unsigned-ipa` artifact when
   it finishes.

### Installing the unsigned IPA on an iPad

An **unsigned** IPA cannot be installed via the normal App Store/TestFlight
path — iOS refuses to run unsigned code. To actually run it on a device
you need one of:

- **AltStore / SideStore** — resigns the IPA locally using your own free
  Apple ID (7-day reinstall requirement) or a paid developer account
  (1 year)
- **Sideloadly** — similar resigning flow from a Mac/PC
- **A real Apple Developer Program membership** — replace the
  `CODE_SIGNING_ALLOWED=NO` build settings with your team ID/provisioning
  profile to produce a properly signed IPA instead

This build intentionally skips signing because no signing certificate or
provisioning profile was provided — that step requires your own Apple
Developer account either way.

## Local development

Open `HeliumPad.xcodeproj` in Xcode 16+, select an iPad simulator or a
connected iPad, and run. Minimum deployment target is iPadOS 17.
