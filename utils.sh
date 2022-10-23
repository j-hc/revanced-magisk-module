#!/usr/bin/env bash

source semver

MODULE_TEMPLATE_DIR="revanced-magisk"
MODULE_SCRIPTS_DIR="scripts"
TEMP_DIR="temp"
BUILD_DIR="build"

ARM64_V8A="arm64-v8a"
ARM_V7A="arm-v7a"
GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-$"j-hc/revanced-magisk-module"}
NEXT_VER_CODE=${NEXT_VER_CODE:-$(date +'%Y%m%d')}
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

SERVICE_SH=$(cat $MODULE_SCRIPTS_DIR/service.sh)
POSTFSDATA_SH=$(cat $MODULE_SCRIPTS_DIR/post-fs-data.sh)
CUSTOMIZE_SH=$(cat $MODULE_SCRIPTS_DIR/customize.sh)
UNINSTALL_SH=$(cat $MODULE_SCRIPTS_DIR/uninstall.sh)

json_get() {
	local key=$1 grep_for=${2:-}
	grep -o "\"${key}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/' | if [ "$grep_for" ]; then grep "$grep_for"; else cat; fi
}

get_prebuilts() {
	echo "Getting prebuilts"
	RV_CLI_URL=$(req https://api.github.com/repos/j-hc/revanced-cli/releases/latest - | json_get 'browser_download_url')
	RV_CLI_JAR="${TEMP_DIR}/${RV_CLI_URL##*/}"
	log "CLI: ${RV_CLI_URL##*/}"

	RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | json_get 'browser_download_url')
	RV_INTEGRATIONS_APK=${RV_INTEGRATIONS_URL##*/}
	RV_INTEGRATIONS_APK="${RV_INTEGRATIONS_APK%.apk}-$(cut -d/ -f8 <<<"$RV_INTEGRATIONS_URL").apk"
	log "Integrations: $RV_INTEGRATIONS_APK"
	RV_INTEGRATIONS_APK="${TEMP_DIR}/${RV_INTEGRATIONS_APK}"

	RV_PATCHES=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest -)
	RV_PATCHES_CHANGELOG=$(echo "$RV_PATCHES" | json_get 'body' | sed 's/\(\\n\)\+/\\n/g')
	RV_PATCHES_URL=$(echo "$RV_PATCHES" | json_get 'browser_download_url' 'jar')
	RV_PATCHES_JAR="${TEMP_DIR}/${RV_PATCHES_URL##*/}"
	log "Patches: ${RV_PATCHES_URL##*/}"
	log "\n${RV_PATCHES_CHANGELOG//# [/### [}\n"

	dl_if_dne "$RV_CLI_JAR" "$RV_CLI_URL"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$RV_INTEGRATIONS_URL"
	dl_if_dne "$RV_PATCHES_JAR" "$RV_PATCHES_URL"
}

get_cmpr() {
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm64/cmpr" "https://github.com/j-hc/cmpr/releases/download/20220811/cmpr-arm64-v8a"
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm/cmpr" "https://github.com/j-hc/cmpr/releases/download/20220811/cmpr-armeabi-v7a"
}

abort() { echo "abort: $1" && exit 1; }

