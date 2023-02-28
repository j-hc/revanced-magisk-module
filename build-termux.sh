#!/usr/bin/env bash

set -e

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1"
		if read -r y; then
			if [ "$y" = y ]; then
				return 0
			elif [ "$y" = n ]; then
				return 1
			fi
		fi
		pr "Asking again..."
	done
	return 1
}

if [ ! -f "$(date '+%Y%m%d')" ]; then
	pr "Setting up environment..."
	yes "" | pkg update -y && pkg install -y git wget openssl jq openjdk-17 zip
	: >"$(date '+%Y%m%d')"
fi

pr "Cloning revanced-magisk-module repository..."
if [ -d revanced-magisk-module ]; then
	cd revanced-magisk-module
	git fetch
	git rebase -X ours
elif [ -f build.sh ]; then
	git fetch
	git rebase -X ours
else
	git clone https://github.com/j-hc/revanced-magisk-module --recurse --depth 1
	sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' revanced-magisk-module/config.toml
	cd revanced-magisk-module
fi

if ask "Do you want to open the config.toml for customizations? [y/n]"; then
	nano config.toml
	git add config.toml && git commit -m config || :
fi
if ! ask "Setup is done. Do you want to start building? [y/n]"; then
	exit 0
fi
./build.sh

cd build
pr "Ask for storage permission"
until
	yes | termux-setup-storage >/dev/null 2>&1
	ls /sdcard >/dev/null 2>&1
do
	sleep 1
done

PWD=$(pwd)
mkdir ~/storage/downloads/revanced-magisk-module 2>/dev/null || :
for op in *; do
	[ "$op" = "*" ] && continue
	cp -f "${PWD}/${op}" ~/storage/downloads/revanced-magisk-module/"${op}"
done

pr "Outputs are available in /sdcard/Download/revanced-magisk-module folder"
am start -a android.intent.action.VIEW -d file:///sdcard/Download/revanced-magisk-module -t resource/folder
sleep 2
am start -a android.intent.action.VIEW -d file:///sdcard/Download/revanced-magisk-module -t resource/folder
