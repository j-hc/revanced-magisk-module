#!/bin/bash

MODULE_TEMPLATE_DIR="revanced-magisk"
TEMP_DIR="temp"
BUILD_DIR="build"
ARM64_V8A="arm64-v8a"
ARM_V7A="arm-v7a"

: "${GITHUB_REPOSITORY:=$GITHUB_REPO_FALLBACK}"
: "${NEXT_VER_CODE:=$(date +'%Y%m%d')}"

WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

get_prebuilts() {
	echo "Getting prebuilts"
	mkdir -p "$TEMP_DIR"
	RV_CLI_URL=$(req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*jar\)".*/\1/p')
	RV_CLI_JAR="${TEMP_DIR}/$(echo "$RV_CLI_URL" | awk -F/ '{ print $NF }')"
	log "CLI: ${RV_CLI_JAR#"$TEMP_DIR/"}"

	RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*apk\)".*/\1/p')
	RV_INTEGRATIONS_APK="${TEMP_DIR}/$(echo "$RV_INTEGRATIONS_URL" | awk '{n=split($0, arr, "/"); printf "%s-%s.apk", substr(arr[n], 0, length(arr[n]) - 4), arr[n-1]}')"
	log "Integrations: ${RV_INTEGRATIONS_APK#"$TEMP_DIR/"}"

	RV_PATCHES_URL=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*jar\)".*/\1/p')
	RV_PATCHES_JAR="${TEMP_DIR}/$(echo "$RV_PATCHES_URL" | awk -F/ '{ print $NF }')"
	log "Patches: ${RV_PATCHES_JAR#"$TEMP_DIR/"}"

	dl_if_dne "$RV_CLI_JAR" "$RV_CLI_URL"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$RV_INTEGRATIONS_URL"
	dl_if_dne "$RV_PATCHES_JAR" "$RV_PATCHES_URL"
}

set_prebuilts() {
	[ ! -d "$TEMP_DIR" ] && {
		echo "${TEMP_DIR} directory could not be found"
		exit 1
	}
	RV_CLI_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-cli-*")
	log "CLI: ${RV_CLI_JAR#"$TEMP_DIR/"}"
	RV_INTEGRATIONS_APK=$(find "$TEMP_DIR" -maxdepth 1 -name "app-release-unsigned-*")
	log "Integrations: ${RV_INTEGRATIONS_APK#"$TEMP_DIR/"}"
	RV_PATCHES_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-patches-*")
	log "Patches: ${RV_PATCHES_JAR#"$TEMP_DIR/"}"
}

reset_template() {
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/service.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/module.prop"
	rm -f "${MODULE_TEMPLATE_DIR}/base.apk"
}

req() {
	wget -nv -O "$2" --header="$WGET_HEADER" "$1"
}

dl_if_dne() {
	if [ ! -f "$1" ]; then
		echo -e "\nGetting '$1' from '$2'"
		req "$2" "$1"
	fi
}

log() {
	echo -e "$1  " >>build.log
}

