#!/bin/sh 

cd /bin && \
echo "Checking bash script snippet $1"; echo "$1" | \
sed -r -e "s/\{\{[ ]?/\{/g" -e "s/[ ]?\}\}/\}/g"  | \
shellcheck -s bash -S warning -