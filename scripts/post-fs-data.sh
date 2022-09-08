#!/system/bin/sh
grep __PKGNAME /proc/self/mountinfo | while read -r line; do
	mount_path=$(echo "$line" | cut -d' ' -f5)
	umount -l "$mount_path"
done
