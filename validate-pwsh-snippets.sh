#!/bin/bash

# Extract the inline powershell snippets from the AZDO pipeline yamls and analyze each one.
# The snippets are streamed NUL separated and fed to the analyzer on stdin instead of being
# passed as a command line argument, so long snippets cannot exceed the argument size limit.
set -u

# Directory holding the helper scripts. Overridable so the test suite can run against a
# checkout instead of the copies installed in the image.
bin_dir="${SNIPPET_CHECK_BIN:-/bin}"

status=0
index=0

check_snippet() {
    index=$((index + 1))
    printf '%s\n' "$1" | "${bin_dir}/analyze-pwsh-snippet.ps1" "#${index}" || status=1
}

echo "Validating powershell snippets in input file: ${*}"

while IFS= read -r -d '' snippet; do
    check_snippet "$snippet"
done < <(yq -N -r -0 --from-file "${bin_dir}/extract-pwsh-script-snippets.yq" "$@")

# Handle a final snippet that is not NUL terminated.
if [ -n "${snippet:-}" ]; then
    check_snippet "$snippet"
fi

exit "$status"
