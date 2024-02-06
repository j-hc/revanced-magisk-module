#!/bin/bash

_req() {
    wget -nv -q -O "$2" --header="$3" "$1"
}

gh_req() { _req "$1" "$2" "$GH_HEADER"; }

json_get() { grep -o "\"${1}\":[^\"]*\"[^\"]*\"" | sed -E 's/".*".*"(.*)"/\1/'; }

get_rv_prebuilts() {
    local integrations_src=$1 patches_src=$2 cli_src=$3

    # pr "Getting prebuilts (${patches_src%/*})" >&2
    local rv_cli_url rv_integrations_url rv_patches rv_patches_dl rv_patches_url rv_patches_json

    local rv_cli_rel="https://api.github.com/repos/${cli_src}/releases/"
    if [ "$cli_ver" ]; then rv_cli_rel+="tags/${cli_ver}"; else rv_cli_rel+="latest"; fi
    local rv_integrations_rel="https://api.github.com/repos/${integrations_src}/releases/"
    if [ "$integrations_ver" ]; then rv_integrations_rel+="tags/${integrations_ver}"; else rv_integrations_rel+="latest"; fi
    local rv_patches_rel="https://api.github.com/repos/${patches_src}/releases/"
    if [ "$patches_ver" ]; then rv_patches_rel+="tags/${patches_ver}"; else rv_patches_rel+="latest"; fi
    rv_cli_url=$(gh_req "$rv_cli_rel" - | json_get 'browser_download_url') || return 1
    local rv_cli_jar="${cli_dir}/${rv_cli_url##*/}"
    echo "CLI: $(cut -d/ -f4 <<<"$rv_cli_url")/$(cut -d/ -f9 <<<"$rv_cli_url")  "

    rv_integrations_url=$(gh_req "$rv_integrations_rel" - | json_get 'browser_download_url') || return 1
    local rv_integrations_apk="${integrations_dir}/${rv_integrations_url##*/}"
    echo "Integrations: $(cut -d/ -f4 <<<"$rv_integrations_url")/$(cut -d/ -f9 <<<"$rv_integrations_url")  "

    rv_patches=$(gh_req "$rv_patches_rel" -) || return 1
    # rv_patches_changelog=$(json_get 'body' <<<"$rv_patches" | sed 's/\(\\n\)\+/\\n/g')
    rv_patches_dl=$(json_get 'browser_download_url' <<<"$rv_patches")
    rv_patches_json="${patches_dir}/patches-$(json_get 'tag_name' <<<"$rv_patches").json"
    rv_patches_url=$(grep 'jar' <<<"$rv_patches_dl")
    local rv_patches_jar="${patches_dir}/${rv_patches_url##*/}"
    [ -f "$rv_patches_jar" ] || REBUILD=true
    local nm
    nm=$(cut -d/ -f9 <<<"$rv_patches_url")
    echo "Patches: $(cut -d/ -f4 <<<"$rv_patches_url")/$nm  "
    # shellcheck disable=SC2001
    echo -e "[Changelog](https://github.com/${patches_src}/releases/tag/v$(sed 's/.*-\(.*\)\..*/\1/' <<<"$nm"))\n"
    # echo -e "\n${rv_patches_changelog//# [/### [}\n---" >>"$patches_dir/changelog.md"

    # echo "$rv_cli_jar" "$rv_integrations_apk" "$rv_patches_jar" "$rv_patches_json"
}

get_rv_prebuilts "$@"
