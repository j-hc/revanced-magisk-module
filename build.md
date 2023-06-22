YouTube: 18.19.35  
YouTube-Extended: 18.17.43  
Music (arm64-v8a): 6.07.50  
Music (arm-v7a): 6.07.50  
Music-Extended (arm-v7a): 6.07.50  
Music-Extended (arm64-v8a): 6.07.50  
Twitter: 9.94.0-release.0  
Twitch: 15.4.1  
TikTok: 30.1.2  
Reddit: 2023.24.0  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: j-hc/revanced-cli-2.22.0-all.jar  
Integrations: inotia00/revanced-integrations-0.107.10.apk  
Patches: inotia00/revanced-patches-2.173.10.jar  

YouTube
==
- feat(youtube/default-video-quality): rollback to previous commit
- feat(youtube/hide-general-ads): added some exceptions
- feat(youtube/hide-seekbar): updated patch description https://github.com/inotia00/ReVanced_Extended/issues/1013
- fix(youtube/protobuf-spoof): playing a clip will play the video from the start https://github.com/inotia00/ReVanced_Extended/issues/999
- fix(youtube/protobuf-spoof): subtitles appear at top when you watch related shorts https://github.com/inotia00/ReVanced_Extended/issues/1011
- fix(youtube/sponsorblock): not reflected in the patch information
- feat(youtube/translations): update translation
`Chinese Simplified`, `Greek`, `Indonesian`, `Italian`, `Japanese`, `Russian`, `Spanish`, `Vietnamese`


YouTube Music
==
- feat(music/hide-new-playlist-button): change patch name https://github.com/inotia00/ReVanced_Extended/issues/983
- feat(music/translations): update translation
`Chinese Simplified`


※ Compatible ReVanced Manager: v1.1.0
[Crowdin translation]
- [European Countries](https://crowdin.com/project/revancedextendedeu)
- [Other Countries](https://crowdin.com/project/revancedextended)
---
CLI: j-hc/revanced-cli-2.22.0-all.jar  
Integrations: revanced/revanced-integrations-0.111.0.apk  
Patches: revanced/revanced-patches-2.178.0.jar  

### [2.178.0](https://github.com/revanced/revanced-patches/compare/v2.177.0...v2.178.0) (2023-06-21)
### Bug Fixes
* **boostforreddit:** use correct options ([ec39732](https://github.com/revanced/revanced-patches/commit/ec39732a05f7c4c3360b8ba42fe50fd60952e6ac))
* don't include all Litho patches, when not included ([fc69491](https://github.com/revanced/revanced-patches/commit/fc69491dfe4b119d46dd3da27b556e55fe0cecfb))
* **googlerecorder/remove-device-restrictions:** add missing app constraint ([#2438](https://github.com/revanced/revanced-patches/issues/2438)) ([d5efe26](https://github.com/revanced/revanced-patches/commit/d5efe26f8959cde75dd3865ec3c2df4b05210e4a))
* **youtube/comments:** add missing filter ([#2423](https://github.com/revanced/revanced-patches/issues/2423)) ([cab04b3](https://github.com/revanced/revanced-patches/commit/cab04b3a56cfc5bf00b7c6fcf6f86ab75aa5d4fd))
* **youtube/hide-album-cards:** call correct integrations method ([0dbffaa](https://github.com/revanced/revanced-patches/commit/0dbffaae7d6dcb7050a9ea6e3c771839bcfdfbe1))
* **youtube:** separate `hide-ads` to `hide-layout-components` patch ([7e0417f](https://github.com/revanced/revanced-patches/commit/7e0417f6728fa7b79a9d8cbcfd3ccba484a5567d))
### Features
* **boostforreddit:** add `change-oauth-client-id` patch ([3dbc4bd](https://github.com/revanced/revanced-patches/commit/3dbc4bd49df1656893ef69c68550a2deb6a92cb7))
* **google-recorder:** add `remove-device-restrictions` patch ([ef96ed1](https://github.com/revanced/revanced-patches/commit/ef96ed124e12091dde34124eabd8be9f2bb9280c))
* **twitch:** 15.4.1 support ([#2462](https://github.com/revanced/revanced-patches/issues/2462)) ([826ed49](https://github.com/revanced/revanced-patches/commit/826ed49c7ca5a00e383b743f88f75dbfc00adb43))
* **youtube-music:** remove version compatibility constraints ([276af14](https://github.com/revanced/revanced-patches/commit/276af1415a4d354c62fe6259b6559bca1fa84f08))
* **youtube/hide-layout-components:** separate hiding expandable chips and chapters ([3fb1ce9](https://github.com/revanced/revanced-patches/commit/3fb1ce9f9af150b784e42aaf5b419bb123c08375))

---  
