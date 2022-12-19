#!/usr/bin/env bash

source semver

MODULE_TEMPLATE_DIR="revanced-magisk"
MODULE_SCRIPTS_DIR="scripts"
TEMP_DIR="temp"
BUILD_DIR="build"

GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-$"j-hc/revanced-magisk-module"}
NEXT_VER_CODE=${NEXT_VER_CODE:-$(date +'%Y%m%d')}
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0"

SERVICE_SH=$(cat $MODULE_SCRIPTS_DIR/service.sh)
POSTFSDATA_SH=$(cat $MODULE_SCRIPTS_DIR/post-fs-data.sh)
CUSTOMIZE_SH=$(cat $MODULE_SCRIPTS_DIR/customize.sh)
UNINSTALL_SH=$(cat $MODULE_SCRIPTS_DIR/uninstall.sh)

json_get() {
	grep -o "\"${1}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/'
}

get_prebuilts() {
	echo "Getting prebuilts"
	RV_CLI_URL=$(req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | json_get 'browser_download_url')
	RV_CLI_JAR="${TEMP_DIR}/${RV_CLI_URL##*/}"
	log "CLI: ${RV_CLI_URL##*/}"

	RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | json_get 'browser_download_url')
	RV_INTEGRATIONS_APK=${RV_INTEGRATIONS_URL##*/}
	RV_INTEGRATIONS_APK="${RV_INTEGRATIONS_APK%.apk}-$(cut -d/ -f8 <<<"$RV_INTEGRATIONS_URL").apk"
	log "Integrations: $RV_INTEGRATIONS_APK"
	RV_INTEGRATIONS_APK="${TEMP_DIR}/${RV_INTEGRATIONS_APK}"

	RV_PATCHES=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest -)
	RV_PATCHES_CHANGELOG=$(echo "$RV_PATCHES" | json_get 'body' | sed 's/\(\\n\)\+/\\n/g')
	RV_PATCHES_URL=$(echo "$RV_PATCHES" | json_get 'browser_download_url' | grep 'jar')
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
	local url=$1 version=$2 regexp=$3 output=$4
	url="https://www.apkmirror.com/apk/${url}/${url##*/}-${version//./-}-release/"
	resp=$(req "$url" -) || return 1
	url="https://www.apkmirror.com$(echo "$resp" | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}
