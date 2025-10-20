. "$MODPATH/config"

ui_print ""
if [ -n "$MODULE_ARCH" ] && [ "$MODULE_ARCH" != "$ARCH" ]; then
	abort "ERROR: Wrong arch
Your device: $ARCH
Module: $MODULE_ARCH"
fi
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
else alias mm='nsenter -t1 -m'; fi

mm grep -F "$PKG_NAME" /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	mp=${line#* } mp=${mp%% *}
	mm umount -l "${mp%%\\*}"
done
am force-stop "$PKG_NAME"

pmex() {
	OP=$(pm "$@" 2>&1 </dev/null)
	RET=$?
	echo "$OP"
	return $RET
}

if ! pmex path "$PKG_NAME" >&2; then
	if pmex install-existing "$PKG_NAME" >&2; then
		BASEPATH=$(pmex path "$PKG_NAME") || abort "ERROR: pm path failed $BASEPATH"
		echo >&2 "'$BASEPATH'"
		BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
		if [ "${BASEPATH:1:4}" = data ]; then
			if pmex uninstall -k --user 0 "$PKG_NAME" >&2; then
				rm -rf "$BASEPATH" 2>&1
				ui_print "* Cleared existing $PKG_NAME package"
				ui_print "* Reboot and reflash"
				abort
			else abort "ERROR: pm uninstall failed"; fi
		else ui_print "* Installed stock $PKG_NAME package"; fi
	fi
fi

IS_SYS=false
INS=true
if BASEPATH=$(pmex path "$PKG_NAME"); then
	echo >&2 "'$BASEPATH'"
	BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
	if [ "${BASEPATH:1:4}" != data ]; then
		ui_print "* $PKG_NAME is a system app."
		IS_SYS=true
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
	elif "${MODPATH:?}/bin/$ARCH/cmpr" "$BASEPATH/base.apk" "$MODPATH/$PKG_NAME.apk"; then
		ui_print "* $PKG_NAME is up-to-date"
		INS=false
	fi
fi

install() {
	if [ ! -f "$MODPATH/$PKG_NAME.apk" ]; then
		abort "ERROR: Stock $PKG_NAME apk was not found"
	fi
	ui_print "* Updating $PKG_NAME to $PKG_VER"
	install_err=""
	VERIF1=$(settings get global verifier_verify_adb_installs)
	VERIF2=$(settings get global package_verifier_enable)
	settings put global verifier_verify_adb_installs 0
	settings put global package_verifier_enable 0
	SZ=$(stat -c "%s" "$MODPATH/$PKG_NAME.apk")
	for IT in 1 2; do
		if ! SES=$(pmex install-create --user 0 -i com.android.vending -r -d -S "$SZ"); then
			ui_print "ERROR: install-create failed"
			install_err="$SES"
			break
		fi
		SES=${SES#*[} SES=${SES%]*}
		set_perm "$MODPATH/$PKG_NAME.apk" 1000 1000 644 u:object_r:apk_data_file:s0
		if ! op=$(pmex install-write -S "$SZ" "$SES" "$PKG_NAME.apk" "$MODPATH/$PKG_NAME.apk"); then
			ui_print "ERROR: install-write failed"
			install_err="$op"
			break
		fi
		if ! op=$(pmex install-commit "$SES"); then
			if echo "$op" | grep -q -e INSTALL_FAILED_VERSION_DOWNGRADE -e INSTALL_FAILED_UPDATE_INCOMPATIBLE; then
				ui_print "* Handling install error"
				if [ "$IS_SYS" = true ]; then
					SCNM="/data/adb/post-fs-data.d/$PKG_NAME-uninstall.sh"
					if [ -f "$SCNM" ]; then
						ui_print "* Remove the old module. Reboot and reflash!"
						ui_print ""
						install_err=" "
						break
					fi
					mkdir -p /data/adb/rvhc/empty /data/adb/post-fs-data.d
					echo "mount -o bind /data/adb/rvhc/empty $BASEPATH" >"$SCNM"
					chmod +x "$SCNM"
					ui_print "* Created the uninstall script."
					ui_print ""
					ui_print "* Reboot and reflash the module!"
					install_err=" "
					break
				else
					ui_print "* Uninstalling..."
					if ! op=$(pmex uninstall -k --user 0 "$PKG_NAME"); then
						ui_print "$op"
						if [ $IT = 2 ]; then
							install_err="ERROR: pm uninstall failed."
							break
						fi
					fi
					continue
				fi
			fi
			ui_print "ERROR: install-commit failed"
			install_err="$op"
			break
		fi
		if BASEPATH=$(pmex path "$PKG_NAME"); then
			BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
		else
			install_err="ERROR: install $PKG_NAME manually and reflash the module"
			break
		fi
		break
	done
	settings put global verifier_verify_adb_installs "$VERIF1"
	settings put global package_verifier_enable "$VERIF2"
	if [ "$install_err" ]; then abort "$install_err"; fi
}
if [ $INS = true ] && ! install; then abort; fi
BASEPATHLIB=${BASEPATH}/lib/${ARCH}
if [ $INS = true ] || [ -z "$(ls -A1 "$BASEPATHLIB")" ]; then
	ui_print "* Extracting native libs"
	if [ ! -d "$BASEPATHLIB" ]; then mkdir -p "$BASEPATHLIB"; else rm -f "$BASEPATHLIB"/* >/dev/null 2>&1 || :; fi
	if ! op=$(unzip -o -j "$MODPATH/$PKG_NAME.apk" "lib/${ARCH_LIB}/*" -d "$BASEPATHLIB" 2>&1); then
		ui_print "ERROR: extracting native libs failed"
		abort "$op"
	fi
	set_perm_recursive "${BASEPATH}/lib" 1000 1000 755 755 u:object_r:apk_data_file:s0
fi

ui_print "* Setting Permissions"
set_perm "$MODPATH/base.apk" 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting $PKG_NAME"
mkdir -p "/data/adb/rvhc"
RVPATH=/data/adb/rvhc/${MODPATH##*/}.apk
mv -f "$MODPATH/base.apk" "$RVPATH"

if ! op=$(mm mount -o bind "$RVPATH" "$BASEPATH/base.apk" 2>&1); then
	ui_print "ERROR: Mount failed!"
	ui_print "$op"
fi
am force-stop "$PKG_NAME"
ui_print "* Optimizing $PKG_NAME"
nohup cmd package compile --reset "$PKG_NAME" >/dev/null 2>&1 &

if [ "$KSU" ]; then
	UID=$(dumpsys package "$PKG_NAME" | grep -m1 uid)
	UID=${UID#*=} UID=${UID%% *}
	if [ -z "$UID" ]; then
		UID=$(dumpsys package "$PKG_NAME" | grep -m1 userId)
		UID=${UID#*=} UID=${UID%% *}
	fi
	if [ "$UID" ]; then
		if ! OP=$("${MODPATH:?}/bin/$ARCH/ksu_profile" "$UID" "$PKG_NAME" 2>&1); then
			ui_print "ERROR ksu_profile: $OP"
		fi
	else
		ui_print "no UID"
		dumpsys package "$PKG_NAME" >&2
	fi
fi

rm -rf "${MODPATH:?}/bin" "$MODPATH/$PKG_NAME.apk"

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
