CLI: revanced-cli-2.21.0-all.jar  
Integrations: revanced-integrations-0.103.0.apk  
Patches: revanced-patches-2.169.0.jar  

### [2.169.0](https://github.com/revanced/revanced-patches/compare/v2.168.0...v2.169.0) (2023-04-21)
### Bug Fixes
* add missing annotation to patches ([#1882](https://github.com/revanced/revanced-patches/issues/1882)) ([d86b6a4](https://github.com/revanced/revanced-patches/commit/d86b6a4a659172c3f1db8eb883f28dfee4e83e4c))
* **youtube/hide-video-action-buttons:** change 'Hide create, clip and thanks buttons' to default off ([#1923](https://github.com/revanced/revanced-patches/issues/1923)) ([fc89c86](https://github.com/revanced/revanced-patches/commit/fc89c865f94fffd748809eaf0504cc91f6389500))
* **youtube/hide-video-action-buttons:** fix 'hide share button' ([#1924](https://github.com/revanced/revanced-patches/issues/1924)) ([bc05e44](https://github.com/revanced/revanced-patches/commit/bc05e4494d914f944a831bfb83a150ad93bb342f))
* **youtube/microg-support:** remove incorrect patch dependency ([3e0c45c](https://github.com/revanced/revanced-patches/commit/3e0c45c2dff9f6336e42fdd3d1b5b5de5af1b1cb))
* **youtube/microg-support:** rename patch correctly ([091a25d](https://github.com/revanced/revanced-patches/commit/091a25d46145b1c27791245fca0933e9c8a68e9a))
* **youtube/return-youtube-dislike:** render dislikes when scrolling into the screen ([#1873](https://github.com/revanced/revanced-patches/issues/1873)) ([85675b8](https://github.com/revanced/revanced-patches/commit/85675b800070de9752b2a4bfea3182381d4cfba4))
* **youtube/sponsorblock:** do not depend on `remember-playback-speed` patch ([b0834fa](https://github.com/revanced/revanced-patches/commit/b0834faa69755a94f70ae5075a10cf15e8a6b857))
* **youtube/sponsorblock:** fix autorepeat button layout ([#1868](https://github.com/revanced/revanced-patches/issues/1868)) ([5e148d9](https://github.com/revanced/revanced-patches/commit/5e148d9384e8f9f1bc8f5daa7e68a05574810329))
* **youtube/spoof-signature-verification:** depend on `client-spoof` patch ([0d47375](https://github.com/revanced/revanced-patches/commit/0d47375092639e3e5dad8d67991004fc2f103606))
* **youtubevanced/hide-ads:** hide more types of ads ([#1781](https://github.com/revanced/revanced-patches/issues/1781)) ([47ff447](https://github.com/revanced/revanced-patches/commit/47ff447f8ec0e5bbc174f34bd7d61b3031276641))
* **youtubevanced/hide-ads:** remove broken ad filter ([#1881](https://github.com/revanced/revanced-patches/issues/1881)) ([5b987e1](https://github.com/revanced/revanced-patches/commit/5b987e14e81a47691883a5b5196c7ffee03941d0))
### Features
* `change-package-name` patch ([#1864](https://github.com/revanced/revanced-patches/issues/1864)) ([f9a6672](https://github.com/revanced/revanced-patches/commit/f9a6672122eb28fe06c9f5e137906ad868a491d6))
* `enable-android-debugging` patch ([#1876](https://github.com/revanced/revanced-patches/issues/1876)) ([bd224d9](https://github.com/revanced/revanced-patches/commit/bd224d90deb838ee3e7bd0c16860023ebf113e96))
* **facebook:** `hide-inbox-ads` patch ([#1893](https://github.com/revanced/revanced-patches/issues/1893)) ([2cfc982](https://github.com/revanced/revanced-patches/commit/2cfc9829e119884ca566d6ad90fd0542317891d7))
* **id-austria:** bump compatibility to `2.6.0` ([#1827](https://github.com/revanced/revanced-patches/issues/1827)) ([f48e794](https://github.com/revanced/revanced-patches/commit/f48e794eebf9ea44008c4c8a3967ad039d19180a))
* **inshorts:** `hide-ads` patch ([#1828](https://github.com/revanced/revanced-patches/issues/1828)) ([04a2acc](https://github.com/revanced/revanced-patches/commit/04a2accfe9f9254af9074ad0a309d485cedb01cb))
* **memegenerator:** `unlock-pro` patch ([#1902](https://github.com/revanced/revanced-patches/issues/1902)) ([7d30541](https://github.com/revanced/revanced-patches/commit/7d3054178187bed294d156d3858613fa63a626ef))
* **photomath/unlock-plus:** bump compatibility to `8.21.1` ([#1926](https://github.com/revanced/revanced-patches/issues/1926)) ([beb8d9c](https://github.com/revanced/revanced-patches/commit/beb8d9cbf254b4a2b2207a307934be65507dcf80))
* **photomath:** bump compatibility up to `8.21.0` ([#1886](https://github.com/revanced/revanced-patches/issues/1886)) ([43464fd](https://github.com/revanced/revanced-patches/commit/43464fd6ffe6f097c574156146aeb23f8f026840))
* **reddit:** bump compatibility to `2023.12.0` ([#1825](https://github.com/revanced/revanced-patches/issues/1825)) ([e3666e6](https://github.com/revanced/revanced-patches/commit/e3666e68ed4816c85fbb110cb098f53fddf135f1))
* use better patch description ([32fcd25](https://github.com/revanced/revanced-patches/commit/32fcd258c6b00315265c09380550a2e98b5ec9e7))
* **youtube-music:** `bypass-certificate-checks` patch ([#1810](https://github.com/revanced/revanced-patches/issues/1810)) ([ef8f26f](https://github.com/revanced/revanced-patches/commit/ef8f26fb976c3044039f9bff0496088763ab66cd))
* **youtube/settings:** disable preferences and add dialog messages to preferences ([#1801](https://github.com/revanced/revanced-patches/issues/1801)) ([05023ba](https://github.com/revanced/revanced-patches/commit/05023bab1d94e04553ac274468bdba7a19ad9180))
* **youtube/sponsorblock:** skip to video highlight ([#1874](https://github.com/revanced/revanced-patches/issues/1874)) ([83747b7](https://github.com/revanced/revanced-patches/commit/83747b7aea33d8fe4b4b9514fdf7c9081c357410))
* **youtube:** bump compatibility to `18.08.37` ([29561ec](https://github.com/revanced/revanced-patches/commit/29561eca10e18e11f2d4a7f9bab2f12303490b6f))
* **youtube:** change default video speed and quality inside the settings menu ([#1880](https://github.com/revanced/revanced-patches/issues/1880)) ([fbb1763](https://github.com/revanced/revanced-patches/commit/fbb17636d8ab9f2a43ead896451804b04464527c))
* **youtube:** constrain compatibility to `18.08.37` ([7403fc8](https://github.com/revanced/revanced-patches/commit/7403fc86ae7b7d756a2939fa0a507f237aaf6edf))
* **youtube:** sponsorblock improvements ([#1557](https://github.com/revanced/revanced-patches/issues/1557)) ([b5d712a](https://github.com/revanced/revanced-patches/commit/b5d712a3326d1e8cdb8d8642aa7bd1bee6e30ac1))
* **youtube:** support version `18.08.37` ([4f4ceab](https://github.com/revanced/revanced-patches/commit/4f4ceab2cc32a38dd3967fd4e81f690330c08f5c))

  
**App Versions:**  
YouTube: 18.08.37  
Music (arm64-v8a): 5.39.52  
Music (arm-v7a): 5.39.52  
Twitter: 9.85.0-release.0  
Reddit: 2023.12.0  
Twitch: 14.6.1  
TikTok: 27.8.3  

Install [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) to be able to use non-root YouTube or Music  

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)  
