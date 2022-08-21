# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""
grep __PKGNAME /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	line=${line#*' '}
	line=${line%%' '*}
	umount -l ${line%%\\*} # trims \040(deleted)
done

if [ $ARCH = "arm" ]; then
	XDELTA_PRELOAD=$MODPATH/lib/arm
	alias xdelta='$MODPATH/bin/arm/xdelta'
	alias cmpr='$MODPATH/bin/arm/cmpr'
elif [ $ARCH = "arm64" ]; then
	XDELTA_PRELOAD=$MODPATH/lib/arm64
	alias xdelta='$MODPATH/bin/arm64/xdelta'
	alias cmpr='$MODPATH/bin/arm64/cmpr'
else
	abort "ERROR: unsupported arch: ${ARCH}!"
fi
set_perm_recursive $MODPATH/bin 0 0 0755 0777

basepath() {
	basepath=$(pm path __PKGNAME | grep base)
	echo ${basepath#*:}
}

BASEPATH=$(basepath)
if [ -n "$BASEPATH" ] && cmpr $BASEPATH $MODPATH/stock.apk; then
	ui_print "* Installed __PKGNAME and module stock.apk are identical"
	ui_print "* Skipping stock APK installation"
else
	ui_print "* Installing/Updating stock __PKGNAME"
	set_perm $MODPATH/stock.apk 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install -r -d $MODPATH/stock.apk 2>&1); then
		ui_print "ERROR: APK installation failed!"
		abort "${op}"
	fi
	BASEPATH=$(basepath)
fi

ui_print "* Patching __PKGNAME (v__MDVRSN) on the fly"
if ! op=$(LD_LIBRARY_PATH=$XDELTA_PRELOAD xdelta -d -f -s $BASEPATH $MODPATH/rvc.xdelta $MODPATH/base.apk 2>&1); then
	ui_print "ERROR: Patching failed!"
	abort "$op"
fi
ui_print "* Patching done"
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting __PKGNAME"
if ! op=$(mount -o bind $MODPATH/base.apk $BASEPATH 2>&1); then
	ui_print "ERROR: Mount failed!"
	abort "$op"
fi

ui_print "   by j-hc (github.com/j-hc)"
ui_print " "
rm -r $MODPATH/bin $MODPATH/lib $MODPATH/rvc.xdelta $MODPATH/stock.apk
am force-stop __PKGNAME
