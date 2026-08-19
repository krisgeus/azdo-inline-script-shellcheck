#!/bin/bash

# Unit tests for the AZDO inline script validators.
#
# Against the docker image (as the build pipeline runs them):
#   docker run --rm -v "$PWD/tests:/tests" --entrypoint /tests/run-tests.sh <image>
#
# Against a checkout, with yq, shellcheck and pwsh on the PATH:
#   SNIPPET_CHECK_BIN="$PWD" ./tests/run-tests.sh
#
# The powershell tests are skipped when pwsh or PSScriptAnalyzer is unavailable. Set
# SNIPPET_CHECK_REQUIRE_ALL=1 to turn those skips into failures.
set -u

SNIPPET_CHECK_BIN="${SNIPPET_CHECK_BIN:-/bin}"
export SNIPPET_CHECK_BIN

fixtures="$(cd "$(dirname "$0")/fixtures" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

passed=0
failed=0
skipped=0
current=""
out=""
rc=0

# The image installs the entrypoints without their .sh suffix.
resolve() {
    if [ -x "${SNIPPET_CHECK_BIN}/$1" ]; then
        printf '%s\n' "${SNIPPET_CHECK_BIN}/$1"
    elif [ -x "${SNIPPET_CHECK_BIN}/$1.sh" ]; then
        printf '%s\n' "${SNIPPET_CHECK_BIN}/$1.sh"
    fi
}

validate_shell="$(resolve validate-shell-snippets)"
validate_pwsh="$(resolve validate-pwsh-snippets)"

start() {
    current="$1"
    printf '%s\n' "- ${current}"
}

pass() {
    passed=$((passed + 1))
}

fail() {
    failed=$((failed + 1))
    printf '  FAILED: %s\n' "$1"
    printf '  --- output ---\n%s\n  --------------\n' "${out}"
}

skip() {
    # The build pipeline runs against an image that has everything installed, so a skip
    # there means coverage was silently lost and should fail the build instead.
    if [ "${SNIPPET_CHECK_REQUIRE_ALL:-0}" = "1" ]; then
        failed=$((failed + 1))
        printf '  FAILED: %s (required when SNIPPET_CHECK_REQUIRE_ALL=1)\n' "$1"
        return
    fi
    skipped=$((skipped + 1))
    printf '  SKIPPED: %s\n' "$1"
}

# Run a validator, capturing combined output in ${out} and the exit code in ${rc}.
run_validator() {
    local validator="$1"
    shift
    out="$("${validator}" "$@" 2>&1)"
    rc=$?
}

snippet_count() {
    printf '%s\n' "${out}" | grep -c '^Checking'
}

assert_status() {
    if [ "${rc}" -eq "$1" ]; then
        return 0
    fi
    fail "expected exit status $1, got ${rc}"
    return 1
}

assert_snippets() {
    local count
    count="$(snippet_count)"
    if [ "${count}" -eq "$1" ]; then
        return 0
    fi
    fail "expected $1 snippet(s) to be checked, got ${count}"
    return 1
}

assert_contains() {
    case "${out}" in
        *"$1"*) return 0 ;;
    esac
    fail "expected output to contain '$1'"
    return 1
}

assert_not_contains() {
    case "${out}" in
        *"$1"*)
            fail "expected output not to contain '$1'"
            return 1
            ;;
    esac
    return 0
}

# Build a pipeline yaml holding one inline snippet of roughly a megabyte, which is far
# beyond what fits in a command line argument. ${1} is the yaml key, ${2} the line to
# repeat and ${3} an optional final line.
generate_long_snippet_yaml() {
    local target="${work}/long-$1.yml"
    {
        printf 'steps:\n  - %s: |\n' "$1"
        awk -v line="$2" 'BEGIN { for (i = 0; i < 12000; i++) printf "      %s %d\n", line, i }'
        if [ -n "${3:-}" ]; then
            printf '      %s\n' "$3"
        fi
    } > "${target}"
    printf '%s\n' "${target}"
}

# --- shell snippets -------------------------------------------------------------------

