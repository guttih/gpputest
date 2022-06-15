#!/usr/bin/env bash

PACKAGE="gpputest"
DIR="$HOME"
if [[ -n $1 ]]; then
    DIR="$1"
fi
echo "DIR:$DIR"
if test -d $DIR/rpmbuild; then
    rm -rf $DIR/rpmbuild
fi

rm -rf $DIR/$PACKAGE-*
