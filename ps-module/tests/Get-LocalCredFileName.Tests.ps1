# Requires -Module Pester
. (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.ps1')
#. (Find-TH-TargetFile -SearchPath $PSScriptRoot -SourceFile (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf))
Import-Module (Find-TH-TargetFile -SearchPath $PSScriptRoot -ModulePath)

Describe "Get-LocalCredFileName" -Tag 'Unit' {
    Context "Windows OS" {
        It "Returns correct path with default BasePath" {
            $appName = "TestApp"
            $expectedFile = "LocalCred_TestApp.xml"
            $result = Get-LocalCredFileName -AppName $appName -OSType "Windows"
            $userProfile = $env:USERPROFILE
            $expectedPath = Join-Path $userProfile $expectedFile
            $result | Should -Be $expectedPath
        }

        It "Returns correct path with custom BasePath" {
            $appName = "TestApp"
            $basePath = "TestDrive:SavedCreds"
            $expectedFile = "LocalCred_TestApp.xml"
            $result = Get-LocalCredFileName -AppName $appName -OSType "Windows" -BasePath $basePath
            $expectedPath = Join-Path $basePath $expectedFile
            $result | Should -Be $expectedPath
        }
    }

    Context "Linux OS" {
        BeforeAll {
            $env:HOME = "TestDrive:SavedCreds"
            if (!(Test-Path $env:HOME)) {
                New-Item $env:HOME -ItemType Directory | Out-Null
            }
        }
        AfterAll {
            Remove-Item $env:HOME -Recurse -Force
        }

        It "Returns correct path with default BasePath and creates directory if missing" {
            $appName = "TestApp"
            $expectedFile = "LocalCred_TestApp.xml"
            $expectedDir = Join-Path $env:HOME "temp"
            if (Test-Path $expectedDir) { Remove-Item $expectedDir -Recurse -Force }
            $result = Get-LocalCredFileName -AppName $appName -OSType "Linux"
            $expectedPath = Join-Path $expectedDir $expectedFile
            $result | Should -Be $expectedPath
            Test-Path $expectedDir | Should -Be $true
        }

        It "Returns correct path with custom BasePath" {
            $appName = "TestApp"
            $basePath = Join-Path $env:HOME "custom"
            if (!(Test-Path $basePath)) { New-Item $basePath -ItemType Directory | Out-Null }
            $expectedFile = "LocalCred_TestApp.xml"
            $result = Get-LocalCredFileName -AppName $appName -OSType "Linux" -BasePath $basePath
            $expectedPath = Join-Path $basePath $expectedFile
            $result | Should -Be $expectedPath
        }
    }

    Context "Parameter Validation" {
        It "Throws if AppName is empty" {
            { Get-LocalCredFileName -AppName "" } | Should -Throw
        }
        It "Throws if AppName is null" {
            { Get-LocalCredFileName -AppName $null } | Should -Throw
        }
        It "Throws if OSType is invalid" {
            { Get-LocalCredFileName -AppName "TestApp" -OSType "MacOs" } | Should -Throw
        }
    }
}