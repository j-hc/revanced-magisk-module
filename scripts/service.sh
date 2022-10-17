#!/system/bin/sh
# shellcheck disable=SC2086
MODDIR=${0%/*}
RVPATH=/data/adb/__PKGNAME_rv.apk
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
sleep __MNTDLY

ln -f $MODDIR/base.apk $RVPATH
BASEPATH=$(pm path __PKGNAME | grep base)
BASEPATH=${BASEPATH#*:}
if [ "$BASEPATH" ] && [ -d ${BASEPATH%base.apk}/lib ]; then
	chcon u:object_r:apk_data_file:s0 $RVPATH
	su -Mc mount -o bind $RVPATH $BASEPATH
fi
