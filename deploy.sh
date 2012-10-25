#!/bin/bash

APP="tsms"
ENV="stg"

CTRL_USER="evodeploy";
CTRL_SERVER="prod-deploy1.visi.gdi"
CTRL_SCRIPT="/var/repo/scripts/release/deployer.rb"
CTRL_ARGS=""

DEFAULT_ACTIONS="checkout extract deploy status purge-checkouts purge-extracts"

usage () {
    echo "USAGE: $0 [options] [actions]"
    echo "options:"
    echo "  -h               Display this message"
    echo "  --help           Display this message"
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
    echo "  checkout         checkout the code"
    echo "  extract          extract the code"
    echo "  deploy           deploy the code"
#    echo "  migrate-db-pre   perform the pre-release database migrations (migrate)"
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
	checkout|extract|deploy)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
#	migrate-db-pre|migrate-db-post)
#	    actions[${#actions[@]}]="$1"         ## push on end of actions
#	    shift;
#	    ;;
	purge-checkouts|purge-extracts)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	-e|--environment)
	    case $2 in
		POC|poc)
		    ENV="poc"
		    ;;
		QC|qc)
		    ENV="qc"
		    ;;
		STG|stg)
		    ENV="stg"
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
	-T|-d|-v)
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
    echo "Executing Default Actions: ${DEFAULT_ACTIONS[@]}"
    actions="${DEFAULT_ACTIONS[@]}"
fi;

##echo ${actions[@]}
##echo ${CTRL_ARGS}

CMD="${CTRL_SCRIPT} ${CTRL_ARGS} -e ${ENV} -a ${APP} ${actions[@]}"

echo
echo "== Executing Command: ${CTRL_USER}@${CTRL_SERVER} [${CMD}] =="

ssh -q -tt "${CTRL_USER}@${CTRL_SERVER}" "${CMD}"
