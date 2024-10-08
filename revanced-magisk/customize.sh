. "$MODPATH/config"

ui_print ""
if [ -n "$MODULE_ARCH" ] && [ "$MODULE_ARCH" != "$ARCH" ]; then
	abort "ERROR: Wrong arch
Your device: $ARCH
Module: $MODULE_ARCH"
fi

alias cmpr="$MODPATH/bin/$ARCH/cmpr"
if [ "$ARCH" = "arm" ]; then
	ARCH_LIB=armeabi-v7a
elif [ "$ARCH" = "arm64" ]; then
	ARCH_LIB=arm64-v8a
elif [ "$ARCH" = "x86" ]; then
	ARCH_LIB=x86
elif [ "$ARCH" = "x64" ]; then
	ARCH_LIB=x86_64
else abort "ERROR: unreachable: ${ARCH}"; fi
RVPATH=/data/adb/rvhc/${MODPATH##*/}.apk

set_perm_recursive "$MODPATH/bin" 0 0 0755 0777

if su -M -c true >/dev/null 2>/dev/null; then
	alias mm='su -M -c'
else
	alias mm='nsenter -t1 -m'
fi

mm grep -F "$PKG_NAME" /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	mp=${line#* } mp=${mp%% *}
	mm umount -l "${mp%%\\*}"
done
am force-stop "$PKG_NAME"

if ! (pm path "$PKG_NAME" >/dev/null 2>&1 </dev/null); then
	if ! op=$(pm install-existing "$PKG_NAME" 2>&1 </dev/null) && echo "$op" | grep -qv NameNotFoundException; then
		ui_print "ERROR: install-existing failed"
		abort "$op"
	fi
	ui_print "* Installed existing $PKG_NAME"
fi

INS=true
IS_SYS=false
if BASEPATH=$(pm path "$PKG_NAME" 2>&1 </dev/null); then
	BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
	if echo "$BASEPATH" | grep -qF -e '/system/' -e '/product/'; then
		ui_print "* $PKG_NAME is a system app"
		if [ "${BASEPATH:1:6}" != system ]; then BASEPATH=/system${BASEPATH}; fi
		IS_SYS=true
	elif [ ! -d "${BASEPATH}/lib" ]; then
		ui_print "* Invalid installation found. Uninstalling..."
		if ! op=$(pm uninstall -k --user 0 "$PKG_NAME" 2>&1 </dev/null); then
			abort "$op"
		fi
	elif [ ! -f "$MODPATH/$PKG_NAME.apk" ]; then
		ui_print "* Stock $PKG_NAME APK was not found"
		VERSION=$(dumpsys package "$PKG_NAME" | grep -m1 versionName) VERSION="${VERSION#*=}"
		if [ "$VERSION" = "$PKG_VER" ] || [ -z "$VERSION" ]; then
			ui_print "* Skipping stock installation"
			INS=false
		else
			abort "ERROR: Version mismatch
			installed: $VERSION
			module:    $PKG_VER
			"
		fi
	elif cmpr "$BASEPATH/base.apk" "$MODPATH/$PKG_NAME.apk"; then
		ui_print "* $PKG_NAME is up-to-date"
		INS=false
	fi
fi

install() {
	if [ ! -f "$MODPATH/$PKG_NAME.apk" ]; then
		abort "ERROR: Stock $PKG_NAME apk was not found"
	fi
	ui_print "* Updating $PKG_NAME to $PKG_VER"
	VERIF_ADB=$(settings get global verifier_verify_adb_installs)
	settings put global verifier_verify_adb_installs 0
	SZ=$(stat -c "%s" "$MODPATH/$PKG_NAME.apk")

	while true; do
		if ! SES=$(pm install-create --user 0 -i com.android.vending -r -d -S "$SZ" 2>&1 </dev/null); then
			ui_print "ERROR: install-create failed"
			settings put global verifier_verify_adb_installs "$VERIF_ADB"
			abort "$SES"
		fi
		SES=${SES#*[} SES=${SES%]*}
		set_perm "$MODPATH/$PKG_NAME.apk" 1000 1000 644 u:object_r:apk_data_file:s0
		if ! op=$(pm install-write -S "$SZ" "$SES" "$PKG_NAME.apk" "$MODPATH/$PKG_NAME.apk" 2>&1 </dev/null); then
			ui_print "ERROR: install-write failed"
			settings put global verifier_verify_adb_installs "$VERIF_ADB"
			abort "$op"
		fi
		if ! op=$(pm install-commit "$SES" 2>&1 </dev/null); then
			if echo "$op" | grep -q INSTALL_FAILED_VERSION_DOWNGRADE; then
				ui_print "* ERROR: INSTALL_FAILED_VERSION_DOWNGRADE"
				if [ "$IS_SYS" = true ]; then
					ui_print "* Use system mount mode"
					BASEPATH=${MODPATH}${BASEPATH}
					set_perm "$BASEPATH" 1000 1000 755 u:object_r:system_file:s0
					RVPATH=$BASEPATH/${BASEPATH##*/}.apk
					rm "$MODPATH/service.sh" "$MODPATH/uninstall.sh"
					break
				else
					ui_print "* Uninstalling..."
					if ! op=$(pm uninstall -k --user 0 "$PKG_NAME" 2>&1 </dev/null); then
						ui_print "$op"
					fi
					continue
				fi
			fi
			ui_print "ERROR: install-commit failed"
			settings put global verifier_verify_adb_installs "$VERIF_ADB"
			abort "$op"
		fi
		if BASEPATH=$(pm path "$PKG_NAME" 2>&1 </dev/null); then
			BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
		else
			abort "ERROR: install $PKG_NAME manually and reflash the module"
		fi
		break
	done
	settings put global verifier_verify_adb_installs "$VERIF_ADB"
}
if [ $INS = true ] && ! install; then abort; fi

BASEPATHLIB=${BASEPATH}/lib/${ARCH}
if [ -z "$(ls -A1 "$BASEPATHLIB")" ]; then
	ui_print "* Extracting native libs"
	mkdir -p "$BASEPATHLIB"
	if ! op=$(unzip -j "$MODPATH"/"$PKG_NAME".apk lib/"${ARCH_LIB}"/* -d "$BASEPATHLIB" 2>&1); then
		ui_print "ERROR: extracting native libs failed"
		abort "$op"
	fi
	set_perm_recursive "${BASEPATH}/lib" 1000 1000 755 755 u:object_r:apk_data_file:s0
fi
mv -f "$MODPATH/base.apk" "$RVPATH"

ui_print "* Setting Permissions"
set_perm "$RVPATH" 1000 1000 644 u:object_r:apk_data_file:s0

if [ "$IS_SYS" = false ]; then
	ui_print "* Mounting $PKG_NAME"
	mkdir -p "/data/adb/rvhc"
	if ! op=$(mm mount -o bind "$RVPATH" "$BASEPATH/base.apk" 2>&1); then
		ui_print "ERROR: Mount failed!"
		ui_print "$op"
	fi
	am force-stop "$PKG_NAME"

	ui_print "* Optimizing $PKG_NAME"
	nohup cmd package compile --reset "$PKG_NAME" >/dev/null 2>&1 &
fi

ui_print "* Cleanup"
rm -rf "${MODPATH:?}/bin" "$MODPATH/$PKG_NAME.apk"

if [ -d "/data/adb/modules/zygisk-assistant" ]; then
	ui_print "* If you are using zygisk-assistant, you need to"
	ui_print "  give root permissions to $PKG_NAME"
fi

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
