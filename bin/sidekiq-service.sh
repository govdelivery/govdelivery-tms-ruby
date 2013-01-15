#!/bin/bash
# chkconfig: 235 30 80
# description: Sidekiq Ruby Background Job Proccessing

# Source function library.
. /etc/rc.d/init.d/functions || exit 5

# Source sidekiq settings
. /etc/sysconfig/sidekiq || exit 5

if [[ -z "$environment" ]]; then
    echo "no environment set!"
    exit 5
fi

export RAILS_ENV=$environment


status () {
    RETVAL=0
    
    pid=""
    if [[ -f "$pid_file" ]]; then
	pid=$(cat "$pid_file")
    fi
    
    if [[ -z $pid ]]; then  ## no known pid
	
	UNMANAGED=$(ps -f -u "${user}" | grep -v grep | grep sidekiq)
	if [[ $? -eq 0 ]]; then
	    echo "PID file not found, but Sidekiq processes are running!"
	    echo "$UNMANAGED"
	    return 10
	else
	    echo "Sidekiq not running"
	    return 1
	fi;
	
    else  ## have an expected pid
	
	MANAGED=$(ps -f --pid $pid --ppid $pid)
	if [[ $? -eq 0 ]]; then
	    echo "Sidekiq Process:"
	    echo "$MANAGED"
	else
	    echo "PID file exists, but no managed sidekiq process found. Removing pid file"
	    rm $pid_file
	    let RETVAL++
	fi
	
	CHILDREN=$(ps -f --ppid $pid)
	if [[ $? -eq 0 ]]; then
	    echo "Sidekiq Children:"
	    echo "$CHILDREN"
	fi
	
	UNMANAGED=$(ps -f -u "${user}" | grep -v grep | grep -v $pid | grep sidekiq)
	if [[ $? -eq 0 ]]; then
	    echo "Found unmanaged Sidekiq processes!"
	    echo "$UNMANAGED"
	    let RETVAL+=10
	fi;
    fi
    return $RETVAL
}

### Start
start () {
    status > /dev/null
    if [[ $? -eq 0 ]]; then 
	echo "Sidekiq already running"
	return 0
    fi

    echo "starting Sidekiq"
    pid_dir=$(dirname $pid_file)
    if [[ ! -d $pid_dir ]]; then
	echo "Creating pid_dir: ${pid_dir}"
	mkdir "${pid_dir}" || exit 5
	chown "${user}" "${pid_dir}" || exit 5
    fi
    
    cd "${app_path}" || exit 5
    su ${user} -s /bin/sh -c "bundle exec sidekiq -P \"${pid_file}\" >> ${app_path}/log/sidekiq.log 2>&1 &"

    sleep 3
    status
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]; then
	echo "Sidekiq failed to start"
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
    status > /dev/null
    if [[ $? -eq 1 ]]; then 
	echo "Sidekiq is not running"
	return 0
    fi
    
    echo "Stopping Sidekiq"
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

    if [[ $RETVAL -ne 1 ]]; then
	echo "Sidekiq failed to stop correctly"
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

