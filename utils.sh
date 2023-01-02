#!/usr/bin/env bash

source semver

MODULE_TEMPLATE_DIR="revanced-magisk"
MODULE_SCRIPTS_DIR="scripts"
TEMP_DIR="temp"
BUILD_DIR="build"
PKGS_LIST="${TEMP_DIR}/module-pkgs"

if [ "${GITHUB_TOKEN+x}" ]; then
	GH_AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
else
	GH_AUTH_HEADER=""
fi
GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-$"j-hc/revanced-magisk-module"}
NEXT_VER_CODE=${NEXT_VER_CODE:-$(date +'%Y%m%d')}
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0"
DRYRUN=false

SERVICE_SH=$(cat $MODULE_SCRIPTS_DIR/service.sh)
CUSTOMIZE_SH=$(cat $MODULE_SCRIPTS_DIR/customize.sh)
UNINSTALL_SH=$(cat $MODULE_SCRIPTS_DIR/uninstall.sh)

json_get() {
	grep -o "\"${1}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/'
}

toml_prep() {
	__TOML__=$(echo "$1" | tr -d '\t\r' | tr "'" '"' | grep -o '^[^#]*' | grep -v '^$' | sed -r 's/(\".*\")|\s*/\1/g')
}
toml_get_all_tables() {
	echo "$__TOML__" | grep -x '\[.*\]' | tr -d '[]' || return 1
}
toml_get() {
	local table=$1 key=$2
	val=$(echo "$__TOML__" | sed -n "/\[${table}]/,/^\[.*]$/p" | grep "^${key}=")
	[ "$val" ] && echo "${val#*=}" | sed -e "s/^\"//; s/\"$//"
}

#shellcheck disable=SC2034
read_main_config() {
	COMPRESSION_LEVEL=$(toml_get "main-config" compression-level)
	ENABLE_MAGISK_UPDATE=$(toml_get "main-config" enable-magisk-update)
	PARALLEL_JOBS=$(toml_get "main-config" parallel-jobs)
	UPDATE_PREBUILTS=$(toml_get "main-config" update-prebuilts)
	BUILD_MINDETACH_MODULE=$(toml_get "main-config" build-mindetach-module)
}

