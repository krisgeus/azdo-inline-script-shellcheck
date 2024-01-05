#!/bin/sh

(pwsh -c "get-date" || true) && \
ls -la "${HOME}/.cache" && \
chmod 555 "${HOME}/.cache/powershell" && \
ls -la "${HOME}/.cache/powershell/" && \
rm -f "${HOME}/.cache/powershell/StartupProfileData-NonInteractive" && \
ls -la "${HOME}/.cache/powershell/" && \

pwsh -c "Install-Module -Name PSScriptAnalyzer -Scope AllUsers -Force"

/usr/local/bin/yq -N -r -0 --from-file /bin/extract-pwsh-script-snippets.yq "$@" | \
    xargs -0 -I{} /bin/analyze-pwsh-snippet.ps1 -snippet {}