test_shell() {
    if [ -z "${validate_shell}" ]; then
        start "shell snippets"
        skip "validate-shell-snippets not found in ${SNIPPET_CHECK_BIN}"
        return
    fi

    start "shell: clean snippet passes"
    run_validator "${validate_shell}" "${fixtures}/shell-clean.yml"
    assert_status 0 && assert_snippets 1 && pass

    start "shell: snippet with a warning fails"
    run_validator "${validate_shell}" "${fixtures}/shell-warning.yml"
    assert_status 1 && assert_contains "SC2164" && pass

    start "shell: every inline script flavour is extracted"
    run_validator "${validate_shell}" "${fixtures}/shell-flavours.yml"
    assert_status 0 && assert_snippets 5 && pass

    start "shell: snippets below stages and jobs are extracted"
    run_validator "${validate_shell}" "${fixtures}/shell-nested.yml"
    assert_status 0 && assert_snippets 3 && pass

    start "shell: multiple yaml files are all processed"
    run_validator "${validate_shell}" "${fixtures}/shell-clean.yml" "${fixtures}/shell-nested.yml"
    assert_status 0 && assert_snippets 4 && pass

    start "shell: azdo template expressions and pipeline variables are accepted"
    run_validator "${validate_shell}" "${fixtures}/shell-azdo-syntax.yml"
    assert_status 0 && assert_snippets 1 && pass

    start "shell: yaml without steps is a no-op"
    run_validator "${validate_shell}" "${fixtures}/no-steps.yml"
    assert_status 0 && assert_snippets 0 && pass

    # Regression test: passing the snippet as an argument used to fail with
    # 'xargs: command line cannot be assembled, too long'.
    start "shell: a snippet too large for a command line argument is checked"
    run_validator "${validate_shell}" "$(generate_long_snippet_yaml bash 'echo "line"')"
    assert_status 0 && assert_snippets 1 && assert_not_contains "too long" && pass

    # And the tail of that snippet must actually reach shellcheck, not just the head.
    start "shell: a large snippet is checked in full"
    run_validator "${validate_shell}" "$(generate_long_snippet_yaml bash 'echo "line"' 'cd /tmp')"
    assert_status 1 && assert_contains "SC2164" && pass
}

# --- powershell snippets --------------------------------------------------------------

test_pwsh() {
    if [ -z "${validate_pwsh}" ]; then
        start "powershell snippets"
        skip "validate-pwsh-snippets not found in ${SNIPPET_CHECK_BIN}"
        return
    fi
    if ! command -v pwsh > /dev/null 2>&1; then
        start "powershell snippets"
        skip "pwsh is not installed"
        return
    fi
    if ! pwsh -NoProfile -Command 'exit (Get-Module -ListAvailable PSScriptAnalyzer) ? 0 : 1' > /dev/null 2>&1; then
        start "powershell snippets"
        skip "PSScriptAnalyzer is not installed"
        return
    fi

    start "powershell: clean snippet passes"
    run_validator "${validate_pwsh}" "${fixtures}/pwsh-clean.yml"
    assert_status 0 && assert_snippets 1 && pass

    start "powershell: snippet with a warning fails"
    run_validator "${validate_pwsh}" "${fixtures}/pwsh-warning.yml"
    assert_status 1 && assert_contains "PSAvoidUsingInvokeExpression" && pass

    start "powershell: every inline script flavour is extracted"
    run_validator "${validate_pwsh}" "${fixtures}/pwsh-flavours.yml"
    assert_status 0 && assert_snippets 6 && pass

    start "powershell: snippets below stages and jobs are extracted"
    run_validator "${validate_pwsh}" "${fixtures}/pwsh-nested.yml"
    assert_status 0 && assert_snippets 2 && pass

    start "powershell: azdo template expressions are rewritten"
    run_validator "${validate_pwsh}" "${fixtures}/pwsh-azdo-syntax.yml"
    assert_status 0 && assert_snippets 1 && pass

    start "powershell: yaml without steps is a no-op"
    run_validator "${validate_pwsh}" "${fixtures}/no-steps.yml"
    assert_status 0 && assert_snippets 0 && pass

    # Regression test, see the shell equivalent above.
    start "powershell: a snippet too large for a command line argument is checked"
    run_validator "${validate_pwsh}" "$(generate_long_snippet_yaml pwsh 'Write-Output "line"')"
    assert_status 0 && assert_snippets 1 && assert_not_contains "too long" && pass

    start "powershell: a large snippet is checked in full"
    run_validator "${validate_pwsh}" "$(generate_long_snippet_yaml pwsh 'Write-Output "line"' 'Invoke-Expression "Get-ChildItem"')"
    assert_status 1 && assert_contains "PSAvoidUsingInvokeExpression" && pass
}

printf 'Running tests against %s\n\n' "${SNIPPET_CHECK_BIN}"
test_shell
test_pwsh

printf '\n%s passed, %s failed, %s skipped\n' "${passed}" "${failed}" "${skipped}"
[ "${failed}" -eq 0 ]
