#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PACKAGE="gpputest"
RPMBUILD_DIR="$HOME/rpmbuild"
$DIR/clean.sh
if ! test -f "build/build.sh";then
    echo "You need to be located in the root directory of the **gpputest** repository"
    exit 1
fi

CURRENT_DIR=$( pwd )
echo "CURRENT_DIR: $CURRENT_DIR"

NAME_VER=gpputest-1.0.0
FILES_DIR=$HOME/$NAME_VER

#Text Color commands
#
#Brief: Commands to change the color of a text
highlight=$(echo -en '\033[01;37m')
purpleColor=$(echo -en '\033[01;35m')
cyanColor=$(echo -en '\033[01;36m')
errorColor=$(echo -en '\033[01;31m')
warningColor=$(echo -en '\033[00;33m')
successColor=$(echo -en '\033[01;32m')
norm=$(echo -en '\033[0m')



mkdir -p "$FILES_DIR" && cp -R src/* "$FILES_DIR"
echo "tar -czvf $NAME_VER.tar.gz $NAME_VER"
cd "$FILES_DIR" && cd .. || exit 
tar -czvf "$NAME_VER.tar.gz" "$NAME_VER"
cd "$CURRENT_DIR" || exit

rpmdev-setuptree

if ! test -f "$PACKAGE.spec"; then
    rpmdev-newspec gpputest
    echo "You will need to configure the spec file witch command:"
    echo "  vi  "$PACKAGE.spec""
    exit 1
fi
cp "$FILES_DIR.tar.gz" $RPMBUILD_DIR/SOURCES/
cp gpputest.spec $RPMBUILD_DIR/SPECS/

echo "Checking .spec file"
if rpmlint $RPMBUILD_DIR/SPECS/gpputest.spec; then
    echo "Specfile without errors"
else
    echo "${errorColor}There was an error linting the spec file${norm}, please fix it"
    exit 1
fi

echo "rpmbuild -bs -vv $RPMBUILD_DIR/SPECS/$PACKAGE.spec"
if rpmbuild -bb -vv $RPMBUILD_DIR/SPECS/$PACKAGE.spec;then
   RESULT="${successColor}---- SUCCESS building rpm ---${norm}"
else 
    RESULT="${errorColor}---- ERROR building rpm ---${norm}"
fi
echo "tree $RPMBUILD_DIR" && tree $RPMBUILD_DIR
echo -ne "\n\n$RESULT\n\n"
echo "to list files in tar"
echo "tar -ztvf $RPMBUILD_DIR/SOURCES/$NAME_VER.tar.gz"

URL=$( dirname $( grep "Source0:" gpputest.spec | tr -s ' '|cut -d ' ' -f2 ) )

echo scp $RPMBUILD_DIR/SOURCES/$NAME_VER.tar.gz guttih@guttih.com:/var/www/web-guttih/public/vault/repo/assets/release

if scp $RPMBUILD_DIR/SOURCES/* guttih@guttih.com:/var/www/web-guttih/public/vault/repo/assets/release; then
    echo "${successColor}Package accessable${norm} at: $URL/$NAME_VER.tar.gz"
else
    echo "Error deploying package to guttih.com"
fi
