#! /bin/sh
### BEGIN INIT INFO
# Provides:     redis-server
# Required-Start:   $syslog $remote_fs
# Required-Stop:    $syslog $remote_fs
# Should-Start:     $local_fs
# Should-Stop:      $local_fs
# Default-Start:    2 3 4 5
# Default-Stop:     0 1 6
# Short-Description:    redis-server - Persistent key-value db
# Description:      redis-server - Persistent key-value db
### END INIT INFO


PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/redis-server
DAEMON_ARGS=/etc/redis/redis.conf
NAME=redis-server
DESC=redis-server

RUNDIR=/var/run/redis
PIDFILE=$RUNDIR/redis-server.pid

test -x $DAEMON || exit 0

set -e

if [ "$2" = "" ]; then
    INSTANCES=$( cd /etc/redis; for f in redis.*.conf; do echo "$f" | sed -e 's/^redis\.//; s/\.conf//'; done )
else
    INSTANCES="$2"
fi

case "$1" in
  start)
    echo -n "Starting $DESC: "
    mkdir -p $RUNDIR
    for inst in $INSTANCES; do
        PIDFILE=$RUNDIR/redis-server.$inst.pid
        CONF=/etc/redis/redis.$inst.conf
        touch $PIDFILE
        chown redis:redis $RUNDIR $PIDFILE
        chmod 755 $RUNDIR
        if start-stop-daemon --start --quiet --umask 007 --pidfile $PIDFILE --chuid redis:redis --exec $DAEMON -- $CONF
        then
            echo "$NAME."
        else
            echo "failed"
        fi
    done
    ;;
  stop)
    echo -n "Stopping $DESC: "
    for inst in  $INSTANCES; do
        PIDFILE=$RUNDIR/redis-server.$inst.pid
        if start-stop-daemon --stop --retry forever/QUIT/1 --quiet --oknodo --pidfile $PIDFILE --exec $DAEMON
        then
            echo "$NAME."
        else
            echo "failed"
        fi
        rm -f $PIDFILE
    done
    ;;

  restart|force-reload)
    ${0} stop $INSTANCES
    ${0} start $INSTANCES
    ;;

  status)
    echo -n "$DESC is "
    for inst in $INSTANCES; do
        PIDFILE=$RUNDIR/redis-server.$inst.pid
        if start-stop-daemon --stop --quiet --signal 0 --name ${NAME} --pidfile ${PIDFILE}
        then
            echo "running"
        else
            echo "not running"
        fi
    done
    ;;

  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload} [INTANCES]" >&2
    exit 1
    ;;
esac

exit 0