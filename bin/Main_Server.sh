#! /bin/bash
#
# network Bring up/down networking
#
# chkconfig: 345 20 80
# description: Starts and stops the MongoDB
#
# /etc/rc.d/init.d/mongodb

APP_HOME=/home/dst/backup/kasun/dst/Framework

# Use LSB init script functions for printing messages, if possible
#
lsb_functions="/lib/lsb/init-functions"
if test -f $lsb_functions ; then
  . $lsb_functions
else
  log_success_msg()
  {
    echo " SUCCESS! $@"
  }
  log_failure_msg()
  {
    echo " ERROR! $@"
  }
fi
start(){
        cd $APP_HOME/src
        perl server_main.pl >/dev/null &
        sleep 3s
        count=`ps -ef|grep "Schedule\:\:Cron MainLoop"|grep -v grep|wc -l`
        if [ $count -ge 1 ]; then
                log_success_msg "Service gr_main server started"
                exit 0
        else
                log_failure_msg "Service gr_main server didn't started"
                exit 1
        fi
}
stop(){
        #APP_PID=`ps -ef|grep 'Schedule::Cron MainLoop'|grep -v grep|awk '{print $2}'`
	#kill -9 $APP_PID
	ps -ef | grep 'Schedule::Cron MainLoop' | grep -v grep | awk '{print $2}' | xargs kill
	if [ $? -eq 0 ]; then
                log_success_msg "Service main-server stoped. Checked logs for more info"
                exit 0
        else
                log_failure_msg "Service main-server didn't stoped. Checked logs for more info"
                exit 1
        fi
}
restart(){
        stop
        sleep 3s
        start
}
status(){
        count=`ps -ef|grep "Schedule::Cron MainLoop"|grep -v grep|wc -l`
        if [ $count -ge 1 ]; then
                log_success_msg "Service gr_main_server active"
                exit 0
        else
                log_failure_msg "Service gr_main_server no running"
                exit 1
        fi
}
case $1 in
        start)
                start
                ;;
        stop)
                stop
                ;;
        restart)
                restart
                ;;
        status)
                status
                ;;
        *)
                echo "Usage sdp-server start|stop|status|restart"
esac
