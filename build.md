YouTube: 18.32.39  
Music-Extended (arm64-v8a): 6.19.51  
YouTube-Extended: 18.31.40  
Music (arm64-v8a): 6.20.51  
Music (arm-v7a): 6.20.51  
Twitter: 10.8.0-release.0  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  

---
Changelog:  
CLI: inotia00/revanced-cli-3.1.2-all.jar  
Integrations: inotia00/revanced-integrations-0.117.8.apk  
Patches: inotia00/revanced-patches-2.190.8.jar  

YouTube
==
- feat(youtube): remove `optimize-resource` patch https://github.com/inotia00/ReVanced_Extended/issues/1336
- feat(youtube/append-time-stamps-information): change patch name `enable-time-stamps-speed` → `append-time-stamps-information`
- feat(youtube/append-time-stamps-information): users can now choose between playback speed and video quality, which users can also toggle by long-pressing on the timestamp
- feat(youtube/custom-playback-speed): change to abstract patch
- feat(youtube/integration): minor refactoring
- fix(youtube/default-playback-speed): toast message is showing that the playback speed has been saved even though the `default-playback-speed` patch is not included https://github.com/inotia00/ReVanced_Extended/issues/1385
- fix(youtube/disable-shorts-on-startup): not working on YouTube v18.31.40 https://github.com/inotia00/ReVanced_Extended/issues/1375
- fix(youtube/hide-feed-flyout-panel): doesn't work on tablet https://github.com/inotia00/ReVanced_Extended/issues/1381
- fix(youtube/hide-handle): patch information contains incorrect patch name
- fix(youtube/hide-quick-action): unintentional buttons are hidden
- fix(youtube/hide-shorts-components): no longer check navbar index when hiding the shorts header
- fix(youtube/hide-suggestions-shelf): suggestions shelf is not hidden or playlist shelf is hidden under certain circumstances https://github.com/inotia00/ReVanced_Extended/issues/1327
- fix(youtube/litho-filter): don't remove the buffer until the thread stops
- fix(youtube/navber-index-hook): no longer using litho filter
- fix(youtube/settings): alert dialog when first installed does not match with the app's theme https://github.com/inotia00/ReVanced_Extended/issues/1379
- fix(youtube/sponsorblock): default value of `Show video length without segments` setting was changed after fetch
- fix(youtube/spoof-player-parameter): seekbar thumbnail not showing in shorts video
- fix(youtube/spoof-player-parameter): watching previews in your feed is added to your watch history https://github.com/inotia00/ReVanced_Extended/issues/1313
- refactor(youtube/default-video-quality): reimplemented with new method
- feat(youtube/translations): update translation
`Arabic`, `Chinese Traditional`, `Japanese`, `Korean`, `Vietnamese`


YouTube Music
==
- feat(music): add `custom-playback-speed` patch https://github.com/inotia00/ReVanced_Extended/issues/1367
- feat(music): add `hide-account-menu` patch https://github.com/inotia00/ReVanced_Extended/issues/1361
- feat(music): add `hide-handle` patch
- feat(music): add `hide-terms-container` patch
- feat(music): add `import/export-settings` patch
- feat(music): add `start-page` patch
- feat(music): integrate `hide-navigation-label`, `hide-sample-buttons`, `hide-upgrade-button` into `hide-navigation-bar-component`
- feat(music): remove `optimize-resource` patch
- feat(music/exclusive-audio-playback): now patch enables the `Don't play podcast videos` setting
- feat(music/hide-cast-button): patch now hides the cast banner inside the player https://github.com/inotia00/ReVanced_Extended/issues/252
- feat(music/hide-new-playlist-button): change setting description
- feat(music/replace-dismiss-queue): add `Continue watching` settings
- feat(music/settings): change category name `Bottom Player` → `Action Bar`
- feat(music/settings): create `Video` category
- feat(music/video-information): integrate `video-id` patch
- fix(music/hide-cast-button): change patch description
- fix(music/hide-sample-button): unintended buttons are hidden
- fix(music/hide-upgrade-button): library tab stuck when opening device files https://github.com/inotia00/ReVanced_Extended/issues/906
- fix(music/remember-video-quality): quality auto value was saved
- fix(music/replace-dismiss-queue): audio does not stop when intent chooser is displayed
- fix(music/settings): fix invalid class name
- fix(music/spoof-app-version): remove unintentional dependencies
- refactor(music/remember-video-quality): reimplemented with new method
- feat(music/translations): update translation
`Bengali`, `Brazilian`, `Dutch`, `Japanese`, `Korean`, `Polish`, `Russian`, `Turkish`, `Vietnamese`


Etc
==
- build: update dependency


※ Compatible ReVanced Manager: [RVX Manager v1.9.7 (fork)](https://github.com/inotia00/revanced-manager/releases/tag/v1.9.7)
[Crowdin translation]
- [YT Music](https://crowdin.com/project/revanced-music-extended)
---
CLI: j-hc/revanced-cli-3.2.0-all.jar  
Integrations: ReVanced/revanced-integrations-0.117.1.apk  
Patches: ReVanced/revanced-patches-2.190.0.jar  

### [2.190.0](https://github.com/ReVanced/revanced-patches/compare/v2.189.0...v2.190.0) (2023-09-03)
### Bug Fixes
* **Infinity for Reddit - Spoof client:** Support latest version ([8a5311b](https://github.com/ReVanced/revanced-patches/commit/8a5311b1e645ca2aab1e416d647cf52bf0be6e7f))
### Features
* **Photomath:** Support latest version ([5a2cad0](https://github.com/ReVanced/revanced-patches/commit/5a2cad077f03880ee1417c5cfd448bbdea4c07e2))
* **Twitch:** Support version `16.1.0` ([#2923](https://github.com/ReVanced/revanced-patches/issues/2923)) ([d9834a9](https://github.com/ReVanced/revanced-patches/commit/d9834a9abb43390af4cb33f5dd5a0e2d3b7060e2))

---  
