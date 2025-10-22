<#
.SYNOPSIS
    Reads and parses an INI configuration file into a PowerShell hashtable.

.DESCRIPTION
    This function reads an INI file and converts it into a nested hashtable structure.
    The function supports sections, key-value pairs, comments, and handles empty lines.
    Keys that appear before any section header are placed in a "DEFAULT" section.

.PARAMETER IniFilePath
    The path to the INI file to read. This parameter is mandatory.

.OUTPUTS
    System.Collections.Hashtable
    Returns a nested hashtable where:
    - Top-level keys are section names
    - Each section contains a hashtable of key-value pairs
    - Returns $null if the file is not found

.EXAMPLE
    $config = Read-IniFile -IniFilePath "C:\config\app.ini"

.EXAMPLE
    $settings = Read-IniFile -IniFilePath "./settings.ini"
    $dbConnection = $settings["Database"]["ConnectionString"]

.NOTES
    - Lines starting with # or ; are treated as comments and ignored
    - Empty lines are ignored
    - Section headers must be enclosed in square brackets [SectionName]
    - Key-value pairs are separated by the equals sign (=)
    - Leading and trailing whitespace is trimmed from keys and values
#>
function Read-IniFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IniFilePath
    )

    $ini = @{}
    $currentSection = "DEFAULT"

    if (-not (Test-Path $IniFilePath)) {
        Write-Error "INI file not found: $IniFilePath"
        return $null
    }

    Get-Content $IniFilePath | ForEach-Object {
        $line = $_.Trim()

        # Skip empty lines and comments
        if ($line -eq "" -or $line.StartsWith("#") -or $line.StartsWith(";")) {
            return
        }

        # Check for section headers
        if ($line -match '^\[(.+)\]$') {
            $currentSection = $matches[1]
            if (-not $ini.ContainsKey($currentSection)) {
                $ini[$currentSection] = @{}
            }
        }
        # Check for key-value pairs
        elseif ($line -match '^(.+?)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            if (-not $ini.ContainsKey($currentSection)) {
                $ini[$currentSection] = @{}
            }

            $ini[$currentSection][$key] = $value
        }
    }

    return $ini
}
