# WindowsComponentInstaller Module

## Overview

The **WindowsComponentInstaller** is a PowerShell module that provides automated installation capabilities for multiple Windows components and applications. It supports both GUI-based and programmatic installation methods with comprehensive logging and verification.

## Features

- ✅ **PowerShell Module** - Proper module structure with manifest
- ✅ **Public Functions** - 10 exported functions for flexibility
- ✅ **GUI Support** - Windows Forms interface for interactive use
- ✅ **Programmatic API** - Full programmatic control over installations
- ✅ **11 Components** - Support for .NET, SQL Server, Visual C++, and more
- ✅ **Silent Installation** - All components install without user interaction
- ✅ **Logging** - Comprehensive logging to file and console
- ✅ **Verification** - Post-installation verification
- ✅ **Architecture Detection** - Automatic x86/x64 detection

## Installation

### Method 1: Manual Installation

1. Copy the `WindowsComponentInstaller` folder to one of your PowerShell module paths:
   ```powershell
   # View your module paths
   $env:PSModulePath -split ';'
   
   # Common locations:
   # C:\Users\<Username>\Documents\WindowsPowerShell\Modules
   # C:\Program Files\WindowsPowerShell\Modules
   ```

2. Import the module:
   ```powershell
   Import-Module WindowsComponentInstaller
   ```

### Method 2: Import from Current Directory

```powershell
# Import from current location
Import-Module .\WindowsComponentInstaller -Force
```

### Method 3: Using the Wrapper Script

Simply run the provided wrapper script:
```powershell
.\Start-ComponentInstaller.ps1
```

## Quick Start

### GUI Mode (Recommended for Interactive Use)

```powershell
# Import module
Import-Module WindowsComponentInstaller

# Show GUI
Show-ComponentInstallerGUI
```

### Programmatic Mode

```powershell
# Import module
Import-Module WindowsComponentInstaller

# Get available components
$components = Get-ComponentList

# Install 7-Zip
$sevenZip = $components | Where-Object { $_.Name -eq "7-Zip" }
Install-WindowsComponent -Component $sevenZip

# Verify installation
Invoke-PostInstallationVerification
```

## Exported Functions

### 1. Show-ComponentInstallerGUI

Displays the graphical user interface for component selection and installation.

```powershell
# Basic usage
Show-ComponentInstallerGUI

# With custom installers path
Show-ComponentInstallerGUI -InstallersPath "C:\MyInstallers"
```

**Parameters:**
- `InstallersPath` (Optional): Custom path to installers directory

**Requirements:**
- Administrator privileges
- Windows Forms assemblies

---

### 2. Install-WindowsComponent

Installs a single Windows component silently.

```powershell
# Get component
$component = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }

# Install
Install-WindowsComponent -Component $component

# Install with custom path
Install-WindowsComponent -Component $component -InstallersPath "C:\Installers"

# Install SQL Server with password
$password = ConvertTo-SecureString "MyPassword!" -AsPlainText -Force
$sqlComponent = Get-ComponentList | Where-Object { $_.Name -eq "SQL Server 2012 x64" }
Install-WindowsComponent -Component $sqlComponent -SQLServerPassword $password
```

**Parameters:**
- `Component` (Required): Component hashtable from Get-ComponentList
- `InstallersPath` (Optional): Custom path to installers
- `SQLServerPassword` (Optional): SecureString for SQL Server SA password

**Returns:** Boolean indicating success/failure

---

### 3. Install-SQLServerInstance

Specialized function for SQL Server installation with automatic configuration.

```powershell
# Create secure password
$password = ConvertTo-SecureString "Str0ng!Pass" -AsPlainText -Force

# Install SQL Server 2012 x64
Install-SQLServerInstance `
    -InstallerPath "C:\Installers\sqlserver2012_x64.exe" `
    -Version "2012" `
    -Architecture "x64" `
    -SAPassword $password
```

**Parameters:**
- `InstallerPath` (Required): Full path to SQL Server installer
- `Version` (Required): "2008" or "2012"
- `Architecture` (Required): "x86" or "x64"
- `SAPassword` (Required): SecureString for SA account

**Returns:** Boolean indicating success/failure

**Configuration Applied:**
- Mixed mode authentication
- TCP/IP enabled on port 1433
- Named Pipes disabled
- Automatic service startup
- Current user as sysadmin

---

### 4. Get-ComponentList

Returns the list of all available components.

```powershell
# Get all components
$components = Get-ComponentList

# Filter by architecture
$x64Components = $components | Where-Object { $_.Architecture -eq "x64" }

# Filter by priority
$highPriority = $components | Where-Object { $_.Priority -le 2 }

# Find specific component
$dotnet = $components | Where-Object { $_.Name -like "*NET*" }
```

**Returns:** Array of hashtables with component details

