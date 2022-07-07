#!/bin/bash

set -e

source utils.sh

BUILD_YT=false
BUILD_MUSIC=false

print_usage() {
	echo -e "Usage:\n${0} youtube|music|all|clean"
}

if [ -z "$1" ]; then
	print_usage
	exit 0
elif [ "$1" == "clean" ]; then
	rm -rf ./temp ./revanced-cache ./*.jar ./*.apk ./*.zip ./*.keystore build.log
	reset_template
	exit 0
elif [ "$1" == "all" ]; then
	BUILD_YT=true
	BUILD_MUSIC=true
elif [ "$1" == "youtube" ]; then
	BUILD_YT=true
elif [ "$1" == "music" ]; then
	BUILD_MUSIC=true
else
	print_usage
	exit 1
fi

>build.log
log "$(date +'%Y-%m-%d')\n"
get_prebuilts

if $BUILD_YT; then
	build_yt
fi

if $BUILD_MUSIC; then
	build_music
fi

echo "Done"