get_apkmirror_vers() {
	local apkmirror_category=$1
	apkm_resp=$(req "https://www.apkmirror.com/uploads/?appcategory=${apkmirror_category}" -)
	apkm_name=$(echo "$apkm_resp" | sed -n 's;.*Latest \(.*\) Uploads.*;\1;p')
	vers=$(echo "$apkm_resp" | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p')
	for v in $vers; do
		if ! grep -q "${apkm_name} ${v} beta" <<<"$apkm_resp"; then
			echo "$v"
		fi
	done
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
	declare -r tdir=$(mktemp -d -p $TEMP_DIR)
	local cmd="java -jar $RV_CLI_JAR --temp-dir=$tdir -c -a $stock_input -o $patched_apk -b $RV_PATCHES_JAR --keystore=ks.keystore $patcher_args"
	echo "$cmd"
	eval "$cmd"
}

zip_module() {
	local patched_apk=$1 module_name=$2 stock_apk=$3 pkg_name=$4 template_dir=$5
	cp -f "$patched_apk" "${template_dir}/base.apk"
	cp -f "$stock_apk" "${template_dir}/${pkg_name}.apk"
	cd "$template_dir" || abort "Module template dir not found"
	zip -"$COMPRESSION_LEVEL" -FSr "../../${BUILD_DIR}/${module_name}" .
	cd ../..
}

build_rv() {
	local -n args=$1
	local version patcher_args dl_from build_mode_arr
	local mode_arg=${args[mode]%/*} version_mode=${args[mode]#*/}
	local arch=${args[arch]:-all} app_name_l=${args[app_name],,}
	if [ "${args[apkmirror_dlurl]:-}" ] && [ "${args[regexp]:-}" ]; then dl_from=apkmirror; else dl_from=uptodown; fi

	if [ "$mode_arg" = none ]; then
		echo 2
		return
	elif [ "$mode_arg" = module ]; then
		build_mode_arr=(module)
	elif [ "$mode_arg" = apk ]; then
		build_mode_arr=(apk)
	elif [ "$mode_arg" = both ]; then
		build_mode_arr=(apk module)
	else
		echo "ERROR: undefined build mode for ${args[app_name]}: '${mode_arg}'"
		echo 2
		return
	fi

	for build_mode in "${build_mode_arr[@]}"; do
		patcher_args="${args[patcher_args]:-}"
		printf "Building '%s' (%s) in " "${args[app_name]}" "${arch}"
		if [ "$build_mode" = module ]; then echo "'module' mode"; else echo "'APK' mode"; fi
		if [ "${args[microg_patch]:-}" ]; then
			if [ "$build_mode" = module ]; then
				patcher_args="$patcher_args -e ${args[microg_patch]}"
			elif [[ "${args[patcher_args]}" = *"${args[microg_patch]}"* ]]; then
				abort "UNREACHABLE $LINENO"
			fi
		fi
		if [ "$version_mode" = auto ] && [ $dl_from = apkmirror ]; then
			version=$(get_patch_last_supported_ver "${args[pkg_name]}")
			if [ -z "$version" ]; then
				version=$(get_apkmirror_vers "${args[apkmirror_dlurl]##*/}" | if [ "${args[pkg_name]}" = "com.twitter.android" ]; then grep release; else cat; fi | get_largest_ver)
			fi
		elif [ "$version_mode" = latest ]; then
			if [ $dl_from = apkmirror ]; then
				version=$(get_apkmirror_vers "${args[apkmirror_dlurl]##*/}" | if [ "${args[pkg_name]}" = "com.twitter.android" ]; then grep release; else cat; fi | get_largest_ver)
			elif [ $dl_from = uptodown ]; then
				version=$(get_uptodown_ver "${app_name_l}")
			fi
			patcher_args="$patcher_args --experimental"
		else
			version=$version_mode
			patcher_args="$patcher_args --experimental"
		fi
		if [ -z "${version}" ]; then
			echo "ERROR: empty version"
			return 1
		fi
		echo "Choosing version '${version}'"

		local stock_apk="${TEMP_DIR}/${app_name_l}-stock-v${version}-${arch}.apk"
		local apk_output="${BUILD_DIR}/${app_name_l}-revanced-v${version}-${arch}.apk"
		if [ "${args[microg_patch]:-}" ]; then
			local patched_apk="${TEMP_DIR}/${app_name_l}-revanced-v${version}-${arch}-${build_mode}.apk"
		else
			local patched_apk="${TEMP_DIR}/${app_name_l}-revanced-v${version}-${arch}.apk"
		fi
		if [ ! -f "$stock_apk" ]; then
			if [ $dl_from = apkmirror ]; then
				echo "Downloading from APKMirror"
				if ! dl_apkmirror "${args[apkmirror_dlurl]}" "$version" "${args[regexp]}" "$stock_apk"; then
					echo "ERROR: Could not find version '${version}' for ${args[app_name]}"
					return 1
				fi
			elif [ $dl_from = uptodown ]; then
				echo "Downloading the latest version from Uptodown"
				if ! dl_uptodown "$app_name_l" "$stock_apk"; then
					echo "ERROR: Could not download ${args[app_name]}"
					return 1
				fi
			else
				abort "UNREACHABLE $LINENO"
			fi
		fi

		if [ "${arch}" = "all" ]; then
			! grep -q "${args[app_name]}:" build.md && log "${args[app_name]}: ${version}"
		else
			! grep -q "${args[app_name]} (${arch}):" build.md && log "${args[app_name]} (${arch}): ${version}"
		fi

		[ ! -f "$patched_apk" ] && patch_apk "$stock_apk" "$patched_apk" "$patcher_args"
		if [ ! -f "$patched_apk" ]; then
			echo "BUILDING '${args[app_name]}' FAILED"
			return
		fi
		if [ "$build_mode" = apk ]; then
			cp -f "$patched_apk" "${apk_output}"
			echo "Built ${args[app_name]} (${arch}) (non-root): '${apk_output}'"
			continue
		fi

		declare -r base_template=$(mktemp -d -p $TEMP_DIR)
		cp -a $MODULE_TEMPLATE_DIR/. "$base_template"

		uninstall_sh "${args[pkg_name]}" "$base_template"
		service_sh "${args[pkg_name]}" "$base_template"
		postfsdata_sh "${args[pkg_name]}" "$base_template"
		customize_sh "${args[pkg_name]}" "$base_template"

		local upj pn
		upj=$([ "${arch}" = "all" ] && echo "${app_name_l}-update.json" || echo "${app_name_l}-${arch}-update.json")
		if [ "${args[module_prop_name]:-}" ]; then
			pn=${args[module_prop_name]}
		else
			pn=$([ "${arch}" = "all" ] && echo "${app_name_l}-rv-jhc-magisk" || echo "${app_name_l}-${arch}-rv-jhc-magisk")
		fi
		module_prop "$pn" \
			"${args[app_name]} ReVanced" \
			"$version" \
			"${args[app_name]} ReVanced Magisk module" \
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/${upj}" \
			"$base_template"

		local module_output="${app_name_l}-revanced-magisk-v${version}-${arch}.zip"
		zip_module "$patched_apk" "$module_output" "$stock_apk" "${args[pkg_name]}" "$base_template"
		rm -rf "$base_template"

		echo "Built ${args[app_name]} (${arch}) (root): '${BUILD_DIR}/${module_output}'"
	done
}

join_args() {
	echo "$1" | tr -d '\t\r' | tr ' ' '\n' | grep -v '^$' | sed "s/^/${2} /" | paste -sd " " - || echo ""
}

#shellcheck disable=SC2034
build_youtube() {
	declare -A youtube_args
	youtube_args[app_name]="YouTube"
	youtube_args[patcher_args]="-m ${RV_INTEGRATIONS_APK} $(join_args "${YOUTUBE_EXCLUDED_PATCHES}" -e) $(join_args "${YOUTUBE_INCLUDED_PATCHES}" -i)"
	youtube_args[mode]="$YOUTUBE_MODE"
	youtube_args[microg_patch]="microg-support"
	youtube_args[pkg_name]="com.google.android.youtube"
	youtube_args[rip_all_libs]=true
	youtube_args[apkmirror_dlurl]="google-inc/youtube"
	youtube_args[regexp]="APK</span>[^@]*@\([^#]*\)"
	youtube_args[module_prop_name]="ytrv-magisk"

	build_rv youtube_args
}

#shellcheck disable=SC2034
build_music() {
	declare -A ytmusic_args
	ytmusic_args[app_name]="Music"
	ytmusic_args[patcher_args]="$(join_args "${MUSIC_EXCLUDED_PATCHES}" -e) $(join_args "${MUSIC_INCLUDED_PATCHES}" -i)"
	ytmusic_args[microg_patch]="music-microg-support"
	ytmusic_args[pkg_name]="com.google.android.apps.youtube.music"
	ytmusic_args[rip_all_libs]=false
	ytmusic_args[apkmirror_dlurl]="google-inc/youtube-music"

	for a in arm64-v8a arm-v7a; do
		if [ $a = arm64-v8a ]; then
			ytmusic_args[module_prop_name]="ytmusicrv-magisk"
			ytmusic_args[arch]=arm64-v8a
			ytmusic_args[regexp]='arm64-v8a</div>[^@]*@\([^"]*\)'
			ytmusic_args[mode]="$MUSIC_ARM64_V8A_MODE"
		elif [ $a = arm-v7a ]; then
			ytmusic_args[module_prop_name]="ytmusicrv-arm-magisk"
			ytmusic_args[arch]=arm-v7a
			ytmusic_args[regexp]='armeabi-v7a</div>[^@]*@\([^"]*\)'
			ytmusic_args[mode]="$MUSIC_ARM_V7A_MODE"
		fi

		build_rv ytmusic_args
	done
}

#shellcheck disable=SC2034
build_twitter() {
	declare -A tw_args
	tw_args[app_name]="Twitter"
	tw_args[mode]="$TWITTER_MODE"
	tw_args[pkg_name]="com.twitter.android"
	tw_args[apkmirror_dlurl]="twitter-inc/twitter"
	tw_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv tw_args
}

#shellcheck disable=SC2034
build_reddit() {
	declare -A reddit_args
	reddit_args[app_name]="Reddit"
	reddit_args[mode]="$REDDIT_MODE"
	reddit_args[pkg_name]="com.reddit.frontpage"
	reddit_args[apkmirror_dlurl]="redditinc/reddit"
	reddit_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv reddit_args
}

#shellcheck disable=SC2034
build_twitch() {
	declare -A twitch_args
	twitch_args[app_name]="Twitch"
	twitch_args[patcher_args]="-m ${RV_INTEGRATIONS_APK}"
	twitch_args[mode]="$TWITCH_MODE"
	twitch_args[pkg_name]="tv.twitch.android.app"
	twitch_args[apkmirror_dlurl]="twitch-interactive-inc/twitch"
	twitch_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv twitch_args
}

#shellcheck disable=SC2034
build_tiktok() {
	declare -A tiktok_args
	tiktok_args[app_name]="TikTok"
	tiktok_args[patcher_args]="-m ${RV_INTEGRATIONS_APK}"
	tiktok_args[mode]="$TIKTOK_MODE"
	tiktok_args[pkg_name]="com.zhiliaoapp.musically"
	tiktok_args[apkmirror_dlurl]="tiktok-pte-ltd/tik-tok-including-musical-ly"
	tiktok_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv tiktok_args
}

#shellcheck disable=SC2034
build_spotify() {
	declare -A spotify_args
	spotify_args[app_name]="Spotify"
	spotify_args[mode]="$SPOTIFY_MODE"
	spotify_args[pkg_name]="com.spotify.music"

	build_rv spotify_args
}

#shellcheck disable=SC2034
build_ticktick() {
	declare -A ticktick_args
	ticktick_args[app_name]="TickTick"
	ticktick_args[mode]="$TICKTICK_MODE"
	ticktick_args[pkg_name]="com.ticktick.task"
	ticktick_args[apkmirror_dlurl]="appest-inc/ticktick-to-do-list-with-reminder-day-planner"
	ticktick_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv ticktick_args
}

#shellcheck disable=SC2034
build_warn_wetter() {
	declare -A warn_wetter_args
	warn_wetter_args[app_name]="WarnWetter"
	warn_wetter_args[mode]="$WARN_WETTER_MODE"
	warn_wetter_args[pkg_name]="de.dwd.warnapp"
	warn_wetter_args[apkmirror_dlurl]="deutscher-wetterdienst/warnwetter"
	warn_wetter_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv warn_wetter_args
}

#shellcheck disable=SC2034
build_backdrops() {
	declare -A backdrops_args
	backdrops_args[app_name]="Backdrops"
	backdrops_args[mode]="$BACKDROPS_MODE"
	backdrops_args[pkg_name]="com.backdrops.wallpapers"
	backdrops_args[apkmirror_dlurl]="backdrops/backdrops-wallpapers"
	backdrops_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv backdrops_args
}

#shellcheck disable=SC2034
build_windy() {
	declare -A windy_args
	windy_args[app_name]="Windy"
	windy_args[mode]="$WINDY_MODE"
	windy_args[pkg_name]="co.windyapp.android"
	windy_args[apkmirror_dlurl]="windy-weather-world-inc/windy-wind-weather-forecast"
	windy_args[regexp]='APK</span>[^@]*@\([^#]*\)'

	build_rv windy_args
}

postfsdata_sh() { echo "${POSTFSDATA_SH//__PKGNAME/$1}" >"${2}/post-fs-data.sh"; }
uninstall_sh() { echo "${UNINSTALL_SH//__PKGNAME/$1}" >"${2}/uninstall.sh"; }
customize_sh() { echo "${CUSTOMIZE_SH//__PKGNAME/$1}" >"${2}/customize.sh"; }
service_sh() {
	s="${SERVICE_SH//__MNTDLY/$MOUNT_DELAY}"
	echo "${s//__PKGNAME/$1}" >"${2}/service.sh"
}
module_prop() {
	echo "id=${1}
name=${2}
version=v${3}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=${4}" >"${6}/module.prop"

	if [ "$ENABLE_MAGISK_UPDATE" = true ]; then echo "updateJson=${5}" >>"${6}/module.prop"; fi
}
