#!/bin/bash
set -o nounset   # exit on use of unset variables

APP="xact"
ENV="qc-ep"

CTRL_USER="evodeploy";
CTRL_SERVER="prod-deploy1.visi.gdi"
CTRL_SCRIPT="/var/repo/scripts/release/deployer.rb"
CTRL_ARGS=""
YES="false"
DEFAULT_ACTIONS="checkout extract deploy status purge-checkouts purge-extracts"

usage () {
    echo "USAGE: $0 [options] [actions]"
    echo "options:"
    echo "  -h               Display this message"
    echo "  -e env           environment to control"
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
    echo "Information:"                                                                                                                             
    echo "  version          display the version on each host"
    echo
    echo "Deployment Actions:"
    echo "  checkout         checkout the code (create tarball on ${CTRL_SERVER})"
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
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	version)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	migrate-db-pre|migrate-db-post)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	promote)
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
		    if [[ ! $YES ]]; then
			echo -n "Are you sure you want to execute against ${ENV}? (y/n) "
			read x
			if [[ "$x" != "y" && "$x" != "yes" ]]; then
			    echo "ABORTING..."
			    exit 20
			fi
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
	-c|--control-server)
	    CTRL_SERVER="$2"
	    shift 2;
	    ;;
	-T|-d|-v|-f|-hh)
	    CTRL_ARGS="${CTRL_ARGS} ${1}"        ## add to control args
	    shift;
	    ;;
	-y)
	    CTRL_ARGS="${CTRL_ARGS} ${1}"        ## add to control args
	    YES="true"
	    shift;
	    ;;
	*)
	    echo "Unknown paramater: $1"         ## What'chu talkin' 'bout, Willis?
	    exit 2;
	    ;;
    esac
done


### If no action specified, set default
if [[ ${#actions[@]} == 0 ]]; then 
    echo "Executing Default Remote Actions: ${DEFAULT_ACTIONS[@]}"
    actions="${DEFAULT_ACTIONS[@]}"
fi;

#echo "Remote Actions: ${actions[@]}"
#echo "Control Args:   ${CTRL_ARGS}"

if [[ ${#actions} != 0 ]]; then 
    CMD="${CTRL_SCRIPT} ${CTRL_ARGS} -e ${ENV} -a ${APP} ${actions[@]}"

    echo
    echo "== Executing Command: ${CTRL_USER}@${CTRL_SERVER} [${CMD}] =="
    
    ### Call remote deployer script
    ssh -q -tt "${CTRL_USER}@${CTRL_SERVER}" "${CMD}" || { echo 'deploy failed'; exit 1; }
fi;
