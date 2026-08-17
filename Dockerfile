# ShellCheck image
FROM koalaman/shellcheck-alpine:latest AS builder

FROM drjp81/powershell:latest

ENV POWERSHELL_TELEMETRY_OPTOUT=1

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN pwsh -Command \
    "Set-PSRepository -ErrorAction Stop -InstallationPolicy Trusted -Name PSGallery -Verbose; \
    Install-Module -ErrorAction Stop -Name PSScriptAnalyzer -Scope AllUsers -Force"

USER ubuntu

SHELL ["/bin/bash", "-c"]

COPY validate-pwsh-snippets.sh /bin/validate-pwsh-snippets
COPY analyze-pwsh-snippet.ps1 /bin/analyze-pwsh-snippet.ps1
COPY extract-pwsh-script-snippets.yq /bin/extract-pwsh-script-snippets.yq

COPY --from=builder /bin/shellcheck /bin/

COPY validate-shell-snippets.sh /bin/validate-shell-snippets
COPY .shellcheckrc /bin/.shellcheckrc
COPY shellcheck-shell-snippet.sh /bin/shellcheck-shell-snippet.sh
COPY extract-shell-script-snippets.yq /bin/extract-shell-script-snippets.yq

ENTRYPOINT ["/bin/validate-shell-snippets"]
