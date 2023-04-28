#!/bin/sh

cd environments

for d in */ ; do
    EXPFILE=".exptime$(echo -e  "$d" | sed 's/.$//')"
    [ $(date +%s) -ge $(cat $EXPFILE) ] && rm -Rf $d $EXPFILE
done
