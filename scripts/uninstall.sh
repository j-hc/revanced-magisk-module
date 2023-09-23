#!/system/bin/sh
{
	MODDIR=${0%/*}
	rm "$NVBASE/rvhc/${MODDIR##*/}".apk
	rmdir "$NVBASE/rvhc"
	# if __ISBNDL; then
	# 	until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
	# 	sleep 15
	# 	pm uninstall __PKGNAME
	# fi
} &