**Component Properties:**
- `Name`: Display name
- `File`: Installer filename
- `SilentArgs`: Silent installation arguments
- `Priority`: Installation order (1-5)
- `Architecture`: "Any", "x86", or "x64"
- `Type`: "SQLServer" for SQL components
- `Version`: SQL Server version (if applicable)

---

### 5. Get-SystemArchitecture

Detects the system architecture.

```powershell
$arch = Get-SystemArchitecture
# Returns "x64" or "x86"

if ($arch -eq "x64") {
    Write-Host "64-bit system detected"
}
```

**Returns:** String ("x64" or "x86")

---

### 6. Test-ComponentFile

Checks if a component installer file exists.

```powershell
$component = Get-ComponentList | Select-Object -First 1
$exists = Test-ComponentFile -Component $component

if ($exists) {
    Write-Host "Installer found"
} else {
    Write-Host "Installer missing"
}

# With custom path
Test-ComponentFile -Component $component -InstallersPath "C:\MyInstallers"
```

**Parameters:**
- `Component` (Required): Component hashtable
- `InstallersPath` (Optional): Custom installers directory

**Returns:** Boolean

---

### 7. Invoke-PostInstallationVerification

Verifies installed components.

```powershell
# Run verification
$results = Invoke-PostInstallationVerification

# Display results
foreach ($result in $results) {
    Write-Host $result
}
```

**Returns:** Array of verification result strings

**Checks:**
- .NET Framework 3.5 status
- SQL Server service status
- Visual C++ Redistributables
- 7-Zip installation

---

### 8. Disable-WindowsFirewall

Disables Windows Firewall for all profiles.

```powershell
$result = Disable-WindowsFirewall

if ($result) {
    Write-Host "Firewall disabled successfully"
} else {
    Write-Host "Failed to disable firewall"
}
```

**Returns:** Boolean indicating success/failure

**Warning:** Disabling firewall may expose system to security risks.

---

### 9. Set-SystemLocaleToEnglishUS

Configures system locale to English (US).

```powershell
$result = Set-SystemLocaleToEnglishUS

if ($result) {
    Write-Host "Locale configured successfully"
}
```

**Returns:** Boolean indicating success/failure

**Changes:**
- System locale: en-US
- User culture: en-US
- Timezone: Eastern Standard Time

---

### 10. Write-InstallLog

Writes log messages to file and console.

```powershell
# Different log levels
Write-InstallLog -Message "Starting installation" -Level INFO
Write-InstallLog -Message "Component installed" -Level SUCCESS
Write-InstallLog -Message "Minor issue detected" -Level WARNING
Write-InstallLog -Message "Installation failed" -Level ERROR

# Custom log file
Write-InstallLog -Message "Custom log" -Level INFO -LogFile "C:\Logs\custom.txt"
```

**Parameters:**
- `Message` (Required): Log message
- `Level` (Optional): "INFO", "WARNING", "ERROR", or "SUCCESS"
- `LogFile` (Optional): Custom log file path

**Default Log Location:** `ModuleRoot\Logs\InstallationLog_YYYYMMDD.txt`

## Usage Examples

### Example 1: Install Development Tools

```powershell
Import-Module WindowsComponentInstaller

# Get components
$components = Get-ComponentList

# Select development tools
$devTools = $components | Where-Object { 
    $_.Name -in @(".NET Framework 3.5", "Visual C++ Redistributable x64", "7-Zip")
}

# Sort by priority and install
$devTools | Sort-Object Priority | ForEach-Object {
    Write-Host "Installing $($_.Name)..." -ForegroundColor Yellow
    $result = Install-WindowsComponent -Component $_
    if ($result) {
        Write-Host "  ✓ Success" -ForegroundColor Green
    }
}
```

### Example 2: SQL Server Setup

```powershell
Import-Module WindowsComponentInstaller

# Get SQL Server and dependencies
$components = Get-ComponentList
$sqlComponents = $components | Where-Object {
    $_.Name -in @(
        "Visual C++ Redistributable x64",
        "SQL Server Native Client 2012 x64",
        "SQL Server 2012 x64"
    )
}

# Create password
$password = Read-Host "Enter SA password" -AsSecureString

# Install in order
foreach ($component in ($sqlComponents | Sort-Object Priority)) {
    Write-Host "Installing $($component.Name)..."
    if ($component.Type -eq "SQLServer") {
        Install-WindowsComponent -Component $component -SQLServerPassword $password
    } else {
        Install-WindowsComponent -Component $component
    }
}

# Verify
Invoke-PostInstallationVerification
```

### Example 3: Batch Installation

```powershell
Import-Module WindowsComponentInstaller

# Define components to install
$componentNames = @(
    ".NET Framework 3.5",
    "Visual C++ Redistributable x64",
    "7-Zip"
)

# Get and install
$components = Get-ComponentList | Where-Object { $_.Name -in $componentNames }
$successCount = 0
$failCount = 0

foreach ($component in ($components | Sort-Object Priority)) {
    $result = Install-WindowsComponent -Component $component
    if ($result) { $successCount++ } else { $failCount++ }
}

Write-Host "Summary: $successCount successful, $failCount failed"
```

