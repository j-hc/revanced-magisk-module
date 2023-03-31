#### ⚠️ Do not download modules from 3rd party sources like random websites you found on Google. Only use this repository. I am not responsible for anything they may contain.
#### ⚠️ Only non-root releases (Magisk's are disabled)

You can see the patches applied for [Revanced](https://github.com/kevinr99089/revanced.extended/blob/main/config.toml) and for [ReVanced Extended](https://github.com/kevinr99089/revanced.extended/blob/main/config-rv-ex.toml)

- Available Apps: YouTube (Ex), YT Music (Ex).

#### Please note that the signature is different from ReVanced Manager. Applications patched here cannot be updated on an app patched by ReVanced Manager (without uninstalling the application first, remember to export your settings before uninstalling it) (but you can update applications present on kevinr99089/revanced.extended, the signatures do not change).

After much thought, I decided to stop patching applications with ReVanced here. You can find most patched apps with ReVanced [here](https://github.com/revanced-apks/build-apps/releases/latest) (since revanced-apks is also a fork of j-hc, the signature is identical, so you can update even if you have installed one of the apps on my fork). This will allow me to concentrate only on Extended, and to automate it.
BUT, i'm trying to setup another repository to patch ReVanced, you can view here when it's ready.

# ReVanced Magisk Module
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/rvc_magisk)
[![Build Modules](https://github.com/kevinr99089/revanced.extended/actions/workflows/build.yml/badge.svg)](https://github.com/kevinr99089/revanced.extended/actions/workflows/build.yml)
[![CI](https://github.com/kevinr99089/revanced.extended/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/kevinr99089/revanced.extended/actions/workflows/ci.yml)

Extensive ReVanced builder  

Get the [latest CI release](https://github.com/j-hc/revanced-magisk-module/releases).

[**mindetach module**](https://github.com/j-hc/mindetach-magisk) in the releases section detaches YouTube and YouTube Music from Play Store and blocks it from updating them.

## Features
 * Support all present and future ReVanced and [ReVanced Extended](https://github.com/inotia00/revanced-patches) apps
 * Can build Magisk modules and non-root APKs
 * Updated daily with the latest versions of apps and patches
 * Optimize APKs and modules for size
 * Modules
     * recompile invalidated odex for faster usage
     * receive updates from Magisk app
     * do not break safetynet or trigger root detections
     * handle installation of the correct version of the stock app and all that
     * support Magisk and KernelSU

#### **Note that the [CI workflow](../../actions/workflows/ci.yml) is scheduled to build the modules and APKs everyday using GitHub Actions if there is a change in ReVanced patches. You may want to disable it.**

## To include/exclude patches or patch more ReVanced Apps
[**See the list of patches**](https://github.com/revanced/revanced-patches#-patches)

 * Star the repo :eyes:
 * [Fork the repo](https://github.com/j-hc/revanced-magisk-module/fork) or use it as a template
 * Customize [`config.toml`](./config.toml)
 * Run the build [workflow](../../actions/workflows/build.yml)
 * Grab your modules and APKs from [releases](../../releases)

To add more ReVanced apps or build ReVanced Extended `config.toml`, read here [`CONFIG.md`](./CONFIG.md)

# Building Locally
## On Termux
```console
bash <(curl -sSf https://raw.githubusercontent.com/j-hc/revanced-magisk-module/main/build-termux.sh)
```

## On Desktop
Make sure you have JDK 17 and jq installed. Then run:

```console
$ git clone --recurse https://github.com/j-hc/revanced-magisk-module
$ cd revanced-magisk-module
$ ./build.sh
```
