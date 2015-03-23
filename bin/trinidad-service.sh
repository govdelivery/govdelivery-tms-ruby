#!/bin/bash
# chkconfig: 2345 98 02
# description: Trinidad Tomcat JRuby Server

### BEGIN INIT INFO
# Provides: Trinidad
# Required-Start:
# Defalt-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Trinidad Tomcat JRuby Server
### END INIT INFO


# Source function library.
. /etc/rc.d/init.d/functions || exit 5

app="trinidad"
app_name="Trinidad"
jmx_port="3019"

JMX_ARGS="-J-Dcom.sun.management.jmxremote=true -J-Dcom.sun.management.jmxremote.port=${jmx_port} -J-Dcom.sun.management.jmxremote.authenticate=false -J-Dcom.sun.management.jmxremote.ssl=false"
# JMX_ARGS="${JMX_ARGS} -J-Djava.rmi.server.hostname=poc-xact1"
JAVA_ARGS="-J-XX:+UseConcMarkSweepGC -J-XX:+CMSClassUnloadingEnabled -J-XX:MaxPermSize=256m"

# Source Application settings
test -f /etc/sysconfig/trinidad.sh && source /etc/sysconfig/trinidad.sh
test -f /etc/sysconfig/xact.sh && source /etc/sysconfig/xact.sh

pid_dir=$(dirname $pid_file)
restart_file="${pid_dir}/restart-trinidad.txt"

if [[ -z "$APP_ENVIRONMENT" ]]; then
    echo "no environment set!"
    exit 5
fi

export RAILS_ENV=$APP_ENVIRONMENT
export REDIS_NAMESPACE_QUIET=1

log_file="${app_path}/log/${app}.log"

status () {
    RETVAL=0

    pid=""
    if [[ -f "$pid_file" ]]; then
        pid=$(cat "$pid_file")
    fi

    if [[ -z $pid ]]; then  ## no known pid

        UNMANAGED=$(ps -f -u "${user}" | grep -v grep | grep ${app})
        if [[ $? -eq 0 ]]; then
            echo "PID file not found, but ${app_name} processes are running!"
            echo "$UNMANAGED"
            return 10
        else
            echo "${app_name} not running"
            return 1
        fi;

    else  ## have an expected pid

        MANAGED=$(ps -f --pid $pid --ppid $pid)
        if [[ $? -eq 0 ]]; then
            echo "${app_name} Process:"
            echo "$MANAGED"
        else
            echo "PID file exists, but no managed ${app_name} process found. Removing pid file"
            rm $pid_file
            let RETVAL++
        fi

        CHILDREN=$(ps -f --ppid $pid)
        if [[ $? -eq 0 ]]; then
            echo "${app_name} Children:"
            echo "$CHILDREN"
        fi

        UNMANAGED=$(ps -f -u "${user}" | grep -v grep | grep -v $pid | grep ${app})
        if [[ $? -eq 0 ]]; then
            echo "Found unmanaged ${app_name} processes!"
            echo "$UNMANAGED"
            let RETVAL+=10
        fi;
    fi
    return $RETVAL
}

### Start
start () {
    [[ $(whoami) == "root" ]] || { echo "Must be root"; exit 2; }

    status > /dev/null
    if [[ $? -eq 0 ]]; then
        echo "${app_name} already running"
        return 0
    fi

    echo "Starting ${app_name}"
    echo "$(date) Starting ${app_name}" >> "${log_file}"
    chown "${user}:${user}" "${log_file}" || exit 5

    if [[ ! -d $pid_dir ]]; then
          echo "Creating pid_dir: ${pid_dir}"
          mkdir "${pid_dir}" || exit 5
          chown "${user}" "${pid_dir}" || exit 5
    fi

    cd "${app_path}" || exit 5

    umask 0003;
    su ${user} -s /bin/sh -c "bundle exec jruby ${JMX_ARGS} ${JAVA_ARGS} -S \"script/${app}\" -e \"${environment}\" -p 8080 --monitor \"${restart_file}\" --ajp >> ${log_file} 2>&1 & echo "'$!'" > \"${pid_file}\"  "

    i=60
    RETVAL=1
    while [[ i -gt 0 && $RETVAL -ne 0 ]]; do
        sleep 1
        status > /dev/null
        RETVAL=$?
        let i--
    done

    status
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]; then
        echo "${app_name} failed to start"
    fi;

    return ${RETVAL}
}


### Stop
stop () {
    [[ $(whoami) == "root" ]] || { echo "Must be root"; exit 2; }

    status > /dev/null
    stat="$?"
    case $stat in
        1)
            echo "${app_name} is not running"
            return 0
            ;;
        0)
            echo "Stopping ${app_name}"
            echo "$(date) Stopping ${app_name}" >> "${log_file}"

            cd "${app_path}" || exit 5
            pid=$(cat "$pid_file")
            echo "killing ${pid}"
            kill "${pid}"
            ;;
        1[01])
            echo "ERROR: Found unmanaged ${app_name} processes"
            status
            echo "ERROR: Can't stop!"
            return $stat
            ;;
    esac;

    i=10
    RETVAL=0
    while [[ i -gt 0 && $RETVAL -ne 1 ]]; do
        sleep 1
        status > /dev/null
        RETVAL=$?
        let i--
    done

    if [[ $RETVAL -eq 1 ]]; then
        echo "${app_name} stopped"
        return 0
    else
        echo "${app_name} failed to stop correctly"
        return 1
    fi;
    return 0
}

restart () {
    stop
    start
}

reload () {
    start
    touch ${restart_file}
}


case "$1" in
  start)
        start
        RETVAL=$?
        ;;
  stop)
        stop
        RETVAL=$?
        ;;
  status)
        status
        RETVAL=$?
        ;;
  restart)
        restart
        RETVAL=$?
        ;;
  reload)
         reload
        RETVAL=$?
          ;;
  *)
        echo $"Usage: $0 {start|stop|restart|reload|status}"
        exit 1
esac

exit ${RETVAL}
