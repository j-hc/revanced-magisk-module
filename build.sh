#!/usr/bin/env bash

set -eu -o pipefail

source build.conf
source utils.sh

print_usage() {
	echo -e "Usage:\n${0} build|clean|reset-template"
}

if [ -z ${1+x} ]; then
	print_usage
	exit 0
elif [ "$1" = "clean" ]; then
	rm -rf revanced-cache build.md build
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

: >build.md
mkdir -p "$BUILD_DIR" "$TEMP_DIR"

if [ "$UPDATE_PREBUILTS" = true ]; then get_prebuilts; else set_prebuilts; fi
reset_template
get_cmpr

if ((COMPRESSION_LEVEL > 9)) || ((COMPRESSION_LEVEL < 1)); then
	abort "COMPRESSION_LEVEL must be between 1 and 9"
fi

build_youtube
build_music $ARM64_V8A
build_music $ARM_V7A
build_twitter
build_reddit
build_tiktok
build_spotify
build_warn_wetter

if [ "$BUILD_MINDETACH_MODULE" = true ]; then
	echo "Building mindetach module"
	cd mindetach-magisk/mindetach/
	: >detach.txt
	if [ "${YOUTUBE_MODE%/*}" != none ]; then echo "com.google.android.youtube" >>detach.txt; fi
	if [ "${MUSIC_ARM64_V8A_MODE%/*}" != none ] || [ "${MUSIC_ARM_V7A_MODE%/*}" != none ]; then
		echo "com.google.android.apps.youtube.music" >>detach.txt
	fi
	zip -r ../../build/mindetach.zip .
	cd ../../
fi

log "\n[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"

reset_template
echo "Done"
