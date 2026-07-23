#!/system/bin/sh
MODDIR="$(dirname "$(readlink -f "$0")")"
export MODDIR
. "$MODDIR/utils.sh"

echo ""

DFILE="$MODDIR/disabled_by_action"

if [ -z "$(get_mounts)" ]; then
	rm -f "$DFILE"
	if mount_rv_now; then
		echo "* Enabled successfully"
		cp -f "$MODDIR/module.prop.orig" "$MODDIR/module.prop"
	else
		echo "* Failed to enable"
	fi
	echo ""
	get_mounts
else
	touch "$DFILE"
	umount_all
	echo "* Disabled successfully"

	ch_desc "⛔ Disabled by action"
fi
