#!/system/bin/sh
MODDIR=${0%/*}
RVPATH=/data/adb/rvhc/${MODDIR##*/}.apk
. "$MODDIR/config"

err() {
	[ ! -f "$MODDIR/err" ] && cp "$MODDIR/module.prop" "$MODDIR/err"
	sed -i "s/^des.*/description=⚠️ Needs reflash: '${1}'/g" "$MODDIR/module.prop"
}

until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d "/sdcard/Android" ]; do sleep 1; done
while
	BASEPATH=$(pm path "$PKG_NAME" 2>&1 </dev/null)
	SVCL=$?
	[ $SVCL = 20 ]
do sleep 2; done

run() {
	if [ $SVCL != 0 ]; then
		err "app not installed"
		return
	fi
	sleep 4

	BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
	if [ ! -d "$BASEPATH/lib" ]; then
		err "mount failed (ROM issue)"
		return
	fi
	VERSION=$(dumpsys package "$PKG_NAME" | grep -m1 versionName) VERSION="${VERSION#*=}"
	if [ "$VERSION" != "$PKG_VER" ] && [ "$VERSION" ]; then
		err "version mismatch (installed:${VERSION}, module:$PKG_VER)"
		return
	fi
	grep "$PKG_NAME" /proc/mounts | while read -r line; do
		mp=${line#* } mp=${mp%% *}
		umount -l "${mp%%\\*}"
	done
	if ! chcon u:object_r:apk_data_file:s0 "$RVPATH"; then
		err "apk not found"
		return
	fi
	mount -o bind "$RVPATH" "$BASEPATH/base.apk"
	am force-stop "$PKG_NAME"
	[ -f "$MODDIR/err" ] && mv -f "$MODDIR/err" "$MODDIR/module.prop"
}

run

if [ "$KSU" = true ] && /data/adb/ksud kernel 2>&1 | grep -q "umount" >/dev/null 2>&1; then
	echo "allow zygote adb_data_file dir search" > /dev/revanced_rule
	/data/adb/ksud sepolicy apply /dev/revanced_rule
	rm /dev/revanced_rule

	APK_PATH=$(pm path "$PKG_NAME")
	/data/adb/ksud kernel umount add "$APK_PATH" -f 2 > /dev/null
	/data/adb/ksud kernel notify-module-mounted > /dev/null
fi
