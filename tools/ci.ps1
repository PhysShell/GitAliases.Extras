[CmdletBinding()]
param(
    [switch]$LintOnly,
    [switch]$TestOnly,
    [switch]$CurrentShellOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[string]$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..') |
    Select-Object -ExpandProperty Path -First 1

if (-not $TestOnly) {
    & (Join-Path $root 'tools\lint.ps1')
}

if (-not $LintOnly) {
    $testArgs = @{}
    if ($CurrentShellOnly) {
        $testArgs.CurrentShellOnly = $true
    }
    & (Join-Path $root 'tools\test.ps1') @testArgs
}

Write-Host 'CI checks completed.'
