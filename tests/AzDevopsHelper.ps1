# Requires -Version 5.0
Import-Module (Join-Path $PSScriptRoot "/../AzDevopsHelper.psd1" -Resolve) -Force -Verbose

Get-Module AzDevopsHelper -ListAvailable | Select-Object -Property Name,Version,Path



Describe 'Get-Greeting' {

    It 'Returns greeting with provided name' -Skip:$false {
        (Get-Greeting -Name 'Martin') | Should -Be 'Hello, Martin! 👋'
    }

    It 'Falls back to current user when name not provided' -Skip:$false {
        $result = Get-Greeting
        $result | Should -Match 'Hello, .+! 👋'
    }
}
