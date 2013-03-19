#!/bin/bash
#

APP="xact"
ENV="stg-ep"

CTRL_USER="evodeploy";
CTRL_SERVER="prod-deploy1.visi.gdi"
CTRL_SCRIPT="/var/repo/scripts/release/deployer.rb"
CTRL_ARGS=""
DEFAULT_ACTIONS="checkout extract stop-sidekiq deploy start-sidekiq status purge-checkouts purge-extracts"
DEFAULT_LOCAL_ACTIONS="run-tests"
BUILD_URL="http://qa-automation.stp01.office.gdi/job/90_TSMS_Client_Test/build"

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
    echo "  migrate-db-pre   perform the pre-release database migrations (migrate)"
#    echo "  migrate-db-post  perform the post-release database migrations (data_migrate)"
    echo "  purge-checkouts  purge old copies of checked out code"
    echo "  purge-extracts   purge old copies of extracted code"
    echo
    echo "Local Actions (Note, always run last)"
    echo "  run-tests        start integration tests on build server" 
    echo
    echo "default actions if not specified: ${DEFAULT_ACTIONS} ${DEFAULT_LOCAL_ACTIONS}"
}

declare -a actions
declare -a local_actions

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
	checkout|extract)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	deploy)
	    actions[${#actions[@]}]="stop-sidekiq"   ## push on end of actions
	    actions[${#actions[@]}]="$1"             ## push on end of actions
	    actions[${#actions[@]}]="start-sidekiq"  ## push on end of actions
	    shift;
	    ;;
#	migrate-db-pre|migrate-db-post)
	migrate-db-pre)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	purge-checkouts|purge-extracts)
	    actions[${#actions[@]}]="$1"         ## push on end of actions
	    shift;
	    ;;
	run-tests)
	    local_actions[${#local_actions[@]}]="$1"         ## push on end of local_actions
	    shift;
	    ;;
	-e|--environment)
	    case $2 in
		POC*|poc*)
		    ENV="$2"
		    ;;
		QC*|qc*)
		    ENV="$2"
		    ;;
		STG*|stg*)
		    ENV="$2"
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
	    BUILD_URL="http://www.google.com"    ## Set BUILD_URL to something that will return 200
	    ;;
	*)
	    echo "Unknown paramater: $1"         ## What'chu talkin' 'bout, Willis?
	    exit 2;
	    ;;
    esac
done


### If no action specified, set default
if [[ ${#actions} == 0 && ${#local_actions} == 0 ]]; then 
    echo "Executing Default Remote Actions: ${DEFAULT_ACTIONS[@]}"
    echo "          Default Local Actions:  ${DEFAULT_LOCAL_ACTIONS[@]}"
    actions="${DEFAULT_ACTIONS[@]}"
    local_actions="${DEFAULT_LOCAL_ACTIONS[@]}"
fi;

#echo "Remote Actions: ${actions[@]}"
#echo "Local Actions:  ${local_actions[@]}"
#echo "Control Args:   ${CTRL_ARGS}"

if [[ ${#actions} != 0 ]]; then 
    CMD="${CTRL_SCRIPT} ${CTRL_ARGS} -e ${ENV} -a ${APP} ${actions[@]}"

    echo
    echo "== Executing Command: ${CTRL_USER}@${CTRL_SERVER} [${CMD}] =="
    
    ssh -q -tt "${CTRL_USER}@${CTRL_SERVER}" "${CMD}" || { echo 'deploy failed'; exit 1; }
fi;

if [[ ${#local_actions} != 0 ]]; then 
    for action in "${local_actions[@]}"; do
	case ${action} in 
	    run-tests)
		echo
		echo "Starting tests on build server..." 
		response=$(curl -sL -w "%{http_code}\\n" "${BUILD_URL}" -o /dev/null)
		if [[ ${response} == 200 ]]; then
		    echo "Integration tests started."
		else
		    echo "Could not start integration tests!";
		    echo "  URL used:      ${BUILD_URL}"
		    echo "  Curl response: ${response}"
		    exit 1
		fi
		;;

	    *)
		echo "Unknown Action: $action"
		exit 2;
		;;
	esac;
    done
fi


