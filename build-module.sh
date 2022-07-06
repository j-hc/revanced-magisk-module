#!/bin/bash

set -e

if [ "$1" == "clean" ]; then
	rm -r revanced-cache *.jar *.apk *.zip *.keystore build.log
fi

PATCHER_ARGS="-e microg-support -e premium-heading"

WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"
PATCHED_APK="revanced-base.apk"

function req() {
	wget -nv -O "$2" --header="$WGET_HEADER" $1
}

# yes this is how i download the stock yt apk from apkmirror
function dl_yt() {
	URL="https://www.apkmirror.com$(req $1 - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*BUNDLE</span>[^@]*@\([^#]*\).*;\1;p')"
	log "downloaded from: $URL"
	URL="https://www.apkmirror.com$(req $URL - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	URL="https://www.apkmirror.com$(req $URL - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req $URL "$2"
}

function dl_if_dne() {
	if [ ! -f "$1" ]; then
		echo -e "\nGetting '$1' from '$2'"
		req "$2" "$1"
	fi
}

function log() {
	echo -e "$1" >>build.log
}

>build.log

log "$(date +'%Y-%m-%d')\n"

echo "All necessary files (revanced cli, patches and integrations, stock YouTube apk) will be downloaded, Youtube apk will be patched and zipped into a Magisk module"

RV_CLI_URL=$(req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_CLI_JAR=$(echo $RV_CLI_URL | awk -F/ '{ print $NF }')
log $RV_CLI_JAR

RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*apk\)".*/\1/p')
RV_INTEGRATIONS_APK=$(echo $RV_INTEGRATIONS_URL | awk '{n=split($0, arr, "/"); printf "%s-%s.apk", substr(arr[n], 0, length(arr[n]) - 4), arr[n-1]}')
log $RV_INTEGRATIONS_APK

RV_PATCHES_URL=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_PATCHES_JAR=$(echo $RV_PATCHES_URL | awk -F/ '{ print $NF }')
log $RV_PATCHES_JAR

dl_if_dne $RV_CLI_JAR $RV_CLI_URL
dl_if_dne $RV_INTEGRATIONS_APK $RV_INTEGRATIONS_URL
dl_if_dne $RV_PATCHES_JAR $RV_PATCHES_URL

# This only finds the supported versions of some random patch wrt the first occurance of the string but that's fine
SUPPORTED_VERSIONS=$(unzip -p $RV_PATCHES_JAR | strings -n 8 -s , | sed -rn 's/.*youtube,versions,(([0-9.]*,*)*),Lk.*/\1/p')
echo "Supported versions of the patch: $SUPPORTED_VERSIONS"
LAST_VER=$(echo $SUPPORTED_VERSIONS | awk -F, '{ print $NF }')
echo "Choosing '${LAST_VER}'"
log "\nYouTube version: ${LAST_VER}"
BASE_APK="base-v${LAST_VER}.apk"

if [ ! -f "$BASE_APK" ]; then
	DL_OUTPUT="yt-stock-v${LAST_VER}.zip"
	dl_yt "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${LAST_VER//./-}-release/" $DL_OUTPUT
	unzip -p $DL_OUTPUT base.apk >$BASE_APK
fi

java -jar $RV_CLI_JAR -a $BASE_APK -c -o $PATCHED_APK -b $RV_PATCHES_JAR -m $RV_INTEGRATIONS_APK $PATCHER_ARGS
mv -f $PATCHED_APK ./revanced-magisk/${PATCHED_APK}

echo "Creating the magisk module..."
OUTPUT="revanced-magisk-v${LAST_VER}.zip"
sed -i "s/version=v.*$/version=v${LAST_VER}/g" ./revanced-magisk/module.prop

cd revanced-magisk
zip -r ../$OUTPUT .

echo "Created the magisk module '${OUTPUT}'"
