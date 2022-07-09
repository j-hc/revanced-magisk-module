# YouTube ReVanced Magisk Module

<sub>(unaffiliated whatsoever)<sub>

This repo includes a simple script that downloads all the latest version of necessary prebuilt revanced tools and the stock APKs of YouTube and YouTube Music from APKMirror, applies the patches and creates magisk modules

You will need to install the stock YouTube app matching with the module's version on your phone using an installer like [SAI](https://play.google.com/store/apps/details?id=com.aefyr.sai&hl=tr&gl=US) **with the split APKs**.  
You can go grab the split APKs from APKMirror (the bundle, not the apk or it will crash). The link is also provided in release notes.

You can get the [latest CI release](https://github.com/j-hc/revanced-magisk-module/releases) from here.

## Updating
Reflashing in Magisk sometimes breaks modules for some reason. In that case just remove the module, reboot and flash again.

### Note
I exclude some patches to my liking. If you want to change them:  
 * Fork the repo
 * Edit the patcher args in [`build.sh`](./build.sh)
 * Start the workflow to build

# Building the Magisk Module

```bash
$ ./build.sh all
```
