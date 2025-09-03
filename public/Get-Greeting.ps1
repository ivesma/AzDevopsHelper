function Get-Greeting {
<#
.SYNOPSIS
Returns a personalized greeting.

.DESCRIPTION
Emits a friendly greeting for a supplied name. If no name is provided, uses the current user.

.PARAMETER Name
The name to greet.

.EXAMPLE
Get-Greeting -Name 'Martin'
Hello, Martin! 👋

.NOTES
Part of the AzDevopsHelper module.
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )

    begin { }
    process {
        if (-not $Name) {
            $Name = $env:USERNAME
        }

        Write-Log -Message "Greeting generated for '$Name'." -Level Info
        "Hello, $Name! 👋"
    }
    end { }
}

