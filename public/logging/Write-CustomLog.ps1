<#
.SYNOPSIS
Writes a custom log message with various formatting and logging options.

.DESCRIPTION
The `Write-CustomLog` function allows you to write log messages with customizable levels, formatting, and metadata.
It supports indentation, error handling, and integration with external logging mechanisms.

.PARAMETER Message
The text message to write. This parameter is mandatory and cannot be null or empty.

.PARAMETER Arguments
An array of objects used to format the `Message` string. This parameter is optional.

.PARAMETER Body
An object that can contain additional log metadata, useful for logging targets like ElasticSearch. This parameter is optional.

.PARAMETER ExceptionInfo
An optional `ErrorRecord` object that provides additional error information.

.PARAMETER Level
The log level description. Valid values are 'NOTSET', 'DEBUG', 'INFO', 'WARNING', and 'ERROR'. Defaults to 'INFO'.

.PARAMETER Indent
The indent level prefix to prepend to the message. Defaults to 1.

.PARAMETER CallerScope
The scope depth for the call stack. Defaults to 2.

.PARAMETER ThrowError
A switch parameter that, when specified, throws an error after logging the message.

.EXAMPLE
Write-CustomLog -Message "This is an informational message."

Writes an informational message to the log.

.EXAMPLE
Write-CustomLog -Message "This is a warning message." -Level "WARNING"

Writes a warning message to the log with a yellow foreground color.

.EXAMPLE
Write-CustomLog -Message "An error occurred." -Level "ERROR" -ThrowError

Writes an error message to the log with a red background and throws an error.

.EXAMPLE
Write-CustomLog -Message "Formatted message: {0}" -Arguments @("Value1") -Level "DEBUG"

Writes a debug message with formatted arguments.

.NOTES
- The function checks if logging is enabled using `Test-Logging`. If logging is enabled, it delegates to `Write-Log`.
- Indentation is applied to the message if the `Indent` parameter is greater than 1.
- The function supports both console output and external logging mechanisms.

#>
function Write-CustomLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'The text message to write.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false, HelpMessage = 'An array of objects used to format <Message>.')]
        [ValidateNotNull()]
        [array]$Arguments = @(),

        [Parameter(Mandatory = $false, HelpMessage = 'An object that can contain additional log metadata (used in target like ElasticSearch).')]
        [object]$Body,

        [Parameter(Mandatory = $false, HelpMessage = 'An optional ErrorRecord.')]
        [System.Management.Automation.ErrorRecord]$ExceptionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Fill Level Description.')]
        [ValidateSet('NOTSET', 'DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO',

        [Parameter(Mandatory = $false, HelpMessage = 'Indent level prefix to message.')]
        [Alias('LogIndent')]
        [int]$Indent = 1,

        [Parameter(Mandatory = $false, HelpMessage = 'Scope Depth for Callstack.')]
        [int]$CallerScope = 2,

        [Parameter(Mandatory = $false, HelpMessage = 'Throw an error after logging message.')]
        [Alias('ThrowOnError')]
        [switch]$ThrowError
    )
    if (!(Test-Logging)) {
        $funcName = (Get-PSCallStack)[1].FunctionName.Replace('<Begin>', '')
        $msg = ('[{0:yyyy-MM-dd HH:mm:ss}] {1} [{2}] ' -f (Get-Date), $funcName, $Level.ToUpper())
        if ($Arguments.Count -gt 0) {
            $msg += ($Message -F $Arguments)
        } else {
            $msg += $Message
        }
        if ($Indent -gt 1) {
            $msg = ('{0}{1}' -f ('   ' * $Indent), $msg)
        }

        switch ($Level) {
            'WARNING' {
                Write-Host $msg -ForegroundColor Yellow
            }
            'DEBUG' {
                Write-Verbose $msg -BackgroundColor Blue -ForegroundColor Yellow
            }
            'ERROR' {
                Write-Host $msg -BackgroundColor Red -ForegroundColor White
                if ($null -ne $ExceptionInfo) {
                    Write-Host $ExceptionInfo.Exception.ToString()
                }
            }
            Default {
                Write-Host $msg
            }
        }
        if ($ThrowError) {
            throw $msg
        }
    } else {
        if ($Indent -gt 1) {
            $Message = ('_{0}{1}' -f ('   ' * $Indent), $Message)
        }

        Set-LoggingCallerScope -CallerScope $CallerScope
        Write-Log -Level $Level -Message $Message -Arguments $Arguments -Body $Body -ExceptionInfo $ExceptionInfo
        if ($ThrowError) {
            throw $Message
        }
    }
}
