# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""

if [ $ARCH = "arm" ]; then
	alias cmpr='$MODPATH/bin/arm/cmpr'
elif [ $ARCH = "arm64" ]; then
	alias cmpr='$MODPATH/bin/arm64/cmpr'
else
	abort "ERROR: unsupported arch: ${ARCH}"
fi
set_perm_recursive $MODPATH/bin 0 0 0755 0777

basepath() {
	basepath=$(pm path __PKGNAME | grep base)
	echo ${basepath#*:}
}

grep __PKGNAME /proc/self/mountinfo | while read -r line; do
	ui_print "* Un-mount"
	mountpoint=$(echo "$line" | cut -d' ' -f5)
	umount -l "${mountpoint%%\\*}"
done
am force-stop __PKGNAME

BASEPATH=$(basepath)
if [ -n "$BASEPATH" ] && cmpr $BASEPATH $MODPATH/__PKGNAME.apk; then
	ui_print "* Installed __PKGNAME and module APKs are identical"
	ui_print "* Skipping stock APK installation"
else
	ui_print "* Updating stock __PKGNAME"
	set_perm $MODPATH/__PKGNAME.apk 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install --user 0 -i com.android.vending -r -d $MODPATH/__PKGNAME.apk 2>&1); then
		ui_print "ERROR: APK installation failed!"
		abort "${op}"
	fi
	BASEPATH=$(basepath)
	if [ -z "$BASEPATH" ]; then
		abort "ERROR: install __PKGNAME manually and reflash the module"
	fi
fi
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting __PKGNAME"
RVPATH=/data/adb/__PKGNAME_rv.apk
ln -f $MODPATH/base.apk $RVPATH

if ! op=$(su -Mc mount -o bind $RVPATH $BASEPATH 2>&1); then
	ui_print "ERROR: Mount failed!"
	abort "$op"
fi
rm -r $MODPATH/bin $MODPATH/__PKGNAME.apk
rm -f /data/local/tmp/__PKGNAME_rv.apk
am force-stop __PKGNAME

ui_print "* Optimizing __PKGNAME"
cmd package compile --reset __PKGNAME &

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
