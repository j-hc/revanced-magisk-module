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
	rm -r revanced-cache ./*.jar ./*.apk ./*.zip build.log build || true
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

if [ "$UPDATE_PREBUILTS" = true ]; then get_prebuilts; else set_prebuilts; fi

if [ "$BUILD_YT" = true ]; then build_yt; fi
if [ "$BUILD_MUSIC_ARM64_V8A" = true ]; then build_music "$ARM64_V8A"; fi
if [ "$BUILD_MUSIC_ARM_V7A" = true ]; then build_music "$ARM_V7A"; fi
if [ "$BUILD_TWITTER" = true ]; then build_twitter; fi
if [ "$BUILD_REDDIT" = true ]; then build_reddit; fi
if [ "$BUILD_MINDETACH_MODULE" = true ]; then
	echo "Building mindetach module"
	cd mindetach-magisk/mindetach/
	: >detach.txt
	echo "com.google.android.youtube" >>detach.txt
	echo "com.google.android.apps.youtube.music" >>detach.txt
	zip -r ../../build/mindetach.zip .
	cd ../../
fi

echo "Done"
