#!/system/bin/sh
# shellcheck disable=SC2086,SC1091
MODDIR=${0%/*}
RVPATH=$NVBASE/rvhc/${MODDIR##*/}.apk
. $MODDIR/config

until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d "/sdcard/Android" ]; do sleep 1; done
while
	BASEPATH=$(pm path $PKG_NAME)
	svcl=$?
	[ $svcl = 20 ]
do sleep 2; done
sleep 5

err() {
	[ ! -f $MODDIR/err ] && cp $MODDIR/module.prop $MODDIR/err
	sed -i "s/^des.*/description=⚠️ Needs reflash: '${1}'/g" $MODDIR/module.prop
}

if [ $svcl = 0 ]; then
	BASEPATH=${BASEPATH##*:}
	BASEPATH=${BASEPATH%/*}
	if [ -d $BASEPATH/lib ]; then
		VERSION=$(dumpsys package $PKG_NAME | grep -m1 versionName)
		VERSION="${VERSION#*=}"
		if [ "$VERSION" = $PKG_VER ] || [ -z "$VERSION" ]; then
			grep $PKG_NAME /proc/mounts | while read -r line; do
				mp=${line#* }
				mp=${mp%% *}
				umount -l ${mp%%\\*}
			done
			if chcon u:object_r:apk_data_file:s0 $RVPATH; then
				mount -o bind $RVPATH $BASEPATH/base.apk
				am force-stop $PKG_NAME
				[ -f $MODDIR/err ] && mv -f $MODDIR/err $MODDIR/module.prop
			else
				err "mount failed"
			fi
		else
			err "version mismatch (installed:${VERSION}, module:$PKG_VER)"
		fi
	else
		err "zygote crashed"
	fi
else
	err "app not installed"
fi
