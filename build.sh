#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob
trap "rm -rf temp/*tmp.* temp/*/*tmp.* temp/*-temporary-files; exit 130" INT

if [ "${1-}" = "clean" ]; then
	rm -rf temp build logs build.md
	exit 0
fi

source utils.sh

vtf() { if ! isoneof "${1}" "true" "false"; then abort "ERROR: '${1}' is not a valid option for '${2}': only true or false is allowed"; fi; }

toml_prep "$(cat 2>/dev/null "${1:-config.toml}")" || abort "could not find config file '${1:-config.toml}'\n\tUsage: $0 <config.toml>"
# -- Main config --
main_config_t=$(toml_get_table "")
COMPRESSION_LEVEL=$(toml_get "$main_config_t" compression-level) || COMPRESSION_LEVEL="9"
if ! PARALLEL_JOBS=$(toml_get "$main_config_t" parallel-jobs); then
	if [ "$OS" = Android ]; then PARALLEL_JOBS=1; else PARALLEL_JOBS=$(nproc); fi
fi
DEF_PATCHES_VER=$(toml_get "$main_config_t" patches-version) || DEF_PATCHES_VER=""
DEF_INTEGRATIONS_VER=$(toml_get "$main_config_t" integrations-version) || DEF_INTEGRATIONS_VER=""
DEF_CLI_VER=$(toml_get "$main_config_t" cli-version) || DEF_CLI_VER=""
DEF_PATCHES_SRC=$(toml_get "$main_config_t" patches-source) || DEF_PATCHES_SRC="ReVanced/revanced-patches"
DEF_INTEGRATIONS_SRC=$(toml_get "$main_config_t" integrations-source) || DEF_INTEGRATIONS_SRC="ReVanced/revanced-integrations"
DEF_CLI_SRC=$(toml_get "$main_config_t" cli-source) || DEF_CLI_SRC="j-hc/revanced-cli"
DEF_RV_BRAND=$(toml_get "$main_config_t" rv-brand) || DEF_RV_BRAND="ReVanced"
mkdir -p $TEMP_DIR $BUILD_DIR

if [ "${2-}" = "--config-update" ]; then
	config_update
	exit 0
fi

: >build.md
ENABLE_MAGISK_UPDATE=$(toml_get "$main_config_t" enable-magisk-update) || ENABLE_MAGISK_UPDATE=true
if [ "$ENABLE_MAGISK_UPDATE" = true ] && [ -z "${GITHUB_REPOSITORY-}" ]; then
	pr "You are building locally. Magisk updates will not be enabled."
	ENABLE_MAGISK_UPDATE=false
fi
# -----------------

if ((COMPRESSION_LEVEL > 9)) || ((COMPRESSION_LEVEL < 0)); then abort "compression-level must be within 0-9"; fi

