#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/utils.sh"

err() {
	[ ! -f "$MODDIR/err" ] && cp "$MODDIR/module.prop" "$MODDIR/err"
	sed -i "s/^des.*/description=⚠️ Needs reflash: '${1}'/g" "$MODDIR/module.prop"
}

run() {
	until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
	until [ -d "/sdcard/Android" ]; do sleep 1; done

	while
		BASEPATH=$(get_basepath)
		SVCL=$?
		[ $SVCL = 20 ]
	do sleep 2; done

	if [ $SVCL != 0 ]; then
		err "app not installed"
		return
	fi
	sleep 4

	mount_rv "$BASEPATH"
}

if [ ! -f "$MODDIR/disabled_by_webui" ]; then
	run
fi
