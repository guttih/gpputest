#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PACKAGE="gpputest"

$DIR/clean.sh
if ! test -f "build/build.sh";then
    echo "You need to be located in the root directory of the **gpputest** repository"
    exit 1
fi
WORKDIR=~/gpputest-1.0.0
mkdir -p "$WORKDIR" && cp -R src/* "$WORKDIR"
tar -czvf "$WORKDIR.tar.gz" "$WORKDIR"

rpmdev-setuptree

if ! test -f "$PACKAGE.spec"; then
    rpmdev-newspec gpputest
    echo "You will need to configure the spec file witch command:"
    echo "  vi  "$PACKAGE.spec""
    exit 1
fi
cp "$WORKDIR.tar.gz" ~/rpmbuild/SOURCES/
cp gpputest.spec ~/rpmbuild/SPECS/

echo "Checking .spec file"
if rpmlint ~/rpmbuild/SPECS/gpputest.spec; then
    echo "Specfile without errors"
else
    echo "There was an error linting the spec file, please fix it"
    exit 1
fi