get_prebuilts() {
	echo "Getting prebuilts"
	RV_CLI_URL=$(gh_req https://api.github.com/repos/j-hc/revanced-cli/releases/latest - | json_get 'browser_download_url')
	RV_CLI_JAR="${TEMP_DIR}/${RV_CLI_URL##*/}"
	log "CLI: ${RV_CLI_URL##*/}"

	RV_INTEGRATIONS_URL=$(gh_req https://api.github.com/repos/revanced/revanced-integrations/releases/latest - | json_get 'browser_download_url')
	RV_INTEGRATIONS_APK=${RV_INTEGRATIONS_URL##*/}
	RV_INTEGRATIONS_APK="${RV_INTEGRATIONS_APK%.apk}-$(cut -d/ -f8 <<<"$RV_INTEGRATIONS_URL").apk"
	log "Integrations: $RV_INTEGRATIONS_APK"
	RV_INTEGRATIONS_APK="${TEMP_DIR}/${RV_INTEGRATIONS_APK}"

	RV_PATCHES=$(gh_req https://api.github.com/repos/revanced/revanced-patches/releases/latest -)
	RV_PATCHES_CHANGELOG=$(echo "$RV_PATCHES" | json_get 'body' | sed 's/\(\\n\)\+/\\n/g')
	RV_PATCHES_URL=$(echo "$RV_PATCHES" | json_get 'browser_download_url' | grep 'jar')
	RV_PATCHES_JAR="${TEMP_DIR}/${RV_PATCHES_URL##*/}"
	log "Patches: ${RV_PATCHES_URL##*/}"
	log "\n${RV_PATCHES_CHANGELOG//# [/### [}\n"

	dl_if_dne "$RV_CLI_JAR" "$RV_CLI_URL"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$RV_INTEGRATIONS_URL"
	dl_if_dne "$RV_PATCHES_JAR" "$RV_PATCHES_URL"
}

get_cmpr() {
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm64/cmpr" "https://github.com/j-hc/cmpr/releases/latest/download/cmpr-arm64-v8a"
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm/cmpr" "https://github.com/j-hc/cmpr/releases/latest/download/cmpr-armeabi-v7a"
}

abort() { echo "abort: $1" && exit 1; }

set_prebuilts() {
	[ -d "$TEMP_DIR" ] || abort "${TEMP_DIR} directory could not be found"
	RV_CLI_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-cli-*.jar" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced cli not found"
	log "CLI: ${RV_CLI_JAR#"$TEMP_DIR/"}"
	RV_INTEGRATIONS_APK=$(find "$TEMP_DIR" -maxdepth 1 -name "app-release-unsigned-*.apk" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced integrations not found"
	log "Integrations: ${RV_INTEGRATIONS_APK#"$TEMP_DIR/"}"
	RV_PATCHES_JAR=$(find "$TEMP_DIR" -maxdepth 1 -name "revanced-patches-*.jar" | tail -n1)
	[ -z "$RV_CLI_JAR" ] && abort "revanced patches not found"
	log "Patches: ${RV_PATCHES_JAR#"$TEMP_DIR/"}"
}

req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }
gh_req() { wget -nv -O "$2" --header="$GH_AUTH_HEADER" "$1"; }
log() { echo -e "$1  " >>build.md; }
get_largest_ver() {
	local max=0
	while read -r v || [ -n "$v" ]; do
		#shellcheck disable=SC2001
		if [ "$(command_compare "$(sed 's/\./-/3' <<<"$v")" "$(sed 's/\./-/3' <<<"$max")")" = 1 ]; then max=$v; fi
	done
	if [[ $max != 0 ]]; then echo "$max"; fi
}
get_patch_last_supported_ver() {
	unzip -p "$RV_PATCHES_JAR" | strings -s , | sed -rn "s/.*${1},versions,(([0-9.]*,*)*),Lk.*/\1/p" | tr ',' '\n' | get_largest_ver
}

dl_if_dne() {
	if [ ! -f "$1" ]; then
		echo -e "\nGetting '$1' from '$2'"
		req "$2" "$1"
	fi
}

# ------- apkmirror -------------
dl_apkmirror() {
	local url=$1 version=$2 regexp=$3 output=$4
	if [ $DRYRUN = true ]; then
		echo "#" >"$output"
		return
	fi
	local resp
	url="${url}/${url##*/}-${version//./-}-release/"
	resp=$(req "$url" -) || return 1
	url="https://www.apkmirror.com$(echo "$resp" | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}
get_apkmirror_vers() {
	local apkmirror_category=$1 allow_alpha_version=$2
	local vers
	# apkm_resp=$(req "https://www.apkmirror.com/uploads/?appcategory=${apkmirror_category}" -)
	# apkm_name=$(echo "$apkm_resp" | sed -n 's;.*Latest \(.*\) Uploads.*;\1;p')
	vers=$(req "https://www.apkmirror.com/uploads/?appcategory=${apkmirror_category}" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p')
	if [ "$allow_alpha_version" = false ]; then grep -i -v -e "beta" -e "alpha" <<<"$vers"; else echo "$vers"; fi
}
get_apkmirror_pkg_name() {
	req "$1" - | sed -n 's;.*id=\(.*\)" class="accent_color.*;\1;p'
}
# ------------------------------

# ------- uptodown -------------
get_uptodown_resp() {
	req "https://${1}.en.uptodown.com/android/versions" -
}
get_uptodown_vers() {
	echo "$1" | grep -x '^[0-9.]* <span>.*</span>' | sed 's/ <s.*//'
}
dl_uptodown() {
	local uptwod_resp=$1 version=$2 output=$3
	url=$(echo "$uptwod_resp" | grep "${version} <span>" -B 1 | head -1 | sed -n 's;.*data-url="\(.*\)".*;\1;p')
	url=$(req "$url" - | sed -n 's;.*data-url="\(.*\)".*;\1;p')
	req "$url" "$output"
}
get_uptodown_pkg_name() {
	local p
	p=$(req "https://${1}.en.uptodown.com/android/download" - | grep -A 1 "Package Name" | tail -1)
	echo "${p:4:-5}"
}
# ------------------------------

patch_apk() {
	local stock_input=$1 patched_apk=$2 patcher_args=$3
	declare -r tdir=$(mktemp -d -p $TEMP_DIR)
	local cmd="java -jar $RV_CLI_JAR --rip-lib x86_64 --rip-lib x86 --temp-dir=$tdir -c -a $stock_input -o $patched_apk -b $RV_PATCHES_JAR --keystore=ks.keystore $patcher_args"
	echo "$cmd"
	if [ $DRYRUN = true ]; then
		cp -f "$stock_input" "$patched_apk"
	else
		eval "$cmd"
	fi
}

zip_module() {
	local patched_apk=$1 module_name=$2 stock_apk=$3 pkg_name=$4 template_dir=$5
	cp -f "$patched_apk" "${template_dir}/base.apk"
	cp -f "$stock_apk" "${template_dir}/${pkg_name}.apk"
	cd "$template_dir" || abort "Module template dir not found"
	zip -"$COMPRESSION_LEVEL" -FSr "../../${BUILD_DIR}/${module_name}" .
	cd ../..
}

build_rv() {
	local -n args=$1
	local version patcher_args build_mode_arr pkg_name uptwod_resp
	local mode_arg=${args[build_mode]} version_mode=${args[version]}
	local app_name_l=${args[app_name],,}
	local dl_from=${args[dl_from]}
	local arch=${args[arch]}

	if [ "$mode_arg" = module ]; then
		build_mode_arr=(module)
	elif [ "$mode_arg" = apk ]; then
		build_mode_arr=(apk)
	elif [ "$mode_arg" = both ]; then
		build_mode_arr=(apk module)
	else
		echo "ERROR: undefined build mode for '${args[app_name]}': '${mode_arg}'"
		echo "    only 'both', 'apk' or 'module' are allowed"
		return 1
	fi

	for build_mode in "${build_mode_arr[@]}"; do
		patcher_args="${args[patcher_args]}"
		echo -n "Building '${args[app_name]}' (${arch}) in "
		if [ "$build_mode" = module ]; then echo "'module' mode"; else echo "'APK' mode"; fi
		if [ "${args[microg_patch]}" ]; then
			if [ "$build_mode" = module ]; then
				patcher_args="$patcher_args -e ${args[microg_patch]}"
			elif [[ "${args[patcher_args]}" = *"${args[microg_patch]}"* ]]; then
				abort "UNREACHABLE $LINENO"
			fi
		fi
		if [ "$dl_from" = apkmirror ]; then
			pkg_name=$(get_apkmirror_pkg_name "${args[apkmirror_dlurl]}")
		elif [ "$dl_from" = uptodown ]; then
			uptwod_resp=$(get_uptodown_resp "$app_name_l")
			pkg_name=$(get_uptodown_pkg_name "$app_name_l")
		fi

		local get_latest_ver=false
		if [ "$version_mode" = auto ]; then
			version=$(get_patch_last_supported_ver "$pkg_name")
			if [ -z "$version" ]; then get_latest_ver=true; fi
		elif [ "$version_mode" = latest ]; then
			get_latest_ver=true
		else
			version=$version_mode
			patcher_args="$patcher_args --experimental"
		fi
		if [ "$build_mode" = module ]; then
			if [ "${args[rip_libs]}" = true ]; then
				# --unsigned and --rip-lib is only available in my revanced-cli builds
				patcher_args="$patcher_args --unsigned --rip-lib arm64-v8a --rip-lib armeabi-v7a"
			else
				patcher_args="$patcher_args --unsigned"
			fi
		fi
		if [ $get_latest_ver = true ]; then
			local apkmvers uptwodvers
			if [ "$dl_from" = apkmirror ]; then
				apkmvers=$(get_apkmirror_vers "${args[apkmirror_dlurl]##*/}" "${args[allow_alpha_version]}")
				version=$(echo "$apkmvers" | get_largest_ver)
				[ "$version" ] || version=$(echo "$apkmvers" | head -1)
			elif [ "$dl_from" = uptodown ]; then
				uptwodvers=$(get_uptodown_vers "$uptwod_resp")
				version=$(echo "$uptwodvers" | get_largest_ver)
				[ "$version" ] || version=$(echo "$uptwodvers" | head -1)
			fi
		fi
		if [ -z "$version" ]; then
			echo "ERROR: empty version"
			return 1
		fi
		echo "Choosing version '${version}'"

		local stock_apk="${TEMP_DIR}/${app_name_l}-stock-v${version}-${arch}.apk"
		local apk_output="${BUILD_DIR}/${app_name_l}-revanced-v${version}-${arch}.apk"
		if [ "${args[microg_patch]}" ]; then
			local patched_apk="${TEMP_DIR}/${app_name_l}-revanced-v${version}-${arch}-${build_mode}.apk"
		else
			local patched_apk="${TEMP_DIR}/${app_name_l}-revanced-v${version}-${arch}.apk"
		fi
		if [ ! -f "$stock_apk" ]; then
			if [ "$dl_from" = apkmirror ]; then
				echo "Downloading '${args[app_name]}' from APKMirror"
				if ! dl_apkmirror "${args[apkmirror_dlurl]}" "$version" "${args[apkmirror_regex]}" "$stock_apk"; then
					echo "ERROR: Could not find any release of '${args[app_name]}' with the given version ('${version}') and regex"
					return 1
				fi
			elif [ "$dl_from" = uptodown ]; then
				echo "Downloading '${args[app_name]}' from Uptodown"
				if ! dl_uptodown "$uptwod_resp" "$version" "$stock_apk"; then
					echo "ERROR: Could not download ${args[app_name]}"
					return 1
				fi
			else
				abort "UNREACHABLE $LINENO"
			fi
		fi

		if [ "${arch}" = "all" ]; then
			! grep -q "${args[app_name]}:" build.md && log "${args[app_name]}: ${version}"
		else
			! grep -q "${args[app_name]} (${arch}):" build.md && log "${args[app_name]} (${arch}): ${version}"
		fi

		if [ ! -f "$patched_apk" ]; then patch_apk "$stock_apk" "$patched_apk" "$patcher_args"; fi
		if [ ! -f "$patched_apk" ]; then
			echo "BUILDING '${args[app_name]}' FAILED"
			return
		fi
		if [ "$build_mode" = apk ]; then
			cp -f "$patched_apk" "${apk_output}"
			echo "Built ${args[app_name]} (${arch}) (non-root): '${apk_output}'"
			continue
		fi
		if ! grep -q "$pkg_name" $PKGS_LIST; then echo "$pkg_name" >>$PKGS_LIST; fi

		declare -r base_template=$(mktemp -d -p $TEMP_DIR)
		cp -a $MODULE_TEMPLATE_DIR/. "$base_template"

		uninstall_sh "$pkg_name" "$base_template"
		service_sh "$pkg_name" "$version" "$base_template"
		customize_sh "$pkg_name" "$version" "$base_template"

		local upj
		upj=$([ "${arch}" = "all" ] && echo "${app_name_l}-update.json" || echo "${app_name_l}-${arch}-update.json")
		module_prop "${args[module_prop_name]}" \
			"${args[app_name]} ReVanced" \
			"$version" \
			"${args[app_name]} ReVanced Magisk module" \
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update/${upj}" \
			"$base_template"

		local module_output="${app_name_l}-revanced-magisk-v${version}-${arch}.zip"
		zip_module "$patched_apk" "$module_output" "$stock_apk" "$pkg_name" "$base_template"
		rm -rf "$base_template"

		echo "Built ${args[app_name]} (${arch}) (root): '${BUILD_DIR}/${module_output}'"
	done
}

join_args() {
	echo "$1" | tr -d '\t\r' | tr ' ' '\n' | grep -v '^$' | sed "s/^/${2} /" | paste -sd " " - || echo ""
}

uninstall_sh() { echo "${UNINSTALL_SH//__PKGNAME/$1}" >"${2}/uninstall.sh"; }
customize_sh() {
	local s="${CUSTOMIZE_SH//__PKGNAME/$1}"
	echo "${s//__PKGVER/$2}" >"${3}/customize.sh"
}
service_sh() {
	local s="${SERVICE_SH//__PKGNAME/$1}"
	echo "${s//__PKGVER/$2}" >"${3}/service.sh"
}
module_prop() {
	echo "id=${1}
name=${2}
version=v${3}
versionCode=${NEXT_VER_CODE}
author=j-hc
description=${4}" >"${6}/module.prop"

	if [ "$ENABLE_MAGISK_UPDATE" = true ]; then echo "updateJson=${5}" >>"${6}/module.prop"; fi
}
