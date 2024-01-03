#!/usr/bin/env pwsh

# Print powershell snippet to check.
# AZDO parameter / variable refferences with ${{ par }} are converted into shell variable syntax
# PSAnalyzer is invoked
param (
    [string]$snippet = ""
)

Write-Information "Checking powershell script snippet $snippet" -InformationAction Continue;
$pwsh_snippet = $snippet -replace '\{\{[ ]?([^ ]*)[ ]?\}\}', '$1';
Invoke-ScriptAnalyzer -ScriptDefinition $pwsh_snippet -EnableExit -ReportSummary -Severity Error, Warning
