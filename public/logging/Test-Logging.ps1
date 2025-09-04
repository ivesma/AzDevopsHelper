function Test-Logging {
    <#
        .SYNOPSIS
            Test availability of Logger module
        .DESCRIPTION
            Test availability of Logger module
    #>
    [CmdletBinding()]
    param (
        [string]$ModuleName = 'Logging'
    )

    return ($null -ne (Get-Module -Name $ModuleName -ListAvailable))
}