#!/bin/bash

source ../.env

for host in $HOSTS; do
  server-status -s "$host" -e "$EMAILS"
done
