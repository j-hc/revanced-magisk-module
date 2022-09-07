# ReVanced Magisk Module
[![Build Modules](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml/badge.svg)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/build.yml)
[![CI](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/j-hc/revanced-magisk-module/actions/workflows/ci.yml)

This repo includes a simple script that downloads all the latest version of necessary prebuilt revanced tools and build patched apps according to your config file (so do not create issues related to revanced in this repo).

You can get the [latest CI release from here](https://github.com/j-hc/revanced-magisk-module/releases).

The [**mindetach module**](https://github.com/j-hc/mindetach-magisk) in the releases section detaches YouTube and YouTube Music from Play Store and blocks it from updating them.

## To include/exclude patches or build non-root variant
[**See the list of patches**](https://github.com/revanced/revanced-patches#-list-of-available-patches)

 * Star the repo :eyes:
 * Use the repo as template or fork it (if you choose the repo to be private, you won't receive updates from Magisk app)
 * Edit the patcher args in [`build.conf`](./build.conf)
 * Run the [workflow](../../actions/workflows/build.yml)
 * Grab your modules from [releases](../../releases)

**If you include microg patches in [build.conf](./build.conf), you get non-root APKs instead of Magisk modules. Twitter and Reddit will always be built as APKs regardless. To be able to use non-root variant you will need to install [Vanced MicroG](https://www.apkmirror.com/apk/team-vanced/microg-youtube-vanced/microg-youtube-vanced-0-2-24-220220-release/).**

## Installation
 * Simply flash the module, you do not need to install YouTube or Music beforehand. Everything is handled by the module.
 * No need for a reboot after the installation. YouTube or Music will be mounted immediately.
 * x86 and x86_64 arches are not supported!

## Updating
The modules support Magisk update which means you will receive updates from your Magisk app, downloading from github releases and reflashing is not necessary.  
  
### **Note that the [CI workflow](../../actions/workflows/ci.yml) is scheduled to build the modules and APKs everyday if there is a change. You may want to disable it.**

# Building Locally
Make sure you have OpenJDK 17 and xdelta3 installed. Then run:

```console
$ git clone --recurse-submodules https://github.com/j-hc/revanced-magisk-module
$ cd revanced-magisk-module
$ ./build.sh build
```
