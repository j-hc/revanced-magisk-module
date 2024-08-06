#!/system/bin/sh
{
	MODDIR=${0%/*}
	rm "/data/adb/rvhc/${MODDIR##*/}".apk
	rmdir "/data/adb/rvhc"
} &
