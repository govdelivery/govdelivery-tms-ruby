#!/bin/bash
#
# Use null operator ':' and default variable assignment to allow
# overrideable environment variables
_NAME=$(basename $0)
_NAME=${_NAME/.sh/}

# Oracle directory
: ${ORACLE_HOME:="/opt/oracle/instantclient_11_2"}
: ${TNS_ADMIN:="/opt/oracle/instantclient_11_2"}

# Application Directory
: ${XACT_DIR:="/opt/xact/current"}
: ${SCRIPT_DIR:="${XACT_DIR}/bin"}
: ${REPORT_DIR:="${XACT_DIR}/public/custom_reports"}

# Ruby environment
: ${RAILS_ENV:="production"}

: ${JRUBY_HOME:="/opt/jruby/jruby-1.7.2"}
: ${JAVA:="java"}
JAVA_OPTS="-Djffi.boot.library.path=${JRUBY_HOME}/lib/native/arm-Linux:${JRUBY_HOME}/lib/native/i386-Linux:${JRUBY_HOME}/lib/native/x86_64-Linux -Xbootclasspath/a:${JRUBY_HOME}/lib/jruby.jar -classpath :${XACT_DIR}/bundle/jruby/1.9 -Djruby.home=${JRUBY_HOME} -Djruby.lib=${JRUBY_HOME}/lib -Djruby.script=jruby -Djruby.shell=/bin/sh"

# Email log file to
: ${MAILTO:="productionsupport@govdelivery.com"}

# Log for errors
LOG="$(mktemp --tmpdir ${_NAME}-XXXX)"
function cleanup() {
    rm -f $LOG
}
trap cleanup EXIT

# Log to file and direct copy to stderr
function log() {
    echo "$@" | tee -a $LOG >&2
}

function build_report() {
    _output=$1; shift
    _script=$1; shift
    _script_opts=$@

    if [[ ! -e $_script ]] ; then
	log "Script $_script not found. Skipping."
	return
    fi
    # Change in the working directory
    cd ${XACT_DIR}

    # Yes, for some reason the environment variables need to be
    # assigned here as they're passed to Java rather than exported
    # above.
    ORACLE_HOME=${ORACLE_HOME} TNS_ADMIN=${TNS_ADMIN} RAILS_ENV=${RAILS_ENV} \
	${JAVA} ${JAVA_OPTS} org.jruby.Main $_script $_script_opts 2>>$LOG | grep -v 'Tomcat' > $_output
    if [[ $? -ne 0 ]] ; then
	log "Error: build_report($_output, $_script, $_script_opts)"
    fi
}

function usage() {
    cat <<EOF >&2
Usage: [RAILS_ENV=ENVIRONMENT] $0 {24hr|reporting|deliverability|opens|clicks}

Run json generating scripts to drop Geckoboard reports in
${XACT_HOME}/public/custom_reports directory.

Email errors to MAILTO=${MAILTO}.

SCRIPT           DESCRIPTION
                 LOCATION
24hr             Sends last 24 hours
                 ${REPORT_DIR}/uscmshim_24h_sends.json
reporting |
deliverability   Simple numbers in deliverability?
                 ${REPORT_DIR}/uscmshim_reporting.json

opens            Number of opens in last 24 hours
                 ${REPORT_DIR}/uscmshim_opens_reporting.json

clicks           Number of clicks in last 24 hours
                 ${REPORT_DIR}/uscmshim_clicks_reporting.json
EOF
}

# Make sure the directories exist before starting
for d in ${XACT_DIR} ${ORACLE_HOME} ${TNS_ADMIN} ${REPORT_DIR} ${SCRIPT_DIR} ; do
    if [[ ! -d ${d} ]] ; then
	echo "Directory ${d} does not exist. Exiting." >&2
	exit 1
    fi
done

# test arguments
if [[ $# -lt 1 ]] ; then
    usage
    exit 0
fi

# select and build the report
case $1 in
    24*) build_report ${REPORT_DIR}/uscmshim_24h_sends.json ${SCRIPT_DIR}/script.rb ;;
    deliver*|report*) build_report ${REPORT_DIR}/uscmshim_reporting.json ${SCRIPT_DIR}/uscmshim_reporting.rb -d ;;
    open*) build_report ${REPORT_DIR}/uscmshim_opens_reporting.json ${SCRIPT_DIR}/uscmshim_reporting.rb -o ;;
    click*) build_report ${REPORT_DIR}/uscmshim_clicks_reporting.json ${SCRIPT_DIR}/uscmshim_reporting.rb -c ;;
    *) usage ; exit 1 ;;
esac

# Email the errors if something happened
if [[ $? -ne 0 ]] ; then
    if (type mailx 2>&1 >/dev/null) && [[ -s ${LOG} ]] ; then
	mailx -s "${_NAME} Error Report" ${MAILTO} < ${LOG}
    fi
fi
# END
