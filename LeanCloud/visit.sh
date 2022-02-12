#!/bin/bash

URL_FILE="/root/url.list"
if [ -n "$1" ]; then
    URL_FILE=$1
fi

VISIT_TIMES=20
if [ -n "$2" ]; then
    VISIT_TIMES=$2;
fi

URLS=( $(cat ${URL_FILE}) )

for ((i=0;i<VISIT_TIMES;i++)) 
do
    URL_COUNT=0
    for URL in ${URLS[@]}
    do
        echo "total_visit_times: ${VISIT_TIMES}, visit_count: ${i}, total_urls=${#URLS[@]}, url_count=${URL_COUNT}"
        google-chrome --headless --disable-gpu --no-sandbox ${URL} >> log.log 2>&1
        ((URL_COUNT++))
    done
done