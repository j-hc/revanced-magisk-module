YouTube: 18.19.35  
YouTube-Extended: 18.17.43  
Music (arm64-v8a): 5.39.52  
Music (arm-v7a): 5.39.52  
Music-Extended (arm64-v8a): 6.03.51  
Music-Extended (arm-v7a): 6.03.51  
Twitter: 9.90.0-release.0  
Twitch: 14.6.1  
TikTok: 29.7.4  
Reddit: 2023.21.0  
Messenger: 410.0.0.17.85  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) to be able to use non-root YouTube or Music  

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
Integrations: revanced/revanced-integrations-0.109.0.apk  
Patches: revanced/revanced-patches-2.175.0.jar  

### [2.175.0](https://github.com/revanced/revanced-patches/compare/v2.174.0...v2.175.0) (2023-05-31)
### Bug Fixes
* **settings:** sort setting preferences using lowercase ([#2312](https://github.com/revanced/revanced-patches/issues/2312)) ([2743a95](https://github.com/revanced/revanced-patches/commit/2743a95b417a6023799035e30631e7b3a68bcc45))
* **spoof-wifi-connection:** use updated instruction indices ([#2199](https://github.com/revanced/revanced-patches/issues/2199)) ([76fb700](https://github.com/revanced/revanced-patches/commit/76fb700884dae5b71a57f9530fad9d4a98ba0af0))
* **youtube/downloads:** rename patch to `external-downloads` ([#2274](https://github.com/revanced/revanced-patches/issues/2274)) ([4480911](https://github.com/revanced/revanced-patches/commit/4480911e0b056f2148616a0c2af6b4ab7c482c3b))
* **youtube/hide-info-cards:** fix hide-info-cards setting does not work ([#2246](https://github.com/revanced/revanced-patches/issues/2246)) ([72773ac](https://github.com/revanced/revanced-patches/commit/72773ac56987753fac6c0087d048b4378a3dd360))
* **youtube/hide-player-buttons:** fix previous/next button showing if previous video exists ([#2261](https://github.com/revanced/revanced-patches/issues/2261)) ([91d1aab](https://github.com/revanced/revanced-patches/commit/91d1aabd32be1607019bc443fb06284ca3343e9d))
* **youtube/hide-shorts-components:** clarify settings switch ([#2276](https://github.com/revanced/revanced-patches/issues/2276)) ([3e6d052](https://github.com/revanced/revanced-patches/commit/3e6d0528b287ded401dacdcea698d4ec97b926ee))
* **youtube/integrations:** fix playback of embedded videos ([#2304](https://github.com/revanced/revanced-patches/issues/2304)) ([1dffbaf](https://github.com/revanced/revanced-patches/commit/1dffbaf0aa73f0f703516648d5cd935000fa2770))
* **youtube/remember-video-quality:** fix typo in video resolutions ([#2323](https://github.com/revanced/revanced-patches/issues/2323)) ([a99cef8](https://github.com/revanced/revanced-patches/commit/a99cef87b40b67a5feb97999fb4f2925ea80b42e))
* **youtube/remove-player-controls-background:** use correct patch name and description ([8732a84](https://github.com/revanced/revanced-patches/commit/8732a84422087fca7e9e1635a0b1d8d2cbf034f4))
* **youtube/theme:** use dynamic background color for custom splash screen ([#2319](https://github.com/revanced/revanced-patches/issues/2319)) ([28594f3](https://github.com/revanced/revanced-patches/commit/28594f3eeaf99fa32ee57214ebbc4342529c6694))
### Features
* **nfctoolsse:** add `unlock-pro` patch ([#2272](https://github.com/revanced/revanced-patches/issues/2272)) ([9789ad3](https://github.com/revanced/revanced-patches/commit/9789ad30ff82d9bb99e870dc8053775dc222a010))
* **remove-screen-capture-restriction:** remove app constraint ([#2260](https://github.com/revanced/revanced-patches/issues/2260)) ([49ce47c](https://github.com/revanced/revanced-patches/commit/49ce47c3eed6a1626674d0f60ae0fdbe349e804b))
* **scbeasy:** add `remove-debugging-detection` patch ([#2287](https://github.com/revanced/revanced-patches/issues/2287)) ([53d91e3](https://github.com/revanced/revanced-patches/commit/53d91e32183663b0aa70994cc4e1d8ae5eb8c8e4))
* **tiktok:** remove compatibility version constraints ([#2306](https://github.com/revanced/revanced-patches/issues/2306)) ([a12c4bb](https://github.com/revanced/revanced-patches/commit/a12c4bb1610234d19b4ac86cd57bb09335566b68))
* **youtube/general-ads:** merge `hide-get-premium` patch into `general-ads` patch ([5195dd8](https://github.com/revanced/revanced-patches/commit/5195dd8936d63c482dbcb2cd0e7e9aab3c75954e))
* **youtube/hide-seekbar:** more fine grained hiding of seekbar ([#2252](https://github.com/revanced/revanced-patches/issues/2252)) ([0f07bf4](https://github.com/revanced/revanced-patches/commit/0f07bf467a4aa06c9bcdf60a2498d88eea8c1429))
* **youtube/hide-shorts-components:** hide channel bar & sound button ([749c83d](https://github.com/revanced/revanced-patches/commit/749c83d068c2201ed6f29047d5428d1072924960))
* **youtube/hide-shorts-components:** hide shorts info panel ([#2278](https://github.com/revanced/revanced-patches/issues/2278)) ([a5b323d](https://github.com/revanced/revanced-patches/commit/a5b323d1d9e5b175c93f0b29732eb1123b83bab7))
* **youtube/navigation-buttons:** use a better preference screen title ([5d7772b](https://github.com/revanced/revanced-patches/commit/5d7772be942c72e05644eca3f68d2bd6b9762d26))

---  