### Example 4: Architecture-Specific Installation

```powershell
Import-Module WindowsComponentInstaller

# Get system architecture
$arch = Get-SystemArchitecture
Write-Host "System: $arch"

# Get compatible components only
$components = Get-ComponentList | Where-Object {
    $_.Architecture -eq "Any" -or $_.Architecture -eq $arch
}

Write-Host "Compatible components: $($components.Count)"
```

### Example 5: Custom Configuration

```powershell
Import-Module WindowsComponentInstaller

# Configure Windows before installation
Disable-WindowsFirewall
Set-SystemLocaleToEnglishUS

# Install components
$component = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }
Install-WindowsComponent -Component $component

# Verify
Invoke-PostInstallationVerification
```

## Directory Structure

```
WindowsComponentInstaller/
├── WindowsComponentInstaller.psd1    # Module manifest
├── WindowsComponentInstaller.psm1    # Module script
├── Installers/                       # Place installer files here
│   ├── dotnet35_installer.exe
│   ├── sqlserver2012_x64.exe
│   ├── vcredist_x64.exe
│   └── ...
└── Logs/                            # Log files location
    └── InstallationLog_YYYYMMDD.txt
```

## Requirements

- **PowerShell**: 3.0 or later
- **OS**: Windows 7, 10, or 11
- **Privileges**: Administrator rights required
- **Assemblies**: System.Windows.Forms, System.Drawing (for GUI)

## Configuration

### Custom Installers Path

You can specify a custom installers path with most functions:

```powershell
$customPath = "C:\MyCustomInstallers"
Show-ComponentInstallerGUI -InstallersPath $customPath
Install-WindowsComponent -Component $comp -InstallersPath $customPath
```

### Custom Log Path

Log files are stored in the module's Logs folder by default. You can specify custom paths:

```powershell
Write-InstallLog -Message "Custom log" -LogFile "C:\CustomLogs\my.log"
```

## Troubleshooting

### Module Not Found

```powershell
# Check module paths
$env:PSModulePath -split ';'

# Import from specific location
Import-Module "C:\Path\To\WindowsComponentInstaller" -Force
```

### Permission Errors

Ensure PowerShell is running as Administrator:
```powershell
#Requires -RunAsAdministrator
```

### Function Not Available

```powershell
# List all exported functions
Get-Command -Module WindowsComponentInstaller

# Reimport with force
Import-Module WindowsComponentInstaller -Force
```

### Installer Not Found

```powershell
# Check installer location
$component = Get-ComponentList | Select-Object -First 1
Test-ComponentFile -Component $component

# Verify Installers folder exists
Test-Path ".\WindowsComponentInstaller\Installers"
```

## Advanced Usage

### Create Custom Component List

```powershell
# Define custom components
$customComponents = @(
    @{
        Name = "My Custom App"
        File = "myapp.exe"
        SilentArgs = "/S"
        Priority = 1
        Architecture = "Any"
    }
)

# Install custom component
Install-WindowsComponent -Component $customComponents[0]
```

### Parallel Installation (Use with Caution)

```powershell
# Install multiple components in parallel
$components = Get-ComponentList | Select-Object -First 3
$jobs = $components | ForEach-Object {
    Start-Job -ScriptBlock {
        param($comp)
        Import-Module WindowsComponentInstaller
        Install-WindowsComponent -Component $comp
    } -ArgumentList $_
}

# Wait for completion
$jobs | Wait-Job | Receive-Job
```

### Integration with Other Scripts

```powershell
# In your deployment script
Import-Module WindowsComponentInstaller

function Deploy-WorkstationSoftware {
    param([string]$ComputerName)
    
    $components = Get-ComponentList | Where-Object {
        $_.Name -in @("7-Zip", "Visual C++ Redistributable x64")
    }
    
    foreach ($comp in $components) {
        Install-WindowsComponent -Component $comp
    }
}
```

## Version History

### Version 1.0.0
- Initial module release
- 10 exported public functions
- GUI and programmatic interfaces
- Support for 11 components
- Comprehensive logging
- Post-installation verification

## Support

For issues or questions:
- Check the log files in the Logs folder
- Review the EXAMPLES.md for usage scenarios
- Ensure all prerequisites are met
- Verify administrator privileges

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please ensure:
- Functions follow PowerShell best practices
- Proper comment-based help is included
- Changes are documented in CHANGELOG.md
- Module version is updated appropriately

---

**Module Name**: WindowsComponentInstaller  
**Version**: 1.0.0  
**Author**: Windows Scripting Automation  
**Last Updated**: 2024-02-06
