#!/bin/bash

MODULE_TEMPLATE_DIR="revanced-magisk"
TEMP_DIR="temp"
GITHUB_REPO_FALLBACK="j-hc/revanced-magisk-module"

: "${GITHUB_REPOSITORY:=$GITHUB_REPO_FALLBACK}"
: "${NEXT_VER_CODE:=$(date +'%Y%m%d')}"

WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

get_prebuilts() {
	echo "Getting prebuilts"
	mkdir -p "$TEMP_DIR"
	RV_CLI_URL=$(req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*jar\)".*/\1/p')
	RV_CLI_JAR="${TEMP_DIR}/$(echo "$RV_CLI_URL" | awk -F/ '{ print $NF }')"
	log "CLI: ${RV_CLI_JAR#"$TEMP_DIR/"}  "

	RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*apk\)".*/\1/p')
	RV_INTEGRATIONS_APK="${TEMP_DIR}/$(echo "$RV_INTEGRATIONS_URL" | awk '{n=split($0, arr, "/"); printf "%s-%s.apk", substr(arr[n], 0, length(arr[n]) - 4), arr[n-1]}')"
	log "Integrations: ${RV_INTEGRATIONS_APK#"$TEMP_DIR/"}  "

	RV_PATCHES_URL=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest - | tr -d ' ' | sed -n 's/.*"browser_download_url":"\(.*jar\)".*/\1/p')
	RV_PATCHES_JAR="${TEMP_DIR}/$(echo "$RV_PATCHES_URL" | awk -F/ '{ print $NF }')"
	log "Patches: ${RV_PATCHES_JAR#"$TEMP_DIR/"}  "

	dl_if_dne "$RV_CLI_JAR" "$RV_CLI_URL"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$RV_INTEGRATIONS_URL"
	dl_if_dne "$RV_PATCHES_JAR" "$RV_PATCHES_URL"
}

reset_template() {
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/common/install.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/service.sh"
	echo "# utils" >"${MODULE_TEMPLATE_DIR}/module.prop"
	rm -f "${MODULE_TEMPLATE_DIR}/base.apk" "${MODULE_TEMPLATE_DIR}/libjsc.so"
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
	echo -e "$1" >>build.log
}

# yes this is how i download the stock yt apk from apkmirror
dl_yt() {
	echo "Downloading YouTube"
	local url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*APK</span>[^@]*@\([^#]*\).*;\1;p')"
	log "\nYouTube version: $1\ndownloaded from: [APKMirror]($url)"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$2"
}

dl_music() {
	echo "Downloading YouTube Music"
	local url="https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${1//./-}-release/"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*arm64-v8a</div>[^@]*@\([^"]*\).*;\1;p')"
	log "\nYouTube Music version: $1\ndownloaded from: [APKMirror]($url)"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$2"
}

build_yt() {
	echo "Patching YouTube"
	reset_template
	local supported_versions last_ver yt_base_apk dl_output yt_patched_apk output
	# This only finds the supported versions of some random patch wrt the first occurance of the string but that's fine
	supported_versions=$(unzip -p "$RV_PATCHES_JAR" | strings -n 8 -s , | sed -rn 's/.*youtube,versions,(([0-9.]*,*)*),Lk.*/\1/p')
	echo "Supported versions of the YouTube patch: $supported_versions"
	last_ver=$(echo "$supported_versions" | awk -F, '{ print $NF }')
	echo "Choosing '${last_ver}'"
	yt_base_apk="${TEMP_DIR}/base-v${last_ver}.apk"

	if [ ! -f "$yt_base_apk" ]; then
		dl_yt "$last_ver" "$yt_base_apk"
	fi

	yt_patched_apk="${TEMP_DIR}/yt-revanced-base.apk"
	java -jar $RV_CLI_JAR -a $yt_base_apk -c -o $yt_patched_apk -b $RV_PATCHES_JAR -m $RV_INTEGRATIONS_APK $1
	mv -f "$yt_patched_apk" "${MODULE_TEMPLATE_DIR}/base.apk"

	echo "Creating the magisk module for YouTube..."
	output="yt-revanced-magisk-v${last_ver}-all.zip"

	service_sh "com.google.android.youtube"
	yt_module_prop "$last_ver"

	cd "$MODULE_TEMPLATE_DIR" || return
	zip -r "../$output" .
	cd ..

	echo "Built YouTube: '${output}'"
}

build_music() {
	echo "Patching YouTube Music"
	reset_template
	local supported_versions last_ver music_apk music_patched_apk output
	# This only finds the supported versions of some random patch wrt the first occurance of the string but that's fine
	supported_versions=$(unzip -p "$RV_PATCHES_JAR" | strings -n 7 -s , | sed -rn 's/.*music,versions,(([0-9.]*,*)*),Lk.*/\1/p')
	echo "Supported versions of the Music patch: $supported_versions"
	last_ver=$(echo "$supported_versions" | awk -F, '{ print $NF }')
	echo "Choosing '${last_ver}'"
	music_apk="${TEMP_DIR}/music-stock-v${last_ver}.apk"

	if [ ! -f "$music_apk" ]; then
		dl_music "$last_ver" "$music_apk"
	fi

	unzip -p "$music_apk" "lib/arm64-v8a/libjsc.so" >"${MODULE_TEMPLATE_DIR}/libjsc.so"

	music_patched_apk="${TEMP_DIR}/music-revanced-base.apk"
	java -jar $RV_CLI_JAR -a $music_apk -c -o $music_patched_apk -b $RV_PATCHES_JAR -m $RV_INTEGRATIONS_APK $1
	mv -f "$music_patched_apk" "${MODULE_TEMPLATE_DIR}/base.apk"

	echo "Creating the magisk module for YouTube Music"
	output="music-revanced-magisk-v${last_ver}-arm64-v8a.zip"

	service_sh "com.google.android.apps.youtube.music"
	music_module_prop "$last_ver"
	echo 'YTPATH=$(pm path com.google.android.apps.youtube.music | grep base | sed "s/package://g; s/\/base.apk//g")
if [ -n "$YTPATH" ]; then
	cp_ch -n $MODPATH/libjsc.so $YTPATH/lib/arm64 0755
fi' >"${MODULE_TEMPLATE_DIR}/common/install.sh"

	cd "$MODULE_TEMPLATE_DIR" || return
	zip -r "../$output" .
	cd ..

	echo "Built Music '${output}'"
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
description=mounts base.apk for YouTube ReVanced
updateJson=https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/yt-update.json" >"${MODULE_TEMPLATE_DIR}/module.prop"
}

music_module_prop() {
	echo "id=ytmusicrv-magisk
name=YouTube Music ReVanced
version=v${1}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=mounts base.apk for YouTube Music ReVanced
updateJson=https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/music-update.json" >"${MODULE_TEMPLATE_DIR}/module.prop"
}
