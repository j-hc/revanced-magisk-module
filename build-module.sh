#!/bin/bash

set -e

echo "All necessary files (revanced cli, patches and integrations, stock YouTube apk) will be downloaded, Youtube apk will be patched and zipped into a Magisk module"

WGET_HEADER='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0'

function req() {
	wget -nv --show-progress -O $2 --header="$WGET_HEADER" $1
}

# yes this is how i download the stock yt apk from apkmirror
function dl_yt() {
	URL="https://www.apkmirror.com$(req $1 - | tr '\n' ' ' | sed -n 's/href="/@/g; s;.*BUNDLE</span>[^@]*@\([^#]*\).*;\1;p')"
	URL="https://www.apkmirror.com$(req $URL - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	URL="https://www.apkmirror.com$(req $URL - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req $URL $2
}

RV_CLI_URL=$(req https://api.github.com/repos/revanced/revanced-cli/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_CLI_JAR=$(echo $RV_CLI_URL | awk -F/ '{ print $NF }')

RV_INTEGRATIONS_URL=$(req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*apk\)".*/\1/p')
RV_INTEGRATIONS_APK=$(echo $RV_INTEGRATIONS_URL | awk '{n=split($0, arr, "/"); printf "%s-%s.apk", substr(arr[n], 0, length(arr[n]) - 4), arr[n-1]}')

RV_PATCHES_URL=$(req https://api.github.com/repos/revanced/revanced-patches/releases/latest - | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_PATCHES_JAR=$(echo $RV_PATCHES_URL | awk -F/ '{ print $NF }')

if [ ! -f $RV_CLI_JAR ]; then
	req $RV_CLI_URL $RV_CLI_JAR
fi
if [ ! -f $RV_INTEGRATIONS_APK ]; then
	req $RV_INTEGRATIONS_URL $RV_INTEGRATIONS_APK
fi
if [ ! -f $RV_PATCHES_JAR ]; then
	req $RV_PATCHES_URL $RV_PATCHES_JAR
fi

SUPPORTED_VERSIONS=$(unzip -p $RV_PATCHES_JAR | strings -n 8 -s , | sed -rn 's/.*youtube,versions,(([0-9.]*,*)*),Lk.*/\1/p')
echo "Supported versions of the patch: $SUPPORTED_VERSIONS"
LAST_VER=$(echo $SUPPORTED_VERSIONS | awk -F, '{ print $NF }')
echo "Choosing $LAST_VER"
BASE_APK="base-v$LAST_VER.apk"

if [ ! -f $BASE_APK ]; then
	echo "$BASE_APK could not be found, will be downloaded from apkmirror.."
	dl_yt "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${LAST_VER//./-}-release/" yt-stock-v$LAST_VER.zip
	unzip -p yt-stock-v$LAST_VER.zip base.apk >$BASE_APK
fi

java -jar $RV_CLI_JAR -a $BASE_APK -c -o revanced-base.apk -b $RV_PATCHES_JAR -e microg-support -m $RV_INTEGRATIONS_APK
mv -f revanced-base.apk ./MMT-Extended/revanced-base.apk

echo "Creating the magisk module..."
OUTPUT="revanced-magisk-v$LAST_VER.zip"
sed -i "s/version=v.*$/version=v$LAST_VER/g" ./MMT-Extended/module.prop

cd MMT-Extended
zip -r ../$OUTPUT .

echo "Created the magisk module '$OUTPUT'"
