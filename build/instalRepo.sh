#!/usr/bin/env bash

#Function: makeYumRepo()
#
#Brief: Creates a repository to a existing repository
#
#Argument 1($1): id (unique text string for the repo)
#Argument 2($2): name (display name of the repo)
#Argument 3($3): full path to the repository 
makeYumRepo(){
    if [ $# -lt 3 ]; then echo "${errorColor}Invalid number of parameters${norm}."; exit 1; fi
     
    
    FILENAME="/etc/yum.repos.d/$1.repo"
    echo "[$1]" >$FILENAME
    echo "name=$2" >>$FILENAME
    echo "baseurl=$3" >>$FILENAME
    echo "gpgcheck=0" >>$FILENAME
    echo "enabled=1" >>$FILENAME
}

if ((EUID != 0)); then
    echo "Error: This command has to be run with superuser privileges (under the root user on most systems)."
    exit 1
fi

makeYumRepo guttih "guttih repository" "https://guttih.com/public/vault/repo/guttih"