@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'WindowsComponentInstaller.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d'

    # Author of this module
    Author = 'Windows Scripting Automation'

    # Company or vendor of this module
    CompanyName = 'Windows Scripting Automation'

    # Copyright statement for this module
    Copyright = '(c) 2024 Windows Scripting Automation. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Automated Windows Components Installation Tool - Provides functions for silent installation of multiple Windows components including .NET Framework, SQL Server, Visual C++ redistributables, and more with GUI support.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Show-ComponentInstallerGUI',
        'Install-WindowsComponent',
        'Install-SQLServerInstance',
        'Get-SystemArchitecture',
        'Test-ComponentFile',
        'Invoke-PostInstallationVerification',
        'Disable-WindowsFirewall',
        'Set-SystemLocaleToEnglishUS',
        'Get-ComponentList',
        'Write-InstallLog'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Windows', 'Installation', 'Automation', 'SQL-Server', 'Silent-Install', 'GUI', 'Components')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/ulrich-sun/scripting_windows/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/ulrich-sun/scripting_windows'

            # ReleaseNotes of this module
            ReleaseNotes = @'
Version 1.0.0:
- Initial module release
- Support for 11 Windows components
- GUI-based component selection
- Silent installation support
- SQL Server automatic configuration
- Windows system configuration
- Comprehensive logging
- Post-installation verification
'@
        }
    }

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}
