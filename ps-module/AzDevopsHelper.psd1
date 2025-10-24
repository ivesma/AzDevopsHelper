@{
    RootModule        = 'AzDevopsHelper.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'e2c3f8b3-4c7a-4e2a-9a1d-2d8f7a8e9c1b'
    Author            = 'Martin Ives'
    CompanyName       = 'Imagesteps Limited'
    Copyright         = '(c) ImageSteps Limited. All rights reserved.'
    Description       = 'Small utilities for demos and day-to-day PowerShell tasks.'
    PowerShellVersion = '5.1'

    # Export only Public functions; PSM1 handles it dynamically
    FunctionsToExport = '*'# @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # Optional dependencies (example commented)
    RequiredModules   = @(
         @{ ModuleName = 'powershell-yaml'; ModuleVersion = '0.4.12' }
    )

    PrivateData = @{
        PSData = @{
            Tags        = @('Azure', 'Pipelines', 'yaml', 'yml', 'Utilities','Productivity','Demo','AzDevopsHelper')
            ProjectUri  = 'https://github.com/yourname/AzDevopsHelper'
            LicenseUri  = 'https://github.com/yourname/AzDevopsHelper/blob/main/LICENSE'
            IconUri     = 'https://raw.githubusercontent.com/yourname/AzDevopsHelper/main/assets/icon.png'
            ReleaseNotes = 'Initial release with Get-Greeting and logging helper.'
        }
    }
}
