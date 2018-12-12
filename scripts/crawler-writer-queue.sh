#!/bin/bash

QUEUE=/usr/local/bin/tracemap/tracemap-backend/crawler/temp

while [[ 1 ]]; do
	savefiles=$(ls -l $QUEUE | grep save | wc -l)
	priofiles=$(ls -l $QUEUE | grep prio | wc -l)
	bigfiles=$(ls -l $QUEUE | grep big | wc -l)
	totalfiles=$(ls -l $QUEUE | grep -v total | wc -l)
	echo "$(date) :: QUEUE | save: $savefiles | prio: $priofiles | big: $bigfiles | total: $totalfiles |"
	if [ -z "$1" ]; then
		sleep 2;
	else
		sleep "$1";
		echo "parameter provided"
	fi
done
