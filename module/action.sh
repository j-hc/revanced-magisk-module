#!/system/bin/sh
MODDIR="$(dirname "$(readlink -f "$0")")"
export MODDIR
. "$MODDIR/utils.sh"

echo ""

DFILE="$MODDIR/disabled_by_action"

MS=$(get_mounts)
if [ -z "$MS" ]; then
	rm -f "$DFILE"
	if mount_rv_now; then
		echo "* Enabled successfully"
	else
		echo "* Failed to enable"
	fi
	echo ""
	echo "$MS"
else
	touch "$DFILE"
	umount_all
	echo "* Disabled successfully"

	ch_desc "⛔ Disabled by action"
fi
