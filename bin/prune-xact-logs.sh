#!/bin/bash

DEBUG="false"
TEST="false"

while [ $# -ne 0 ]; do
    case "$1" in
	-d|-D) DEBUG="true"; shift; ;;
	-t|-T) TEST="true";  shift; ;;
	*)  echo "Unknown parameter: $1"; exit 1; ;;
    esac;
done;

declare -ax LOGDIRS PATTERNS

$DEBUG && echo "$0: starting" && date && ls -laF "$0"


ROTATE_LOG_DATE_PATTERN="\.20[0-9][0-9][01][0-9][0123][0-9]-[0-2][0-9][0-5][0-9][0-5][0-9]"
rotatelog() {
	log="$1"; shift;
	logbase="${log%.*}"
	logtail="${log##*.}"
	if [ -s "$log" ]; then
		$DEBUG && echo "    rotatelog: " cp -p "${log}" "${logbase}.$(date +'%Y%m%d-%H%M%S').${logtail}"
		$TEST  || cp -p "${log}" "${logbase}.$(date +'%Y%m%d-%H%M%S').${logtail}"
		$TEST  || cat /dev/null > "$log"
	fi;
}



## XACT App logs
LOGDIRS[0]="/opt/xact/log"
PATTERNS[0]=".*/xact_[a-z]+_20[0-9][0-9]-[01][0-9]-[0123][0-9]\.log"

## Bundler Logs
LOGDIRS[1]="/opt/xact/log"
PATTERNS[1]=".*/bundler\.log\.20[0-9][0-9][01][0-9][0123][0-9]"

## DB Migrate Logs
LOGDIRS[2]="/opt/xact/log"
PATTERNS[2]=".*/xact_[a-z]+_db-migrate-[-a-z_0-9]+_20[0-9][0-9][01][0-9][0123][0-9]-[0-9]{6}\.log"

## ENV Logs
LOGDIRS[3]="/opt/xact/log"
PATTERNS[3]=".*/(poc|qc|integration|stage|production)-\w{2}_[0-9]{4}-[01][0-9]-[0123][0-9]\.log"

## JaketyJak logs
LOGDIRS[4]="/opt/xact/log"
PATTERNS[4]=".*/jakety-jak\.log\.20[0-9][0-9]-[01][0-9]-[0123][0-9]"



APP_ENV=`hostname -s | sed 's/-.*//'`
case "${APP_ENV}" in
   dev)   AGE=1; DEL=14; ;;      # 2 weeks
   qc)    AGE=1; DEL=7;  ;;      # 1 week
   int)   AGE=1; DEL=21; ;;      # 3 weeks
   stg)   AGE=2; DEL=63; ;;      # 9 weeks
   prod)  AGE=2; DEL=112; ;;     # 16 weeks
   *)     AGE=2; DEL=183; ;;     # No environment available... using prod
esac

let AGEM=$AGE*24*60
let DELM=$DEL*24*60

X=0
while [ "${X}" -lt "${#LOGDIRS[*]}" ]; do
	LOGDIR="${LOGDIRS[${X}]}"
	PATTERN="${PATTERNS[${X}]}"

	$DEBUG && echo
	$DEBUG && echo "$LOGDIR     $PATTERN"

        if [ -d "${LOGDIR}" ]; then
		$DEBUG && find "${LOGDIR}" -follow -regextype posix-egrep -regex "${PATTERN}.*" -type f -mmin +${DELM}  | sed -e 's/^/  remove:    /g'
		$TEST  || find "${LOGDIR}" -follow -regextype posix-egrep -regex "${PATTERN}.*" -type f -mmin +${DELM} -print0 | xargs -0r rm

		$DEBUG && find "${LOGDIR}" -follow -regextype posix-egrep -regex "${PATTERN}" -type f -mmin +${AGEM}  | sed -e 's/^/  compress:  /g'
		$TEST  || find "${LOGDIR}" -follow -regextype posix-egrep -regex "${PATTERN}" -type f -mmin +${AGEM} -print0 | xargs -0r gzip -9f
	fi
	X=`/usr/bin/expr "${X}" + 1`
done
$DEBUG && echo;
$DEBUG && echo "$0: done"
