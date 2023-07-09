class Config:
    REVANCED_APKS_RELEASE_URL = (
        "https://api.github.com/repos/revanced-apks/build-apps/releases/latest"
    )
    MICROG_RELEASE_URL = (
        "https://api.github.com/repos/TeamVanced/VancedMicroG/releases/latest"
    )
    REVANCED_CHANGES_URL = (
        "https://api.github.com/repos/revanced/revanced-patches/compare"
    )
    REVANCED_EXTENDED_CHANGES_URL = (
        "https://api.github.com/repos/inotia00/revanced-patches/compare"
    )

    NOTES = """*≣ Note:*
 ➜ `mindetach.zip` is used to detach play store updates for YT and YT Music for rooted users.
 ➜ `microg.apk` is used for google services and must be installed for non root YT and YT Music."""
    CREDITS_MESSAGE = "Credits to our upstream repository [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"

    RELEASE_MESSAGE = """📑 *RELEASE* {release_name}

{revanced_version_message}

*What's new:*
{changelogs}

{notes}

📦 *Downloads* 

Non-Root:
{nonroot_files}

Magisk (Root):
{root_files}

{credits_message}
    
@revanced_apks_web | revanced-apks.pages.dev"""
