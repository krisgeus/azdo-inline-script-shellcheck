# Pre-commit hook for performing Shellcheck on shell snippets in AZDO pipeline yamls

This pre-commit hook performs shellcheck on script tasks in Azure Devops pipeline yaml files.

## validate-shell-snipets

The validate shell snippets hook extracts (bash) shell script snippets form AZDO pipeline yaml files.
Shellcheck is executed for each snippet encountered.

AZDO parameter or variable references (with the `${{ par }}` syntax) are converted into
shell variabel references to prevent errors.
The Shellcheck is configured to ignore `SC2154` since these variables are provided from
outside the script snippets.
