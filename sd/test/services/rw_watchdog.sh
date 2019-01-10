# This service acts as a watchdog to make sure /tmp/hd1 remains writable

check_mounts() {
	cat /proc/mounts | grep "$1" | grep rw > /dev/null
}

fix_mounts() {
	echo "Loss of RW on $1 at `date`" >> /home/rwlog.txt
	mount /dev/hd1 /home/hd1 -o remount
	mount /home/hd1/record/ /home/hd1/test/http/record/ -o bind -o remount
	echo "Attempted recovery of RW at `date`"
	sync
	sleep 2
	# reboot
}

start() {
	echo "Starting RW check..."
	while true; do
		check_mounts "/tmp/hd1" || fix_mounts "/tmp/hd1"
		sleep 30
	done
}

stop() {
	pkill -TERM -f "`basename $0` start"
}

# Call chosen script in args
"$@"
