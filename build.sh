#!/bin/bash

set -e

source utils.sh

YT_PATCHER_ARGS="-e microg-support -e swipe-controls"
MUSIC_PATCHER_ARGS="-e microg-support"

BUILD_YT=false
BUILD_MUSIC=false
UPDATE_PREBUILTS=true

print_usage() {
	echo -e "Usage:\n${0} youtube|music|all|clean|reset-template"
}

if [ -z "$1" ]; then
	print_usage
	exit 0
elif [ "$1" == "clean" ]; then
	rm -rf ./temp ./revanced-cache ./*.jar ./*.apk ./*.zip ./*.keystore build.log
	reset_template
	exit 0
elif [ "$1" == "reset-template" ]; then
	reset_template
	exit 0
elif [ "$1" == "all" ]; then
	BUILD_YT=true
	BUILD_MUSIC=true
elif [ "$1" == "youtube" ]; then
	BUILD_YT=true
elif [ "$1" == "music" ]; then
	BUILD_MUSIC=true
elif [ "$2" == "--no-update" ]; then
	UPDATE_PREBUILTS=false
else
	print_usage
	exit 1
fi

>build.log
log "$(date +'%Y-%m-%d')\n"

if $UPDATE_PREBUILTS; then
	get_prebuilts
fi

if $BUILD_YT; then
	build_yt "$YT_PATCHER_ARGS"
fi

if $BUILD_MUSIC; then
	build_music "$MUSIC_PATCHER_ARGS"
fi

echo "Done"
