#!/system/bin/sh

if type nsenter >/dev/null 2>/dev/null; then
	ZPID=$(pidof zygote)
	Z64PID=$(pidof zygote64)

	mz() {
		if [ "$ZPID" ]; then nsenter -t "$ZPID" -m -- "$@" || return $?; fi
		if [ "$Z64PID" ]; then nsenter -t "$Z64PID" -m -- "$@" || return $?; fi
	}
	mm() { nsenter -t 1 -m -- "$@"; }
else
	mz() { "$@"; }

	if su -M -c true >/dev/null 2>/dev/null; then
		mm() { su -M -c "$@"; }
	else
		mm() { "$@"; }
	fi
fi

pmex() {
	OP=$(pm "$@" 2>&1 </dev/null)
	RET=$?
	echo "$OP"
	return $RET
}
