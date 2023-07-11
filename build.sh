#!/usr/bin/env bash

set -euo pipefail
trap "rm -rf temp/*tmp.* temp/*/*tmp.*; exit 130" INT

if [ "${1:-}" = "clean" ]; then
	rm -rf temp build logs build.md
	exit 0
fi

source utils.sh
: >build.md

vtf() { if ! isoneof "${1}" "true" "false"; then abort "ERROR: '${1}' is not a valid option for '${2}': only true or false is allowed"; fi; }

toml_prep "$(cat 2>/dev/null "${1:-config.toml}")" || abort "could not find config file '${1:-config.toml}'\n\tUsage: $0 <config.toml>"
# -- Main config --
main_config_t=$(toml_get_table "")
COMPRESSION_LEVEL=$(toml_get "$main_config_t" compression-level) || COMPRESSION_LEVEL="9"
ENABLE_MAGISK_UPDATE=$(toml_get "$main_config_t" enable-magisk-update) || ENABLE_MAGISK_UPDATE=true
if [ "$ENABLE_MAGISK_UPDATE" = true ] && [ -z "${GITHUB_REPOSITORY:-}" ]; then
	pr "You are building locally. Magisk updates will not be enabled."
	ENABLE_MAGISK_UPDATE=false
fi
BUILD_MINDETACH_MODULE=$(toml_get "$main_config_t" build-mindetach-module) || BUILD_MINDETACH_MODULE=false
if [ "$BUILD_MINDETACH_MODULE" = true ] && [ ! -f "mindetach-magisk/mindetach/detach.txt" ]; then
	pr "mindetach module was not found."
	BUILD_MINDETACH_MODULE=false
fi
if ! PARALLEL_JOBS=$(toml_get "$main_config_t" parallel-jobs); then
	if [ "$OS" = Android ]; then PARALLEL_JOBS=1; else PARALLEL_JOBS=$(nproc); fi
fi
LOGGING_F=$(toml_get "$main_config_t" logging-to-file) && vtf "$LOGGING_F" "logging-to-file" || LOGGING_F=false
DEF_PATCHES_VER=$(toml_get "$main_config_t" patches-version) || DEF_PATCHES_VER=""
DEF_INTEGRATIONS_VER=$(toml_get "$main_config_t" integrations-version) || DEF_INTEGRATIONS_VER=""
DEF_PATCHES_SRC=$(toml_get "$main_config_t" patches-source) || DEF_PATCHES_SRC="revanced/revanced-patches"
DEF_INTEGRATIONS_SRC=$(toml_get "$main_config_t" integrations-source) || DEF_INTEGRATIONS_SRC="revanced/revanced-integrations"
DEF_RV_BRAND=$(toml_get "$main_config_t" rv-brand) || DEF_RV_BRAND="ReVanced"
# -- Main config --
mkdir -p $TEMP_DIR $BUILD_DIR

if ((COMPRESSION_LEVEL > 9)) || ((COMPRESSION_LEVEL < 0)); then abort "compression-level must be within 0-9"; fi
if [ "$BUILD_MINDETACH_MODULE" = true ]; then : >$PKGS_LIST; fi
if [ "$LOGGING_F" = true ]; then mkdir -p logs; fi

#check_deps
jq --version >/dev/null || abort "\`jq\` is not installed. install it with 'apt install jq' or equivalent"
java --version >/dev/null || abort "\`openjdk 17\` is not installed. install it with 'apt install openjdk-17-jre-headless' or equivalent"
zip --version >/dev/null || abort "\`zip\` is not installed. install it with 'apt install zip' or equivalent"
# --
get_prebuilts

