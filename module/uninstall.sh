#!/system/bin/sh

MODDIR=${0%/*}
. "$MODDIR/config"

rm -f "/data/adb/rvhc/${MODDIR##*/}.apk"
rmdir "/data/adb/rvhc"

rm -f "/data/adb/post-fs-data.d/$PKG_NAME-uninstall.sh"
