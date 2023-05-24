YouTube: 18.19.35  
YouTube-Extended: 18.17.43  
Music (arm64-v8a): 5.39.52  
Music (arm-v7a): 5.39.52  
Music-Extended (arm64-v8a): 6.03.51  
Twitter: 9.90.0-release.0  
Music-Extended (arm-v7a): 6.03.51  
Twitch: 14.6.1  
TikTok: 27.8.3  

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
Integrations: revanced/revanced-integrations-0.108.0.apk  
Patches: revanced/revanced-patches-2.174.0.jar  

### [2.174.0](https://github.com/revanced/revanced-patches/compare/v2.173.0...v2.174.0) (2023-05-24)
### Bug Fixes
* account fo breaking changes from ReVanced Patcher ([#2103](https://github.com/revanced/revanced-patches/issues/2103)) ([5be25cd](https://github.com/revanced/revanced-patches/commit/5be25cde4b34d58ced35a7edbb499477b538b748))
* check for opcode type `CONST` ([e5bb63c](https://github.com/revanced/revanced-patches/commit/e5bb63c7ab4427b6116de4a999be306e0f3cf12e))
* incorrect cast of instruction ([fb94a1c](https://github.com/revanced/revanced-patches/commit/fb94a1cb48e8952981e2f9146eb90ee92a517b2e))
* incorrect instruction offsets ([42a5a38](https://github.com/revanced/revanced-patches/commit/42a5a387da3c53c579234a44c124ab0ba26117cb))
* incorrect smali syntax ([4e74a80](https://github.com/revanced/revanced-patches/commit/4e74a800c311d7acb2c2ddb492b43747db8a8def))
* **photomath/unlock-plus:** constrain to last working version ([#2232](https://github.com/revanced/revanced-patches/issues/2232)) ([4da268e](https://github.com/revanced/revanced-patches/commit/4da268edc006ea496e3b1efd037676f1c40397da))
* **readme-generator:** attempt sorting versions with `FlexVer` ([#2059](https://github.com/revanced/revanced-patches/issues/2059)) ([a54c464](https://github.com/revanced/revanced-patches/commit/a54c464522fa2a6a2d2525c8cb0ec961c2cc771c))
* **spotify/disable-capture-restriction:** make compatible with latest versions ([#2095](https://github.com/revanced/revanced-patches/issues/2095)) ([e48f127](https://github.com/revanced/revanced-patches/commit/e48f1278da2a9d82e70be41fa2c4c480c574816b))
* **twitter:** correctly resolve to integrations methods ([c655416](https://github.com/revanced/revanced-patches/commit/c655416a91f0a32cfe82b1384f5958cace891833))
* **youtube/custom-video-speed:** add missing class for `video-speeds` patch ([#2137](https://github.com/revanced/revanced-patches/issues/2137)) ([758ef42](https://github.com/revanced/revanced-patches/commit/758ef42f9cd36d665b1737b67bcdde22d3e3eb98))
* **youtube/integrations:** allow playback of embedded videos  ([#2092](https://github.com/revanced/revanced-patches/issues/2092)) ([8a43d75](https://github.com/revanced/revanced-patches/commit/8a43d75e2db63c47bb9ad1b75027df0868c094e5))
* **youtube/minimized-playback:** update settings description ([#2191](https://github.com/revanced/revanced-patches/issues/2191)) ([a561a9a](https://github.com/revanced/revanced-patches/commit/a561a9afc233e466459546fcc8452800ec56e057))
* **youtube/remember-video-quality:** fix default video quality/speed being applied when resuming app. ([#2112](https://github.com/revanced/revanced-patches/issues/2112)) ([f68a41c](https://github.com/revanced/revanced-patches/commit/f68a41ce9f9a78818d3f28b069e70b8c66125f53))
* **youtube/return-youtube-dislikes:** fix temporarily frozen video after opening a shorts ([#2126](https://github.com/revanced/revanced-patches/issues/2126)) ([e0877e3](https://github.com/revanced/revanced-patches/commit/e0877e33814ba396e64e18a577064aa5be952413))
* **youtube/settings:** fix non functional back button in settings ([#2178](https://github.com/revanced/revanced-patches/issues/2178)) ([46da834](https://github.com/revanced/revanced-patches/commit/46da83430f69b451f971bf5e9261e9d64d1a365c))
* **youtube/sponsorblock:** fix skip button in wrong location when full screen and comments visible ([#2051](https://github.com/revanced/revanced-patches/issues/2051)) ([30a954c](https://github.com/revanced/revanced-patches/commit/30a954cac83a66fbb25589edc487797ea5f19986))
* **youtube/sponsorblock:** fix toast shown when scrubbing thru a paused video ([#2152](https://github.com/revanced/revanced-patches/issues/2152)) ([c6c23ff](https://github.com/revanced/revanced-patches/commit/c6c23ff0d9a18e3ef3d4b9b28ffa562a2eceb58b))
* **youtube/spoof-signature-verification:** adjusting summary text ([#2169](https://github.com/revanced/revanced-patches/issues/2169)) ([4ccb1ee](https://github.com/revanced/revanced-patches/commit/4ccb1ee0b988bc0ddd6a0c986975b17caa828770))
* **youtube/theme:** apply custom seekbar color to video thumbnails ([#2085](https://github.com/revanced/revanced-patches/issues/2085)) ([d497027](https://github.com/revanced/revanced-patches/commit/d4970273ad10f62cd9455ef9b847c686147f7dca))
* **youtube/theme:** move options out of dependency patch ([a953448](https://github.com/revanced/revanced-patches/commit/a95344879c2ac2cd6da8ce0273dcb05e8a35d2ec))
* **youtube/vanced-microg-support:** depend on `client-spoof` patch ([83a4905](https://github.com/revanced/revanced-patches/commit/83a490575c60adf21db926df3013f539c6d33068))
* **youtube/video-speed:** add compatibility annotation ([#2156](https://github.com/revanced/revanced-patches/issues/2156)) ([ffa2e5d](https://github.com/revanced/revanced-patches/commit/ffa2e5d7eb0b90bb5c7a6854bab4caf9f810d917))
* **youtube:** add missing compatibility annotations for `theme` and `hide-load-more-button` ([#2150](https://github.com/revanced/revanced-patches/issues/2150)) ([78803f8](https://github.com/revanced/revanced-patches/commit/78803f8ea85684e4c69e75b676fa40bae8760957))
### Features
* add capability to filter from protobuf buffer ([b738b6b](https://github.com/revanced/revanced-patches/commit/b738b6bf3506f222844ef4bca99a91f78d331391))
* **candylinkvpn:** add `unlock-pro` patch ([#2157](https://github.com/revanced/revanced-patches/issues/2157)) ([7159f86](https://github.com/revanced/revanced-patches/commit/7159f867801300d4ae32937743de59421de76238))
* improve structure of `README` ([279b193](https://github.com/revanced/revanced-patches/commit/279b193b687ad9cba44ab9c2a88d2ce06be0bbf0))
* **messenger:** add `disable-switching-emoji-to-sticker-in-message-input-field` patch ([#2099](https://github.com/revanced/revanced-patches/issues/2099)) ([ac5532a](https://github.com/revanced/revanced-patches/commit/ac5532a65c353b1964d9b7d990341fc7362e510d))
* **messenger:** add `disable-typing-indicator` patch ([#2115](https://github.com/revanced/revanced-patches/issues/2115)) ([5d1de4f](https://github.com/revanced/revanced-patches/commit/5d1de4f4eab83e61cfc1c4aaee74179afcb9431f))
* **patch:** bump compatibility ([#2060](https://github.com/revanced/revanced-patches/issues/2060)) ([f86836d](https://github.com/revanced/revanced-patches/commit/f86836d6295db9eb8c59916deaa991b4d99e96be))
* **reddit:** add `sanitize-sharing-links` patch ([#2192](https://github.com/revanced/revanced-patches/issues/2192)) ([9593e4b](https://github.com/revanced/revanced-patches/commit/9593e4b5db604957545b4ab6747c82fb815ac08b))
* **reddit:** remove compatibility version constraints ([#2226](https://github.com/revanced/revanced-patches/issues/2226)) ([f1288e4](https://github.com/revanced/revanced-patches/commit/f1288e4bb8fb1b9f394d73fd814d97db8704b8e0))
* **syncforreddit:** add `disable-ads` patch ([#2066](https://github.com/revanced/revanced-patches/issues/2066)) ([c1de5d6](https://github.com/revanced/revanced-patches/commit/c1de5d6e433263b9a17305fa1c65807921594731))
* **trakt:** add `unlock-pro` patch ([#2210](https://github.com/revanced/revanced-patches/issues/2210)) ([1e8dcae](https://github.com/revanced/revanced-patches/commit/1e8dcae6f540455b8698703bbded5f52fd0c6300))
* **twitch/auto-claim-channel-points:** use correct casing for 
---  
