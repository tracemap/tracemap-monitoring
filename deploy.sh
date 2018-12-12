#!/bin/sh
COREPATH=/usr/local/bin/tracemap
rsync -av --include .env --exclude-from=.gitignore --exclude .git --exclude .gitignore --exclude deploy.sh ./ tm-deploy-staging:$COREPATH/${PWD##*/}