set_prebuilts() {
	[ -d "$TEMP_DIR" ] || abort "${TEMP_DIR} directory could not be found"
	RV_CLI_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-cli-*" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced cli not found"
	log "CLI: ${RV_CLI_JAR#"$TEMP_DIR/"}"
	RV_INTEGRATIONS_APK=$(find "$TEMP_DIR" -maxdepth 1 -name "app-release-unsigned-*" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced integrations not found"
	log "Integrations: ${RV_INTEGRATIONS_APK#"$TEMP_DIR/"}"
	RV_PATCHES_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-patches-*" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced patches not found"
	log "Patches: ${RV_PATCHES_JAR#"$TEMP_DIR/"}"
}

reset_template() {
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/service.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/post-fs-data.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/customize.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/uninstall.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/module.prop"
	rm -rf ${MODULE_TEMPLATE_DIR}/*.apk
	mkdir -p ${MODULE_TEMPLATE_DIR}/bin/arm ${MODULE_TEMPLATE_DIR}/bin/arm64
}

req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }
log() { echo -e "$1  " >>build.md; }
get_largest_ver() {
	local max=0
	while read -r v || [ -n "$v" ]; do
		if [ "$(command_compare "$v" "$max")" = 1 ]; then max=$v; fi
	done
	if [[ $max = 0 ]]; then echo ""; else echo "$max"; fi
}
get_patch_last_supported_ver() {
	unzip -p "$RV_PATCHES_JAR" | strings -s , | sed -rn "s/.*${1},versions,(([0-9.]*,*)*),Lk.*/\1/p" | tr ',' '\n' | get_largest_ver
}

dl_if_dne() {
	if [ ! -f "$1" ]; then
		echo -e "\nGetting '$1' from '$2'"
		req "$2" "$1"
	fi
}

# if you are here to copy paste this piece of code, acknowledge it:)
dl_apkmirror() {
	local url=$1 regexp=$2 output=$3
	resp=$(req "$url" -) || return 1
	url="https://www.apkmirror.com$(echo "$resp" | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}
get_apkmirror_vers() {
	local apkmirror_category=$1
	req "https://www.apkmirror.com/uploads/?appcategory=${apkmirror_category}" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'
}
get_uptodown_ver() {
	local app_name=$1
	req "https://${app_name}.en.uptodown.com/android/download" - | json_get 'softwareVersion'
}
dl_uptodown() {
	local app_name=$1 output=$2
	url=$(req "https://${app_name}.en.uptodown.com/android/download" - | sed -n 's;.*data-url="\(.*\)".*;\1;p')
	req "$url" "$output"
}

patch_apk() {
	local stock_input=$1 patched_apk=$2 patcher_args=$3
	echo "java -jar $RV_CLI_JAR --rip-lib x86 --rip-lib x86_64 -c -a $stock_input -o $patched_apk -b $RV_PATCHES_JAR --keystore=ks.keystore $patcher_args"
	# shellcheck disable=SC2086
	# --rip-lib is only available in my own revanced-cli builds
	java -jar "$RV_CLI_JAR" --rip-lib x86 --rip-lib x86_64 -c -a "$stock_input" -o "$patched_apk" -b "$RV_PATCHES_JAR" --keystore=ks.keystore $patcher_args
}

zip_module() {
	local patched_apk=$1 module_name=$2 stock_apk=$3 pkg_name=$4
	cp -f "$patched_apk" "${MODULE_TEMPLATE_DIR}/base.apk"
	cp -f "$stock_apk" "${MODULE_TEMPLATE_DIR}/${pkg_name}.apk"
	cd "$MODULE_TEMPLATE_DIR" || abort "Module template dir not found"
	zip -"$COMPRESSION_LEVEL" -FSr "../${BUILD_DIR}/${module_name}" .
	cd ..
}

select_ver() {
	local last_ver pkg_name=$1 apkmirror_category=$2 select_ver_experimental=$3
	last_ver=$(get_patch_last_supported_ver "$pkg_name")
	if [ "$select_ver_experimental" = true ] || [ -z "$last_ver" ]; then
		if [ "$pkg_name" = "com.twitter.android" ]; then
			last_ver=$(get_apkmirror_vers "$apkmirror_category" | grep "release" | get_largest_ver)
		else
			last_ver=$(get_apkmirror_vers "$apkmirror_category" | get_largest_ver)
		fi
	fi
	echo "$last_ver"
}

build_rv() {
	local -n args=$1
	local version patcher_args dl_from build_mode_arr
	local mode_arg=${args[mode]%/*} version_mode=${args[mode]#*/}
	args[arch]=${args[arch]:-all}
	if [ "${args[apkmirror_dlurl]:-}" ] && [ "${args[regexp]:-}" ]; then dl_from=apkmirror; else dl_from=uptodown; fi
	reset_template

	if [ "$mode_arg" = none ]; then
		return
	elif [ "$mode_arg" = module ]; then
		build_mode_arr=(module)
	elif [ "$mode_arg" = apk ]; then
		build_mode_arr=(apk)
	elif [ "$mode_arg" = both ]; then
		build_mode_arr=(apk module)
	else
		echo "ERROR: undefined build mode for YouTube: '$mode_arg'"
		return
	fi
	for build_mode in "${build_mode_arr[@]}"; do
		patcher_args="${args[patcher_args]:-}"
		printf "Building '%s' (%s) in " "${args[app_name]}" "${args[arch]}"
		if [ "$build_mode" = module ]; then echo "'module' mode"; else echo "'APK' mode"; fi

		if [ "${args[microg_patch]:-}" ]; then
			if [ "$build_mode" = module ]; then
				patcher_args="$patcher_args -e ${args[microg_patch]}"
			elif [[ "${args[patcher_args]}" = *"${args[microg_patch]}"* ]]; then
				abort "UNREACHABLE $LINENO"
			fi
		fi
		if [ "$version_mode" = auto ] && [ $dl_from = apkmirror ]; then
			version=$(select_ver "${args[pkg_name]}" "${args[apkmirror_dlurl]##*/}" false)
		elif [ "$version_mode" = latest ]; then
			if [ $dl_from = apkmirror ]; then
				version=$(select_ver "${args[pkg_name]}" "${args[apkmirror_dlurl]##*/}" true)
			elif [ $dl_from = uptodown ]; then
				version=$(get_uptodown_ver "${args[app_name],,}")
			fi
			patcher_args="$patcher_args --experimental"
		else
			version=$version_mode
			patcher_args="$patcher_args --experimental"
		fi
		echo "Choosing version '${version}'"

		if [ "$build_mode" = module ]; then
			if [ "${args[rip_all_libs]:-}" = true ]; then
				# --unsigned is only available in my revanced-cli builds
				# native libraries are already extracted. remove them all to keep apks smol
				patcher_args="$patcher_args --unsigned --rip-lib arm64-v8a --rip-lib armeabi-v7a"
			else
				patcher_args="$patcher_args --unsigned"
			fi
		fi

		local stock_apk="${TEMP_DIR}/${args[app_name],,}-stock-v${version}-${args[arch]}.apk"
		local apk_output="${BUILD_DIR}/${args[app_name],,}-revanced-v${version}-${args[arch]}.apk"
		if [ "${args[microg_patch]:-}" ]; then
			local patched_apk="${TEMP_DIR}/${args[app_name],,}-revanced-v${version}-${args[arch]}-${build_mode}.apk"
		else
			local patched_apk="${TEMP_DIR}/${args[app_name],,}-revanced-v${version}-${args[arch]}.apk"
		fi
		if [ ! -f "$stock_apk" ]; then
			if [ $dl_from = apkmirror ]; then
				echo "Downloading from APKMirror"
				if ! dl_apkmirror "https://www.apkmirror.com/apk/${args[apkmirror_dlurl]}-${version//./-}-release/" \
					"${args[regexp]}" \
					"$stock_apk"; then
					echo "ERROR: Could not find version '${version}' for ${args[app_name]}"
					return 1
				fi
			elif [ $dl_from = uptodown ]; then
				echo "Downloading the latest version from Uptodown"
				if ! dl_uptodown "${args[app_name],,}" "$stock_apk"; then
					echo "ERROR: Could not download ${args[app_name]}"
					return 1
				fi
			else
				abort "UNREACHABLE $LINENO"
			fi
		fi

		if [ "${args[arch]}" = "all" ]; then
			! grep -q "${args[app_name]}" build.md && log "${args[app_name]}: ${version}"
		else
			! grep -q "${args[app_name]} (${args[arch]})" build.md && log "${args[app_name]} (${args[arch]}): ${version}"
		fi

		[ ! -f "$patched_apk" ] && patch_apk "$stock_apk" "$patched_apk" "$patcher_args"
		if [ ! -f "$patched_apk" ]; then
			echo "BUILD FAIL"
			return
		fi
		if [ "$build_mode" = apk ]; then
			cp -f "$patched_apk" "${apk_output}"
			echo "Built ${args[app_name]} (${args[arch]}) (non-root): '${apk_output}'"
			continue
		fi

		uninstall_sh "${args[pkg_name]}"
		service_sh "${args[pkg_name]}"
		postfsdata_sh "${args[pkg_name]}"
		customize_sh "${args[pkg_name]}" "${version}"
		module_prop "${args[module_prop_name]}" \
			"${args[app_name]} ReVanced" \
			"${version}" \
			"${args[app_name]} ReVanced Magisk module" \
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/${args[module_update_json]}"

		local module_output="${args[app_name],,}-revanced-magisk-v${version}-${args[arch]}.zip"
		zip_module "$patched_apk" "$module_output" "$stock_apk" "${args[pkg_name]}"

		echo "Built ${args[app_name]} (${args[arch]}) (root): '${BUILD_DIR}/${module_output}'"
	done
}

excluded_patches() {
	if [ "$1" ]; then
		echo "$1" | tr -d '\t\r' | tr ' ' '\n' | grep -v '^$' | sed 's/^/-e /' | paste -sd " " -
	else
		echo ""
	fi
}

build_youtube() {
	declare -A youtube_args
	youtube_args[app_name]="YouTube"
	youtube_args[patcher_args]="-m ${RV_INTEGRATIONS_APK} $(excluded_patches "${YOUTUBE_EXCLUDED_PATCHES}")"
	youtube_args[mode]="$YOUTUBE_MODE"
	youtube_args[microg_patch]="microg-support"
	youtube_args[pkg_name]="com.google.android.youtube"
	youtube_args[rip_all_libs]=true
	youtube_args[apkmirror_dlurl]="google-inc/youtube/youtube"
	youtube_args[regexp]="APK</span>[^@]*@\([^#]*\)"
	youtube_args[module_prop_name]="ytrv-magisk"
	# shellcheck disable=SC2034
	youtube_args[module_update_json]="yt-update.json"

	build_rv youtube_args
}

build_music() {
	declare -A ytmusic_args
	local arch=$1
	ytmusic_args[app_name]="Music"
	ytmusic_args[patcher_args]="$(excluded_patches "${MUSIC_EXCLUDED_PATCHES}")"
	ytmusic_args[microg_patch]="music-microg-support"
	ytmusic_args[arch]=$arch
	ytmusic_args[pkg_name]="com.google.android.apps.youtube.music"
	ytmusic_args[rip_all_libs]=false
	ytmusic_args[apkmirror_dlurl]="google-inc/youtube-music/youtube-music"
	if [ "$arch" = "$ARM64_V8A" ]; then
		ytmusic_args[regexp]='arm64-v8a</div>[^@]*@\([^"]*\)'
		ytmusic_args[module_prop_name]="ytmusicrv-magisk"
		ytmusic_args[mode]="$MUSIC_ARM64_V8A_MODE"

	elif [ "$arch" = "$ARM_V7A" ]; then
		ytmusic_args[regexp]='armeabi-v7a</div>[^@]*@\([^"]*\)'
		ytmusic_args[module_prop_name]="ytmusicrv-arm-magisk"
		ytmusic_args[mode]="$MUSIC_ARM_V7A_MODE"
	fi
	#shellcheck disable=SC2034
	ytmusic_args[module_update_json]="music-update-${arch}.json"

	build_rv ytmusic_args
}

build_twitter() {
	declare -A tw_args
	tw_args[app_name]="Twitter"
	tw_args[mode]="$TWITTER_MODE"
	tw_args[pkg_name]="com.twitter.android"
	tw_args[apkmirror_dlurl]="twitter-inc/twitter/twitter"
	tw_args[regexp]='APK</span>[^@]*@\([^#]*\)'
	tw_args[module_prop_name]="twrv-magisk"
	#shellcheck disable=SC2034
	tw_args[module_update_json]="tw-update.json"

	build_rv tw_args
}

build_reddit() {
	declare -A reddit_args
	reddit_args[app_name]="Reddit"
	reddit_args[mode]="$REDDIT_MODE"
	reddit_args[pkg_name]="com.reddit.frontpage"
	reddit_args[apkmirror_dlurl]="redditinc/reddit/reddit"
	reddit_args[regexp]='APK</span>[^@]*@\([^#]*\)'
	reddit_args[module_prop_name]="rditrv-magisk"
	#shellcheck disable=SC2034
	reddit_args[module_update_json]="rdrv-update.json"

	build_rv reddit_args
}

build_tiktok() {
	declare -A tiktok_args
	tiktok_args[app_name]="TikTok"
	tiktok_args[patcher_args]="-m ${RV_INTEGRATIONS_APK}"
	tiktok_args[mode]="$TIKTOK_MODE"
	tiktok_args[pkg_name]="com.zhiliaoapp.musically"
	tiktok_args[apkmirror_dlurl]="tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly"
	tiktok_args[regexp]='APK</span>[^@]*@\([^#]*\)'
	tiktok_args[module_prop_name]="ttrv-magisk"
	#shellcheck disable=SC2034
	tiktok_args[module_update_json]="tt-update.json"

	build_rv tiktok_args
}

build_spotify() {
	declare -A spotify_args
	spotify_args[app_name]="Spotify"
	spotify_args[mode]="$SPOTIFY_MODE"
	spotify_args[pkg_name]="com.spotify.music"
	spotify_args[module_prop_name]="sprv-magisk"
	#shellcheck disable=SC2034
	spotify_args[module_update_json]="sp-update.json"

	build_rv spotify_args
}

build_warn_wetter() {
	declare -A warn_wetter_args
	warn_wetter_args[app_name]="WarnWetter"
	warn_wetter_args[mode]="$WARN_WETTER_MODE"
	warn_wetter_args[pkg_name]="de.dwd.warnapp"
	warn_wetter_args[apkmirror_dlurl]="deutscher-wetterdienst/warnwetter/warnwetter"
	warn_wetter_args[regexp]='APK</span>[^@]*@\([^#]*\)'
	warn_wetter_args[module_prop_name]="wwrv-magisk"
	#shellcheck disable=SC2034
	warn_wetter_args[module_update_json]="ww-update.json"

	build_rv warn_wetter_args
}

postfsdata_sh() { echo "${POSTFSDATA_SH//__PKGNAME/$1}" >"${MODULE_TEMPLATE_DIR}/post-fs-data.sh"; }
uninstall_sh() { echo "${UNINSTALL_SH//__PKGNAME/$1}" >"${MODULE_TEMPLATE_DIR}/uninstall.sh"; }
customize_sh() { echo "${CUSTOMIZE_SH//__PKGNAME/$1}" >"${MODULE_TEMPLATE_DIR}/customize.sh"; }
service_sh() {
	s="${SERVICE_SH//__MNTDLY/$MOUNT_DELAY}"
	echo "${s//__PKGNAME/$1}" >"${MODULE_TEMPLATE_DIR}/service.sh"
}

module_prop() {
	echo "id=${1}
name=${2}
version=v${3}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=${4}" >"${MODULE_TEMPLATE_DIR}/module.prop"

	[ "$ENABLE_MAGISK_UPDATE" = true ] && echo "updateJson=${5}" >>"${MODULE_TEMPLATE_DIR}/module.prop"
}
