# Requires -Version 5.0
. (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.ps1')
#. (Find-TH-Target#. (Find-TH-TargetFile -SearchPath $PSScriptRoot -SourceFile (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf))
Import-Module (Find-TH-TargetFile -SearchPath $PSScriptRoot -ModulePath)

Describe 'Get-Greeting' -Tag 'Debug' {

    It 'Returns greeting with provided name' -Skip:$false {
        (Get-Greeting -Name 'Martin') | Should -Be 'Hello, Martin! 👋'
    }

    It 'Falls back to current user when name not provided' -Skip:$false {
        $result = Get-Greeting
        $result | Should -Match 'Hello, .+! 👋'
    }
}
