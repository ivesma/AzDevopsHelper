function Get-LocalCredFileName {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$AppName,
        [ValidateSet('Linux', 'Windows')]
        [string]$OSType = 'Windows',
        [string]$BasePath
    )

    $file = ('LocalCred_{0}.xml' -f $AppName)
    $filePath = $BasePath

    switch ($OsType) {
        'Windows' {
            if ([string]::IsNullOrEmpty($filePath)) {
                $filePath = $env:USERPROFILE
            }
        }
        'Linux' {
            if ([string]::IsNullOrEmpty($filePath)) {
                $filePath = (Join-Path $env:HOME 'temp')
            }
            if (!(Test-Path $filePath -PathType Container)) {
                $null = New-Item $filePath -ItemType Directory
            }
        }
        default {
            throw ('Unhandled os type: {0}' -f $OsType)
        }
    }
    return (Join-Path $filePath $file)
}