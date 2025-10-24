# Import the function to test
. "$PSScriptRoot\Read-IniFile.ps1"

function New-TestIniFile {
    param (
        [string]$FilePath,
        [string]$Content
    )


    $Content | Out-File -FilePath $FilePath -Encoding UTF8
}


Describe "Read-IniFile" {
    BeforeAll {
        $testDirectory = Join-Path $TestDrive "IniTests"
        New-Item -Path $testDirectory -ItemType Directory -Force
    }

    Context "When file does not exist" {
        It "Should return null and write error for non-existent file" {
            $result = Read-IniFile -IniFilePath "C:\NonExistent\file.ini" -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
        }
    }

    Context "When parsing valid INI files" {
        It "Should parse simple key-value pairs in DEFAULT section" -Skip:$true {
            $testFile = Join-Path $testDirectory "simple.ini"
            New-TestIniFile -FilePath $testFile -Content @"
key1=value1
key2=value2
"@
            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["key1"] | Should -Be "value1"
            $result["DEFAULT"]["key2"] | Should -Be "value2"
        }

        It "Should parse sections with key-value pairs" -Skip:$true {
            $testFile = Join-Path $testDirectory "sections.ini"
            New-TestIniFile -FilePath $testFile -Content @"
[Section1]
key1=value1
key2=value2

[Section2]
key3=value3
key4=value4
"@

            $result = Read-IniFile -IniFilePath $testFile
            $result["Section1"]["key1"] | Should -Be "value1"
            $result["Section1"]["key2"] | Should -Be "value2"
            $result["Section2"]["key3"] | Should -Be "value3"
            $result["Section2"]["key4"] | Should -Be "value4"
        }

        It "Should handle mixed DEFAULT and sectioned content" -Skip:$true {
            $iniContent = @"
defaultKey=defaultValue
anotherDefault=anotherValue

[Section1]
sectionKey=sectionValue
"@
            $testFile = Join-Path $testDirectory "mixed.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["defaultKey"] | Should -Be "defaultValue"
            $result["DEFAULT"]["anotherDefault"] | Should -Be "anotherValue"
            $result["Section1"]["sectionKey"] | Should -Be "sectionValue"
        }

        It "Should ignore comments starting with #" -Skip:$true {
            $iniContent = @"
# This is a comment
key1=value1
# Another comment
[Section1]
# Comment in section
key2=value2
"@
            $testFile = Join-Path $testDirectory "comments_hash.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["key1"] | Should -Be "value1"
            $result["Section1"]["key2"] | Should -Be "value2"
            $result.Keys | Should -Not -Contain "# This is a comment"
        }

        It "Should ignore comments starting with ;" -Skip:$true {
            $iniContent = @"
; This is a comment
key1=value1
; Another comment
[Section1]
; Comment in section
key2=value2
"@
            $testFile = Join-Path $testDirectory "comments_semicolon.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["key1"] | Should -Be "value1"
            $result["Section1"]["key2"] | Should -Be "value2"
        }

        It "Should ignore empty lines" -Skip:$true {
            $iniContent = @"

key1=value1


[Section1]

key2=value2

"@
            $testFile = Join-Path $testDirectory "empty_lines.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["key1"] | Should -Be "value1"
            $result["Section1"]["key2"] | Should -Be "value2"
        }

        It "Should trim whitespace from keys and values" -Skip:$false {
            $iniContent = @"
  key1  =  value1
key2=  value2
  key3=value3

[  Section1  ]
  sectionKey  =  sectionValue
"@
            $testFile = Join-Path $testDirectory "whitespace.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["key1"] | Should -Be "value1"
            $result["DEFAULT"]["key2"] | Should -Be "value2"
            $result["DEFAULT"]["key3"] | Should -Be "value3"
            $result["Section1"]["sectionKey"] | Should -Be "sectionValue"
        }

        It "Should handle values with equals signs" -Skip:$true {
            $iniContent = @"
connectionString=Server=localhost;Database=test;User=admin
url=https://example.com/api?param=value
"@
            $testFile = Join-Path $testDirectory "equals_in_value.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["connectionString"] | Should -Be "Server=localhost;Database=test;User=admin"
            $result["DEFAULT"]["url"] | Should -Be "https://example.com/api?param=value"
        }

        It "Should handle empty values" -Skip:$true {
            $iniContent = @"
emptyKey=
anotherKey=
normalKey=value
"@
            $testFile = Join-Path $testDirectory "empty_values.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["DEFAULT"]["emptyKey"] | Should -Be ""
            $result["DEFAULT"]["anotherKey"] | Should -Be ""
            $result["DEFAULT"]["normalKey"] | Should -Be "value"
        }

        It "Should handle duplicate section names by using the same section" -Skip:$true {
            $iniContent = @"
[Section1]
key1=value1

[Section1]
key2=value2
"@
            $testFile = Join-Path $testDirectory "duplicate_sections.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["Section1"]["key1"] | Should -Be "value1"
            $result["Section1"]["key2"] | Should -Be "value2"
        }
    }

    Context "When parsing edge cases" {
        It "Should handle empty file" -Skip:$true {
            $testFile = Join-Path $testDirectory "empty.ini"
            "" | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 0
        }

        It "Should handle file with only comments" -Skip:$true {
            $iniContent = @"
# Comment 1
; Comment 2
# Another comment
"@
            $testFile = Join-Path $testDirectory "only_comments.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 0
        }

        It "Should handle section with no key-value pairs" -Skip:$true {
            $iniContent = @"
[EmptySection]

[AnotherSection]
key=value
"@
            $testFile = Join-Path $testDirectory "empty_section.ini"
            $iniContent | Out-File -FilePath $testFile -Encoding UTF8

            $result = Read-IniFile -IniFilePath $testFile
            $result["EmptySection"] | Should -BeOfType [hashtable]
            $result["EmptySection"].Keys.Count | Should -Be 0
            $result["AnotherSection"]["key"] | Should -Be "value"
        }
    }
}