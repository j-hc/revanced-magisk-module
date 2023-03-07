# shellcheck disable=SC2148,SC2086
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

nsenter -t1 -m grep __PKGNAME /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	mp=${line#* }
	mp=${mp%% *}
	nsenter -t1 -m umount -l ${mp%%\\*}
done
am force-stop __PKGNAME

INS=true
if BASEPATH=$(pm path __PKGNAME); then
	BASEPATH=${BASEPATH##*:}
	BASEPATH=${BASEPATH%/*}
	if [ ${BASEPATH:1:6} = system ]; then
		ui_print "* __PKGNAME is a system app"
	elif [ ! -d ${BASEPATH}/lib ]; then
		ui_print "* Invalid installation found. Uninstalling..."
		pm uninstall -k --user 0 __PKGNAME
	elif cmpr $BASEPATH/base.apk $MODPATH/__PKGNAME.apk; then
		ui_print "* __PKGNAME is up-to-date"
		INS=false
	fi
fi
if [ $INS = true ]; then
	ui_print "* Updating __PKGNAME (v__PKGVER)"
	SZ=$(stat -c "%s" $MODPATH/__PKGNAME.apk)
	if ! SES=$(pm install-create --user 0 -i com.android.vending -r -d -S "$SZ" 2>&1); then
		ui_print "ERROR: session creation failed"
		abort "$SES"
	fi
	SES=${SES#*[}
	SES=${SES%]*}
	set_perm "$MODPATH/__PKGNAME.apk" 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install-write -S "$SZ" "$SES" "__PKGNAME.apk" "$MODPATH/__PKGNAME.apk" 2>&1); then
		ui_print "ERROR: install-write failed"
		abort "$op"
	fi
	if ! op=$(pm install-commit "$SES" 2>&1); then
		ui_print "ERROR: install-commit failed"
		abort "$op"
	fi
	if BASEPATH=$(pm path __PKGNAME); then
		BASEPATH=${BASEPATH##*:}
		BASEPATH=${BASEPATH%/*}
	else
		abort "ERROR: install __PKGNAME manually and reflash the module"
	fi
fi
BASEPATHLIB=${BASEPATH}/lib/${ARCH}
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

if ! op=$(nsenter -t1 -m mount -o bind $RVPATH $BASEPATH/base.apk 2>&1); then
	ui_print "ERROR: Mount failed!"
	ui_print "$op"
fi
am force-stop __PKGNAME
ui_print "* Optimizing __PKGNAME"
nohup cmd package compile --reset __PKGNAME >/dev/null 2>&1 &

ui_print "* Cleanup"
rm -rf $MODPATH/bin $MODPATH/__PKGNAME.apk

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
