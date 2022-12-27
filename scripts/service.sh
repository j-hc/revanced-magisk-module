#!/system/bin/sh
# shellcheck disable=SC2086
MODDIR=${0%/*}
RVPATH=/data/adb/__PKGNAME_rv.apk
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
sleep __MNTDLY

ln -f $MODDIR/base.apk $RVPATH
BASEPATH=$(pm path __PKGNAME | grep base)
BASEPATH=${BASEPATH#*:}
if [ $BASEPATH ] && [ -d ${BASEPATH%base.apk}lib ]; then
	VERSION=$(dumpsys package __PKGNAME | grep -m1 versionName)
	if [ ${VERSION#*=} = __PKGVER ]; then
		chcon u:object_r:apk_data_file:s0 $RVPATH
		mount -o bind $RVPATH $BASEPATH
	fi
fi
