#!/bin/sh

yq -N -r -0 --from-file /bin/extract-shell-script-snippets.yq "$@" | \
    xargs -0 -I{} /bin/shellcheck-shell-snippet.sh {}
