# ReVanced Apps

[![CI](https://github.com/avisek/revanced-apps/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/avisek/revanced-apps/actions/workflows/ci.yml)

Latest ReVanced apps for both root and non-root users.

Get the [latest CI release](https://github.com/avisek/revanced-apps/releases).

## Available Apps

- **YouTube** - ReVanced Extended
- **YouTube Music** - ReVanced Extended
- **Google Photos** - Unlimited Storage
- **Spotify** - Premium Unlocked

## Features

- Updated with the latest versions of patches.
- Cleans APKs from unneeded libs to make them smaller.
- Fully open-source, every binary or APK is compiled without human intervention.
- Modules:
  - Recompile invalidated odex for YouTube and YouTube-Music for faster usage.
  - Receive updates from Magisk app.
  - Should not break safetynet or trigger root detections used by certain apps.
  - Handle installation of the correct version of the stock app and all that.
  - Support Magisk and KernelSU.

## Notes

- Use [zygisk-detach](https://github.com/j-hc/zygisk-detach) to block Play Store from updating YouTube and YouTube-Music.
- Non-root versions of YouTube and YouTube-Music require [MicroG](https://github.com/ReVanced/GmsCore/releases) to work.

## Credits

[j-hc](https://github.com/j-hc) for [zygisk-detach](https://github.com/j-hc/zygisk-detach) and the [script on which this is based on](https://github.com/j-hc/revanced-magisk-module).

[ReVanced Team](https://github.com/revanced) for [MicroG](https://github.com/ReVanced/GmsCore/releases).

[inotia00](https://github.com/inotia00) for [revanced-extended patches](https://github.com/inotia00/revanced-patches).
