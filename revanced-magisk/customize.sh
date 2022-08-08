# shellcheck disable=SC2148,SC2086,SC2115
ui_print ""
am force-stop com.google.android.apps.youtube.music
grep com.google.android.apps.youtube.music /proc/mounts | while read -r line; do
	ui_print "* Un-mount"
	echo "$line" | cut -d" " -f2 | xargs -r umount -l
done
pm uninstall com.google.android.apps.youtube.music >/dev/null 2>&1 && ui_print "* Uninstalled current com.google.android.apps.youtube.music"

ui_print "* Installing stock com.google.android.apps.youtube.music APK"
set_perm $MODPATH/stock.apk 0 0 644 u:object_r:apk_data_file:s0
if ! op=$(pm install -r -g $MODPATH/stock.apk 2>&1); then
	ui_print "ERROR: APK installation failed!"
	abort "${op}"
fi

ui_print "* Patching com.google.android.apps.youtube.music (v5.17.51) on the fly"
BASEPATH=$(pm path com.google.android.apps.youtube.music | grep base | cut -d: -f2)
[ -z "$BASEPATH" ] && abort "ERROR: Base path not found!"

if [ "$ARCH" = "arm" ]; then
	export LD_LIBRARY_PATH=$MODPATH/lib/arm
	ln -s $MODPATH/xdelta_arm $MODPATH/xdelta
elif [ "$ARCH" = "arm64" ]; then
	export LD_LIBRARY_PATH=$MODPATH/lib/aarch64
	ln -s $MODPATH/xdelta_aarch64 $MODPATH/xdelta
else
	abort "ERROR: unsupported arch: ${ARCH}"
fi
chmod +x $MODPATH/xdelta
if ! op=$($MODPATH/xdelta -d -f -s $BASEPATH $MODPATH/rvc.xdelta $MODPATH/base.apk 2>&1); then
	ui_print "ERROR: Patching failed!"
	abort "$op"
fi
ui_print "* Patching done"
ui_print "* Setting Permissions"
set_perm $MODPATH/base.apk 1000 1000 644 u:object_r:apk_data_file:s0

ui_print "* Mounting com.google.android.apps.youtube.music"
if ! op=$(mount -o bind $MODPATH/base.apk $BASEPATH 2>&1); then
	ui_print "ERROR: Mount failed!"
	abort "$op"
fi

ui_print " "
rm -r $MODPATH/lib $MODPATH/*xdelta* $MODPATH/stock.apk
am force-stop com.google.android.apps.youtube.music
