YouTube: 18.23.35  
YouTube-Extended: 18.25.40  
Music (arm64-v8a): 6.11.52  
Music-Extended (arm64-v8a): 6.11.52  
Twitch: 15.4.1  
Twitter: 9.98.0-release.0  
TikTok: 30.5.2  
Reddit: 2023.28.0  
Messenger: 418.0.0.11.71  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: j-hc/revanced-cli-2.23.0-all.jar  
Integrations: inotia00/revanced-integrations-0.112.3.apk  
Patches: inotia00/revanced-patches-2.184.3.jar  

YouTube
==
- feat(youtube): remove `hide-live-chat-button` patch (location of the live chat button has been moved even in the old layout)
- feat(youtube/hide-button-container): changed to expose `Experimental Flags` on YouTube v18.20.39 https://github.com/inotia00/ReVanced_Extended/issues/1103
- feat(youtube/spoof-player-parameter): changed to selectable option for MicroG (ROOT) users https://github.com/inotia00/ReVanced_Extended/issues/1110
- fix(youtube/hide-filmstrip-overlay): patch is broken on YouTube v18.20.39
- fix(youtube/hide-feed-flyout-panel): unintended menus are hidden https://github.com/inotia00/ReVanced_Extended/issues/1129
- fix(youtube): move the patch to the correct path
- fix(youtube/hide-account-menu): app crashes in landscape mode https://github.com/inotia00/ReVanced_Extended/issues/549
- fix(youtube/spoof-player-parameter): show video time and chapters while using seekbar
- refactor(youtube): renamed some patches and description
- feat(youtube/translations): update translation
`Arabic`, `Chinese Traditional`, `French`, `Greek`, `Indonesian`, `Italian`, `Japanese`, `Korean`, `Polish`, `Russian`, `Spanish`, `Turkish`, `Vietnamese`


Music
==
- refactor(music): renamed some patches and description
- feat(music/translations): update translation
`Indonesian`, `Vietnamese`


Etc
==
- chore: use new patch naming convention
- refactor: change patches naming convention
- refactor: remove unnecessary annotations

※ Compatible ReVanced Manager: [RVX Manager v1.4.0 (fork)](https://github.com/inotia00/revanced-manager/releases/tag/v1.4.0)
[Crowdin translation]
- [European Countries](https://crowdin.com/project/revancedextendedeu)
- [Other Countries](https://crowdin.com/project/revancedextended)
---
CLI: j-hc/revanced-cli-2.23.0-all.jar  
Integrations: ReVanced/revanced-integrations-0.113.0.apk  
Patches: ReVanced/revanced-patches-2.185.0.jar  

### [2.185.0](https://github.com/ReVanced/revanced-patches/compare/v2.184.0...v2.185.0) (2023-07-20)


### Bug Fixes

* allocate for more than eight `LithoFilter` array items ([#2643](https://github.com/ReVanced/revanced-patches/issues/2643)) ([fc8660b](https://github.com/ReVanced/revanced-patches/commit/fc8660b740bec2747e5f82b7321027bb8a51e0cf))
* **Sync for Reddit - Disable ads:** fix compatibility with latest version ([1456577](https://github.com/ReVanced/revanced-patches/commit/1456577f11c4a7e49d6c1ba0103b919dc487f4cf))
* **Tiktok - Settings:** bump compatibility ([#2656](https://github.com/ReVanced/revanced-patches/issues/2656)) ([6641356](https://github.com/ReVanced/revanced-patches/commit/6641356d41813a20c77faac67c37ea517690d25b))
* **TikTok - Show seekbar:** fix seekbar not always showing ([#2660](https://github.com/ReVanced/revanced-patches/issues/2660)) ([f2742f1](https://github.com/ReVanced/revanced-patches/commit/f2742f1ba117809971a10780823fca99c19a4f34))
* **Trakt - Unlock pro:** constraint to last known working version ([#2662](https://github.com/ReVanced/revanced-patches/issues/2662)) ([324bbde](https://github.com/ReVanced/revanced-patches/commit/324bbde92a851e855c11f266e92fa14c39d88160))
* **YouTube - Spoof client:** show video time and chapters while using seekbar ([#2607](https://github.com/ReVanced/revanced-patches/issues/2607)) ([9546d12](https://github.com/ReVanced/revanced-patches/commit/9546d126430870d1abd8f43bb687b31b9fcb6fb5))
* **YouTube - SponsorBlock:** fix some segments skipping slightly too late ([#2634](https://github.com/ReVanced/revanced-patches/issues/2634)) ([3175431](https://github.com/ReVanced/revanced-patches/commit/31754311870324b1e245b12965d7486878e9eba4))


### Features

* **youtube:** rename `video-speed` to `playback-speed` ([#2642](https://github.com/ReVanced/revanced-patches/issues/2642)) ([77e8639](https://github.com/ReVanced/revanced-patches/commit/77e8639b71048f2795f8f32fe18d052b335e3ce4))




---  
