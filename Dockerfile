FROM koalaman/shellcheck-alpine:latest

RUN apk add --no-cache yq==4.40.5-r0

COPY validate-shell-snippets.sh /bin/validate-shell-snippets
COPY .shellcheckrc /bin/.shellcheckrc
COPY shellcheck-shell-snippet.sh /bin/shellcheck-shell-snippet.sh
COPY extract-shell-script-snippets.yq /bin/extract-shell-script-snippets.yq

ENTRYPOINT ["/bin/validate-shell-snippets"]
