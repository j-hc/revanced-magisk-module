YouTube: 18.23.35  
YouTube-Extended: 18.30.37  
Music (arm64-v8a): 6.14.50  
Music (arm-v7a): 6.14.50  
Music-Extended (arm64-v8a): 6.14.50  
Music-Extended (arm-v7a): 6.14.50  
Twitter: 10.2.0-release.0  
Twitch: 15.4.1  
TikTok: 30.8.1  
Reddit: 2023.31.0  
Messenger: 421.0.0.12.61  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: j-hc/revanced-cli-2.23.0-all.jar  
Integrations: ReVanced/revanced-integrations-0.115.1.apk  
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
Integrations: inotia00/revanced-integrations-0.115.1.apk  
Patches: inotia00/revanced-patches-2.187.1.jar  

YouTube
==
- feat(youtube): add support version `v18.30.37`
- feat(youtube/hide-button-container): now it support versions other than YouTube v18.20.39 https://github.com/ReVanced/revanced-patches/pull/2723
- fix(youtube/integration): move dependence to dummy class path
- fix(youtube/microg-support): app does not close when an error occurs
- fix(youtube/microg-support): error toast message is not set correctly
- feat(youtube/translations): update translation
`Belarusian`, `Bulgarian`, `Chinese Traditional`, `French`, `German`, `Greek`, `Hungarian`, `Indonesian`, `Italian`, `Japanese`, `Polish`, `Russian`, `Vietnamese`


Music
==
- feat(music): add `hide-channel-guidelines` patch
- feat(music/litho): add some exception
- feat(music/enable-new-layout): change default value
- feat(music/enable-new-layout): forcibly disable when the switch is off
- feat(music/enable-sleep-timer): forcibly disable when the switch is off
- feat(music/translations): update translation
`Brazilian`, `Chinese Traditional`, `French`, `Indonesian`, `Korean`, `Russian`, `Spanish`, `Ukrainian`, `Vietnamese`


Etc
==
- At the end of this release, RVX has been [discontinued](https://github.com/inotia00/revanced-documentation/wiki/Announcement). Thank you for using it so far.


※ Compatible ReVanced Manager: [RVX Manager v1.5.2 (fork)](https://github.com/inotia00/revanced-manager/releases/tag/v1.5.2)

---  
