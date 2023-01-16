# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""

if [ $ARCH = "arm" ]; then
	alias cmpr='$MODPATH/bin/arm/cmpr'
	ARCH_LIB=armeabi-v7a
elif [ $ARCH = "arm64" ] || [ $ARCH = "x64" ]; then
	ARCH_LIB=arm64-v8a
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
	ui_print "* __PKGNAME is up-to-date"
else
	ui_print "* Updating __PKGNAME (v__PKGVER)"
	set_perm $MODPATH/__PKGNAME.apk 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install --user 0 -i com.android.vending -r -d $MODPATH/__PKGNAME.apk 2>&1); then
		ui_print "ERROR: APK installation failed!"
		abort "$op"
	fi
	BASEPATH=$(basepath)
	if [ -z "$BASEPATH" ]; then
		abort "ERROR: install __PKGNAME manually and reflash the module"
	fi
fi
BASEPATHLIB=${BASEPATH%base.apk}lib/${ARCH}
if [ -z "$(ls -A1 ${BASEPATHLIB})" ]; then
	ui_print "* Extracting native libs"
	if ! op=$(unzip -j $MODPATH/__PKGNAME.apk lib/${ARCH_LIB}/* -d ${BASEPATHLIB} 2>&1); then
		ui_print "ERROR: extracting native libs failed"
		abort "$op"
	fi
	set_perm_recursive ${BASEPATHLIB} 1000 1000 755 755 u:object_r:apk_data_file:s0
fi
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting __PKGNAME"
RVPATH=/data/adb/__PKGNAME_rv.apk
ln -f $MODPATH/base.apk $RVPATH

if ! op=$(mount -o bind $RVPATH $BASEPATH 2>&1); then
	ui_print "ERROR: Mount failed!"
	abort "$op"
fi
am force-stop __PKGNAME
ui_print "* Optimizing __PKGNAME"
cmd package compile --reset __PKGNAME &

rm -r $MODPATH/bin $MODPATH/__PKGNAME.apk

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
