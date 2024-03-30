# shellcheck disable=SC2148,SC2086,SC1091
. $MODPATH/config

ui_print ""
if [ -n "$MODULE_ARCH" ] && [ $MODULE_ARCH != $ARCH ]; then
	abort "ERROR: Wrong arch
Your device: $ARCH
Module: $MODULE_ARCH"
fi

if [ $ARCH = "arm" ]; then
	ARCH_LIB=armeabi-v7a
	alias cmpr='$MODPATH/bin/arm/cmpr'
elif [ $ARCH = "arm64" ]; then
	ARCH_LIB=arm64-v8a
	alias cmpr='$MODPATH/bin/arm64/cmpr'
elif [ $ARCH = "x86" ]; then
	ARCH_LIB=x86
	alias cmpr='$MODPATH/bin/x86/cmpr'
elif [ $ARCH = "x64" ]; then
	ARCH_LIB=x86_64
	alias cmpr='$MODPATH/bin/x64/cmpr'
else
	abort "ERROR: unsupported arch: ${ARCH}"
fi
set_perm_recursive $MODPATH/bin 0 0 0755 0777

if su -M -c true >/dev/null 2>/dev/null; then
	alias mm='su -M -c'
else
	alias mm='nsenter -t1 -m'
fi

mm grep $PKG_NAME /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	mp=${line#* }
	mp=${mp%% *}
	mm umount -l ${mp%%\\*}
done
am force-stop $PKG_NAME

INS=true
if BASEPATH=$(pm path $PKG_NAME); then
	BASEPATH=${BASEPATH##*:}
	BASEPATH=${BASEPATH%/*}
	if [ ${BASEPATH:1:6} = system ]; then
		ui_print "* $PKG_NAME is a system app"
	elif [ ! -d ${BASEPATH}/lib ]; then
		ui_print "* Invalid installation found. Uninstalling..."
		pm uninstall -k --user 0 $PKG_NAME
	elif [ ! -f $MODPATH/$PKG_NAME.apk ]; then
		ui_print "* Stock $PKG_NAME APK was not found"
		VERSION=$(dumpsys package $PKG_NAME | grep -m1 versionName)
		VERSION="${VERSION#*=}"
		if [ "$VERSION" = $PKG_VER ] || [ -z "$VERSION" ]; then
			ui_print "* Skipping stock installation"
			INS=false
		else
			abort "ERROR: Version mismatch
			installed: $VERSION
			module:    $PKG_VER
			"
		fi
	elif cmpr $BASEPATH/base.apk $MODPATH/$PKG_NAME.apk; then
		ui_print "* $PKG_NAME is up-to-date"
		INS=false
	fi
fi

install() {
	if [ ! -f $MODPATH/$PKG_NAME.apk ]; then
		abort "ERROR: Stock $PKG_NAME apk was not found"
	fi
	ui_print "* Updating $PKG_NAME to $PKG_VER"
	settings put global verifier_verify_adb_installs 0
	SZ=$(stat -c "%s" $MODPATH/$PKG_NAME.apk)
	if ! SES=$(pm install-create --user 0 -i com.android.vending -r -d -S "$SZ" 2>&1); then
		ui_print "ERROR: install-create failed"
		abort "$SES"
	fi
	SES=${SES#*[}
	SES=${SES%]*}
	set_perm "$MODPATH/$PKG_NAME.apk" 1000 1000 644 u:object_r:apk_data_file:s0
	if ! op=$(pm install-write -S "$SZ" "$SES" "$PKG_NAME.apk" "$MODPATH/$PKG_NAME.apk" 2>&1); then
		ui_print "ERROR: install-write failed"
		abort "$op"
	fi
	if ! op=$(pm install-commit "$SES" 2>&1); then
		if echo "$op" | grep -q INSTALL_FAILED_VERSION_DOWNGRADE; then
			ui_print "* INSTALL_FAILED_VERSION_DOWNGRADE. Uninstalling..."
			pm uninstall -k --user 0 $PKG_NAME
			return 1
		fi
		ui_print "ERROR: install-commit failed"
		abort "$op"
	fi
	settings put global verifier_verify_adb_installs 1
	if BASEPATH=$(pm path $PKG_NAME); then
		BASEPATH=${BASEPATH##*:}
		BASEPATH=${BASEPATH%/*}
	else
		abort "ERROR: install $PKG_NAME manually and reflash the module"
	fi
}
if [ $INS = true ]; then
	if ! install; then
		if ! install; then
			abort
		fi
	fi
fi

BASEPATHLIB=${BASEPATH}/lib/${ARCH}
if [ -z "$(ls -A1 ${BASEPATHLIB})" ]; then
	ui_print "* Extracting native libs"
	mkdir -p $BASEPATHLIB
	if ! op=$(unzip -j $MODPATH/$PKG_NAME.apk lib/${ARCH_LIB}/* -d ${BASEPATHLIB} 2>&1); then
		ui_print "ERROR: extracting native libs failed"
		abort "$op"
	fi
	set_perm_recursive ${BASEPATH}/lib 1000 1000 755 755 u:object_r:apk_data_file:s0
fi
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting $PKG_NAME"
mkdir -p $NVBASE/rvhc
RVPATH=$NVBASE/rvhc/${MODPATH##*/}.apk
mv -f $MODPATH/base.apk $RVPATH

if ! op=$(mm mount -o bind $RVPATH $BASEPATH/base.apk 2>&1); then
	ui_print "ERROR: Mount failed!"
	ui_print "$op"
fi
am force-stop $PKG_NAME
ui_print "* Optimizing $PKG_NAME"
nohup cmd package compile --reset $PKG_NAME >/dev/null 2>&1 &

ui_print "* Cleanup"
rm -rf ${MODPATH:?}/bin $MODPATH/$PKG_NAME.apk

for s in "uninstall.sh" "service.sh"; do
	sed -i "2 i\NVBASE=${NVBASE}" $MODPATH/$s
done

ui_print "* Done"
ui_print "  by j-hc (github.com/j-hc)"
ui_print " "
