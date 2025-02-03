#!/system/bin/sh

if type nsenter >/dev/null 2>/dev/null; then
	ZPID=$(pidof zygote)
	Z64PID=$(pidof zygote64)

	mm() {
		if [ "$ZPID" ]; then nsenter -t "$ZPID" -m -- "$@" || return $?; fi
		if [ "$Z64PID" ]; then nsenter -t "$Z64PID" -m -- "$@" || return $?; fi
	}
else
	mm() { "$@"; }
fi

pmex() {
	OP=$(pm "$@" 2>&1 </dev/null)
	RET=$?
	echo "$OP"
	return $RET
}
