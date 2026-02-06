# PowerShell Module - WindowsComponentInstaller

## 🎯 Module Overview

The **WindowsComponentInstaller** module provides a complete PowerShell-based solution for automated Windows component installation. It offers both GUI and programmatic interfaces with full PowerShell module capabilities.

## 🆕 What's New in Module Version

### Module Structure
The tool has been converted into a proper PowerShell module with:

✅ **Module Manifest** (`.psd1`) - Proper metadata and versioning  
✅ **Module Script** (`.psm1`) - All functions as module members  
✅ **Public Functions** - 10 exported functions for flexibility  
✅ **Private Functions** - Internal helper functions  
✅ **Module Variables** - Scoped variables for clean code  
✅ **Comment-Based Help** - Full PowerShell help documentation  

### Benefits of Module Format

1. **Reusability** - Import once, use anywhere in your scripts
2. **Discoverability** - Functions appear in PowerShell ISE and VS Code IntelliSense
3. **Help System** - Full `Get-Help` support for all functions
4. **Versioning** - Proper semantic versioning
5. **Distribution** - Easy to share and deploy
6. **Organization** - Clean separation of public and private functions

## 📦 Installation

### Option 1: Copy to Module Path

```powershell
# View your PowerShell module paths
$env:PSModulePath -split ';'

# Copy the WindowsComponentInstaller folder to one of these locations
# Common paths:
# - C:\Users\<Username>\Documents\WindowsPowerShell\Modules
# - C:\Program Files\WindowsPowerShell\Modules
```

### Option 2: Import from Current Directory

```powershell
# Navigate to the repository folder
cd C:\Path\To\scripting_windows

# Import the module
Import-Module .\WindowsComponentInstaller -Force
```

### Option 3: Add to PowerShell Profile

```powershell
# Edit your PowerShell profile
notepad $PROFILE

# Add this line:
Import-Module "C:\Path\To\scripting_windows\WindowsComponentInstaller"
```

## 🚀 Quick Start

### Method 1: Using the Wrapper Script (Easiest)

```powershell
# Just run the wrapper script (maintains backward compatibility)
.\Start-ComponentInstaller.ps1
```

### Method 2: Import and Use GUI

```powershell
# Import module
Import-Module .\WindowsComponentInstaller

# Launch GUI
Show-ComponentInstallerGUI
```

### Method 3: Programmatic Installation

```powershell
# Import module
Import-Module .\WindowsComponentInstaller

# Get component list
$components = Get-ComponentList

# Install a specific component
$sevenZip = $components | Where-Object { $_.Name -eq "7-Zip" }
Install-WindowsComponent -Component $sevenZip
```

## 📚 Module Functions

### Exported Public Functions

The module exports 10 public functions:

| Function | Description |
|----------|-------------|
| `Show-ComponentInstallerGUI` | Launch the graphical interface |
| `Install-WindowsComponent` | Install a single component |
| `Install-SQLServerInstance` | Install SQL Server with configuration |
| `Get-ComponentList` | Get list of available components |
| `Get-SystemArchitecture` | Detect system architecture (x86/x64) |
| `Test-ComponentFile` | Check if installer file exists |
| `Invoke-PostInstallationVerification` | Verify installed components |
| `Disable-WindowsFirewall` | Disable Windows Firewall |
| `Set-SystemLocaleToEnglishUS` | Configure system locale |
| `Write-InstallLog` | Write log messages |

### Getting Help

Every function has full PowerShell help documentation:

```powershell
# Get help for any function
Get-Help Show-ComponentInstallerGUI -Full
Get-Help Install-WindowsComponent -Examples
Get-Help Get-ComponentList -Detailed

# List all module functions
Get-Command -Module WindowsComponentInstaller
```

## 💡 Usage Examples

### Example 1: Interactive GUI Installation

```powershell
# Import and show GUI
Import-Module .\WindowsComponentInstaller
Show-ComponentInstallerGUI
```

### Example 2: Silent Batch Installation

```powershell
Import-Module .\WindowsComponentInstaller

# Define components to install
$componentsToInstall = @(
    ".NET Framework 3.5",
    "Visual C++ Redistributable x64",
    "7-Zip"
)

# Get and install components
$components = Get-ComponentList | Where-Object { $_.Name -in $componentsToInstall }

foreach ($component in ($components | Sort-Object Priority)) {
    Write-Host "Installing $($component.Name)..." -ForegroundColor Yellow
    $result = Install-WindowsComponent -Component $component
    if ($result) {
        Write-Host "  ✓ Installed" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed" -ForegroundColor Red
    }
}
```

