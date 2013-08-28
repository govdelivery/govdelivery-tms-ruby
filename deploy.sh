#!/bin/bash
#

APP="xact"
ENV="qc-ep"

CTRL_USER="evodeploy";
CTRL_SERVER="prod-deploy1.visi.gdi"
CTRL_SCRIPT="/var/repo/scripts/release/deployer.rb"
CTRL_ARGS=""
DEFAULT_ACTIONS="checkout extract stop-sidekiq deploy start-sidekiq status purge-checkouts purge-extracts"

usage () {
    echo "USAGE: $0 [options] [actions]"
    echo "options:"
    echo "  -h               Display this message"
    echo "  -T               Test mode"
    echo "  -d               Pass Debug Mode Flag"
    echo "  -v               Pass Verbose Mode Flag"
    echo
    echo "Control Actions:"
    echo "  start            start all services"
    echo "  stop             stop all services"
    echo "  restart          restart all services"
    echo "  status           check status of all services"
    echo "  start-SERVICE    start SERVICE"
    echo "  stop-SERVICE     stop SERVICE"
    echo "  restart-SERVICE  restart SERVICE"
    echo "  status-SERVICE   check status of SERVICE"
    echo
    echo "Deployment Actions:"
    echo "  checkout         checkout the code (create tarball on prod-deploy1)"
    echo "  extract          extract the code  (extract tarball to target NFS share, create softlinks, bundle install)"
    echo "  deploy           deploy the code   (for each server { stop, update symlink, start })"
    echo "  migrate-db-pre   perform the pre-release database migrations (migrate)"
#    echo "  migrate-db-post  perform the post-release database migrations (data_migrate)"
    echo "  purge-checkouts  purge old copies of checked out code"
    echo "  purge-extracts   purge old copies of extracted code"
    echo
    echo "default actions if not specified: ${DEFAULT_ACTIONS}"
}

declare -a actions

while [ $# -gt 0 ]; do
    case $1 in
	status|start|stop|restart)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift
	    ;;
	status-*|start-*|stop-*|restart-*)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift
	    ;;
	checkout|purge-checkouts)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	extract|purge-extracts)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	deploy)
	    actions[${#actions[@]}]="$1"             ## push on end of actions
	    shift;
	    ;;
	migrate-db-pre|migrate-db-post)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;

#	-a|--application)
#	    APP="${2}"
#	    shift 2;
#	    ;;
	-e|--environment)
	    case $2 in
                poc*|POC*|qc*|QC*|int*|INT*|stg*|STG*)
		    ENV="$2"
		    ;;
		PROD*|prod*)
		    ENV="$2"
		    echo -n "Are you sure you want to deploy to ${ENV}? (y/n) "
		    read x
		    if [[ "$x" != "y" && "$x" != "yes" ]]; then
			echo "ABORTING..."
			exit 20
		    fi
		    ;;
		*)
		    echo "Unknown Environment: $2"
		    exit 2;
		    ;;
	    esac;
	    shift 2
	    ;;
	-h|--help)
	    usage;
	    exit 0;
	    ;;
	-T|-d|-v|-y|-f|-hh)
	    CTRL_ARGS="${CTRL_ARGS} ${1}"        ## add to control args
	    shift;
	    ;;
	*)
	    echo "Unknown paramater: $1"         ## What'chu talkin' 'bout, Willis?
	    exit 2;
	    ;;
    esac
done


### If no action specified, set default
if [[ ${#actions} == 0 ]]; then 
    echo "Executing Default Remote Actions: ${DEFAULT_ACTIONS[@]}"
    actions="${DEFAULT_ACTIONS[@]}"
fi;

#echo "Remote Actions: ${actions[@]}"
#echo "Control Args:   ${CTRL_ARGS}"

if [[ ${#actions} != 0 ]]; then 
    CMD="${CTRL_SCRIPT} ${CTRL_ARGS} -e ${ENV} -a ${APP} ${actions[@]}"

    echo
    echo "== Executing Command: ${CTRL_USER}@${CTRL_SERVER} [${CMD}] =="
    
    ssh -q -tt "${CTRL_USER}@${CTRL_SERVER}" "${CMD}" || { echo 'deploy failed'; exit 1; }
fi;



## This section is temperary until Stage and Production have seperate Trinidad and Sidekiq servers
case "${ENV}" in
    qc*|QC*|int*|INT*)
	echo
	echo "================= sidekiq deploy for ${ENV}"
	echo "${actions[@]}" | grep -q deploy && {
	    CMD="/var/repo/scripts/release/ruby-release-sidekiq.sh ${CTRL_ARGS} -e ${ENV} -a ${APP}"
	    
	    echo
	    echo "== Executing Command: ${CTRL_USER}@${CTRL_SERVER} [${CMD}] =="
	    
	    ssh -q -tt "${CTRL_USER}@${CTRL_SERVER}" "${CMD}" || { echo 'deploy failed'; exit 1; }
	}
	;;
esac