# -- check_deps --
jq --version >/dev/null || abort "\`jq\` is not installed. install it with 'apt install jq' or equivalent"
java --version >/dev/null || abort "\`openjdk 17\` is not installed. install it with 'apt install openjdk-17-jre' or equivalent"
zip --version >/dev/null || abort "\`zip\` is not installed. install it with 'apt install zip' or equivalent"
# ----------------
rm -rf revanced-magisk/bin/*/tmp.*
get_prebuilts

set_prebuilts() {
	local integrations_src=$1 patches_src=$2 cli_src=$3 integrations_ver=$4 patches_ver=$5 cli_ver=$6
	local patches_dir=${patches_src%/*}
	local integrations_dir=${integrations_src%/*}
	local cli_dir=${cli_src%/*}
	cli_ver=${cli_ver#v}
	integrations_ver="${integrations_ver#v}"
	patches_ver="${patches_ver#v}"
	app_args[cli]=$(find "${TEMP_DIR}/${cli_dir,,}-rv" -name "revanced-cli-${cli_ver:-*}-all.jar" -type f -print -quit 2>/dev/null) && [ "${app_args[cli]}" ] || return 1
	app_args[integ]=$(find "${TEMP_DIR}/${integrations_dir,,}-rv" -name "revanced-integrations-${integrations_ver:-*}.apk" -type f -print -quit 2>/dev/null) && [ "${app_args[integ]}" ] || return 1
	app_args[ptjar]=$(find "${TEMP_DIR}/${patches_dir,,}-rv" -name "revanced-patches-${patches_ver:-*}.jar" -type f -print -quit 2>/dev/null) && [ "${app_args[ptjar]}" ] || return 1
	app_args[ptjs]=$(find "${TEMP_DIR}/${patches_dir,,}-rv" -name "patches-${patches_ver:-*}.json" -type f -print -quit 2>/dev/null) && [ "${app_args[ptjs]}" ] || return 1
}

declare -A cliriplib
idx=0
for table_name in $(toml_get_table_names); do
	if [ -z "$table_name" ]; then continue; fi
	t=$(toml_get_table "$table_name")
	enabled=$(toml_get "$t" enabled) && vtf "$enabled" "enabled" || enabled=true
	if [ "$enabled" = false ]; then continue; fi
	if ((idx >= PARALLEL_JOBS)); then
		wait -n
		idx=$((idx - 1))
	fi

	declare -A app_args
	patches_src=$(toml_get "$t" patches-source) || patches_src=$DEF_PATCHES_SRC
	patches_ver=$(toml_get "$t" patches-version) || patches_ver=$DEF_PATCHES_VER
	integrations_src=$(toml_get "$t" integrations-source) || integrations_src=$DEF_INTEGRATIONS_SRC
	integrations_ver=$(toml_get "$t" integrations-version) || integrations_ver=$DEF_INTEGRATIONS_VER
	cli_src=$(toml_get "$t" cli-source) || cli_src=$DEF_CLI_SRC
	cli_ver=$(toml_get "$t" cli-version) || cli_ver=$DEF_CLI_VER

	if ! set_prebuilts "$integrations_src" "$patches_src" "$cli_src" "$integrations_ver" "$patches_ver" "$cli_ver"; then
		if ! RVP="$(get_rv_prebuilts "$cli_src" "$cli_ver" "$integrations_src" "$integrations_ver" "$patches_src" "$patches_ver")"; then
			abort "could not download rv prebuilts"
		fi
		read -r rv_cli_jar rv_integrations_apk rv_patches_jar rv_patches_json <<<"$RVP"
		app_args[cli]=$rv_cli_jar
		app_args[integ]=$rv_integrations_apk
		app_args[ptjar]=$rv_patches_jar
		app_args[ptjs]=$rv_patches_json
	fi
	if [[ -v cliriplib[${app_args[cli]}] ]]; then app_args[riplib]=${cliriplib[${app_args[cli]}]}; else
		if [[ $(java -jar "${app_args[cli]}" patch 2>&1) == *rip-lib* ]]; then
			cliriplib[${app_args[cli]}]=true
			app_args[riplib]=true
		else
			cliriplib[${app_args[cli]}]=false
			app_args[riplib]=false
		fi
	fi
	if [ "${app_args[riplib]}" = "true" ] && [ "$(toml_get "$t" riplib)" = "false" ]; then app_args[riplib]=false; fi
	app_args[rv_brand]=$(toml_get "$t" rv-brand) || app_args[rv_brand]="$DEF_RV_BRAND"

	app_args[excluded_patches]=$(toml_get "$t" excluded-patches) || app_args[excluded_patches]=""
	if [ -n "${app_args[excluded_patches]}" ] && [[ ${app_args[excluded_patches]} != *'"'* ]]; then abort "patch names inside excluded-patches must be quoted"; fi
	app_args[included_patches]=$(toml_get "$t" included-patches) || app_args[included_patches]=""
	if [ -n "${app_args[included_patches]}" ] && [[ ${app_args[included_patches]} != *'"'* ]]; then abort "patch names inside included-patches must be quoted"; fi
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
	app_args[apkmirror_dlurl]=$(toml_get "$t" apkmirror-dlurl) && {
		app_args[apkmirror_dlurl]=${app_args[apkmirror_dlurl]%/}
		app_args[dl_from]=apkmirror
	} || app_args[apkmirror_dlurl]=""
	app_args[archive_dlurl]=$(toml_get "$t" archive-dlurl) && {
		app_args[archive_dlurl]=${app_args[archive_dlurl]%/}
		app_args[dl_from]=archive
	} || app_args[archive_dlurl]=""
	if [ -z "${app_args[dl_from]-}" ]; then abort "ERROR: no 'apkmirror_dlurl', 'uptodown_dlurl' or 'archive_dlurl' option was set for '$table_name'."; fi
	app_args[arch]=$(toml_get "$t" arch) || app_args[arch]="all"
	if [ "${app_args[arch]}" != "both" ] && [ "${app_args[arch]}" != "all" ] && [[ ${app_args[arch]} != "arm64-v8a"* ]] && [[ ${app_args[arch]} != "arm-v7a"* ]]; then
		abort "wrong arch '${app_args[arch]}' for '$table_name'"
	fi

	app_args[include_stock]=$(toml_get "$t" include-stock) || app_args[include_stock]=true && vtf "${app_args[include_stock]}" "include-stock"
	app_args[dpi]=$(toml_get "$t" apkmirror-dpi) || app_args[dpi]="nodpi"
	table_name_f=${table_name,,}
	table_name_f=${table_name_f// /-}
	app_args[module_prop_name]=$(toml_get "$t" module-prop-name) || {
		app_args[module_prop_name]="${table_name_f}-jhc"
		if [ "${app_args[arch]}" = "arm64-v8a" ]; then
			app_args[module_prop_name]="${app_args[module_prop_name]}-arm64"
		elif [ "${app_args[arch]}" = "arm-v7a" ]; then
			app_args[module_prop_name]="${app_args[module_prop_name]}-arm"
		fi
	}

	if [ "${app_args[arch]}" = both ]; then
		app_args[table]="$table_name (arm64-v8a)"
		app_args[arch]="arm64-v8a"
		app_args[module_prop_name]="${app_args[module_prop_name]}-arm64"
		idx=$((idx + 1))
		build_rv "$(declare -p app_args)" &
		app_args[table]="$table_name (arm-v7a)"
		app_args[arch]="arm-v7a"
		app_args[module_prop_name]="${app_args[module_prop_name]}-arm"
		if ((idx >= PARALLEL_JOBS)); then
			wait -n
			idx=$((idx - 1))
		fi
		idx=$((idx + 1))
		build_rv "$(declare -p app_args)" &
	else
		idx=$((idx + 1))
		build_rv "$(declare -p app_args)" &
	fi
done
wait
rm -rf temp/tmp.*
if [ -z "$(ls -A1 ${BUILD_DIR})" ]; then abort "All builds failed."; fi

log "\nInstall [Microg](https://github.com/ReVanced/GmsCore/releases) for non-root YouTube and YT Music APKs"
log "Use [zygisk-detach](https://github.com/j-hc/zygisk-detach) to detach root ReVanced YouTube and YT Music from Play Store"
log "\n[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)\n"
log "$(cat $TEMP_DIR/*-rv/changelog.md)"

SKIPPED=$(cat $TEMP_DIR/skipped 2>/dev/null || :)
if [ -n "$SKIPPED" ]; then
	log "\nSkipped:"
	log "$SKIPPED"
fi

pr "Done"
