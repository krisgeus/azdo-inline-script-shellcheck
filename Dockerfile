FROM koalaman/shellcheck-alpine

RUN apk add yq

COPY validate-shell-snippets.sh /bin/validate-shell-snippets
COPY .shellcheckrc /bin/.shellcheckrc
COPY xargs.sh /bin/xargs.sh
COPY yq.exp.txt /bin/yq.exp.txt

ENTRYPOINT ["/bin/validate-shell-snippets"]