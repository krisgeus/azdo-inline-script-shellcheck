FROM koalaman/shellcheck-alpine

RUN apk add yq

COPY validate-shell-snippets.sh /bin/validate-shell-snippets
COPY .shellcheckrc /bin/.shellcheckrc

ENTRYPOINT ["/bin/validate-shell-snippets"]