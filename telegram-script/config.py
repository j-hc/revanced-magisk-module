class Config:
    REVANCED_APKS_RELEASE_URL = (
        "https://api.github.com/repos/revanced-apks/build-apps/releases/latest"
    )
    MICROG_RELEASE_URL = (
        "https://api.github.com/repos/ReVanced/GmsCore/releases/latest"
    )
    REVANCED_CHANGES_URL = (
        "https://api.github.com/repos/revanced/revanced-patches/compare"
    )
    REVANCED_EXTENDED_CHANGES_URL = (
        "https://api.github.com/repos/inotia00/revanced-patches/compare"
    )
    
    CREDITS_MESSAGE = "Credits to our upstream repository [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"

    RELEASE_MESSAGE = """📑 *RELEASE* {release_name}

[Release notes and changelogs (What's New)]({changelogs_url})

📦 *Downloads* 

{nonroot_files}

{credits_message}
    
@revanced_apks_web | revanced-apks.pages.dev"""