### Example 3: SQL Server Installation

```powershell
Import-Module .\WindowsComponentInstaller

# Get SQL Server component
$sqlComponent = Get-ComponentList | Where-Object { 
    $_.Name -eq "SQL Server 2012 x64" 
}

# Create secure password
$password = ConvertTo-SecureString "MyStr0ng!Password" -AsPlainText -Force

# Install with dependencies
$dependencies = Get-ComponentList | Where-Object {
    $_.Name -in @("Visual C++ Redistributable x64", "SQL Server Native Client 2012 x64")
}

# Install dependencies first
foreach ($dep in ($dependencies | Sort-Object Priority)) {
    Install-WindowsComponent -Component $dep
}

# Install SQL Server
Install-WindowsComponent -Component $sqlComponent -SQLServerPassword $password

# Verify
Invoke-PostInstallationVerification
```

### Example 4: Check Component Availability

```powershell
Import-Module .\WindowsComponentInstaller

# Get all components
$components = Get-ComponentList

# Check which installer files are present
$installersPath = ".\Installers"
foreach ($component in $components) {
    $exists = Test-ComponentFile -Component $component -InstallersPath $installersPath
    $status = if ($exists) { "✓" } else { "✗" }
    $color = if ($exists) { "Green" } else { "Red" }
    Write-Host "$status $($component.Name)" -ForegroundColor $color
}
```

### Example 5: Windows Configuration

```powershell
Import-Module .\WindowsComponentInstaller

# Configure Windows settings
Write-Host "Configuring Windows..." -ForegroundColor Cyan

# Disable firewall
if (Disable-WindowsFirewall) {
    Write-Host "✓ Firewall disabled" -ForegroundColor Green
}

# Set locale
if (Set-SystemLocaleToEnglishUS) {
    Write-Host "✓ Locale configured" -ForegroundColor Green
}
```

### Example 6: Custom Logging

```powershell
Import-Module .\WindowsComponentInstaller

# Log different message types
Write-InstallLog -Message "Starting custom installation" -Level INFO
Write-InstallLog -Message "Warning: Old files detected" -Level WARNING
Write-InstallLog -Message "Component installed successfully" -Level SUCCESS
Write-InstallLog -Message "Installation failed" -Level ERROR

# Custom log file
Write-InstallLog -Message "Custom log entry" -LogFile "C:\MyLogs\custom.txt"
```

## 🔧 Advanced Usage

### Integration with Automation Scripts

```powershell
# In your deployment script
Import-Module WindowsComponentInstaller

function Deploy-StandardWorkstation {
    [CmdletBinding()]
    param(
        [string[]]$RequiredComponents = @(
            ".NET Framework 3.5",
            "Visual C++ Redistributable x64",
            "7-Zip"
        )
    )
    
    # Get components
    $components = Get-ComponentList | Where-Object { 
        $_.Name -in $RequiredComponents 
    }
    
    # Install in priority order
    $results = @()
    foreach ($component in ($components | Sort-Object Priority)) {
        $result = Install-WindowsComponent -Component $component
        $results += [PSCustomObject]@{
            Component = $component.Name
            Success = $result
        }
    }
    
    # Verify
    $verification = Invoke-PostInstallationVerification
    
    return @{
        InstallResults = $results
        Verification = $verification
    }
}

# Use the function
$deployment = Deploy-StandardWorkstation
$deployment.InstallResults | Format-Table
```

### Remote Installation via PowerShell Remoting

```powershell
# On remote computers
$servers = @("Server1", "Server2", "Server3")

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        # Copy module to remote machine first
        Import-Module WindowsComponentInstaller
        
        # Install components
        $component = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }
        Install-WindowsComponent -Component $component
    }
}
```

## 📁 Module Structure

```
WindowsComponentInstaller/
├── WindowsComponentInstaller.psd1       # Module manifest
├── WindowsComponentInstaller.psm1       # Module script file
├── README.md                            # Module documentation
├── Installers/                          # Installer files directory
│   ├── dotnet35_installer.exe
│   ├── sqlserver2012_x64.exe
│   ├── vcredist_x64.exe
│   └── ... (other installers)
└── Logs/                               # Log files
    └── InstallationLog_YYYYMMDD.txt
```

