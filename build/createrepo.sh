#!/usr/bin/env bash


highlight=$(echo -en '\033[01;37m')
errorColor=$(echo -en '\033[01;31m')
warningColor=$(echo -en '\033[00;33m')
successColor=$(echo -en '\033[01;32m')
norm=$(echo -en '\033[0m')

PACKAGE=$( grep "Name:" ./*.spec |tr -s ' '|cut -d ' ' -f2 )
if [[ -z $PACKAGE ]]; then 
    echo "${errorColor}Package name not found in file .spec file.${norm}"
    exit 1
fi

if ! test -f "build/build.sh";then
    echo "${errorColor}You need to be located in the root directory of the $PACKAGE repository${norm}."
    exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_DIR=$( pwd )
SPEC_FILE="$PACKAGE.spec"
VER=$( grep "Version:" "$SPEC_FILE" |tr -s ' '|cut -d ' ' -f2 )
RPMBUILD_DIR="$HOME/rpmbuild"
NAME_VER="gpputest-$VER"

if [[ -z $VER ]]; then 
    echo "${errorColor}Version not found in file ${norm} $SPEC_FILE"
    exit 1
fi

REPO_DIR="$HOME/guttih"

if test -d "$REPO_DIR"
then
    echo "Directory already exists"
    find "$RPMBUILD_DIR/RPMS/" -type f -name '*.rpm' -exec cp {} "$REPO_DIR"/ \;
    createrepo --update "$REPO_DIR"
else
    mkdir -p "$REPO_DIR"
    find "$RPMBUILD_DIR/RPMS/" -type f -name '*.rpm' -exec cp {} "$REPO_DIR"/ \;
    createrepo "$REPO_DIR"
fi

tree $REPO_DIR
# ssh guttih@guttih.com "rm -rf /var/www/web-guttih/public/vault/repo/guttih; rm /var/www/web-guttih/public/vault/repo/assets/release/gpputest-*.tar.gz"
ssh guttih@guttih.com "rm -rf /var/www/web-guttih/public/vault/repo/guttih"
scp -r "$REPO_DIR" "guttih@guttih.com:/var/www/web-guttih/public/vault/repo"


