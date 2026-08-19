#!/bin/sh

# Check the shell snippet read from stdin.
# $1 is an optional label used in the progress message.
# AZDO parameter / variable refferences with ${{ par }} are converted into shell variable syntax
# Shellcheck is invoked
cd "${SNIPPET_CHECK_BIN:-/bin}" || exit 1
echo "Checking shell script snippet ${1:-}"
sed -r -e "s/\{\{[ ]?/\{/g" -e "s/[ ]?\}\}/\}/g" | \
shellcheck -s bash -S warning -
