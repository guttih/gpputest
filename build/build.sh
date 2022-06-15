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
WORK_DIR=$HOME
RPMBUILD_DIR="$WORK_DIR/rpmbuild"
NAME_VER="$PACKAGE-$VER"
FILES_DIR=$WORK_DIR/$NAME_VER


if [[ -z $VER ]]; then 
    echo "${errorColor}Version not found in file ${norm} $SPEC_FILE"
    exit 1
fi


# --- ACTION STARTS HERE ---
$DIR/clean.sh $WORK_DIR

mkdir -p "$FILES_DIR" && cp -R src/* "$FILES_DIR"
echo "tar -czvf $NAME_VER.tar.gz $NAME_VER"
cd "$FILES_DIR" && cd .. || exit 
tar -czvf "$NAME_VER.tar.gz" "$NAME_VER"
cd "$CURRENT_DIR" || exit

rpmdev-setuptree
# mkdir -p $WORK_DIR/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
            
if ! test -f "$PACKAGE.spec"; then
    rpmdev-newspec $PACKAGE
    echo "You will need to configure the spec file witch command:"
    echo "  vi  "$PACKAGE.spec""
    exit 1
fi
echo "cp $FILES_DIR.tar.gz  $RPMBUILD_DIR/SOURCES/"
     cp "$FILES_DIR.tar.gz" $RPMBUILD_DIR/SOURCES/
echo "cp $PACKAGE.spec  $RPMBUILD_DIR/SPECS/"
     cp "$PACKAGE.spec" $RPMBUILD_DIR/SPECS/

echo "Checking .spec file"
if rpmlint $RPMBUILD_DIR/SPECS/$PACKAGE.spec; then
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
    echo $RESULT
    exit 1
fi
echo "tree $RPMBUILD_DIR" && tree $RPMBUILD_DIR
echo -ne "\n\n$RESULT\n\n"
echo "to list files in tar"
echo "tar -ztvf $RPMBUILD_DIR/SOURCES/$NAME_VER.tar.gz"

URL=$( dirname $( grep "Source0:" $PACKAGE.spec | tr -s ' '|cut -d ' ' -f2 ) )

UPLOAD_ROOT=guttih@guttih.com:/var/www/web-guttih/public/vault/repo
UPLOAD_RELEASE="$UPLOAD_ROOT/assets/release"
UPLOAD_DESC="$UPLOAD_ROOT/description/$PACKAGE"
echo "scp $RPMBUILD_DIR/SOURCES/* $UPLOAD_RELEASE"
if scp $RPMBUILD_DIR/SOURCES/* "$UPLOAD_RELEASE"; then
    echo "${successColor}Package accessable${norm} at: $URL/$NAME_VER.tar.gz"
    scp support/index.html "$UPLOAD_DESC";
else
    echo "${errorColor}Error deploying package${norm} to $UPLOAD_RELEASE"
fi
