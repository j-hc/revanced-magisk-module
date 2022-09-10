# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""

grep __PKGNAME /proc/self/mountinfo | while read -r line; do
	mount_path=$(echo "$line" | cut -d' ' -f5)
	ui_print "* Un-mount $mount_path"
	umount -l "$mount_path"
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
if [ -n "$BASEPATH" ] && cmpr $BASEPATH $MODPATH/__PKGNAME.apk; then
	ui_print "* Installed __PKGNAME and module APKs are identical"
	ui_print "* Skipping stock APK installation"
else
	ui_print "* Updating stock __PKGNAME"
	set_perm $MODPATH/__PKGNAME.apk 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install -i com.android.vending -r -d $MODPATH/__PKGNAME.apk 2>&1); then
		ui_print "ERROR: APK installation failed!"
		abort "${op}"
	fi
	BASEPATH=$(basepath)
	if [ -z "$BASEPATH" ]; then
		abort "ERROR: install __PKGNAME manually and reflash the module"
	fi
fi

ui_print "* Patching __PKGNAME (v__MDVRSN)"
if ! op=$(LD_LIBRARY_PATH=$XDELTA_PRELOAD xdelta -d -f -s $BASEPATH $MODPATH/rv.patch $MODPATH/base.apk 2>&1); then
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
rm -r $MODPATH/bin $MODPATH/lib $MODPATH/rv.patch $MODPATH/__PKGNAME.apk
am force-stop __PKGNAME

ui_print "* Done"
ui_print "   by j-hc (github.com/j-hc)"
ui_print " "
