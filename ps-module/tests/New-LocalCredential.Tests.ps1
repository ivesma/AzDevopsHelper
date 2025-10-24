# File: public/invoke-classes/New-LocalCredential.Tests.ps1
. (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.ps1')
#. (Find-TH-Target#. (Find-TH-TargetFile -SearchPath $PSScriptRoot -SourceFile (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf))

Describe "New-LocalCredential" -Tag 'Unit'  {

    BeforeAll {
        Import-Module (Find-TH-TargetFile -SearchPath $PSScriptRoot -ModulePath) -Verbose -Force

        $testAppName = "TestApp"
        $testOSType = "Windows"
        $testBasePath = "TestDrive:\TestCreds"
        $credFile = Get-LocalCredFileName -AppName $testAppName -OSType $testOSType -BasePath $testBasePath
        if (!(Test-Path $testBasePath)) {
            Write-Host ('[New-LocalCredential.Tests] Creating test directory') -BackgroundColor Gray -ForegroundColor White
            New-Item -Path $testBasePath -ItemType Directory | Out-Null
        }
        if (Test-Path $credFile) {
            Write-Host ('[New-LocalCredential.Tests] Removing existing credential file') -BackgroundColor Gray -ForegroundColor White
            Remove-Item $credFile -Force
        }
    }

    Context "When credential file does not exist" -Skip {
        It "Should prompt for credential and create file"  {

            # TODO: Find out why this does not work as expected
            Mock Get-Credential -ModuleName AzDevopsHelper {
                Write-Host ('[New-LocalCredential.Tests] Message') -BackgroundColor Gray -ForegroundColor White
                New-Object System.Management.Automation.PSCredential ("user", (ConvertTo-SecureString "pass" -AsPlainText -Force))
            }
            $cred = New-LocalCredential -AppName $testAppName -OSType $testOSType -BasePath $testBasePath

            $cred | Should -BeOfType 'System.Management.Automation.PSCredential'
            $cred.UserName | Should -Be "user"
            $cred.GetNetworkCredential().Password | Should -Be "pass"
#            Assert-MockCalled Get-Credential -ModuleName AzDevopsHelper -Exactly 1
        }
    }

    Context "When credential file exists"  {
        It "Should import credential from file" {
            $mockCred = New-Object System.Management.Automation.PSCredential ("user2", (ConvertTo-SecureString "pass2" -AsPlainText -Force)
            )
            $mockCred | Export-Clixml -Path $credFile

            Mock Import-Clixml { $mockCred }

            Write-Host ('[New-LocalCredential.Tests] Read saved credential from file') -BackgroundColor Gray -ForegroundColor White
            $cred = New-LocalCredential -AppName $testAppName -OSType $testOSType -BasePath $testBasePath -Quiet

            $cred | Should -BeOfType 'System.Management.Automation.PSCredential'
            $cred.UserName | Should -Be "user2"
            $cred.GetNetworkCredential().Password | Should -Be "pass2"
#            Assert-MockCalled Import-Clixml -Exactly 1
        }
    }

    Context "Parameter validation" {
        It "Should throw if AppName is missing" {
            { New-LocalCredential } | Should -Throw
        }
        It "Should default OSType to Windows" {
            Mock Get-Credential {
                New-Object System.Management.Automation.PSCredential ("user", (ConvertTo-SecureString "pass" -AsPlainText -Force))
            }
            Mock Export-Clixml { }
            $cred = New-LocalCredential -AppName $testAppName -BasePath $testBasePath -Quiet
            $cred | Should -BeOfType 'System.Management.Automation.PSCredential'
        }
    }
}
