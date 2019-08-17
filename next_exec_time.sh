#!/bin/bash

rundeck_url="http://host.domain.com:4440"
rundeck_auth_token="yourauthtoken"

next_exec(){
    dt=$(wget --no-proxy  -q "$rundeck_url/api/30/job/$1/info?authtoken=$rundeck_auth_token" -O - | xmlstarlet sel -t  -m "//job" -v "@nextScheduledExecution")
    if [ -z "$dt"  ]; then
	echo ""
    else
	name=$(wget --no-proxy  -q "$rundeck_url/api/30/job/$1/info?authtoken=$rundeck_auth_token" -O - | xmlstarlet sel -t  -m "//job" -v "name")
	proj=$(wget --no-proxy  -q "$rundeck_url/api/30/job/$1/info?authtoken=$rundeck_auth_token" -O - | xmlstarlet sel -t  -m "//job" -v "project")

	d=$(date --date="$dt" +%Y.%m.%d.%H:%M)
	echo "$d $proj->$name"
    fi
}

#List of projects
proj_list(){
    wget --no-proxy  -q "$rundeck_url/api/1/projects?authtoken=$rundeck_auth_token" -O -|  grep -o "<name>.*</name>" | awk -F'[<>]' '{print $3}'
}

#List of jobs in project
jobs() {
    wget --no-proxy  -q "$rundeck_url/api/14/project/$1/jobs?authtoken=$rundeck_auth_token" -O - | xmlstarlet sel -t  -m "//job" -v "@id" -o " "
}

#############################
#############MAIN############
#############################

#set -e
set -u
for proj in $(proj_list); do
    for job in $(jobs $proj); do
     next_exec $job
    done


done | grep [0-9]|  sort -nr 

