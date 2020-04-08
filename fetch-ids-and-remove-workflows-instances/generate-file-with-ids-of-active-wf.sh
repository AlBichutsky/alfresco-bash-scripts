#!/bin/env bash

# Script generates file with ids of all Alfresco active workflow instances in format: activiti$proc_id 

# set variabless
admin_account=$1
admin_pass=$2
file=$3

# fetch data
curl -u $admin_account:"$admin_pass" http://localhost:8080/alfresco/service/api/workflow-instances | awk '/"id"/{print $2}' | sed 's/\"//g' | sed 's/\,//g' > /tmp/list_act_proc

# convert the file in DOS-format to UNIX-format
awk '{ sub("\r$", ""); print }' /tmp/list_act_proc > $file
rm -f /tmp/list_act_proc