set_prebuilts() {
	local integrations_src=$1 patches_src=$2 integrations_ver=$3 patches_ver=$4
	local patches_dir=${patches_src%/*}
	patches_dir=${TEMP_DIR}/${patches_dir//[^[:alnum:]]/}-rv
	local integrations_dir=${integrations_src%/*}
	integrations_dir=${TEMP_DIR}/${integrations_dir//[^[:alnum:]]/}-rv

	app_args[cli]=$(find "${TEMP_DIR}/jhc-rv" -name "revanced-cli-*.jar" -type f -print -quit 2>/dev/null) && [ "${app_args[cli]}" ] || return 1
	app_args[integ]=$(find "$integrations_dir" -name "revanced-integrations-${integrations_ver:-*}.apk" -type f -print -quit 2>/dev/null) && [ "${app_args[integ]}" ] || return 1
	app_args[ptjar]=$(find "$patches_dir" -name "revanced-patches-${patches_ver:-*}.jar" -type f -print -quit 2>/dev/null) && [ "${app_args[ptjar]}" ] || return 1
	app_args[ptjs]=$(find "$patches_dir" -name "patches-${patches_ver:-*}.json" -type f -print -quit 2>/dev/null) && [ "${app_args[ptjs]}" ] || return 1
}

build_rv_w() {
	if [ "$LOGGING_F" = true ]; then
		logf=logs/"${table_name,,}.log"
		: >"$logf"
		{ build_rv 2>&1 "$(declare -p app_args)" | tee "$logf"; } &
	else
		build_rv "$(declare -p app_args)" &
	fi
}

idx=0
for table_name in $(toml_get_table_names); do
	if [ -z "$table_name" ]; then continue; fi
	t=$(toml_get_table "$table_name")
	enabled=$(toml_get "$t" enabled) && vtf "$enabled" "enabled" || enabled=true
	if [ "$enabled" = false ]; then continue; fi

	if ((idx >= PARALLEL_JOBS)); then wait -n; else idx=$((idx + 1)); fi
	declare -A app_args
	patches_src=$(toml_get "$t" patches-source) || patches_src=$DEF_PATCHES_SRC
	patches_ver=$(toml_get "$t" patches-version) || patches_ver=$DEF_PATCHES_VER
	integrations_src=$(toml_get "$t" integrations-source) || integrations_src=$DEF_INTEGRATIONS_SRC
	integrations_ver=$(toml_get "$t" integrations-version) || integrations_ver=$DEF_INTEGRATIONS_VER
	if ! set_prebuilts "$integrations_src" "$patches_src" "$integrations_ver" "$patches_ver"; then
		read -r rv_cli_jar rv_integrations_apk rv_patches_jar rv_patches_json \
			<<<"$(get_rv_prebuilts "$integrations_src" "$patches_src" "$integrations_ver" "$patches_ver")"
		app_args[cli]=$rv_cli_jar
		app_args[integ]=$rv_integrations_apk
		app_args[ptjar]=$rv_patches_jar
		app_args[ptjs]=$rv_patches_json
	fi
	app_args[rv_brand]=$(toml_get "$t" rv-brand) || app_args[rv_brand]="$DEF_RV_BRAND"

	app_args[excluded_patches]=$(toml_get "$t" excluded-patches) || app_args[excluded_patches]=""
	app_args[included_patches]=$(toml_get "$t" included-patches) || app_args[included_patches]=""
	app_args[exclusive_patches]=$(toml_get "$t" exclusive-patches) && vtf "${app_args[exclusive_patches]}" "exclusive-patches" || app_args[exclusive_patches]=false
	app_args[version]=$(toml_get "$t" version) || app_args[version]="auto"
	app_args[app_name]=$(toml_get "$t" app-name) || app_args[app_name]=$table_name
	app_args[table]=$table_name
	app_args[build_mode]=$(toml_get "$t" build-mode) && {
		if ! isoneof "${app_args[build_mode]}" both apk module; then
			abort "ERROR: build-mode '${app_args[build_mode]}' is not a valid option for '${table_name}': only 'both', 'apk' or 'module' is allowed"
		fi
	} || app_args[build_mode]=apk
	app_args[uptodown_dlurl]=$(toml_get "$t" uptodown-dlurl) && {
		app_args[uptodown_dlurl]=${app_args[uptodown_dlurl]%/}
		app_args[uptodown_dlurl]=${app_args[uptodown_dlurl]%download}
		app_args[uptodown_dlurl]=${app_args[uptodown_dlurl]%/}
		app_args[dl_from]=uptodown
	} || app_args[uptodown_dlurl]=""
	app_args[apkmonk_dlurl]=$(toml_get "$t" apkmonk-dlurl) && {
		app_args[apkmonk_dlurl]=${app_args[apkmonk_dlurl]%/}
		app_args[dl_from]=apkmonk
	} || app_args[apkmonk_dlurl]=""
	app_args[apkmirror_dlurl]=$(toml_get "$t" apkmirror-dlurl) && {
		app_args[apkmirror_dlurl]=${app_args[apkmirror_dlurl]%/}
		app_args[dl_from]=apkmirror
	} || app_args[apkmirror_dlurl]=""
	if [ -z "${app_args[dl_from]:-}" ]; then abort "ERROR: no 'apkmirror_dlurl', 'uptodown_dlurl' or 'apkmonk_dlurl' option was set for '$table_name'."; fi
	app_args[arch]=$(toml_get "$t" apkmirror-arch) && {
		if ! isoneof "${app_args[arch]}" universal both arm64-v8a arm-v7a; then
			abort "ERROR: arch '${app_args[arch]}' is not a valid option for '${table_name}': only 'universal', 'arm64-v8a', 'arm-v7a', 'both' is allowed"
		fi
	} || app_args[arch]="universal"
	app_args[include_stock]=$(toml_get "$t" include-stock) || app_args[include_stock]=true && vtf "${app_args[include_stock]}" "include-stock"
	app_args[merge_integrations]=$(toml_get "$t" merge-integrations) || app_args[merge_integrations]=true && vtf "${app_args[merge_integrations]}" "merge-integrations"
	app_args[dpi]=$(toml_get "$t" apkmirror-dpi) || app_args[dpi]="nodpi"
	table_name_f=${table_name,,}
	table_name_f=${table_name_f// /-}
	app_args[module_prop_name]=$(toml_get "$t" module-prop-name) || app_args[module_prop_name]="${table_name_f}-jhc"

	if [ "${app_args[arch]}" = both ]; then
		app_args[table]="$table_name (arm64-v8a)"
		app_args[module_prop_name]="${app_args[module_prop_name]}-arm64"
		app_args[arch]="arm64-v8a"
		build_rv_w
		app_args[table]="$table_name (arm-v7a)"
		app_args[module_prop_name]="${app_args[module_prop_name]}-arm"
		app_args[arch]="arm-v7a"
		build_rv_w
	else
		build_rv_w
	fi
done
wait
rm -rf temp/tmp.*
if [ -z "$(ls -A1 ${BUILD_DIR})" ]; then abort "All builds failed."; fi

if [ "$BUILD_MINDETACH_MODULE" = true ]; then
	pr "Building mindetach module"
	cp -f $PKGS_LIST mindetach-magisk/mindetach/detach.txt
	pushd mindetach-magisk/mindetach/
	zip -qr ../../build/mindetach-"$(grep version= module.prop | cut -d= -f2)".zip .
	popd
fi

if youtube_t=$(toml_get_table "YouTube"); then youtube_mode=$(toml_get "$youtube_t" "build-mode") || youtube_mode="apk"; else youtube_mode="module"; fi
if music_t=$(toml_get_table "Music"); then music_mode=$(toml_get "$music_t" "build-mode") || music_mode="apk"; else music_mode="module"; fi
if [ "$youtube_mode" != module ] || [ "$music_mode" != module ]; then
	log "\nInstall [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) for non-root YouTube or YT Music"
fi
log "\n[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"
log "\n---\nChangelog:"
log "$(cat $TEMP_DIR/*-rv/changelog.md)"

pr "Done"
