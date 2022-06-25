while [ "$(getprop sys.boot_completed)" != 1 ];
do sleep 1;
done;

# >A11
YTPATH=$(readlink -f /data/app/*/com.google.android.youtube*/oat | sed 's/\/oat//g')

if [ ! -z "$YTPATH" ]
then
	su -c mount $MODDIR/revanced-base.apk $YTPATH/base.apk
else
	# <A11
	YTPATH=$(readlink -f /data/app/com.google.android.youtube*/oat | sed 's/\/oat//g')
	
	if [ ! -z "$YTPATH" ]
	then
		su -c mount $MODDIR/revanced-base.apk $YTPATH/base.apk
	fi
fi
