# Config

Three APK download websites are supported and adding a new app is as easy as this:
```toml
[Some-App]
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app"
```
or:
```toml
[Some-App]
uptodown-dlurl = "https://app.en.uptodown.com/android"
```
or:
```toml
[Some-App]
apkmonk-dlurl = "https://www.apkmonk.com/app/com.app.app/"
```

## If you'd like to get to know more about other options:

There exists an example below with all defaults shown and all the keys explicitly set.  
**All keys are optional** (except download urls) and are assigned to their default values if not set explicitly.  

```toml
patches-source = "revanced/revanced-patches" # where to fetch patches bundle from. default: "revanced/revanced-patches"
integrations-source = "revanced/revanced-integrations" # where to fetch integrations from. default: "revanced/revanced-integrations"
rv-brand = "ReVanced Extended" # rebrand from 'ReVanced' to something different. default: "ReVanced"

patches-version = "v2.160.0" # locks the patches version. default: latest available
integrations-version = "v0.95.0" # locks the integrations version. default: latest available

[Some-App]
app-name = "SomeApp" # if set, release name becomes SomeApp instead of Some-App. default is same as table name, which is 'Some-App' here.
enabled = true # whether to build the app. default: true
version = "auto" # 'auto', 'latest', 'beta' or a custom one e.g. '17.40.41'. default: auto
# 'auto' option gets the latest possible version supported by all the included patches
# 'latest' gets the latest stable without checking patches support. 'beta' gets the latest beta/alpha
include-stock = true # includes stock apk in the module
build-mode = "both" # 'both', 'apk' or 'module'. default: apk
excluded-patches = "some-patch some-other-path" # whitespace seperated list of patches to exclude. default: "" (empty)
included-patches = "patch-name" # whitespace seperated list of patches to include, all default patches are included by default. default: "" (empty)
exclusive-patches = false # exclude all patches by default. default: false
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app" # download url. if not set, uptodown dl url is used.
uptodown-dlurl = "https://spotify.en.uptodown.com/android" # uptodown url. if not set, apkmirror dl url is used. apkmirror is prioritized
apkmonk-dlurl = "https://www.apkmonk.com/app/com.app.app/" # apkmonk url.
module-prop-name = "some-app-magisk" # magisk module prop name. not required.
merge-integrations = false # set false to never merge even when needed default: true
dpi = "360-480dpi" # used to select apk variant from apkmirror. default: nodpi
arch = "arm64-v8a" # 'arm64-v8a', 'arm-v7a' or 'all'. default: all
# arch option is sometimes needed to be able to download the apks from apkmirror.
# and does not affect anything else
```
