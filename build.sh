#!/usr/bin/env bash

set -euo pipefail

source utils.sh
trap "rm -rf temp/tmp.*" INT

: >build.md
mkdir -p "$BUILD_DIR" "$TEMP_DIR"

toml_prep "$(cat 2>/dev/null "${1:-config.toml}")" || abort "could not find config file '${1}'"
main_config_t=$(toml_get_table "")
COMPRESSION_LEVEL=$(toml_get "$main_config_t" compression-level)
ENABLE_MAGISK_UPDATE=$(toml_get "$main_config_t" enable-magisk-update)
PARALLEL_JOBS=$(toml_get "$main_config_t" parallel-jobs)
UPDATE_PREBUILTS=$(toml_get "$main_config_t" update-prebuilts)
BUILD_MINDETACH_MODULE=$(toml_get "$main_config_t" build-mindetach-module)

if ((COMPRESSION_LEVEL > 9)) || ((COMPRESSION_LEVEL < 0)); then abort "compression-level must be from 0 to 9"; fi
if [ "$UPDATE_PREBUILTS" = true ]; then get_prebuilts; else set_prebuilts; fi
if [ "$BUILD_MINDETACH_MODULE" = true ]; then : >$PKGS_LIST; fi
jq --version >/dev/null || abort "\`jq\` is not installed. install it with 'apt install jq' or equivalent"
get_cmpr

log "**App Versions:**"
idx=0
for table_name in $(toml_get_table_names); do
	if [ -z "$table_name" ]; then continue; fi
	t=$(toml_get_table "$table_name")
	enabled=$(toml_get "$t" enabled) || enabled=true
	if [ "$enabled" = false ]; then continue; fi

	if ((idx >= PARALLEL_JOBS)); then wait -n; else idx=$((idx + 1)); fi
	declare -A app_args
	merge_integrations=$(toml_get "$t" merge-integrations) || merge_integrations=false
	excluded_patches=$(toml_get "$t" excluded-patches) || excluded_patches=""
	included_patches=$(toml_get "$t" included-patches) || included_patches=""
	exclusive_patches=$(toml_get "$t" exclusive-patches) || exclusive_patches=false
	app_args[version]=$(toml_get "$t" version) || app_args[version]="auto"
	app_args[app_name]=$(toml_get "$t" app-name) || app_args[app_name]=$table_name
	app_args[allow_alpha_version]=$(toml_get "$t" allow-alpha-version) || app_args[allow_alpha_version]=false
	app_args[build_mode]=$(toml_get "$t" build-mode) || app_args[build_mode]=apk
	app_args[microg_patch]=$(toml_get "$t" microg-patch) || app_args[microg_patch]=""
	app_args[uptodown_dlurl]=$(toml_get "$t" uptodown-dlurl) && app_args[uptodown_dlurl]=${app_args[uptodown_dlurl]%/} || app_args[uptodown_dlurl]=""
	app_args[apkmirror_dlurl]=$(toml_get "$t" apkmirror-dlurl) && app_args[apkmirror_dlurl]=${app_args[apkmirror_dlurl]%/} || app_args[apkmirror_dlurl]=""

	app_args[arch]=$(toml_get "$t" arch) || app_args[arch]="all"
	app_args[module_prop_name]=$(toml_get "$t" module-prop-name) || {
		app_name_l=${app_args[app_name],,}
		app_args[module_prop_name]=$([ "${app_args[arch]}" = "all" ] && echo "${app_name_l}-rv-jhc-magisk" || echo "${app_name_l}-${app_args[arch]}-rv-jhc-magisk")
	}
	if [ "${app_args[arch]}" = "all" ]; then
		app_args[apkmirror_regex]="APK</span>[^@]*@\([^#]*\)"
	elif [ "${app_args[arch]}" = "arm64-v8a" ]; then
		app_args[apkmirror_regex]='arm64-v8a</div>[^@]*@\([^"]*\)'
	elif [ "${app_args[arch]}" = "arm-v7a" ]; then
		app_args[apkmirror_regex]='armeabi-v7a</div>[^@]*@\([^"]*\)'
	fi
	if [ "${app_args[apkmirror_dlurl]:-}" ] && [ "${app_args[apkmirror_regex]:-}" ]; then app_args[dl_from]=apkmirror; else app_args[dl_from]=uptodown; fi

	app_args[patcher_args]="$(join_args "${excluded_patches}" -e) $(join_args "${included_patches}" -i)"
	[ "$merge_integrations" = true ] && app_args[patcher_args]="${app_args[patcher_args]} -m ${RV_INTEGRATIONS_APK}"
	[ "$exclusive_patches" = true ] && app_args[patcher_args]="${app_args[patcher_args]} --exclusive"

	build_rv app_args &
done
wait

rm -rf temp/tmp.*

if [ "$BUILD_MINDETACH_MODULE" = true ]; then
	echo "Building mindetach module"
	cp -f $PKGS_LIST mindetach-magisk/mindetach/detach.txt
	pushd mindetach-magisk/mindetach/
	zip -r ../../build/mindetach-"$(grep version= module.prop | cut -d= -f2)".zip .
	popd
fi

youtube_mode=$(toml_get "$(toml_get_table "YouTube")" "build-mode") || youtube_mode="module"
music_arm_mode=$(toml_get "$(toml_get_table "Music-arm")" "build-mode") || music_arm_mode="module"
music_arm64_mode=$(toml_get "$(toml_get_table "Music-arm64")" "build-mode") || music_arm64_mode="module"
if [ "$youtube_mode" != module ] || [ "$music_arm_mode" != module ] || [ "$music_arm64_mode" != module ]; then
	log "\nInstall [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) to be able to use non-root YouTube or Music"
fi
log "\n[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"

echo "Done"