## 🔍 Module Information

### View Module Details

```powershell
# Get module information
Get-Module WindowsComponentInstaller

# View manifest details
Test-ModuleManifest .\WindowsComponentInstaller\WindowsComponentInstaller.psd1

# List exported functions
Get-Command -Module WindowsComponentInstaller

# View module variables
Get-Variable -Scope Script (when inside module)
```

### Module Properties

- **Name**: WindowsComponentInstaller
- **Version**: 1.0.0
- **GUID**: a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d
- **Author**: Windows Scripting Automation
- **PowerShell Version**: 3.0+
- **Compatible Editions**: Desktop
- **Required Assemblies**: System.Windows.Forms, System.Drawing

## 🆚 Script vs Module Comparison

### Original Script (Install-WindowsComponents.ps1)
- ✅ Single file
- ✅ Simple to run
- ❌ Must be in same directory
- ❌ Limited reusability
- ❌ No IntelliSense support
- ❌ Can't import functions separately

### New Module (WindowsComponentInstaller)
- ✅ Proper PowerShell module
- ✅ Import once, use anywhere
- ✅ Full IntelliSense support
- ✅ Individual function access
- ✅ Follows PowerShell best practices
- ✅ Easy to version and distribute
- ✅ Can be published to PowerShell Gallery
- ✅ Backward compatible (wrapper script included)

## 🎓 Learning Resources

### Module Development
- [PowerShell Module Documentation](https://docs.microsoft.com/powershell/scripting/developer/module/)
- [Writing Help for PowerShell Modules](https://docs.microsoft.com/powershell/scripting/developer/help/)
- [PowerShell Best Practices](https://docs.microsoft.com/powershell/scripting/developer/cmdlet/)

### Using This Module
- See `Example-ProgrammaticInstall.ps1` for comprehensive examples
- Run `Get-Help <FunctionName> -Examples` for function-specific examples
- Check the main README.md for general usage
- Review EXAMPLES.md for real-world scenarios

## 🐛 Troubleshooting

### Module Not Loading

```powershell
# Force reimport
Remove-Module WindowsComponentInstaller -ErrorAction SilentlyContinue
Import-Module .\WindowsComponentInstaller -Force

# Check for errors
Import-Module .\WindowsComponentInstaller -Verbose
```

### Functions Not Available

```powershell
# Verify module is loaded
Get-Module WindowsComponentInstaller

# Check exported functions
(Get-Module WindowsComponentInstaller).ExportedFunctions

# Ensure you're not in a restricted execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Permission Issues

```powershell
# Ensure running as Administrator
#Requires -RunAsAdministrator

# Or check manually
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Administrator privileges required"
}
```

## 📝 Change Log

### Version 1.0.0 (Current)
- ✅ Converted script to PowerShell module
- ✅ Created module manifest (.psd1)
- ✅ Organized functions into module script (.psm1)
- ✅ Added 10 exported public functions
- ✅ Implemented private helper functions
- ✅ Added comprehensive comment-based help
- ✅ Created module-specific documentation
- ✅ Maintained backward compatibility with wrapper script
- ✅ Added programmatic usage examples

## 🔮 Future Enhancements

Potential future module improvements:
- [ ] Add Pester tests for module functions
- [ ] Support for module auto-update
- [ ] Configuration file support (JSON/XML)
- [ ] Additional component definitions
- [ ] Custom component registration
- [ ] Parallel installation capabilities
- [ ] Integration with package managers (Chocolatey, WinGet)
- [ ] Publish to PowerShell Gallery
- [ ] WPF-based modern UI option
- [ ] REST API wrapper for remote management

## 🤝 Contributing

To contribute to this module:
1. Fork the repository
2. Create a feature branch
3. Follow PowerShell naming conventions (Verb-Noun)
4. Add comment-based help to new functions
5. Update module version in manifest
6. Update documentation
7. Submit pull request

## 📄 License

MIT License - See LICENSE file for details

---

**Module Version**: 1.0.0  
**Last Updated**: 2024-02-06  
**Requires**: PowerShell 3.0+, Windows 7/10/11, Administrator privileges
