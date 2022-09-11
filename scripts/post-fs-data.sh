#!/system/bin/sh
grep __PKGNAME /proc/self/mountinfo | while read -r line; do
	mountpoint=$(echo "$line" | cut -d' ' -f5)
	umount -l "${mountpoint%%\\*}"
done
