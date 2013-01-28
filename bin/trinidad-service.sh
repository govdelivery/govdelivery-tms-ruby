#!/bin/bash
# chkconfig: 235 30 80
# description: Trinidad Tomcat JRuby Server

# Source function library.
. /etc/rc.d/init.d/functions || exit 5

app="trinidad"
app_name="Trinidad"


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
    su ${user} -s /bin/sh -c "bundle exec \"${app}\" -e \"${environment}\" -p 8080 --monitor \"${pid_dir}/restart.txt\" --ajp  >> ${log_file} 2>&1 & echo "'$!'" > \"${pid_file}\"  "

    i=30
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
        stop
        start
	RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac

exit ${RETVAL}

