[CmdletBinding()]
param(
    [string]$TestsPath = '',
    [switch]$CurrentShellOnly,
    [string[]]$Shells = @('powershell', 'pwsh')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-UserModulePath {
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return (Join-Path $HOME 'Documents\WindowsPowerShell\Modules')
    } else {
        return (Join-Path $HOME 'Documents\PowerShell\Modules')
    }
}

$userModules = Get-UserModulePath
if ($env:PSModulePath -notlike "*$userModules*") {
    $env:PSModulePath = "$userModules;$env:PSModulePath"
}

if (-not $TestsPath) {
    $TestsPath = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\tests') |
        Select-Object -ExpandProperty Path -First 1
}

if (-not (Test-Path -LiteralPath $TestsPath)) {
    throw "Tests folder not found: $TestsPath"
}

$runAllShells = -not $CurrentShellOnly
if ($env:GITHUB_ACTIONS -eq 'true' -or $env:CI -eq 'true') {
    $runAllShells = $false
}

if ($runAllShells) {
    $uniqueShells = @($Shells | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
    if ($uniqueShells.Count -eq 0) {
        throw 'No shells specified for test execution.'
    }

    $missingShells = @($uniqueShells | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) })
    if ($missingShells.Count -gt 0) {
        throw ("Missing required shell executable(s): {0}. Install both Windows PowerShell 5.1 ('powershell') and PowerShell 7+ ('pwsh'), or run -CurrentShellOnly." -f ($missingShells -join ', '))
    }

    foreach ($shellName in $uniqueShells) {
        Write-Host ("Running tests in {0}..." -f $shellName)
        & $shellName -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -TestsPath $TestsPath -CurrentShellOnly
        if ($LASTEXITCODE -ne 0) {
            throw ("Tests failed in shell: {0}" -f $shellName)
        }
    }

    Write-Host ("Pester: all tests passed in shells: {0}." -f ($uniqueShells -join ', '))
    return
}

if (-not (Get-Module -ListAvailable -Name Pester)) {
    throw "Pester is not installed in this shell. Run: Install-Module Pester -Scope CurrentUser -Force"
}

Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop

$result = Invoke-Pester -Path $TestsPath -CI -PassThru -ErrorAction Stop
if ($null -eq $result) {
    throw 'Invoke-Pester returned no result.'
}
if ($result.FailedCount -gt 0) {
    throw "Pester failed: $($result.FailedCount) test(s) failed."
}

Write-Host ("Pester: all tests passed ({0} passed) in {1} {2}." -f $result.PassedCount, $PSVersionTable.PSEdition, $PSVersionTable.PSVersion)
