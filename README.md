# LIVE CONTENT for iOS

[![Build unsigned IPA](https://github.com/ACOPS1206/LIVE-CONTENT-iOS/actions/workflows/build.yml/badge.svg)](https://github.com/ACOPS1206/LIVE-CONTENT-iOS/actions/workflows/build.yml)

Create a custom Live Activity with your own text, SF Symbol, accent color, and a tiny photo thumbnail. The activity appears on the Lock Screen and, on supported iPhones, in the Dynamic Island.

## Features

- Start, update, and end a Live Activity
- Custom title and message
- Photo picker with automatic thumbnail compression
- Multiple SF Symbols and accent colors
- Lock Screen, compact, minimal, and expanded Dynamic Island layouts
- Unsigned IPA build from GitHub Actions

## Requirements

- iOS 17 or later
- Xcode 16 or later
- A physical device for full Live Activity testing

## Build locally

```sh
brew install xcodegen
xcodegen generate
open LiveContent.xcodeproj
```

Choose your development team and replace the bundle identifiers if needed before installing on a device.

## Photo limitation

ActivityKit limits the complete dynamic state to roughly 4 KB. Selected photos are therefore resized and heavily compressed into a small thumbnail. This keeps updates reliable without a server or shared App Group.

## GitHub Actions

Every push to `main` and every manual workflow dispatch builds an unsigned IPA. Download `LiveContent-unsigned-ipa` from the workflow run's Artifacts section. The IPA still needs signing before installation.
