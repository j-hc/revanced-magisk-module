#!/system/bin/sh
{
	MODDIR=${0%/*}
	MODULES=${MODDIR%/*}
	NVBASE=${MODULES%/*}
	rm $NVBASE/rvhc/__PKGNAME_rv.apk
	rmdir $NVBASE/rvhc
} &
