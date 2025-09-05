. (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.ps1')
#. (Find-TH-TargetFile -SearchPath $PSScriptRoot -SourceFile (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf))
Import-Module (Find-TH-TargetFile -SearchPath $PSScriptRoot -ModulePath)

Describe 'Test-Logging' -Tag 'Unit' {

    Context 'When Logging module is available' {
        It "Should return $true" {
            Test-Logging -ModuleName (Get-Module -ListAvailable | Select-Object -ExpandProperty Name -First 1) | Should -BeTrue
        }
    }

    Context 'When Logging module is not available' {

        It "Should return $false" {
            Test-Logging -ModuleName "XXNotAvailableXX" | Should -BeFalse
        }
    }
}