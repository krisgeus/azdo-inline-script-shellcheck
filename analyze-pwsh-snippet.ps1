#!/usr/bin/env pwsh

# Check the powershell snippet read from stdin.
# $label is an optional label used in the progress message.
# AZDO parameter / variable refferences with ${{ par }} are converted into shell variable syntax
# PSAnalyzer is invoked
param (
    [string]$label = ""
)

$snippet = [Console]::In.ReadToEnd();
Write-Information "Checking powershell script snippet $label" -InformationAction Continue;
$pwsh_snippet = $snippet -replace '\{\{[ ]?([^ ]*)[ ]?\}\}', '$1';
Invoke-ScriptAnalyzer -ScriptDefinition $pwsh_snippet -EnableExit -ReportSummary -Severity Error, Warning
