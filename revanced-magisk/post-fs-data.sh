#!/system/bin/sh
grep com.google.android.apps.youtube.music /proc/mounts | while read -r line; do
	echo "$line" | cut -d" " -f2 | xargs -r umount -l
done
