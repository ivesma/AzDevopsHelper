# Requires -Version 5.1
# Requires -Module Pester
. (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.ps1')
#. (Find-TH-Target#. (Find-TH-TargetFile -SearchPath $PSScriptRoot -SourceFile (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf))
Import-Module (Find-TH-TargetFile -SearchPath $PSScriptRoot -ModulePath)

Describe "All functions have Tests" -Tag 'Debug' {
    It "All functions should have corresponding tests" {
        Set-ItResult -Inconclusive -Because "Still to be implemented"
    }
}