#!/bin/env bash

#################################################################################################
#          Deleting audit entries for a given application and time range in human format        #
#################################################################################################

# name of audit application, for example "alfresco-access", "alfresco-workflows", "alfresco-security"
audit_app=$1

# start of time range in format "MM.DD.YYYY", for example "10/07/2017" (it's means 10/07/2017 00:00:00)
start_time=$2

# end of time range in format "MM.DD.YYYY", for example "11/30/2017" (it's means 11/30/2017 00:00:00)
end_time=$3

# name of admin account, for example, "admin"
admin_account=$4

# admin account password, for example, "SomePassword"
admin_pass=$5

# convert time to unix timestamp and add milliseconds 
start_unixtime=$(date -d "$start_time" "+%s%3N")
end_unixtime=$(date -d "$end_time" "+%s%3N")

echo "========= Cleaning Alfresco audit logs  ========="
echo "hostname: $HOSTNAME"
echo "audit application: $audit_app"
echo "time range: $start_time - $end_time"
echo "link (METHOD PUT): http://localhost:8080/alfresco/service/api/audit/clear/$audit_app?fromTime=$start_unixtime&toTime=$end_unixtime"
echo "=================================================="

read -p "Press ENTER to CLEAN audit entries..."

# run Alfresco web-script 
curl -X POST -u $admin_account:"$admin_pass" "http://localhost:8080/alfresco/service/api/audit/clear/$audit_app?fromTime=$start_unixtime&toTime=$end_unixtime"


