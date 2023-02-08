# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""

if [ $ARCH = "arm" ]; then
	#arm
	ARCH_LIB=armeabi-v7a
	alias cmpr='$MODPATH/bin/arm/cmpr'
elif [ $ARCH = "arm64" ]; then
	#arm64
	ARCH_LIB=arm64-v8a
	alias cmpr='$MODPATH/bin/arm64/cmpr'
else
	abort "ERROR: unsupported arch: ${ARCH}"
fi
set_perm_recursive $MODPATH/bin 0 0 0755 0777

grep __PKGNAME /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	mp=${line#* }
	mp=${mp%% *}
	umount -l ${mp%%\\*}
done
am force-stop __PKGNAME

BASEPATH=$(pm path __PKGNAME | grep base)
BASEPATH=${BASEPATH#*:}
INS=true
if [ "$BASEPATH" ]; then
	if [ ! -d ${BASEPATH%base.apk}lib ]; then
		ui_print "* Invalid installation found. Uninstalling..."
		pm uninstall -k --user 0 __PKGNAME
	elif cmpr $BASEPATH $MODPATH/__PKGNAME.apk; then
		ui_print "* __PKGNAME is up-to-date"
		INS=false
	fi
fi
if [ $INS = true ]; then
	ui_print "* Updating __PKGNAME (v__PKGVER)"
	set_perm $MODPATH/__PKGNAME.apk 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install --user 0 -i com.android.vending -r -d $MODPATH/__PKGNAME.apk 2>&1); then
		ui_print "ERROR: APK installation failed!"
		abort "$op"
	fi
	BASEPATH=$(pm path __PKGNAME | grep base)
	BASEPATH=${BASEPATH#*:}
	if [ -z "$BASEPATH" ]; then
		abort "ERROR: install __PKGNAME manually and reflash the module"
	fi
fi
BASEPATHLIB=${BASEPATH%base.apk}lib/${ARCH}
if [ -z "$(ls -A1 ${BASEPATHLIB})" ]; then
	ui_print "* Extracting native libs"
	mkdir -p $BASEPATHLIB
	if ! op=$(unzip -j $MODPATH/__EXTRCT lib/${ARCH_LIB}/* -d ${BASEPATHLIB} 2>&1); then
		ui_print "ERROR: extracting native libs failed"
		abort "$op"
	fi
	set_perm_recursive ${BASEPATHLIB} 1000 1000 755 755 u:object_r:apk_data_file:s0
fi
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting __PKGNAME"
mkdir $NVBASE/rvhc 2>/dev/null
RVPATH=$NVBASE/rvhc/__PKGNAME_rv.apk
mv -f $MODPATH/base.apk $RVPATH

if ! op=$(su -Mc mount -o bind $RVPATH $BASEPATH 2>&1); then
	ui_print "$op"
	ui_print "WARNING: Mount failed! Trying in non-global mountspace mode"
	if ! op=$(mount -o bind $RVPATH $BASEPATH 2>&1); then
		ui_print "ERROR: $op"
		abort "Try flasing the module in official Magisk Manager app"
	fi
fi
am force-stop __PKGNAME
ui_print "* Optimizing __PKGNAME"
cmd package compile --reset __PKGNAME &

ui_print "* Cleanup"
rm -rf $MODPATH/bin $MODPATH/__PKGNAME.apk $NVBASE/__PKGNAME_rv.apk
for s in "uninstall.sh" "service.sh"; do
	sed -i "2 i\NVBASE=${NVBASE}" $MODPATH/$s
done

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
