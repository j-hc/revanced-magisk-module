#!/usr/bin/env bash

set -e

pr() {
	echo -e "\033[0;32m[+] ${1}\033[0m"
}

pr "Setting up environment..."
(yes "" | pkg update -y && pkg install -y git wget openssl jq openjdk-17)

pr "Cloning revanced-magisk-module repository..."
git clone https://github.com/j-hc/revanced-magisk-module --recurse --depth 1
cd revanced-magisk-module
sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' config.toml

pr "Do you want to open the config.toml for customizations? [y/n]"
read -r y
if [ "$y" = y ]; then
	nano config.toml
else
	pr "No app is selected for patching."
fi
pr "Setup is done. Do you want to start building? [y/n]"
read -r y
if [ "$y" = y ]; then
	./build.sh
fi
