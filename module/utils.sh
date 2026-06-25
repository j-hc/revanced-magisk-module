#!/system/bin/sh

RVPATH=/data/adb/rvhc/${MODDIR##*/}.apk
. "$MODDIR/config"

pmex() {
	OP=$(pm "$@" 2>&1 </dev/null)
	RET=$?
	echo "$OP"
	return $RET
}

get_app_version() {
	VERSION=$(dumpsys package "$PKG_NAME" 2>&1 | grep -m1 versionName=) VERSION="${VERSION#*=}"
	echo "$VERSION"
}

get_basepath() {
	BASEPATH=$(pmex path "$PKG_NAME")
	SVCL=$?

	BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
	echo "$BASEPATH"
	return $SVCL
}

umount_all() {
	su -M -c grep -F "$PKG_NAME" /proc/mounts | while read -r line; do
		mp=${line#* } mp=${mp%% *} mp=${mp%%\\*}
		su -M -c umount -l "${mp}"
	done
	am force-stop "$PKG_NAME" || :
}

get_mounts() {
	su -M -c grep -F "$PKG_NAME" /proc/mounts || :
}

mount_rv() {
	if [ ! -d "${1}/lib" ]; then
		err "mount failed. Dont report this, consider using rvmm-zygisk-mount"
		return 1
	fi
	VERSION=$(get_app_version)
	if [ "$VERSION" != "$PKG_VER" ] && [ "$VERSION" ]; then
		err "version mismatch (installed:${VERSION}, module:$PKG_VER)"
		return 1
	fi
	umount_all
	if ! chcon u:object_r:apk_data_file:s0 "$RVPATH"; then
		err "apk not found"
		return 1
	fi
	mount -o bind "$RVPATH" "${1}/base.apk"
	am force-stop "$PKG_NAME"
	[ -f "$MODDIR/err" ] && mv -f "$MODDIR/err" "$MODDIR/module.prop"
	return 0
}

mount_nosleep() {
	if ! BASEPATH=$(get_basepath); then return 1; fi
	mount_rv "$BASEPATH"
}
