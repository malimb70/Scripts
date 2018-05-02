#!/bin/sh

# BSD style yesturday
YESTURDAY=`date -v -1d "+%Y%m%d"`

FETCHERRORDIR=/var/log/varnish/fetcherror

mkdir -p ${FETCHERRORDIR}/archive/${YESTURDAY}

find ${FETCHERRORDIR} -depth 1 -name 'fetcherror-*' -mtime +1h -exec mv {} ${FETCHERRORDIR}/archive/${YESTURDAY}/ \;

