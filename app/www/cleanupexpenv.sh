#!/bin/sh

cd $(dirname "$0")

cd environments && \
for d in */ ; do
    EXPFILE=".exptime$(echo -e  "$d" | sed 's/.$//')"
    [ $(date +%s) -ge $(cat $EXPFILE) ] && rm -Rf $d $EXPFILE && echo "removed expired env: $d" 
done
