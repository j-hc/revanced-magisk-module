#!/system/bin/sh
{
	rm ${NVBASE}/rvhc/__PKGNAME_rv.apk
	rmdir ${NVBASE}/rvhc
	if __ISBNDL :; then
		until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
		until [ "$(getprop init.svc.bootanim)" = stopped ]; do sleep 1; done
		sleep 3
		pm uninstall __PKGNAME
	fi
} &
