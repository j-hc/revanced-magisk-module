#### ⚠️ Do not download modules from 3rd party sources like random websites you found on Google. There are many that uses my modules and impersonates ReVanced.

# ReVanced Extended
[![Build Modules](https://github.com/NoName-exe/revanced-extended/actions/workflows/build.yml/badge.svg)](https://github.com/NoName-exe/revanced-extended/actions/workflows/build.yml)
[![CI](https://github.com/NoName-exe/revanced-extended/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/NoName-exe/revanced-extended/actions/workflows/ci.yml)

Get the [latest CI release](https://github.com/NoName-exe/revanced-extended/releases/latest).

## Features
 * Updated with the latest versions of patches.
 * Cleans APKs from unneeded libs to make them smaller.
 * Fully open-source, every binary or APK is compiled without human intervention.
 * Modules:
     * Recompile invalidated odex for YouTube and YouTube-Music for faster usage.
     * Receive updates from Magisk app.
     * Should not break safetynet or trigger root detections used by certain apps.
     * Handle installation of the correct version of the stock app and all that.


 ## Notes
* YouTube Magisk Module is installed as a system app and requires a reboot to install/update.
* YouTube-Music Magisk Module is installed as a user app and does not require a reboot to install/update.
* Use [mindetach](https://github.com/j-hc/mindetach-magisk) to block Play Store from updating YouTube and YouTube-Music.
* Non-root versions of YouTube and YouTube-Music require [Vanced MicroG](https://github.com/inotia00/VancedMicroG/releases/latest) or [mMicroG](https://github.com/inotia00/mMicroG/releases/latest) to work.

## Credits
[j-hc](https://github.com/j-hc) for [mindetach](https://github.com/j-hc/mindetach-magisk) and the [script on which this is based on](https://github.com/j-hc/revanced-magisk-module).

[NoName-exe](https://github.com/NoName-exe) for the [repack script](https://github.com/NoName-exe/revanced-misc-stuff/) for Magisk module

[HuskyDG](https://github.com/HuskyDG) for his [Magisk Module Template](https://github.com/HuskyDG/revanced-build-ci) that installs YouTube as a system app.

[inotia00](https://github.com/inotia00) for [revanced-extended patches](https://github.com/inotia00/revanced-patches/tree/revanced-extended) and  [Vanced MicroG](https://github.com/inotia00/VancedMicroG).
=======
[**mindetach module**](https://github.com/j-hc/mindetach-magisk) in the releases section detaches YouTube and YouTube Music from Play Store and blocks their forced updates.