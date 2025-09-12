#Install-Module -Name powershell-yaml -Scope CurrentUser -Force
Import-Module (Join-Path $PSScriptRoot '../AzDevopsHelper.psd1' -Resolve) -Force -Verbose

Get-Command -Module powershell-yaml

$cred = New-LocalCredential -AppName 'AzDO_Service_Access' -OSType 'Windows'
$pat = $cred.GetNetworkCredential().Password
$pat