#!/bin/bash
: ${1?"Usage: '$0 \$pid' should supply a PID"}

JDK_BIN=""
PID=$1
DUMP_DATE=`date +%Y%m%d%H%M%S`
DUMP_DIR=`hostname`"-"$DUMP_DATE

function dot(){
	echo -e ".\c"
}

if [ ! -d $DUMP_DIR ]; then
	mkdir $DUMP_DIR
fi

echo -e "Dumping $PID to the $DUMP_DIR...\c"

# resource

lsof -p $PID > $DUMP_DIR/lsof-$PID.dump
dot

ss -antp > $DUMP_DIR/ss.dump 2>&1
dot


netstat -s > $DUMP_DIR/netstat-s.dump 2>&1
dot

iostat -x > $DUMP_DIR/iostat.dump 2>&1
dot

mpstat > $DUMP_DIR/mpstat.dump 2>&1
dot

vmstat 1 3 > $DUMP_DIR/vmstat.dump 2>&1
dot

free -h > $DUMP_DIR/free.dump 2>&1
dot

sar -n DEV 1 2 > $DUMP_DIR/sar-traffic.dump 2>&1
dot

sar -p ALL  > $DUMP_DIR/sar-cpu.dump  2>&1
dot

sysctl -a > $DUMP_DIR/sysctl.dump 2>&1
dot

uptime > $DUMP_DIR/uptime.dump 2>&1
dot

ps -ef > $DUMP_DIR/ps.dump 2>&1
dot

dmesg > $DUMP_DIR/dmesg.dump 2>&1
dot

top -Hp $PID -b -n 1 -c >  $DUMP_DIR/top-$PID.dump 2>&1
dot

# java
kill -3 $PID
dot

${JDK_BIN}jinfo $PID > $DUMP_DIR/jinfo.dump 2>&1
dot

${JDK_BIN}jstack $PID > $DUMP_DIR/jstack.dump 2>&1
dot

${JDK_BIN}jstat -gcutil $PID > $DUMP_DIR/jstat-gcutil.dump 2>&1
dot

${JDK_BIN}jstat -gccapacity $PID > $DUMP_DIR/jstat-gccapacity.dump 2>&1
dot

${JDK_BIN}jmap $PID > $DUMP_DIR/jmap.dump 2>&1
dot

${JDK_BIN}jmap -heap $PID > $DUMP_DIR/jmap-heap.dump 2>&1
dot

${JDK_BIN}jmap -histo $PID > $DUMP_DIR/jmap-histo.dump 2>&1
dot

${JDK_BIN}jmap -dump:format=b,file=$DUMP_DIR/heap.bin $PID > /dev/null  2>&1
dot

# advance

if [ ! -f  $DUMP_DIR/jmap-heap.dump ]; then
	gcore -o $DUMP_DIR/core $PID
	dot
	#${JDK_BIN}jhsdb jmap --exe ${JDK}java  --core $DUMP_DIR/core --binaryheap
fi

echo "OK!"
echo "DUMP: $DUMP_DIR"
