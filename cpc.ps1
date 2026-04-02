#!/usr/bin/env pwsh
# cpc.ps1 — PowerShell wrapper for the cpc Python script
& python (Join-Path $PSScriptRoot 'cpc') @args
exit $LASTEXITCODE
