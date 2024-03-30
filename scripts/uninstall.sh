#!/system/bin/sh
{
	MODDIR=${0%/*}
	rm "$NVBASE/rvhc/${MODDIR##*/}".apk
	rmdir "$NVBASE/rvhc"
} &
