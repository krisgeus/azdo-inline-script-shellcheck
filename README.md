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
  rev: v2.0.1
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
  rev: v2.0.1
  hooks:
  - id: validate-shell-snippets-docker-latest
    name: Check shell snippets in yaml files
```

## validate-shell-snippets-docker-release

Same as [Validate Shell Snippets](#validate-shell-snippets) but using the pre-built docker image from the release (tag v2.0.1)

### validate-shell-snippets-docker-release Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.1
  hooks:
  - id: validate-shell-snippets-docker-release
    name: Check shell snippets in yaml files
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
  rev: v2.0.1
  hooks:
  - id: validate-powershell-snippets-docker-latest
    name: Check shell snippets in yaml files
```

## validate-powershell-snippets-docker-release

Same as [Validate Powershell Snippets](#validate-powershell-snippets-docker-latest) but
using the pre-built docker image from the release (tag v2.0.1)

### validate-powershell-snippets-docker-release Usage

In your `.pre-commit-config.yaml` use the following config:

```yaml
- repo: https://github.com/krisgeus/azdo-inline-script-shellcheck
  rev: v2.0.1
  hooks:
  - id: validate-powershell-snippets-docker-release
    name: Check shell snippets in yaml files
```
