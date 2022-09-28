# ReVanced Magisk Module
[![Build Modules](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml/badge.svg)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml)
[![CI](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml)

You can get the [latest CI release from here](https://github.com/j-hc/revanced-magisk-module/releases).

The [**mindetach module**](https://github.com/j-hc/mindetach-magisk) in the releases section detaches YouTube and YouTube Music from Play Store and blocks it from updating them.

## Features
 * Can build Magisk modules or non-root APKs
 * Updated daily with the latest versions of apps and patches in accordance with your configuration
 * Cleans APKs from unneeded libs to make them smaller
 * Fully open-source, every binary or APK is compiled without human intervention
 * Modules
     * recompiles invalidated odex for YouTube and Music apps for faster usage
     * receive updates from Magisk app
     * do not break safetynet or trigger root detections used by certain apps
     * handle installation of the correct version of the stock app and all that
     * mount the patched app immediately without needing to reboot
     * do not cause any permanent changes in /system or /data partitions


The default config is for building Magisk modules for YouTube and YT Music, if you want a repo that builds **APKs for every app** you can check out this one: https://github.com/revanced-apks/build-apps

## To include/exclude patches or build non-root variant
[**See the list of patches**](https://github.com/revanced/revanced-patches#-list-of-available-patches)

 * Star the repo :eyes:
 * Use the repo as template or fork it (if you choose the repo to be private, you won't receive updates from Magisk app)
 * Edit the patcher args in [`build.conf`](./build.conf)
 * Run the [workflow](../../actions/workflows/build.yml)
 * Grab your modules from [releases](../../releases)

**If you include microg patches in [build.conf](./build.conf), you get non-root APKs instead of Magisk modules. Apps except Youtube and Music will always be built as APKs regardless. To be able to use non-root variants of YT and Music you will need to install [Vanced MicroG](https://github.com/TeamVanced/VancedMicroG/releases).**

### **Note that the [CI workflow](../../actions/workflows/ci.yml) is scheduled to build the modules and APKs everyday if there is a change. You may want to disable it.**

# Building Locally
Make sure you have JDK 17 installed. Then run:

```console
$ git clone --recurse-submodules https://github.com/j-hc/revanced-magisk-module
$ cd revanced-magisk-module
$ ./build.sh build
```
