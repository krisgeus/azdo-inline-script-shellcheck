#!/bin/sh

# Print shell snippet to check.
# AZDO parameter / variable refferences with ${{ par }} are converted into shell variable syntax
# shellcheck is invoked
cd /bin && \
echo "Checking shell script snippet $1"; echo "$1" | \
sed -r -e "s/\{\{[ ]?/\{/g" -e "s/[ ]?\}\}/\}/g"  | \
shellcheck -s bash -S warning -
