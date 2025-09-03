# Ensure strictness
Set-StrictMode -Version Latest

$modPath = Split-Path (Get-Variable -Name 'PSCommandPath' -ValueOnly -Scope Script)
$moduleName = Get-ChildItem $modPath -Filter '*.psm1' | Select-Object -First 1 | Select-Object -ExpandProperty BaseName

$psdFile = Get-ChildItem $modPath -Recurse -Filter ('{0}.pssettings' -f $moduleName) | Select-Object -First 1
$tmpDataPath = Join-Path $psdFile.DirectoryName '.temp'
if (!(Test-Path $tmpDataPath -PathType Container)) {
    New-Item -Path $tmpDataPath -ItemType Directory
}

if ($null -eq $psdFile) {
    throw ('Unable to locate {0}.pssettings in {1}' -f $moduleName, $modPath)
}
$psData = Import-PowerShellDataFile -Path $psdFile.FullName

<# Set-Variable -Scope Global -Name ('{0}_{1}' -f $psData.GlobalRootPathVarPrefix, $moduleName) -Value $modPath
Set-Variable -Scope Global -Name 'AzDoOrganisation' -Value $psData.AzDoOrganisation
Set-Variable -Name "XlMaxRows" -Value 1048576 -Option Constant, AllScope -Force
Set-Variable -Name "XlMaxCols" -Value 256 -Option Constant, AllScope -Force #>

$exFuncNames = @()

foreach ($subFolder in (Get-ChildItem $modPath -Directory)) {
    if ($psData.IncludeScripts.Keys -notcontains $subFolder.Name) {
        continue
    }
    $scriptFiles = Get-ChildItem $subFolder.FullName -Recurse -Filter '*.ps1'
    foreach ($scriptFile in $scriptFiles | Where-Object { !$_.BaseName.ToLower().EndsWith('.tests') -and !$_.FullName.ToLower().EndsWith('.sb.ps1') }) {
        . ($scriptFile.FullName)
        if ($psData.IncludeScripts[$subFolder.Name].isPublic) {
            $exFuncNames += $scriptFile.BaseName
        }
    }
}

Export-ModuleMember -Function ($exFuncNames | Sort-Object -Unique) -Verbose
