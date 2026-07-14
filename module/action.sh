#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/utils.sh"

DFILE="$MODDIR/disabled_by_action"

if [ -z "$(get_mounts)" ]; then
	rm -f "$DFILE"
	if mount_nosleep; then
		echo "* Enabled successfully"
		cp -f "$MODDIR/module.prop.orig" "$MODDIR/module.prop"
	else
		echo "* Failed"
	fi
	echo ""
	get_mounts
else
	touch "$DFILE"
	umount_all
	echo "* Disabled"

	ch_desc "⛔ Disabled by action"
fi
