#!/system/bin/sh
grep __PKGNAME /proc/mounts | while read -r line; do
	echo "$line" | cut -d" " -f2 | xargs -r umount -l
done
