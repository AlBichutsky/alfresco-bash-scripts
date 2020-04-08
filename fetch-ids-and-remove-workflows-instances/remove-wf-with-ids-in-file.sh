#!/bin/bash

# Script removes Alfresco workflows instances with ids in given file
# Use only in testing environment !

# set variables
admin_account=$1
admin_pass=$2
file=$3

echo "Warning! Alfresco workflows instances with ids in file $file will be removed on $HOSTNAME"
read -p "Press ENTER to to continue or Ctrl+c for cancel"

# removing 
while read line
do
echo "Processing: $(cat -v <<< $(echo "$line"))"
curl -X DELETE -u $admin_account:"$admin_pass" http://localhost:8080/alfresco/s/api/workflow-instances/$line?forced=true
done < $file
