#!/bin/bash
# GCE Instance Revive Script
# general GCE startup script
# Initial version from RXWatcher
# $1 PROJECTID, $2 ZONE, $3 INSTANCE, $4 LOGFILE

LOGFILE=$4
PROJECTID=$1
ZONE=$2
INSTANCE=$3

check_running () {

if pidof -o %PPID -x "gce.sh"; then
exit 1
fi

}

check_status () {
echo "$(date "+%d.%m.%Y %T") Checking $INSTANCE Status.."
PRESTATUS=$(/usr/bin/gcloud compute instances describe $INSTANCE --project=$PROJECTID --zone=$ZONE | grep  "status")
STATUS=${PRESTATUS:7}
if [ $STATUS = "RUNNING" ]; then
        echo "$(date "+%d.%m.%Y %T") $INSTANCE Instance is Running at"$(/usr/bin/gcloud compute instances describe $INSTANCE --project=$PROJECTID --zone=$ZONE|grep natIP | cut -d':'  -f2) |tee -a $LOGFILE
        exit
fi
if [ $STATUS = "TERMINATED" ]; then
        echo "$(date "+%d.%m.%Y %T") $INSTANCE Instance is NOT Running" | tee -a $LOGFILE
        echo "$(date "+%d.%m.%Y %T") Sending Instance startup command for $INSTANCE" | tee -a $LOGFILE
        echo "$(date "+%d.%m.%Y %T") Waiting for services to come online....." | tee -a $LOGFILE
        /usr/bin/gcloud compute instances start $INSTANCE --project=$PROJECTID --zone=$ZONE
        echo "$(date "+%d.%m.%Y %T") $INSTANCE started." | tee -a $LOGFILE
fi
}

# check_running
check_status

exit
