# Config

Adding a new app is as easy as this:
```toml
[Some-App]
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app" # download url for the app. if not set, uptodown is used.
```

## If you'd like to get to know more about other options:

There exists an example below with all defaults and all the keys explicitly set.  
Almost all keys are optional and are assigned their default values if not set explicitly.  

```toml
[Some-App]
app-name = "SomeApp"                                      # if set, app name becomes SomeApp instead of Some-App. default is same as table name.
enabled = true                                            # whether to build the app. default: true
build-mode = "both"                                       # 'both', 'apk' or 'module'. default: apk
excluded-patches = "some-patch"                           # whitespace seperated list of patches to exclude. default: "" (empty)
included-patches = "patch-name"                           # whitespace seperated list of patches to include. default: "" (empty)
version = "auto"                                          # 'auto', 'latest' or a custom one e.g. '17.40.41'. default: auto
exclusive-patches = false                                 # exclude all patches by default. default: false
microg-patch = "microg-support"                           # name of the microg-patch if exists for the app. default: "" (empty)
apkmirror-dlurl = "https://www.apkmirror.com/apk/inc/app" # download url for the app. if not set, uptodown is used.
module-prop-name = "ytrv-magisk"                          # explicit magisk module prop name. not explicitly needed to be set.
merge-integrations = true                                 # whether to merge revanced integrations. default: false
arch = "arm64-v8a"                                        # 'arm64-v8a', 'arm-v7a' or 'all'. 
                                                          # this option is sometimes needed to be able to download the apks from apkmirror. default: all
apkmirror-regex = 'APK</span>[^@]*@\([^#]*\)'             # regex used to get the dl url in apkmirror. default: APK</span>[^@]*@\([^#]*\)
														  # this default gets the url to the non-bundle apk.
```