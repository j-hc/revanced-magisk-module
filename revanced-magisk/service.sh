#!/system/bin/sh
MODDIR=${0%/*}
RVPATH=$NVBASE/rvhc/${MODDIR##*/}.apk
. "$MODDIR/config"

until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d "/sdcard/Android" ]; do sleep 1; done
while
	BASEPATH=$(pm path "$PKG_NAME")
	svcl=$?
	[ $svcl = 20 ]
do sleep 2; done
sleep 5

err() {
	[ ! -f "$MODDIR/err" ] && cp "$MODDIR/module.prop" "$MODDIR/err"
	sed -i "s/^des.*/description=⚠️ Needs reflash: '${1}'/g" "$MODDIR/module.prop"
}

if [ $svcl != 0 ]; then
	err "app not installed"
	exit
fi
BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
if [ ! -d "$BASEPATH/lib" ]; then
	err "zygote crashed (fix your ROM)"
	exit
fi
VERSION=$(dumpsys package "$PKG_NAME" | grep -m1 versionName) VERSION="${VERSION#*=}"
if [ "$VERSION" != "$PKG_VER" ] && [ "$VERSION" ]; then
	err "version mismatch (installed:${VERSION}, module:$PKG_VER)"
	exit
fi
grep "$PKG_NAME" /proc/mounts | while read -r line; do
	mp=${line#* } mp=${mp%% *}
	umount -l "${mp%%\\*}"
done
if ! chcon u:object_r:apk_data_file:s0 "$RVPATH"; then
	err "apk not found"
	exit
fi
mount -o bind "$RVPATH" "$BASEPATH/base.apk"
am force-stop "$PKG_NAME"
[ -f "$MODDIR/err" ] && mv -f "$MODDIR/err" "$MODDIR/module.prop"
