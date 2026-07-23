#!/system/bin/sh
MODDIR="$(dirname "$(readlink -f "$0")")"
export MODDIR
. "$MODDIR/utils.sh"

run() {
	until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
	until [ -d "/sdcard/Android" ]; do sleep 1; done

	while
		BASEPATH=$(get_basepath)
		SVCL=$?
		[ $SVCL = 20 ]
	do sleep 2; done

	if [ $SVCL != 0 ]; then
		ch_desc_err "App not installed: '$BASEPATH'"
		return
	fi
	sleep 4

	mount_rv "$BASEPATH"
}

if [ ! -f "$MODDIR/disabled_by_action" ]; then
	run
fi
