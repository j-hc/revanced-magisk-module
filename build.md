YouTube: 18.23.35  
YouTube-Extended: 18.29.38  
Music (arm-v7a): 6.13.52  
Music (arm64-v8a): 6.13.52  
Music-Extended (arm-v7a): 6.13.52  
Music-Extended (arm64-v8a): 6.13.52  
Twitch: 15.4.1  
Twitter: 10.1.0-release.0  
TikTok: 30.6.4  
Reddit: 2023.30.0  
Messenger: 420.0.0.15.50  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: j-hc/revanced-cli-2.23.0-all.jar  
Integrations: ReVanced/revanced-integrations-0.115.0.apk  
Patches: ReVanced/revanced-patches-2.187.0.jar  

### [2.187.0](https://github.com/ReVanced/revanced-patches/compare/v2.186.0...v2.187.0) (2023-08-02)
### Bug Fixes
* Remove version numbers from individual patches ([#2709](https://github.com/ReVanced/revanced-patches/issues/2709)) ([7a828ea](https://github.com/ReVanced/revanced-patches/commit/7a828ea8826864505fac9b2bdb3a1261d9f4dc35))
* **Sync for Reddit - Change OAuth client id:** Disable piracy detection ([cd103dd](https://github.com/ReVanced/revanced-patches/commit/cd103dd9b8ff2667246d4abaf75577f28bf1a11b))
* Use clearer descriptions ([8dbb0e2](https://github.com/ReVanced/revanced-patches/commit/8dbb0e212e8ceeb0381a3509e45afca095ddee53))
* **YouTube - Spoof app version:** Fix grammar in description ([#2711](https://github.com/ReVanced/revanced-patches/issues/2711)) ([dd249e6](https://github.com/ReVanced/revanced-patches/commit/dd249e62243e57733a6ff4d3a17d30db0e08a84d))
* **YouTube - Spoof App Version:** Remove 17.30.35 target (version no longer works correctly) ([#2703](https://github.com/ReVanced/revanced-patches/issues/2703)) ([210108b](https://github.com/ReVanced/revanced-patches/commit/210108bd8f86f583f5cd5d5538480b76d51d7776))
* **YouTube - Theme:** only set splash screen color if background colors are set ([f058db4](https://github.com/ReVanced/revanced-patches/commit/f058db4ba4300400ac92b4a9790708eb8bde7092))
### Features
* **Joey for Reddit:** Add `Change OAuth client id` patch ([1bac47d](https://github.com/ReVanced/revanced-patches/commit/1bac47df889b5221bef1c03e652f894be8d39385))
* **Joey for Reddit:** Add `Disable ads` patch ([ad7e147](https://github.com/ReVanced/revanced-patches/commit/ad7e14771208dcab08fd6dc29403b1a4cf602111))
* **Reddit is Fun - Spoof client:** Spoof the user agent ([b9aaf61](https://github.com/ReVanced/revanced-patches/commit/b9aaf610ad9f1f45a72265a3782d2cf996020139))
* **Sync for Reddit:** add `Disable Sync for Lemmy bottom sheet` patch ([56b535b](https://github.com/ReVanced/revanced-patches/commit/56b535b2a136d4b0afbddf2c8e251889c2555056))
* **YouTube - Hide layout components:** Hide `chips shelf` ([#2699](https://github.com/ReVanced/revanced-patches/issues/2699)) ([8e6058b](https://github.com/ReVanced/revanced-patches/commit/8e6058b62350b3d14d79e6fe52b0ad781b66b5de))
* **YouTube:** add `Player Flyout Menu` patch ([#2295](https://github.com/ReVanced/revanced-patches/issues/2295)) ([aea0af0](https://github.com/ReVanced/revanced-patches/commit/aea0af059784ae4820a0e73ff91f97bbc3ebc4c7))

---
CLI: inotia00/revanced-cli-2.22.2-all.jar  
Integrations: inotia00/revanced-integrations-0.114.12.apk  
Patches: inotia00/revanced-patches-2.186.12.jar  

YouTube
==
- feat(youtube): add `hide-latest-videos-button` patch [ScreenShot](https://imgur.com/a/VT7Rd2L)
- feat(youtube/enable-old-quality-layout): match with the official Revanced
- feat(youtube/enable-new-thumbnail-preview): forcibly disable when the switch is off
- feat(youtube/hide-comment-component): `hide preview comment` hides the dots of live comments [ScreenShot](https://imgur.com/a/THMek2L)
- feat(youtube/hide-general-ads): update filter
- feat(youtube/settings): remove github link in the settings https://github.com/inotia00/ReVanced_Extended/issues/1278
- feat(youtube/spoof-app-version): add 18.09.39 to version list [to revert new library tab ui](https://github.com/inotia00/ReVanced_Extended/issues/630)
- fix(youtube): some dependence is missing https://github.com/inotia00/ReVanced_Extended/issues/1291
- fix(youtube/enable-new-splash-animation): remove android version restriction
- refactor(youtube/litho): filter litho components using prefix tree
- feat(youtube/translations): update translation
`Arabic`, `Bengali`, `Brazilian`, `Chinese Simplified`, `Chinese Traditional`, `French`, `German`, `Greek`, `Hungarian`, `Indonesian`, `Italian`, `Japanese`, `Korean`, `Polish`, `Romanian`, `Russian`, `Spanish`, `Turkish`, `Ukrainian`, `Vietnamese`
feat(youtube/language-switch): add a new type of string


YouTube Music
==
- refactor(music/litho): filter litho components using prefix tree
- feat(music/translations): update translation
`Czech`, `Indonesian`, `Polish`, `Russian`, `Ukrainian`


Etc
==
- final release will be rolled out next week


※ Compatible ReVanced Manager: [RVX Manager v1.5.1 (fork)](https://github.com/inotia00/revanced-manager/releases/tag/v1.5.1)

[Crowdin translation]
- [YouTube/European Countries](https://crowdin.com/project/revancedextendedeu)
- [YouTube/Other Countries](https://crowdin.com/project/revancedextended)
- [YT Music](https://crowdin.com/project/revanced-music-extended)

---  
