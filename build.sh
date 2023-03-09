#!/usr/bin/env bash

set -euo pipefail
trap "rm -rf temp/tmp.*; exit 1" INT

if [ "${1:-}" = "clean" ]; then
	rm -rf temp build logs
	exit 0
fi

source utils.sh

: >build.md

vtf() {
	if ! isoneof "${1}" "true" "false"; then
		abort "ERROR: '${1}' is not a valid option for '${2}': only true or false is allowed"
	fi
}

toml_prep "$(cat 2>/dev/null "${1:-config.toml}")" || abort "could not find config file '${1}'"

# -- Main config --
main_config_t=$(toml_get_table "")
COMPRESSION_LEVEL=$(toml_get "$main_config_t" compression-level) || abort "ERROR: compression-level is missing"
ENABLE_MAGISK_UPDATE=$(toml_get "$main_config_t" enable-magisk-update) || abort "ERROR: enable-magisk-update is missing"
if [ "$ENABLE_MAGISK_UPDATE" = true ] && [ -z "${GITHUB_REPOSITORY:-}" ]; then
	pr "You are building locally. Magisk updates will not be enabled."
	ENABLE_MAGISK_UPDATE=false
fi
PARALLEL_JOBS=$(toml_get "$main_config_t" parallel-jobs) || PARALLEL_JOBS=1
BUILD_MINDETACH_MODULE=$(toml_get "$main_config_t" build-mindetach-module) || abort "ERROR: build-mindetach-module is missing"
LOGGING_F=$(toml_get "$main_config_t" logging-to-file) && vtf "$LOGGING_F" "logging-to-file" || LOGGING_F=false
CONF_PATCHES_VER=$(toml_get "$main_config_t" patches-version) || CONF_PATCHES_VER=
CONF_INTEGRATIONS_VER=$(toml_get "$main_config_t" integrations-version) || CONF_INTEGRATIONS_VER=

PATCHES_SRC=$(toml_get "$main_config_t" patches-source) || PATCHES_SRC="revanced/revanced-patches"
INTEGRATIONS_SRC=$(toml_get "$main_config_t" integrations-source) || INTEGRATIONS_SRC="revanced/revanced-integrations"
RV_BRAND=$(toml_get "$main_config_t" rv-brand) || RV_BRAND="ReVanced"
RV_BRAND_F=${RV_BRAND,,}
RV_BRAND_F=${RV_BRAND_F// /-}
PREBUILTS_DIR="${TEMP_DIR}/tools-${RV_BRAND_F}"
mkdir -p "$BUILD_DIR" "$PREBUILTS_DIR"
# -- Main config --

if ((COMPRESSION_LEVEL > 9)) || ((COMPRESSION_LEVEL < 0)); then abort "compression-level must be from 0 to 9"; fi
if [ "${NOSET:-}" = true ]; then set_prebuilts; else get_prebuilts || set_prebuilts; fi
if [ "$BUILD_MINDETACH_MODULE" = true ]; then : >$PKGS_LIST; fi
if [ "$LOGGING_F" = true ]; then mkdir -p logs; fi
jq --version >/dev/null || abort "\`jq\` is not installed. install it with 'apt install jq' or equivalent"

log "**App Versions:**"
idx=0
for table_name in $(toml_get_table_names); do
	if [ -z "$table_name" ]; then continue; fi
	t=$(toml_get_table "$table_name")
	enabled=$(toml_get "$t" enabled) && vtf "$enabled" "enabled" || enabled=true
	if [ "$enabled" = false ]; then continue; fi

	if ((idx >= PARALLEL_JOBS)); then wait -n; else idx=$((idx + 1)); fi
	declare -A app_args
	app_args[excluded_patches]=$(toml_get "$t" excluded-patches) || app_args[excluded_patches]=""
	app_args[included_patches]=$(toml_get "$t" included-patches) || app_args[included_patches]=""
	app_args[exclusive_patches]=$(toml_get "$t" exclusive-patches) && vtf "${app_args[exclusive_patches]}" "exclusive-patches" || app_args[exclusive_patches]=false
	app_args[version]=$(toml_get "$t" version) || app_args[version]="auto"
	app_args[app_name]=$(toml_get "$t" app-name) || app_args[app_name]=$table_name
	app_args[allow_alpha_version]=$(toml_get "$t" allow-alpha-version) && vtf "${app_args[allow_alpha_version]}" "allow-alpha-version" || app_args[allow_alpha_version]=false
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
	if [ -z "${app_args[dl_from]:-}" ]; then
		abort "ERROR: no 'apkmirror_dlurl', 'uptodown_dlurl', 'apkmonk_dlurl' were set for '$table_name'."
	fi
	app_args[arch]=$(toml_get "$t" arch) && {
		if ! isoneof "${app_args[arch]}" all arm64-v8a arm-v7a; then
			abort "ERROR: arch '${app_args[arch]}' is not a valid option for '${table_name}': only 'all', 'arm64-v8a', 'arm-v7a' is allowed"
		fi
	} || app_args[arch]="all"
	app_args[merge_integrations]=$(toml_get "$t" merge-integrations) || app_args[merge_integrations]=false
	app_args[dpi]=$(toml_get "$t" dpi) || app_args[dpi]="nodpi"
	app_args[module_prop_name]=$(toml_get "$t" module-prop-name) || {
		app_name_l=${app_args[app_name],,}
		if [ "${app_args[arch]}" = "all" ]; then
			app_args[module_prop_name]="${app_name_l}-${RV_BRAND_F}-jhc"
		else
			app_args[module_prop_name]="${app_name_l}-${app_args[arch]}-${RV_BRAND_F}-jhc"
		fi
	}
	if [ "$LOGGING_F" = true ]; then
		logf=logs/"${table_name,,}.log"
		: >"$logf"
		{ build_rv 2>&1 app_args | tee "$logf"; } &
	else
		build_rv app_args &
	fi
done
wait
rm -rf temp/tmp.*

if [ "$BUILD_MINDETACH_MODULE" = true ]; then
	pr "Building mindetach module"
	cp -f $PKGS_LIST mindetach-magisk/mindetach/detach.txt
	pushd mindetach-magisk/mindetach/
	zip -qr ../../build/mindetach-"$(grep version= module.prop | cut -d= -f2)".zip .
	popd
fi

youtube_mode=$(toml_get "$(toml_get_table "YouTube")" "build-mode") || youtube_mode="module"
music_arm_mode=$(toml_get "$(toml_get_table "Music-arm")" "build-mode") || music_arm_mode="module"
music_arm64_mode=$(toml_get "$(toml_get_table "Music-arm64")" "build-mode") || music_arm64_mode="module"
if [ "$youtube_mode" != module ] || [ "$music_arm_mode" != module ] || [ "$music_arm64_mode" != module ]; then
	log "\nInstall [Vanced Microg](https://github.com/TeamVanced/VancedMicroG/releases) to be able to use non-root YouTube or Music"
fi
log "\n[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)"

pr "Done"
