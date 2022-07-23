#!/bin/bash

set -euo pipefail

source build.conf
source utils.sh

print_usage() {
	echo -e "Usage:\n${0} build|clean|reset-template"
}

if [ -z ${1+x} ]; then
	print_usage
	exit 0
elif [ "$1" = "clean" ]; then
	rm -rf ./temp ./revanced-cache ./*.jar ./*.apk ./*.zip ./*.keystore build.log
	reset_template
	exit 0
elif [ "$1" = "reset-template" ]; then
	reset_template
	exit 0
elif [ "$1" = "build" ]; then
	:
else
	print_usage
	exit 1
fi

: >build.log
log "$(date +'%Y-%m-%d')\n"
mkdir -p "$BUILD_DIR"

if [ "$UPDATE_PREBUILTS" = true ]; then
	get_prebuilts
else
	set_prebuilts
fi

if [ "$BUILD_YT" = true ]; then
	build_yt "$YT_PATCHER_ARGS"
fi

if [ "$BUILD_MUSIC_ARM64_V8A" = true ]; then
	build_music "$MUSIC_PATCHER_ARGS" "$ARM64_V8A"
fi

if [ "$BUILD_MUSIC_ARM_V7A" = true ]; then
	build_music "$MUSIC_PATCHER_ARGS" "$ARM_V7A"
fi

if [ "$BUILD_TWITTER" = true ]; then
	build_twitter
fi

echo "Done"
