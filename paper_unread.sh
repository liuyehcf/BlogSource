#!/bin/bash

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)

FILES=$(find ${ROOT}/resources/paper -name "*.pdf")

READ_COUNT=0
UNREAD_COUNT=0
for FILE in ${FILES[@]}
do
    FILE=${FILE#*/resources/paper/}
    FILE="/resources/paper/${FILE}"
    
    if ! grep "<a href=\"${FILE}\">" ${ROOT}/_posts/Papers.md > /dev/null 2>&1; then
        ((++UNREAD_COUNT))
        echo ${FILE}
    else
        ((++READ_COUNT))
    fi
done

echo "READ_COUNT: ${READ_COUNT}, UNREAD_COUNT: ${UNREAD_COUNT}"