# yes this is how i download the stock yt apk from apkmirror
dl_yt() {
	echo "Downloading YouTube"
	local url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*APK</span>[^@]*@\([^#]*\).*;\1;p')"
	log "\nYouTube version: $1"
	log "downloaded from: [APKMirror - YouTube]($url)"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$2"
}

dl_music() {
	local arch="$3"
	echo "Downloading YouTube Music (${arch})"
	local url="https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${1//./-}-release/"
	if [ "$arch" = "$ARM64_V8A" ]; then
		url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*arm64-v8a</div>[^@]*@\([^"]*\).*;\1;p')"
	elif [ "$arch" = "$ARM_V7A" ]; then
		url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*armeabi-v7a</div>[^@]*@\([^"]*\).*;\1;p')"
	else
		echo "Wrong arch: '$arch'"
		return
	fi
	log "\nYouTube Music ($arch) version: $1"
	log "downloaded from: [APKMirror - YouTube Music (${arch})]($url)"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$2"
}

dl_twitter() {
	echo "Downloading Twitter"
	local url="https://www.apkmirror.com/apk/twitter-inc/twitter/twitter-${1//./-}-release/"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*APK</span>[^@]*@\([^#]*\).*;\1;p')"
	log "\nTwitter version: $1"
	log "downloaded from: [APKMirror - Twitter]($url)"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$2"
}

apk_last_ver() {
	req "$1" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\)</span>.*;\1;p' | grep release | head -n 1 | xargs
}

build_twitter() {
	echo "Building Twitter"
	local supported_versions last_ver
	supported_versions=$(unzip -p "$RV_PATCHES_JAR" | strings -n 8 -s , | sed -rn 's/.*twitter,versions,(([0-9.]*,*)*),Lk.*/\1/p')
	if [ -z "$supported_versions" ]; then
		last_ver=$(apk_last_ver "https://www.apkmirror.com/apk/twitter-inc/")
		echo "Choosing latest version '${last_ver}'"
	else
		echo "Supported versions of the Twitter patch: $supported_versions"
		last_ver=$(echo "$supported_versions" | awk -F, '{ print $NF }')
		echo "Choosing '${last_ver}'"
	fi
	local twitter_base_apk="${TEMP_DIR}/twitter-stock-v${last_ver}.apk"
	if [ ! -f "$twitter_base_apk" ]; then
		dl_twitter "$last_ver" "$twitter_base_apk"
	fi

	local twitter_patched_apk="twitter-revanced-v${last_ver}.apk"
	java -jar "$RV_CLI_JAR" -a "$twitter_base_apk" -c -o "$twitter_patched_apk" -b "$RV_PATCHES_JAR" --keystore=ks.keystore

	mv -f "$twitter_patched_apk" "$BUILD_DIR"
	echo "Built Twitter: '${BUILD_DIR}/${twitter_patched_apk}'"
}

build_yt() {
	echo "Building YouTube"
	reset_template
	local supported_versions last_ver
	# This only finds the supported versions of some random patch wrt the first occurance of the string but that's fine
	supported_versions=$(unzip -p "$RV_PATCHES_JAR" | strings -n 8 -s , | sed -rn 's/.*youtube,versions,(([0-9.]*,*)*),Lk.*/\1/p')
	echo "Supported versions of the YouTube patch: $supported_versions"
	last_ver=$(echo "$supported_versions" | awk -F, '{ print $NF }')
	echo "Choosing '${last_ver}'"
	local yt_base_apk="${TEMP_DIR}/yt-stock-v${last_ver}.apk"

	if [ ! -f "$yt_base_apk" ]; then
		dl_yt "$last_ver" "$yt_base_apk"
	fi

	local yt_patched_apk="${TEMP_DIR}/yt-revanced-base.apk"
	java -jar "$RV_CLI_JAR" -a "$yt_base_apk" -c -o "$yt_patched_apk" -b "$RV_PATCHES_JAR" -m "$RV_INTEGRATIONS_APK" --keystore=ks.keystore $1
	mv -f "$yt_patched_apk" "${MODULE_TEMPLATE_DIR}/base.apk"

	echo "Creating the magisk module for YouTube..."
	local output="yt-revanced-magisk-v${last_ver}-all.zip"

	service_sh "com.google.android.youtube"
	yt_module_prop "$last_ver"

	cd "$MODULE_TEMPLATE_DIR" || return
	zip -r "../$output" .
	cd ..

	mv -f "$output" "$BUILD_DIR"
	echo "Built YouTube: '${BUILD_DIR}/${output}'"
}

build_music() {
	local arch="$2"
	echo "Building YouTube Music ($arch)"
	reset_template
	local supported_versions last_ver
	# This only finds the supported versions of some random patch wrt the first occurance of the string but that's fine
	supported_versions=$(unzip -p "$RV_PATCHES_JAR" | strings -n 7 -s , | sed -rn 's/.*music,versions,(([0-9.]*,*)*),Lk.*/\1/p')
	echo "Supported versions of the Music patch: $supported_versions"
	last_ver=$(echo "$supported_versions" | awk -F, '{ print $NF }')
	echo "Choosing '${last_ver}'"
	local music_apk="${TEMP_DIR}/music-stock-v${last_ver}-${arch}.apk"

	if [ ! -f "$music_apk" ]; then
		dl_music "$last_ver" "$music_apk" "$arch"
	fi

	local music_patched_apk="${TEMP_DIR}/music-revanced-base.apk"
	java -jar "$RV_CLI_JAR" -a "$music_apk" -c -o "$music_patched_apk" -b "$RV_PATCHES_JAR" -m "$RV_INTEGRATIONS_APK" --keystore=ks.keystore $1
	mv -f "$music_patched_apk" "${MODULE_TEMPLATE_DIR}/base.apk"

	echo "Creating the magisk module for YouTube Music ($arch)"
	local output="music-revanced-magisk-v${last_ver}-${arch}.zip"

	service_sh "com.google.android.apps.youtube.music"
	music_module_prop "$last_ver" "$arch"

	cd "$MODULE_TEMPLATE_DIR" || return
	zip -r "../$output" .
	cd ..

	mv -f "$output" "$BUILD_DIR"
	echo "Built Music '${BUILD_DIR}/${output}'"
}

service_sh() {
	echo 'while [ "$(getprop sys.boot_completed)" != 1 ]; do
	sleep 1
done

YTPATH=$(pm path PACKAGE | grep base | sed "s/package://g; s/\/base.apk//g")
if [ -n "$YTPATH" ]; then
	su -c mount $MODDIR/base.apk $YTPATH/base.apk
fi' | sed "s/PACKAGE/$1/g" >"${MODULE_TEMPLATE_DIR}/service.sh"
}

yt_module_prop() {
	echo "id=ytrv-magisk
name=YouTube ReVanced
version=v${1}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=mounts base.apk for YouTube ReVanced" >"${MODULE_TEMPLATE_DIR}/module.prop"

	if [ "$ENABLE_MAGISK_UPDATE" = true ]; then
		echo "updateJson=https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/yt-update.json" >>"${MODULE_TEMPLATE_DIR}/module.prop"
	fi
}

music_module_prop() {
	local arch="$2"
	local update_json="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/music-update-${arch}.json"
	if [ "$arch" = "$ARM64_V8A" ]; then
		local id="ytmusicrv-magisk"
	elif [ "$arch" = "$ARM_V7A" ]; then
		local id="ytmusicrv-arm-magisk"
	else
		echo "Wrong arch for prop: '$arch'"
		return
	fi

	echo "id=${id}
name=YouTube Music ReVanced
version=v${1}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=mounts base.apk for YouTube Music ReVanced" >"${MODULE_TEMPLATE_DIR}/module.prop"

	if [ "$ENABLE_MAGISK_UPDATE" = true ]; then
		echo "updateJson=${update_json}" >>"${MODULE_TEMPLATE_DIR}/module.prop"
	fi
}
