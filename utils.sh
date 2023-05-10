#!/usr/bin/env bash

MODULE_TEMPLATE_DIR="revanced-magisk"
MODULE_SCRIPTS_DIR="scripts"
TEMP_DIR="temp"
BUILD_DIR="build"
PKGS_LIST="${TEMP_DIR}/module-pkgs"

if [ "${GITHUB_TOKEN:-}" ]; then GH_HEADER="Authorization: token ${GITHUB_TOKEN}"; else GH_HEADER=; fi
NEXT_VER_CODE=${NEXT_VER_CODE:-$(date +'%Y%m%d')}
REBUILD=false
OS=$(uname -o)

SERVICE_SH=$(cat $MODULE_SCRIPTS_DIR/service.sh)
CUSTOMIZE_SH=$(cat $MODULE_SCRIPTS_DIR/customize.sh)
UNINSTALL_SH=$(cat $MODULE_SCRIPTS_DIR/uninstall.sh)

# -------------------- json/toml --------------------
json_get() { grep -o "\"${1}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/'; }
toml_prep() { __TOML__=$(tr -d '\t\r' <<<"$1" | tr "'" '"' | grep -o '^[^#]*' | grep -v '^$' | sed -r 's/(\".*\")|\s*/\1/g; 1i []'); }
toml_get_table_names() {
	local tn
	tn=$(grep -x '\[.*\]' <<<"$__TOML__" | tr -d '[]') || return 1
	if [ "$(sort <<<"$tn" | uniq -u | wc -l)" != "$(wc -l <<<"$tn")" ]; then
		abort "ERROR: Duplicate tables in TOML"
	fi
	echo "$tn"
}
toml_get_table() { sed -n "/\[${1}]/,/^\[.*]$/p" <<<"$__TOML__"; }
toml_get() {
	local table=$1 key=$2 val
	val=$(grep -m 1 "^${key}=" <<<"$table") && sed -e "s/^\"//; s/\"$//" <<<"${val#*=}"
}
# ---------------------------------------------------

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
epr() {
	echo >&2 -e "\033[0;31m[-] ${1}\033[0m"
	if [ "${GITHUB_REPOSITORY:-}" ]; then echo -e "::error::utils.sh [-] ${1}\n"; fi
}
abort() {
	epr "ABORT: ${1:-}"
	exit 1
}

get_prebuilts() {
	pr "Getting prebuilts"
	local rv_cli_url rv_integrations_url rv_patches rv_patches_changelog rv_patches_dl rv_patches_url rv_integrations_rel rv_patches_rel
	rv_cli_url=$(gh_req "https://api.github.com/repos/j-hc/revanced-cli/releases/latest" - | json_get 'browser_download_url') || return 1
	RV_CLI_JAR="${PREBUILTS_DIR}/${rv_cli_url##*/}"
	log "CLI: ${rv_cli_url##*/}"

	if [ "$CONF_INTEGRATIONS_VER" ]; then
		rv_integrations_rel="https://api.github.com/repos/${INTEGRATIONS_SRC}/releases/tags/${CONF_INTEGRATIONS_VER}"
	else
		rv_integrations_rel="https://api.github.com/repos/${INTEGRATIONS_SRC}/releases/latest"
	fi
	if [ "$CONF_PATCHES_VER" ]; then
		rv_patches_rel="https://api.github.com/repos/${PATCHES_SRC}/releases/tags/${CONF_PATCHES_VER}"
	else
		rv_patches_rel="https://api.github.com/repos/${PATCHES_SRC}/releases/latest"
	fi

	rv_integrations_url=$(gh_req "$rv_integrations_rel" - | json_get 'browser_download_url')
	RV_INTEGRATIONS_APK="${PREBUILTS_DIR}/${rv_integrations_url##*/}"
	log "Integrations: ${rv_integrations_url##*/}"

	rv_patches=$(gh_req "$rv_patches_rel" -)
	rv_patches_changelog=$(json_get 'body' <<<"$rv_patches" | sed 's/\(\\n\)\+/\\n/g')
	rv_patches_dl=$(json_get 'browser_download_url' <<<"$rv_patches")
	RV_PATCHES_JSON="${PREBUILTS_DIR}/patches-$(json_get 'tag_name' <<<"$rv_patches").json"
	rv_patches_url=$(grep 'jar' <<<"$rv_patches_dl")
	RV_PATCHES_JAR="${PREBUILTS_DIR}/${rv_patches_url##*/}"
	[ -f "$RV_PATCHES_JAR" ] || REBUILD=true
	log "Patches: ${rv_patches_url##*/}"
	log "\n${rv_patches_changelog//# [/### [}\n"

	dl_if_dne "$RV_CLI_JAR" "$rv_cli_url"
	dl_if_dne "$RV_INTEGRATIONS_APK" "$rv_integrations_url"
	dl_if_dne "$RV_PATCHES_JAR" "$rv_patches_url"
	dl_if_dne "$RV_PATCHES_JSON" "$(grep 'json' <<<"$rv_patches_dl")"

	if [ "$OS" = Android ]; then
		local arch
		if [ "$(uname -m)" = aarch64 ]; then arch=arm64; else arch=arm; fi
		dl_if_dne ${TEMP_DIR}/aapt2 https://github.com/rendiix/termux-aapt/raw/d7d4b4a344cc52b94bcdab3500be244151261d8e/prebuilt-binary/${arch}/aapt2
	fi
	mkdir -p ${MODULE_TEMPLATE_DIR}/bin/arm64 ${MODULE_TEMPLATE_DIR}/bin/arm
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm64/cmpr" "https://github.com/j-hc/cmpr/releases/latest/download/cmpr-arm64-v8a"
	dl_if_dne "${MODULE_TEMPLATE_DIR}/bin/arm/cmpr" "https://github.com/j-hc/cmpr/releases/latest/download/cmpr-armeabi-v7a"

	HTMLQ="${TEMP_DIR}/htmlq"
	if [ ! -f "${TEMP_DIR}/htmlq" ]; then
		if [ "$OS" = Android ]; then
			if [ "$arch" = arm64 ]; then
				arch=arm64-v8a
			else
				arch=armeabi-v7a
			fi
			dl_if_dne ${TEMP_DIR}/htmlq https://github.com/j-hc/htmlq-ndk/releases/latest/download/htmlq-${arch}
			chmod +x $HTMLQ
		else
			req "https://github.com/mgdm/htmlq/releases/latest/download/htmlq-x86_64-linux.tar.gz" "${TEMP_DIR}/htmlq.tar.gz"
			tar -xf "${TEMP_DIR}/htmlq.tar.gz" -C "$TEMP_DIR"
			rm "${TEMP_DIR}/htmlq.tar.gz"
		fi

	fi
}

set_prebuilts() {
	[ -d "$PREBUILTS_DIR" ] || abort "${PREBUILTS_DIR} directory could not be found"
	RV_CLI_JAR=$(find "$PREBUILTS_DIR" -maxdepth 1 -name "revanced-cli-*.jar" | tail -n1)
	[ "$RV_CLI_JAR" ] || abort "revanced cli not found"
	log "CLI: ${RV_CLI_JAR#"$PREBUILTS_DIR/"}"
	RV_INTEGRATIONS_APK=$(find "$PREBUILTS_DIR" -maxdepth 1 -name "revanced-integrations-*.apk" | tail -n1)
	[ "$RV_INTEGRATIONS_APK" ] || abort "revanced integrations not found"
	log "Integrations: ${RV_INTEGRATIONS_APK#"$PREBUILTS_DIR/"}"
	RV_PATCHES_JAR=$(find "$PREBUILTS_DIR" -maxdepth 1 -name "revanced-patches-*.jar" | tail -n1)
	[ "$RV_PATCHES_JAR" ] || abort "revanced patches not found"
	log "Patches: ${RV_PATCHES_JAR#"$PREBUILTS_DIR/"}"
	RV_PATCHES_JSON=$(find "$PREBUILTS_DIR" -maxdepth 1 -name "patches-*.json" | tail -n1)
	[ "$RV_PATCHES_JSON" ] || abort "patches.json not found"
	HTMLQ="${TEMP_DIR}/htmlq"
}

_req() {
	if [ "$2" = - ]; then
		wget -nv -O "$2" --header="$3" "$1"
	else
		local dlp
		dlp="$(dirname "$2")/tmp.$(basename "$2")"
		wget -nv -O "$dlp" --header="$3" "$1"
		mv -f "$dlp" "$2"
	fi
}
req() { _req "$1" "$2" "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0"; }
gh_req() { _req "$1" "$2" "$GH_HEADER"; }

log() { echo -e "$1  " >>build.md; }
get_largest_ver() {
	local vers m
	vers=$(tee)
	m=$(head -1 <<<"$vers")
	if ! semver_validate "$m"; then echo "$m"; else sort -rV <<<"$vers" | head -1; fi
}
semver_validate() {
	local a="${1%-*}"
	local ac="${a//[.0-9]/}"
	[ ${#ac} = 0 ]
}
get_patch_last_supported_ver() {
	local inc_sel exc_sel
	inc_sel=$(list_args "$2" | sed 's/.*/\.name == "&"/' | paste -sd '~' | sed 's/~/ or /g' || :)
	exc_sel=$(list_args "$3" | sed 's/.*/\.name != "&"/' | paste -sd '~' | sed 's/~/ and /g' || :)
	inc_sel=${inc_sel:-false}
	if [ "$4" = false ]; then inc_sel="${inc_sel} or .excluded==false"; fi
	jq -r ".[]
			| select(.compatiblePackages[].name==\"${1}\")
			| select(${inc_sel})
			| select(${exc_sel:-true})
			| .compatiblePackages[].versions" "$RV_PATCHES_JSON" |
		tr -d ' ,\t[]"' | grep -v '^$' | sort | uniq -c | sort -nr | head -1 | xargs | cut -d' ' -f2 || return 1
}

dl_if_dne() {
	if [ ! -f "$1" ]; then
		pr "Getting '$1' from '$2'"
		req "$2" "$1"
	fi
}

isoneof() {
	local i=$1 v
	shift
	for v; do [ "$v" = "$i" ] && return 0; done
	return 1
}

# -------------------- apkmirror --------------------
dl_apkmirror() {
	local url=$1 version=${2// /-} output=$3 apkorbundle=$4 arch=$5 dpi=$6
	[ "${DRYRUN:-}" ] && {
		echo >"$output"
		return 0
	}
	local resp node app_table dlurl=""
	[ "$arch" = universal ] && apparch=(universal noarch 'arm64-v8a + armeabi-v7a') || apparch=("$arch")
	url="${url}/${url##*/}-${version//./-}-release/"
	resp=$(req "$url" -) || return 1
	for ((n = 2; n < 40; n++)); do
		node=$($HTMLQ "div.table-row:nth-child($n)" -r "span:nth-child(n+3)" <<<"$resp")
		if [ -z "$node" ]; then break; fi
		app_table=$($HTMLQ --text --ignore-whitespace <<<"$node")
		if [ "$(sed -n 3p <<<"$app_table")" = "$apkorbundle" ] && { [ "$apkorbundle" = BUNDLE ] ||
			{ [ "$apkorbundle" = APK ] && [ "$(sed -n 6p <<<"$app_table")" = "$dpi" ] &&
				isoneof "$(sed -n 4p <<<"$app_table")" "${apparch[@]}"; }; }; then
			dlurl=https://www.apkmirror.com$($HTMLQ --attribute href "div:nth-child(1) > a:nth-child(1)" <<<"$node")
			break
		fi
	done
	[ -z "$dlurl" ] && return 1
	url="https://www.apkmirror.com$(req "$dlurl" - | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p' | tail -1)"
	if [ "$apkorbundle" = BUNDLE ] && [[ "$url" != *"&forcebaseapk=true" ]]; then url="${url}&forcebaseapk=true"; fi
	url="https://www.apkmirror.com$(req "$url" - | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}
get_apkmirror_vers() {
	local apkmirror_category=$1 allow_alpha_version=$2
	local vers apkm_resp
	apkm_resp=$(req "https://www.apkmirror.com/uploads/?appcategory=${apkmirror_category}" -)
	# apkm_name=$(echo "$apkm_resp" | sed -n 's;.*Latest \(.*\) Uploads.*;\1;p')
	vers=$(sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p' <<<"$apkm_resp")
	if [ "$allow_alpha_version" = false ]; then
		local IFS=$'\n'
		vers=$(grep -iv "\(beta\|alpha\)" <<<"$vers")
		local v r_vers=()
		for v in $vers; do
			grep -iq "${v} \(beta\|alpha\)" <<<"$apkm_resp" || r_vers+=("$v")
		done
		echo "${r_vers[*]}"
	else
		echo "$vers"
	fi
}
get_apkmirror_pkg_name() { req "$1" - | sed -n 's;.*id=\(.*\)" class="accent_color.*;\1;p'; }
# --------------------------------------------------

# -------------------- uptodown --------------------
get_uptodown_resp() { req "${1}/versions" -; }
get_uptodown_vers() { sed -n 's;.*version">\(.*\)</span>$;\1;p' <<<"$1"; }
dl_uptodown() {
	local uptwod_resp=$1 version=$2 output=$3
	local url
	url=$(grep -F "${version}</span>" -B 2 <<<"$uptwod_resp" | head -1 | sed -n 's;.*data-url="\(.*\)".*;\1;p') || return 1
	url=$(req "$url" - | sed -n 's;.*data-url="\(.*\)".*;\1;p') || return 1
	req "$url" "$output"
}
get_uptodown_pkg_name() { req "${1}/download" - | $HTMLQ --text "tr.full:nth-child(1) > td:nth-child(3)"; }
# --------------------------------------------------

# -------------------- apkmonk ---------------------
get_apkmonk_resp() { req "${1}" -; }
get_apkmonk_vers() { grep -oP 'download_ver.+?>\K([0-9,\.]*)' <<<"$1"; }
dl_apkmonk() {
	local apkmonk_resp=$1 version=$2 output=$3
	local url
	url="https://www.apkmonk.com/down_file?pkg="$(grep -F "$version</a>" <<<"$apkmonk_resp" | grep -oP 'href=\"/download-app/\K.+?(?=/?\">)' | sed 's;/;\&key=;') || return 1
	url=$(req "$url" - | grep -oP 'https.+?(?=\",)')
	req "$url" "$output"
}
get_apkmonk_pkg_name() { grep -oP '.*apkmonk\.com\/app\/\K([,\w,\.]*)' <<<"$1"; }
# --------------------------------------------------

patch_apk() {
	local stock_input=$1 patched_apk=$2 patcher_args=$3
	declare -r tdir=$(mktemp -d -p $TEMP_DIR)
	local cmd="java -jar $RV_CLI_JAR --rip-lib x86_64 --rip-lib x86 --temp-dir=$tdir -c -a $stock_input -o $patched_apk -b $RV_PATCHES_JAR --keystore=ks.keystore $patcher_args"
	if [ "$OS" = Android ]; then
		cmd+=" --custom-aapt2-binary=${TEMP_DIR}/aapt2"
	fi
	pr "$cmd"
	if [ "${DRYRUN:-}" = true ]; then
		cp -f "$stock_input" "$patched_apk"
	else
		eval "$cmd"
	fi
	[ -f "$patched_apk" ]
}

build_rv() {
	local -n args=$1
	local version build_mode_arr pkg_name uptwod_resp
	local mode_arg=${args[build_mode]} version_mode=${args[version]}
	local app_name=${args[app_name]}
	local app_name_l=${app_name,,}
	app_name_l=${app_name_l// /-}
	local dl_from=${args[dl_from]}
	local arch=${args[arch]}
	local p_patcher_args=()
	p_patcher_args+=("$(join_args "${args[excluded_patches]}" -e) $(join_args "${args[included_patches]}" -i)")
	[ "${args[exclusive_patches]}" = true ] && p_patcher_args+=("--exclusive")

	if [ "$dl_from" = apkmirror ]; then
		pkg_name=$(get_apkmirror_pkg_name "${args[apkmirror_dlurl]}")
	elif [ "$dl_from" = uptodown ]; then
		uptwod_resp=$(get_uptodown_resp "${args[uptodown_dlurl]}")
		pkg_name=$(get_uptodown_pkg_name "${args[uptodown_dlurl]}")
	elif [ "$dl_from" = apkmonk ]; then
		pkg_name=$(get_apkmonk_pkg_name "${args[apkmonk_dlurl]}")
		apkmonk_resp=$(get_apkmonk_resp "${args[apkmonk_dlurl]}")
	fi

	local get_latest_ver=false
	if [ "$version_mode" = auto ]; then
		version=$(
			get_patch_last_supported_ver "$pkg_name" \
				"${args[included_patches]}" "${args[excluded_patches]}" "${args[exclusive_patches]}"
		) || get_latest_ver=true
	elif isoneof "$version_mode" latest beta; then
		get_latest_ver=true
		p_patcher_args+=("--experimental")
	else
		version=$version_mode
		p_patcher_args+=("--experimental")
	fi
	if [ $get_latest_ver = true ]; then
		local apkmvers uptwodvers aav
		if [ "$dl_from" = apkmirror ]; then
			if [ "$version_mode" = beta ]; then aav="true"; else aav="false"; fi
			apkmvers=$(get_apkmirror_vers "${args[apkmirror_dlurl]##*/}" "$aav")
			version=$(get_largest_ver <<<"$apkmvers") || version=$(head -1 <<<"$apkmvers")
		elif [ "$dl_from" = uptodown ]; then
			uptwodvers=$(get_uptodown_vers "$uptwod_resp")
			version=$(get_largest_ver <<<"$uptwodvers") || version=$(head -1 <<<"$uptwodvers")
		elif [ "$dl_from" = apkmonk ]; then
			apkmonkvers=$(get_apkmonk_vers "$apkmonk_resp")
			version=$(get_largest_ver <<<"$apkmonkvers") || version=$(head -1 <<<"$apkmonkvers")
		fi
	fi
	if [ -z "$version" ]; then
		epr "empty version, not building ${app_name}."
		return 0
	fi
	pr "Choosing version '${version}' (${app_name})"
	local version_f=${version// /}
	local stock_apk="${TEMP_DIR}/${pkg_name}-${version_f}-${arch}.apk"
	if [ ! -f "$stock_apk" ]; then
		for dl_p in apkmirror uptodown apkmonk; do
			if [ "$dl_p" = apkmirror ]; then
				if [ -z "${args[apkmirror_dlurl]}" ]; then continue; fi
				pr "Downloading '${app_name}' from APKMirror"
				local apkm_arch
				if [ "$arch" = "all" ]; then apkm_arch="universal"; 
				elif [ "$arch" = "arm64-v8a" ]; then apkm_arch="arm64-v8a";
				elif [ "$arch" = "arm-v7a" ]; then apkm_arch="armeabi-v7a"; fi
				if ! dl_apkmirror "${args[apkmirror_dlurl]}" "$version" "$stock_apk" APK "$apkm_arch" "${args[dpi]}"; then
					epr "ERROR: Could not find any release of '${app_name}' with version '${version}', arch '${apkm_arch}' and dpi '${args[dpi]}' from APKMirror"
					continue
				fi
				break
			elif [ "$dl_p" = uptodown ]; then
				if [ -z "${args[uptodown_dlurl]}" ]; then continue; fi
				if [ -z "${uptwod_resp:-}" ]; then uptwod_resp=$(get_uptodown_resp "${args[uptodown_dlurl]}"); fi
				pr "Downloading '${app_name}' from Uptodown"
				if ! dl_uptodown "$uptwod_resp" "$version" "$stock_apk"; then
					epr "ERROR: Could not download ${app_name} from Uptodown"
					continue
				fi
				break
			elif [ "$dl_p" = apkmonk ]; then
				if [ -z "${args[apkmonk_dlurl]}" ]; then continue; fi
				if [ -z "${apkmonk_resp:-}" ]; then apkmonk_resp=$(get_apkmonk_resp "${args[apkmonk_dlurl]}"); fi
				pr "Downloading '${app_name}' from Apkmonk"
				if ! dl_apkmonk "$apkmonk_resp" "$version" "$stock_apk"; then
					epr "ERROR: Could not download ${app_name} from Apkmonk"
					continue
				fi
				break
			fi
		done
		if [ ! -f "$stock_apk" ]; then
			epr "ERROR: Could not download ${app_name} from any provider"
			return 0
		fi
	fi
	if [ "${arch}" = "all" ]; then
		grep -q "${app_name}:" build.md || log "${app_name}: ${version}"
	else
		grep -q "${app_name} (${arch}):" build.md || log "${app_name} (${arch}): ${version}"
	fi
	if [ "${args[merge_integrations]}" = true ]; then
		p_patcher_args+=("-m ${RV_INTEGRATIONS_APK}")
	fi

	local microg_patch
	microg_patch=$(jq -r ".[] | select(.compatiblePackages[].name==\"${pkg_name}\") | .name" "$RV_PATCHES_JSON" | grep -F microg || :)
	if [ "$microg_patch" ]; then
		p_patcher_args=("${p_patcher_args[@]//-[ei] ${microg_patch}/}")
	fi

	local stock_bundle_apk="${TEMP_DIR}/${pkg_name}-${version_f}-${arch}-bundle.apk"
	local is_bundle=false
	if [ "$mode_arg" = module ] || [ "$mode_arg" = both ]; then
		if [ -f "$stock_bundle_apk" ]; then
			is_bundle=true
		elif [ "$dl_from" = apkmirror ]; then
			pr "Downloading '${app_name}' bundle from APKMirror"
			if dl_apkmirror "${args[apkmirror_dlurl]}" "$version" "$stock_bundle_apk" BUNDLE "" ""; then
				if (($(stat -c%s "$stock_apk") - $(stat -c%s "$stock_bundle_apk") > 10000000)); then
					pr "'${app_name}' bundle was downloaded successfully and will be used for the module"
					is_bundle=true
				else
					pr "'${app_name}' bundle was downloaded but will not be used"
				fi
			else
				pr "'${app_name}' bundle was not found"
			fi
		fi
	fi

	if [ "$mode_arg" = module ]; then
		build_mode_arr=(module)
	elif [ "$mode_arg" = apk ]; then
		build_mode_arr=(apk)
	elif [ "$mode_arg" = both ]; then
		build_mode_arr=(apk module)
	fi
	local patcher_args patched_apk build_mode
	for build_mode in "${build_mode_arr[@]}"; do
		patcher_args=("${p_patcher_args[@]}")
		pr "Building '${app_name}' (${arch}) in '$build_mode' mode"
		if [ "$microg_patch" ]; then
			patched_apk="${TEMP_DIR}/${app_name_l}-${RV_BRAND_F}-${version_f}-${arch}-${build_mode}.apk"
			if [ "$build_mode" = apk ]; then
				patcher_args+=("-i ${microg_patch}")
			elif [ "$build_mode" = module ]; then
				patcher_args+=("-e ${microg_patch}")
			fi
		else
			patched_apk="${TEMP_DIR}/${app_name_l}-${RV_BRAND_F}-${version_f}-${arch}.apk"
		fi
		if [ "$build_mode" = module ]; then
			if [ $is_bundle = false ] || [ "${args[include_stock]}" = false ]; then
				patcher_args+=("--unsigned --rip-lib arm64-v8a --rip-lib armeabi-v7a")
			else
				patcher_args+=("--unsigned")
			fi
		fi
		if [ ! -f "$patched_apk" ] || [ "$REBUILD" = true ]; then
			if ! patch_apk "$stock_apk" "$patched_apk" "${patcher_args[*]}"; then
				pr "Building '${app_name}' failed!"
				return 0
			fi
		fi
		if [ "$build_mode" = apk ]; then
			local apk_output="${BUILD_DIR}/${app_name_l}-${RV_BRAND_F}-v${version_f}-${arch}.apk"
			cp -f "$patched_apk" "$apk_output"
			pr "Built ${app_name} (${arch}) (non-root): '${apk_output}'"
			continue
		fi
		local base_template upj
		base_template=$(mktemp -d -p $TEMP_DIR)
		cp -a $MODULE_TEMPLATE_DIR/. "$base_template"
		if [ "$BUILD_MINDETACH_MODULE" = true ] && ! grep -q "$pkg_name" $PKGS_LIST; then echo "$pkg_name" >>$PKGS_LIST; fi
		if [ "$arch" = "all" ]; then
			upj="${app_name_l}-update.json"
		else
			upj="${app_name_l}-${arch}-update.json"
		fi
		local isbndl extrct stock_apk_module
		if [ $is_bundle = true ]; then
			isbndl=":"
			extrct="base.apk"
			stock_apk_module=$stock_bundle_apk
		else
			isbndl="! :"
			extrct="${pkg_name}.apk"
			stock_apk_module=$stock_apk
		fi

		uninstall_sh "$pkg_name" "$isbndl" "$base_template"
		service_sh "$pkg_name" "$version" "$base_template"
		customize_sh "$pkg_name" "$version" "$arch" "$extrct" "$base_template"
		module_prop \
			"${args[module_prop_name]}" \
			"${app_name} ${RV_BRAND}" \
			"$version" \
			"${app_name} ${RV_BRAND} Magisk module" \
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY:-}/update/${upj}" \
			"$base_template"

		local module_output="${app_name_l}-${RV_BRAND_F}-magisk-v${version}-${arch}.zip"
		if [ ! -f "$module_output" ] || [ "$REBUILD" = true ]; then
			pr "Packing module ($app_name)"
			cp -f "$patched_apk" "${base_template}/base.apk"
			if [ "${args[include_stock]}" = true ]; then cp -f "$stock_apk_module" "${base_template}/${pkg_name}.apk"; fi
			pushd >/dev/null "$base_template" || abort "Module template dir not found"
			zip -"$COMPRESSION_LEVEL" -FSqr "../../${BUILD_DIR}/${module_output}" .
			popd >/dev/null || :
		fi

		pr "Built ${app_name} (${arch}) (root): '${BUILD_DIR}/${module_output}'"
	done
}

list_args() { tr -d '\t\r' <<<"$1" | tr ' ' '\n' | grep -v '^$' || :; }
join_args() { list_args "$1" | sed "s/^/${2} /" | paste -sd " " - || :; }

uninstall_sh() {
	local s="${UNINSTALL_SH//__PKGNAME/$1}"
	echo "${s//__ISBNDL/$2}" >"${3}/uninstall.sh"
}
customize_sh() {
	local s="${CUSTOMIZE_SH//__PKGNAME/$1}"
	s="${s//__EXTRCT/$4}"
	# shellcheck disable=SC2001
	if [ "$3" = "arm64-v8a" ]; then
		s=$(sed 's/#arm$/abort "ERROR: Wrong arch\nYour device: arm\nModule: arm64"/g' <<<"$s")
	elif [ "$3" = "arm-v7a" ]; then
		s=$(sed 's/#arm64$/abort "ERROR: Wrong arch\nYour device: arm64\nModule: arm"/g' <<<"$s")
	fi
	echo "${s//__PKGVER/$2}" >"${5}/customize.sh"
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
