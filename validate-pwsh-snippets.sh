#!/bin/sh

/usr/local/bin/yq -N -r -0 --from-file /bin/extract-pwsh-script-snippets.yq "$@" | \
    xargs -0 -I{} /bin/analyze-pwsh-snippet.ps1 -snippet {}
