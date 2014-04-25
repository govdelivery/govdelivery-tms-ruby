#!/bin/bash
# chkconfig: 2345 98 02
# description: Sidekiq Ruby Background Job Proccessing

### BEGIN INIT INFO
# Provides: Sidekiq
# Required-Start: 
# Defalt-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Sidekiq Ruby Background Job Proccessing
### END INIT INFO


# Source function library.
. /etc/rc.d/init.d/functions || exit 5

app="sidekiq"
app_name="Sidekiq"
jmx_port="3020"

JMX_ARGS="-J-Dcom.sun.management.jmxremote=true -J-Dcom.sun.management.jmxremote.port=${jmx_port} -J-Dcom.sun.management.jmxremote.authenticate=false -J-Dcom.sun.management.jmxremote.ssl=false"
# JMX_ARGS="${JMX_ARGS} -J-Djava.rmi.server.hostname=poc-xact1"
JAVA_ARGS="-J-XX:+UseConcMarkSweepGC -J-XX:+CMSClassUnloadingEnabled -J-XX:MaxPermSize=512m"


# Source Application settings
. /etc/sysconfig/${app} || exit 5

if [[ -z "$environment" ]]; then
    echo "no environment set!"
    exit 5
fi

export RAILS_ENV=$environment
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

    pid_dir=$(dirname $pid_file)
    if [[ ! -d $pid_dir ]]; then
	echo "Creating pid_dir: ${pid_dir}"
	mkdir "${pid_dir}" || exit 5
	chown "${user}" "${pid_dir}" || exit 5
    fi
    
    cd "${app_path}" || exit 5

    umask 0003;
    su ${user} -s /bin/sh -c "bundle exec jruby ${JMX_ARGS} ${JAVA_ARGS} -S \"${app}\" -P \"${pid_file}\" >> ${log_file} 2>&1 &"

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

### Tell sidekiq to stop accepting new jobs.
quiet () {   
    status > /dev/null
    if [[ $? -eq 1 ]]; then 
	echo "Sidekiq is not running"
	return 0
    fi
    
    cd "${app_path}" || exit 5
    su ${user} -s /bin/sh -c "bundle exec sidekiqctl quiet \"${pid_file}\" ${deadline_timeout}"
    RETVAL=$?
    return ${RETVAL}
}

### Stop
stop () {
    [[ $(whoami) == "root" ]] || { echo "Must be root"; exit 2; }

    status > /dev/null
    if [[ $? -eq 1 ]]; then 
	echo "${app_name} is not running"
	return 0
    fi
    
    echo "Stopping ${app_name}"
    echo "$(date) Stopping ${app_name}" >> "${log_file}"

    cd "${app_path}" || exit 5
    su ${user} -s /bin/sh -c "bundle exec sidekiqctl stop \"${pid_file}\" ${deadline_timeout}"
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]; then
	echo "Problem with Stop"
	return $RETVAL
    fi;

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



case "$1" in
  start)
        start
	RETVAL=$?
	;;
 quiet)
	quiet
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
	quiet
        stop
        start
	RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac

exit ${RETVAL}

