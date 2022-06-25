#!/bin/bash

echo "All necessary files (revanced cli, patches and integrations) will be downloaded, Youtube apk will be patched and zipped into a Magisk module"

# CURRENT VERSION
YTBASE="base-v17.24.34.apk"
OUTPUT="revanced-magisk-v17.24.34.zip"

function dl() {
	wget -q --show-progress $1 || {
		echo "Download Failed"
		exit 1
	}
}

if [[ ! -f "$YTBASE" ]]; then
	echo "$YTBASE not found in the current directory"
fi

RV_CLI_URL=$(wget -nv -O - https://api.github.com/repos/revanced/revanced-cli/releases/latest | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_CLI_JAR=$(echo $RV_CLI_URL | awk -F/ '{ print $NF }')

RV_INTEGRATIONS_URL=$(wget -nv -O - https://api.github.com/repos/revanced/revanced-integrations/releases/latest | sed -n 's/.*"browser_download_url": "\(.*apk\)".*/\1/p')
RV_INTEGRATIONS_APK=$(echo $RV_INTEGRATIONS_URL | awk -F/ '{ print $NF }')

RV_PATCHES_URL=$(wget -nv -O - https://api.github.com/repos/revanced/revanced-patches/releases/latest | sed -n 's/.*"browser_download_url": "\(.*jar\)".*/\1/p')
RV_PATCHES_JAR=$(echo $RV_PATCHES_URL | awk -F/ '{ print $NF }')

if [[ ! -f "$RV_CLI_JAR" ]]; then
	dl $RV_CLI_URL
fi
if [[ ! -f "$RV_INTEGRATIONS_APK" ]]; then
	dl $RV_INTEGRATIONS_URL
fi
if [[ ! -f "$RV_PATCHES_JAR" ]]; then
	dl $RV_PATCHES_URL
fi

java -jar $RV_CLI_JAR -a $YTBASE -c -o revanced-base.apk -b $RV_PATCHES_JAR -e microg-support -m $RV_INTEGRATIONS_APK ||
	{
		echo "Building failed"
		exit 1
	}

mv -f revanced-base.apk ./revanced-magisk/revanced-base.apk

echo "Creating the magisk module..."

cd revanced-magisk
zip -r ../$OUTPUT .

echo "Created the magisk module '$OUTPUT'"
