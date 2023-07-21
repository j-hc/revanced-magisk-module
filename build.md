YouTube: 18.23.35  
YouTube-Extended: 18.25.40  
Music (arm64-v8a): 6.11.52  
Music-Extended (arm64-v8a): 6.11.52  
Twitch: 15.4.1  
Twitter: 9.98.0-release.0  
TikTok: 30.5.3  
Reddit: 2023.28.0  
Messenger: 418.0.0.11.71  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: j-hc/revanced-cli-2.23.0-all.jar  
Integrations: ReVanced/revanced-integrations-0.114.0.apk  
Patches: ReVanced/revanced-patches-2.186.0.jar  

### [2.186.0](https://github.com/ReVanced/revanced-patches/compare/v2.185.0...v2.186.0) (2023-07-21)


### Bug Fixes

* **Tiktok - Settings:** get instruction registers dynamically ([#2676](https://github.com/ReVanced/revanced-patches/issues/2676)) ([b34e45b](https://github.com/ReVanced/revanced-patches/commit/b34e45b6dafad8e9d567ad65f58a182b8cc04676))
* **YouTube - Spoof app version:** update target app version description ([#2666](https://github.com/ReVanced/revanced-patches/issues/2666)) ([307442e](https://github.com/ReVanced/revanced-patches/commit/307442e654ff5486656319d91e4a5f5fb2b92651))
* **YouTube - Theme:** allow setting no background color ([8a4e77a](https://github.com/ReVanced/revanced-patches/commit/8a4e77a290a61a1caf93eb8bccaf728c84a3ef53))
* **YouTube - Theme:** apply custom seekbar color to shorts ([#2670](https://github.com/ReVanced/revanced-patches/issues/2670)) ([1f6fe3d](https://github.com/ReVanced/revanced-patches/commit/1f6fe3da4284fd768057ef068c7ddf88d3a11049))


### Features

* **Twitter:** remove `Hide view stats` patch ([f0d3800](https://github.com/ReVanced/revanced-patches/commit/f0d38001b34db63f212209afb91eebf59dad2b24))
* **Youtube - Theme:** add a switch to enable/disable custom seekbar color ([#2663](https://github.com/ReVanced/revanced-patches/issues/2663)) ([5c39985](https://github.com/ReVanced/revanced-patches/commit/5c39985888cdfe3acfdd8811ff9b6f80e243704e))




---
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
