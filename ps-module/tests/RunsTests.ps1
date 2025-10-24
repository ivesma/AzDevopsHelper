[CmdletBinding()]
param (
    [ValidateSet('Unit','Integration','Debug','All')]
    [string]$TagFilter = 'Unit'
)

$ErrorActionPreference = 'Stop'
$config = New-PesterConfiguration
$config.Run.PassThru = $true
$config.Filter.Tag = $TagFilter
$config.output.Verbosity = 'Detailed'

$results = Invoke-Pester -Configuration $config

<# $results | Select-Object -ExcludeProperty Containers | ConvertTo-Json -Depth 15 | Set-Content ($PSCommandPath -Replace '\.ps1$', '.Results.json') -Force
if ($results.FailedCount -gt 0) {
    exit 1
} else {
    exit 0
}

$pNames = @('FailedCount','FailedBlocksCount','FailedContainersCount','PassedCount','SkippedCount','InconclusiveCount','NotRunCount','TotalCount')

$results | Select-Object -Property $pNames #>