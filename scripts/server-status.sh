#!/bin/bash

# from https://gist.github.com/seyDoggy/5814216

NAME=Admin
TESTDATE=`date "+%B %e, %Y"`
TESTTIME=`date "+%H:%M:%S"`

auto_init() {
  runTest
}

runTest() {
  if [[ -z "${SITE}" ]]; then
    echo "You need to set the -s flag to the site URL you wish to test."
    exit 1
  fi
  if [[ -z "${EMAIL}" ]]; then
    echo "You need to set the -e flag to the email address you wish to report errors to."
    exit 1
  fi
  if curl -s --max-time 5.5 --head "${SITE}" | egrep "200 OK|401 Unauthorized" > /dev/null 
    then 
      echo "The HTTP server on ${SITE} is up!" > /dev/null 
    else 
      (echo "Subject: The HTTP server on ${SITE} is down
MIME-Version: 1.0
Content-Type: text/html
Content-Disposition: inline
<p>Dear ${NAME},</p>
<p>This is an automated message from your server status script.</p>
<p>The site ${SITE} was tested on <b>${TESTDATE}</b> at <b>${TESTTIME}</b> and returned an error. It would appear that ${SITE} is inaccessible at this time.</p>
<br>
<p>From your friendly servers status script.</p>
") | sendmail ${EMAIL}
  fi
}

toolUsage () {
less << EOF1
Copyright (c) 2013 Adam Merrifield
Source: https://gist.github.com/seyDoggy/5814216
serverstatus
Usage:
  ./serverstatus.sh [-h] [-s http://somesite.url] [-e some@email.url]
OPTIONS:
  -h  Show this message
  -s  site URL to test
  -e  email address to report errors to
  
  
EXAMPLES:
  
  ./.serverstatus.sh -s http://seydesign.com/ -e my@email.com
    This will test the site seydesign.com and send me an email if it is down.
    Works great as a cron job or launch daemon.
  
EOF1
}

while getopts ":hs:e:" OPTION
do
  case $OPTION in
    h) toolUsage; exit 1;;
    s) SITE="$OPTARG";;
    e) EMAIL="$OPTARG";;
    ?) echo "Invalid option or empty value: -$OPTARG"; exit 1;;
  esac
done

auto_init
