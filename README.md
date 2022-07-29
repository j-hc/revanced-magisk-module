# YouTube ReVanced Magisk Module
[![Build Modules](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml/badge.svg)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml)
[![CI](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml)

<sub>(unaffiliated whatsoever)<sub>

This repo includes a simple script that downloads all the latest version of necessary prebuilt revanced tools and the stock APKs of YouTube and YouTube Music from APKMirror, applies the patches and creates magisk modules.

You will need to **install the stock YouTube (or YT Music) app matching with the module's version on your phone**. The link is also provided in release notes.

You can get the [latest CI release from here](https://github.com/j-hc/revanced-magisk-module/releases).

There is also an extra module in releases that detaches YouTube and YouTube Music from Play Store and stop it from pushing updates for those apps.

## To include/exclude patches
 * Star the repo :eyes:
 * Use the repo as template *or fork it* (if you choose the repo to be private, you won't receive updates from Magisk app)
 * Edit the patcher args in [`build.conf`](./build.conf)
 * Run the [workflow](../../actions/workflows/build.yml)
 * Grab your modules from [releases](../../releases)

**If you include microg patches in [build.conf](./build.conf), you get noroot APKs instead of Magisk modules. Twitter and Reddit will always be built as APKs regardless.**

## Updating
The modules support Magisk update which means you will receive updates from your Magisk app, downloading from github releases and reflashing is not necessary.  
To be able to update YouTube version, you will need to:
 * Disable the module
 * Reboot
 * Install the APK of the new YouTube
 * Update the module and reboot again

  
### **Note that the [CI workflow](../../actions/workflows/ci.yml) is scheduled to build the modules and APKs everyday if there is a change. You may want to disable it.**

# Building the Magisk Modules Locally
Make sure you have [Azul Zulu distribution of OpenJDK 17](https://www.azul.com/downloads/?version=java-17-lts&os=linux&architecture=x86-64-bit&package=jdk) and run:

```console
$ git clone --recurse-submodules https://github.com/j-hc/revanced-magisk-module
$ cd revanced-magisk-module
$ ./build.sh build
```
