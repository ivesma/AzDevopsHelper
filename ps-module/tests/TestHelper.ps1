$ErrorActionPreference = 'Stop'
if (-not (Get-Variable -Name ThisModuleName -Scope Global -ErrorAction SilentlyContinue)) {
    Write-Host "Setting Global:ThisModuleName to 'AzDevopsHelper'" -ForegroundColor Magenta

    Set-Variable -Name ThisModuleName -Scope Global -Option ReadOnly -Value 'AzDevopsHelper'
}

New-Module -Name TestHelper -ScriptBlock {
    function Find-TH-TargetFile {
        param (
            [ValidateScript({ (Test-Path $_ -PathType Container) })]
            [string]$SearchPath,
            [string]$SourceFile,
            [string]$TargetExtn,
            [int]$MaxDepth = 10,
            [switch]$ModulePath
        )

        if ($ModulePath) {
            $SearchPath = (Join-Path -Path $PSScriptRoot '..' -Resolve)
            $targetFileName = "$($Global:ThisModuleName).psd1"
        } else {
            $sFile = (Get-Item (Join-Path $SearchPath $SourceFile) -ErrorAction SilentlyContinue)
            if (-not $sFile) {
                throw "Source file '$SourceFile' not found in path '$SearchPath'"
            }
            if ([string]::IsNullOrEmpty($TargetExtn)) {
                $TargetExtn = $sFile.Extension
            }

            $targetFileName = ('{0}.{1}' -f ($sFile.BaseName -replace '\.tests$', ''), $TargetExtn.TrimStart('.'))
        }

        $foundFile = Get-ChildItem $SearchPath -Recurse -Filter $targetFileName -ErrorAction SilentlyContinue | Select-Object -First 1
        $counter = 0
        while (-not $foundFile) {
            $SearchPath = Join-Path -Path $SearchPath '..' -Resolve
            $foundFile = Get-ChildItem $SearchPath -Recurse -Filter $targetFileName -ErrorAction SilentlyContinue | Select-Object -First 1
            $counter++
            if ($counter -gt $MaxDepth) {
                throw "$targetFileName not found. Max search depth $MaxDepth reached"
            }
        }
        return $foundFile.FullName
    }
}