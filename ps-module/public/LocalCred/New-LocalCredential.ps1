# File: scripts/module/public/New-LocalCredential.ps1
function New-LocalCredential {
    <#
        .SYNOPSIS
            Read/Create Local Persisted Credential
        .DESCRIPTION
            Read/Create Local Persisted Credential
        .PARAMETER AppName
            Name of the Application used for / Key
        .PARAMETER OSType
            Operating System (Windows/Linux) (defaults windows)
    #>
    [CmdletBinding()]
    [OutputType('PSCredential')]
    param (
        [Parameter(Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the Application used for / Key.')]
        [ValidateNotNullOrEmpty()]
        [string]$AppName,

        [Parameter(Mandatory = $false,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Operating System (Windows/Linux) (defaults windows).')]
        [ValidateSet('Linux', 'Windows')]
        [string]$OSType = 'Windows',
        [string]$BasePath,
        [switch]$Quiet
    )
    begin {
        if (!$Quiet) {
            Write-CustomLog -Level INFO -Message '{0}STARTED{0}' -Arguments @('----------')
        }
        $credFile = Get-LocalCredFileName -AppName $AppName -OSType $OSType -BasePath $BasePath
        $IsPester = ($null -ne (Get-PSCallStack | Where-Object { $_.FunctionName.ToLower().Contains('pester') }))
        switch ($OSType) {
            'Linux' {
                $currentUser = $env:USER
            }
            'Windows' {
                $currentUser = $env:USERNAME
            }
            default {}
        }
    }
    process {
        if (Test-Path $credFile -PathType Leaf) {
            $credential = Import-Clixml -Path $credFile
        } else {
            if ($IsPester) {
                Write-Warning ('[{0}|{1}] Called from a Pester Test. Provided testable credentials' -f (Get-Date -Format 'yyyy-MMM-dd HH:mm:ss'), (Split-Path -Leaf $PSCommandPath), $AppName)
                $credential = (New-Object System.Management.Automation.PSCredential ('user', (ConvertTo-SecureString 'pass' -AsPlainText -Force)))
            } else {
                $credential = Get-Credential -UserName $currentUser -Message ('Please enter credentials for {0}' -f $AppName)
            }
            $credential | Export-Clixml -Path $credFile
        }
        return $credential
    }
    end {
        if (!$Quiet) {
            Write-CustomLog -Level INFO -Message '{0}ENDED{0}' -Arguments @('----------')
        }
    }
}