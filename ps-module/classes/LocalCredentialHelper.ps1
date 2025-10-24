<#
.SYNOPSIS
Provides utility methods for managing and retrieving local credentials securely.

.DESCRIPTION
The `LocalCredentialHelper` class includes static methods to handle credential storage and retrieval.
It allows saving credentials to a secure file and retrieving them when needed.
The credentials are stored in an encrypted format using the `Export-Clixml` cmdlet.

.CLASS LocalCredentialHelper
Static class for managing local credentials.

.METHODS
[pscredential] Read([string]$AppName)
    Reads the credentials for the specified application name.
    If no credentials are found, prompts the user to enter credentials and saves them securely.

[pscredential] Read([string]$AppName, [string]$UserName)
    Reads the credentials for the specified application name and username.
    If no credentials are found, prompts the user to enter credentials and saves them securely.

[string] SavedCredentialFileName([string]$AppName)
    Generates the file path for storing the credentials of the specified application.

[string] PlainTextPassword([pscredential]$Credential)
    Retrieves the plain text password from a given PSCredential object.

.NOTES
- The credentials are stored in the user's profile directory in an encrypted XML file.
- The `Get-Credential` cmdlet is used to prompt the user for credentials when they are not already saved.

.EXAMPLES
# Example 1: Retrieve credentials for an application
$credential = [LocalCredentialHelper]::Read("MyApp")

# Example 2: Retrieve credentials for an application with a specific username
$credential = [LocalCredentialHelper]::Read("MyApp", "username")

# Example 3: Get the plain text password from a PSCredential object
$password = [LocalCredentialHelper]::PlainTextPassword($credential)
#>
<# class LocalCredentialHelper {
    static [pscredential] Read([string]$AppName) {
        return [LocalCredentialHelper]::Read($AppName, $env:USERNAME)
    }
    static [pscredential] Read([string]$AppName, [string]$UserName) {
        $savedFile = [LocalCredentialHelper]::SavedCredentialFileName($AppName)

        if (Test-Path $savedFile -PathType Leaf) {
            $credential = Import-Clixml -Path $savedFile
        }
        else {
            $credential = Get-Credential -UserName $UserName -Message "Enter '$AppName' credentials for $UserName"
            $credential | Export-Clixml -Path $savedFile
        }
        return $credential
    }

    static [string] SavedCredentialFileName([string]$AppName) {
        $file = ('LocalCred_{0}.xml' -f $AppName)
        return (Join-Path $env:USERPROFILE $file)
    }

    static [string] PlainTextPassword([pscredential]$Credential) {
        return $Credential.GetNetworkCredential().password
    }
} #>
class LocalCredentialHelper {
    static [pscredential] Read([string]$AppName) {
        return [LocalCredentialHelper]::Read($AppName, 'Windows')
    }
    static [pscredential] Read([string]$AppName, [string]$OsType) {
        $savedFile = [LocalCredentialHelper]::SavedCredentialFileName($AppName, $OsType)

        if (Test-Path $savedFile -PathType Leaf) {
            $credential = Import-Clixml -Path $savedFile
        } else {
            $credential = Get-Credential
            $credential | Export-Clixml -Path $savedFile
        }
        return $credential
    }

    static [string] SavedCredentialFileName([string]$AppName) {
        return [LocalCredentialHelper]::SavedCredentialFileName($AppName, 'Windows')
    }

    static [string] SavedCredentialFileName([string]$AppName, [string]$OsType) {
        $file = ('LocalCred_{0}.xml' -f $AppName)

        switch ($OsType) {
            'Windows' {
                return (Join-Path $env:USERPROFILE $file)
            }
            'Linux' {
                $path = (Join-Path $env:HOME 'temp')
                if (!(Test-Path $path -PathType Container)) {
                    $null = New-Item $path -ItemType Directory
                }
                return (Join-Path $path $file)
            }
            #            'MacOs' {  }
            Default {
                throw ('Unhandled os type: {0}' -f $OsType)
            }
        }
        return $null
    }
}