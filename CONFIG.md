# Config

Adding another revanced app is as easy as this:
```toml
[Some-App]
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app"
# or uptodown-dlurl = "https://app.en.uptodown.com/android"
```

## More about other options:

There exists an example below with all defaults shown and all the keys explicitly set.  
**All keys are optional** (except download urls) and are assigned to their default values if not set explicitly.  

```toml
parallel-jobs = 1 # amount of cores to use for parallel patching, if not set nproc is used
compression-level = 9 # module zip compression level
remove-rv-integrations-checks = true # remove checks from the revanced integrations

patches-source = "revanced/revanced-patches" # where to fetch patches bundle from. default: "revanced/revanced-patches"
integrations-source = "revanced/revanced-integrations" # where to fetch integrations from. default: "revanced/revanced-integrations"
cli-source = "j-hc/revanced-cli" # where to fetch cli from. default: "j-hc/revanced-cli"
# options like cli-source can also set per app
rv-brand = "ReVanced Extended" # rebrand from 'ReVanced' to something different. default: "ReVanced"

patches-version = "v2.160.0" # 'latest', 'dev', or a version number. default: "latest"
# integrations-version and cli-version can be also configured

[Some-App]
app-name = "SomeApp" # if set, release name becomes SomeApp instead of Some-App. default is same as table name, which is 'Some-App' here.
enabled = true # whether to build the app. default: true
version = "auto" # 'auto', 'latest', 'beta' or a version number (e.g. '17.40.41'). default: auto
# 'auto' option gets the latest possible version supported by all the included patches
# 'latest' gets the latest stable without checking patches support. 'beta' gets the latest beta/alpha
include-stock = true # includes stock apk in the module. default: true
build-mode = "apk" # 'both', 'apk' or 'module'. default: apk
excluded-patches = "'Some Patch' 'Some Other Patch'" # whitespace seperated list of patches to exclude. default: "" (empty)
included-patches = "'Patch something'" # whitespace seperated list of patches to include, all default patches are included by default. default: "" (empty)
exclusive-patches = false # exclude all patches by default. default: false
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app"
uptodown-dlurl = "https://spotify.en.uptodown.com/android"
module-prop-name = "some-app-magisk" # magisk module prop name.
apkmirror-dpi = "360-480dpi" # used to select apk variant from apkmirror. default: nodpi
arch = "arm64-v8a" # 'arm64-v8a', 'arm-v7a', 'all', 'both'. 'both' downloads both arm64-v8a and arm-v7a. default: all
riplib = true # enables ripping x86 and x86_64 libs from apks with j-hc revanced cli. default: true
```
