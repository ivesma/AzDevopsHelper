function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Info','Warn','Error')]
        [string]$Level = 'Info'
    )

    $prefix = switch ($Level) {
        'Info'  { '[INFO] ' }
        'Warn'  { '[WARN] ' }
        'Error' { '[ERROR]' }
    }

    Write-Verbose "$prefix $Message"
}
