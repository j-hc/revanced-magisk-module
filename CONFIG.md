# Config

Adding another revanced app is as easy as this:
```toml
[Some-App]
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app"
# or uptodown-dlurl = "https://app.en.uptodown.com/android"
# or apkmonk-dlurl = "https://www.apkmonk.com/app/com.app.app/"
```

## More about other options:

There exists an example below with all defaults shown and all the keys explicitly set.  
**All keys are optional** (except download urls) and are assigned to their default values if not set explicitly.  

```toml
parallel-jobs = 1 # amount of cores to use for parallel patching, if not set nproc is used
patches-source = "inotia00/revanced-patches" # where to fetch patches bundle from. default: "inotia00/revanced-patches"
integrations-source = "inotia00/revanced-integrations" # where to fetch integrations from. default: "inotia00/revanced-integrations"
cli-source = "inotia00/revanced-cli" # where to fetch cli from. default: "inotia00/revanced-cli"
# options like cli-source can also set per app
rv-brand = "ReVanced Extended" # rebrand from 'ReVanced Extended' to something different. default: "ReVanced Extended"

patches-version = "v2.111.4" # locks the patches version. default: latest available
integrations-version = "v0.42.1" # locks the integrations version. default: latest available
cli-version = "v3.0.1" # locks the CLI version. default: latest available

[Some-App]
app-name = "SomeApp" # if set, release name becomes SomeApp instead of Some-App. default is same as table name, which is 'Some-App' here.
enabled = true # whether to build the app. default: true
version = "auto" # 'auto', 'latest', 'beta' or a custom one e.g. '17.45.36'. default: auto
# 'auto' option gets the latest possible version supported by all the included patches
# 'latest' gets the latest stable without checking patches support. 'beta' gets the latest beta/alpha
include-stock = true # includes stock apk in the module. default: true
build-mode = "apk" # 'both', 'apk' or 'module'. default: apk
excluded-patches = "'Some Patch' 'Some Other Patch'" # whitespace seperated list of patches to exclude. default: "" (empty)
included-patches = "'Patch something'" # whitespace seperated list of patches to include, all default patches are included by default. default: "" (empty)
exclusive-patches = false # exclude all patches by default. default: false
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app"
uptodown-dlurl = "https://spotify.en.uptodown.com/android"
apkmonk-dlurl = "https://www.apkmonk.com/app/com.app.app/"
module-prop-name = "some-app-magisk" # magisk module prop name.
merge-integrations = false # set false to never merge even when needed. default: true
apkmirror-dpi = "360-480dpi" # used to select apk variant from apkmirror. default: nodpi
apkmirror-arch = "arm64-v8a" # 'arm64-v8a', 'arm-v7a', 'all', 'both'. 'both' downloads both arm64-v8a and arm-v7a. default: all
```

# Building ReVanced
Use the [original project](https://github.com/j-hc/revanced-magisk-module) instead.
