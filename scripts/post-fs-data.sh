#!/system/bin/sh
grep __PKGNAME /proc/mounts | while read -r line; do
	line=${line#*' '}
	line=${line%%' '*}
	umount -l ${line%%\\*}
done
