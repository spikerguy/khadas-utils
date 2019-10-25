#!/bin/bash

## hyphop ##

#= khadas vims - fan control via user mode i2c
#/

#s https://github.com/hyphop/khadas-utils
#l https://github.com/hyphop/khadas-utils/blob/master/utils/fan
#d https://raw.githubusercontent.com/hyphop/khadas-utils/master/utils/fan

HELP(){ echo "khadas vims - fan control \
USAGE

    fan [ 0 | 1 | 2 | 3 ] 	# set fan speed level from 0 - 3
    fan monitor			# foreground temp monitor 
    fan bg			# background temp monitor - daemon mode
    fan kill			# stop all running fan processes

MORE OPTS

    fan [ on | off ]		# on off fan same as 1 0
    fan [ low | middle | max ]	# fan level  same as 1 2 3
    fan help			# print help

NOTE

    * if fan running as daemon plz dont use manual modes at same time
    * this script writed for tests - and works without any waranty!!!

";}

A=0x18
C=0x88
B=
b=

CMD=

LEVEL_ERROR=-100
LEVEL0=50000
LEVEL1=60000
LEVEL2=70000
LEVEL3=80000

DELTA=1000
DELAY=3
DEFAULT=1


INFO(){
echo "[i] CONSTATS 

LEVEL_ERROR=$LEVEL_ERROR
LEVEL0=$LEVEL0
LEVEL1=$LEVEL1
LEVEL2=$LEVEL2
LEVEL3=$LEVEV3

DELTA=$DELTA
DELAY=$DELAY
DEFAULT=$DEFAULT

"
}

CMD(){
    echo "[#] $@">&2
    $@
}

D="$(dirname $0)"

i2cget=
i2cset=

i2cget=$(which i2cget 2>/dev/null)
i2cset=$(which i2cset 2>/dev/null)

[ "$i2cget" ] || {
[ -f "$D/busybox" ] && {
i2cget="$D/busybox i2cget"
i2cset="$D/busybox i2cset"
}
}

[ "$i2cget" ] || {
[ -f "/opt/busybox" ] && {
i2cget="/opt/busybox i2cget"
i2cset="/opt/busybox i2cset"
}
}

[ "$i2cget" ] || {
    echo "[e] i2c tools not found">&2
    exit 1
}

#which $i2cget 1>/dev/null 2>/dev/null || {
#    echo "[e] need install i2c-tools // apt-get install i2c-tools">&2
#    exit 1
#}

#echo "[i] i2cget: $i2cget">&2
#echo "[i] i2cset: $i2cset">&2

OK=
LOG=/var/log/fan.log

# check i2c bus
for B in /dev/i2c-?; do

#    echo "[i] test $B bus">&2

    [ -c $B ] || {
	echo "[e] i2c devs not found">&2
	exit 1
    }

    b=${B#*-}
    CMD $i2cget -y -f $b $A 1>/dev/null 2>/dev/null && {
	OK=1
    	break
    }
done

[ "$OK" ] || {
    echo "[i] i2c device not found by $A $C">&2
    exit 1
}

#echo "[i] b $B $b ">&2

GET(){
    echo $($i2cget -y $b $A $C b 2>/dev/null)
}


fan_state=

SET(){
    fan_state=$1
    $CMD $i2cset -y $b $A $C $1 b
    echo "[i] set FAN SPEED: $1">&2
}

#echo "[i] $(GET)">&2

[ "$1" ] || {
    HELP
    exit 1
}


AUTO(){

    T=
    for T in /sys/class/thermal/thermal_zone?/temp; do
	[ -f $T ] && break
    done

    [ "$T" ] || {
	echo "[e] temp sensor not found">&2
	exit 1
    }

    ON=

    echo "[i] fan on/off test for 1 sec">&2
    SET 3
    sleep 1
    SET 0
    echo "[i] OK - goto auto LOOP mode">&2

    while [ "1" ] ; do
    while read t ; do

	echo "[i] temp: $t // fan state: $fan_state">&2

	[ "$t" -lt $LEVEL_ERROR ] && {
	    echo "[w] temp senson error">&2
	    continue
	}

	[ "$t" -lt $LEVEL0 ] && {
	    [ "$fan_state" = "0" ] || \
	    SET 0
	    continue
	}

	[ "$t" -lt $LEVEL1 ] && {
	    [ "$t" -gt $((LEVEL0+$DELTA)) ] && {
	    [ "$fan_state" = "1" ] || \
	    SET 1
	    }
	    continue
	}

	[ "$t" -lt $LEVEL2 ] && {
	    [ "$t" -gt $((LEVEL1+$DELTA)) ] && {
	    [ "$fan_state" = "2" ] || \
	    SET 2
	    }
	    continue
	}

	[ "$t" -lt $LEVEL3 ] && {
	    [ "$t" -gt $((LEVEL2+$DELTA)) ] && {
	    [ "$fan_state" = "3" ] || \
	    SET 3
	    }
	    continue
	}

	echo "[e] overheat !!!!">&2

    done < $T
	sleep $DELAY
    done

}

for a in $@; do
case $a in
    on|e*)
    SET $DEFAULT
    ;;
    get|state)
    GET
    ;;
    kill)
    SET 0
    echo "[i] kill bg fan process"
    CMD pkill -f "/fan "
    ;;

    mon*)
    AUTO
    ;;
    daemon|bg)

    AUTO </dev/null 1>$LOG 2>&1 &
    echo "[i] start in bg mode - as $!">&2

    ;;
    1|2|3)
    SET $a
    ;;
    lo*)
    SET 1
    ;;
    mi*)
    SET 2
    ;;
    ma*)
    SET 3
    ;;
    of*|0|d*)
    SET 0
    ;;
    inf*)
    INFO
    ;;
    *)
    HELP
esac
done
