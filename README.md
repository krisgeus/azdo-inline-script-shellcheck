# Pre-commit hook for performing Shellcheck on shell snippets in AZDO pipeline yamls

This pre-commit hook performs shellcheck on script tasks in Azure Devops pipeline yaml files.

## validate-shell-snippets

The validate shell snippets hook extracts (bash) shell script snippets from AZDO pipeline yaml files.
Shellcheck is executed for each snippet encountered.

AZDO parameter or variable references (with the `${{ par }}` syntax) are converted into
shell variabel references to prevent errors.
The Shellcheck is configured to ignore `SC2154` since these variables are provided from
outside the script snippets.

### Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-shell-snippets
    name: Check shell snippets in yaml files
    language: docker
    entry: /bin/validate-shell-snippets
```

## validate-shell-snippets-docker-latest

Same as [Validate Shell Snippets](#validate-shell-snippets) but using the pre-built docker image (tag latest)

### validate-shell-snippets-docker-latest Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-shell-snippets-docker-latest
    name: Check shell snippets in yaml files
```

## validate-shell-snippets-docker-release

Same as [Validate Shell Snippets](#validate-shell-snippets) but using the pre-built docker image from the release (tag v2.0.2)

### validate-shell-snippets-docker-release Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-shell-snippets-docker-release
    name: Check shell snippets in yaml files
```

## validate-powershell-snippets

The validate powershell snippets hook extracts (pwsh) shell script snippets from AZDO pipeline yaml files.
PSScriptAnalyzer is executed for each snippet encountered.

AZDO parameter or variable references (with the `${{ par }}` syntax) are converted into
powershell variabel references to prevent errors.

### Powershell validation Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-powershell-snippets
    name: Check powershell snippets in yaml files
    language: docker
    entry: /bin/validate-pwsh-snippets
```

## validate-powershell-snippets-docker-latest

The validate Powershell snippets hook extracts powershell script snippets from AZDO pipeline yaml files.
PSScriptAnalyzer is executed for each snippet encountered.

AZDO parameter or variable references (with the `${{ par }}` syntax) are converted into
powershell variabel references to prevent errors.

The hook is using the pre-built docker image (tag latest)

### validate-powershell-snippets-docker-latest Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-powershell-snippets-docker-latest
    name: Check shell snippets in yaml files
```

## validate-powershell-snippets-docker-release

Same as [Validate Powershell Snippets](#validate-powershell-snippets-docker-latest) but
using the pre-built docker image from the release (tag v2.0.2)

### validate-powershell-snippets-docker-release Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.2
  hooks:
  - id: validate-powershell-snippets-docker-release
    name: Check shell snippets in yaml files
```

## Tests

The unit tests in `tests/run-tests.sh` cover snippet extraction, the exit status of both
hooks and the handling of snippets that are too large to pass as a command line argument.
The build pipeline runs them against the freshly built image, with
`SNIPPET_CHECK_REQUIRE_ALL=1` so a missing tool fails the build instead of skipping tests:

```shell
docker build -t inline-shell-check:test .
docker run --rm --volume "${PWD}/tests:/tests:ro" \
  --env SNIPPET_CHECK_REQUIRE_ALL=1 \
  --entrypoint /tests/run-tests.sh inline-shell-check:test
```

Building the image only works on `linux/amd64`, so on other architectures run the tests
against the checkout instead. That needs `yq`, `shellcheck` and `pwsh` with
`PSScriptAnalyzer` on the PATH; the powershell tests are skipped when they are missing.

```shell
SNIPPET_CHECK_BIN="${PWD}" ./tests/run-tests.sh
```
