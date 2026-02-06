# Windows Automated Installation Tool

## 📋 Description

This tool provides both a **PowerShell module** and a **graphical interface** for automated installation of multiple Windows components and applications. It supports silent installations, dependency management, SQL Server configuration, and Windows system configuration.

## 🆕 NEW: PowerShell Module

The tool is now available as a **PowerShell module** (`WindowsComponentInstaller`) with 10 exported functions for maximum flexibility:

- ✅ **GUI Mode** - Interactive Windows Forms interface
- ✅ **Programmatic Mode** - Full PowerShell API
- ✅ **Module Functions** - Import and use in your own scripts
- ✅ **Comment-Based Help** - Full `Get-Help` support

**Quick Start:**
```powershell
# Import module
Import-Module .\WindowsComponentInstaller

# Show GUI
Show-ComponentInstallerGUI

# Or install programmatically
$component = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }
Install-WindowsComponent -Component $component
```

👉 See **[MODULE.md](MODULE.md)** for complete module documentation  
👉 See **[Example-ProgrammaticInstall.ps1](Example-ProgrammaticInstall.ps1)** for 9 usage examples

## 🖥️ Supported Systems

- Windows 7
- Windows 10
- Windows 11

## ✨ Features

### Graphical User Interface
- Windows Forms-based GUI
- CheckedListBox for component selection
- Progress tracking and logging
- Real-time installation status

### Supported Components
1. **.NET Framework 3.5** - Legacy framework support
2. **SQL Server 2008 x64/x86** - Database engine
3. **SQL Server 2012 x64/x86** - Database engine
4. **OpenShell 4.4.196** - Classic shell for Windows
5. **SQL Server Native Client 2012 x64/x86** - SQL connectivity
6. **Visual C++ Redistributable x86/x64** - Runtime libraries
7. **7-Zip** - File compression utility

### Installation Features
- ✅ Silent installations (no user interaction required)
- ✅ Automatic dependency ordering
- ✅ Architecture detection (x86/x64)
- ✅ Post-installation verification
- ✅ Comprehensive logging
- ✅ Error handling and recovery

### SQL Server Configuration
When installing SQL Server, the tool automatically configures:
- 🔐 Mixed Mode Authentication (Windows + SQL)
- 🔑 Secure SA password (user-defined)
- 🌐 TCP/IP protocol enabled
- 🔌 Fixed TCP port: 1433
- 🚀 Automatic service startup
- 👤 Current user added as sysadmin
- 🔕 Named Pipes disabled
- 📡 SQL Server Browser enabled

### Windows System Configuration
Optional system configurations:
- 🛡️ Disable Windows Firewall
- 🌍 Set locale to English (US) - en-US
- ⏰ Configure timezone and date format

## 📦 Prerequisites

### System Requirements
- Windows 7 or later
- PowerShell 3.0 or later
- Administrator privileges

### Installer Files
Create an `Installers` folder in the same directory as the script and place the following files:

```
Installers/
├── dotnet35_installer.exe
├── sqlserver2008_x64.exe
├── sqlserver2008_x86.exe
├── sqlserver2012_x64.exe
├── sqlserver2012_x86.exe
├── OpenShellSetup_4_4_196.exe
├── sqlncli_2012_x64.msi
├── sqlncli_2012_x86.msi
├── vcredist_x86.exe
├── vcredist_x64.exe
└── 7z2301.exe (or 7z-installer.exe)
```

## 🚀 Usage

### Option 1: PowerShell Module (Recommended)

```powershell
# Import the module
Import-Module .\WindowsComponentInstaller

# Method A: Show GUI
Show-ComponentInstallerGUI

# Method B: Programmatic installation
$component = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }
Install-WindowsComponent -Component $component

# Method C: Batch installation
$components = Get-ComponentList | Where-Object { 
    $_.Name -in @("7-Zip", "Visual C++ Redistributable x64")
}
foreach ($comp in $components | Sort-Object Priority) {
    Install-WindowsComponent -Component $comp
}
```

See **[MODULE.md](MODULE.md)** for complete module documentation and examples.

### Option 2: Wrapper Script (Backward Compatible)

```powershell
# Run the wrapper script (launches GUI automatically)
.\Start-ComponentInstaller.ps1
```

### Option 3: Original Script

```powershell
# Run the original standalone script
.\Install-WindowsComponents.ps1
```

## 📖 Available Scripts

| Script | Description |
|--------|-------------|
| `Start-ComponentInstaller.ps1` | Wrapper script that imports module and launches GUI |
| `Install-WindowsComponents.ps1` | Original standalone script (still works) |
| `Example-ProgrammaticInstall.ps1` | 9 examples showing programmatic usage |

## 📚 Documentation Files

| File | Description |
|------|-------------|
| **[MODULE.md](MODULE.md)** | Complete module documentation with usage examples |
| **[README.md](README.md)** | This file - general overview and usage |
| **[QUICKSTART.md](QUICKSTART.md)** | Quick 5-minute setup guide |
| **[CONFIG.md](CONFIG.md)** | Detailed configuration options |
| **[EXAMPLES.md](EXAMPLES.md)** | Real-world usage scenarios |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System architecture and flow diagrams |

## 📦 Module Functions

The `WindowsComponentInstaller` module exports 10 public functions:

```powershell
# Get help for any function
Get-Help Show-ComponentInstallerGUI -Full
Get-Help Install-WindowsComponent -Examples

# List all functions
Get-Command -Module WindowsComponentInstaller
```

### Core Functions
- `Show-ComponentInstallerGUI` - Launch GUI
- `Install-WindowsComponent` - Install component
- `Install-SQLServerInstance` - SQL Server installer
- `Get-ComponentList` - Get available components

### Utility Functions
- `Get-SystemArchitecture` - Detect x86/x64
- `Test-ComponentFile` - Check file exists
- `Invoke-PostInstallationVerification` - Verify installs

### Configuration Functions
- `Disable-WindowsFirewall` - Disable firewall
- `Set-SystemLocaleToEnglishUS` - Configure locale
- `Write-InstallLog` - Log messages

## 📊 Installation Order

Components are installed in the following priority order:
1. **.NET Framework 3.5** (Priority 1)
2. **Visual C++ Redistributables** (Priority 2)
3. **SQL Server Native Client** (Priority 2)
4. **SQL Server** (Priority 3)
5. **7-Zip** (Priority 4)
6. **OpenShell** (Priority 5)

## 📝 Logging

Each installation session creates a timestamped log file:
```
InstallationLog_YYYYMMDD_HHMMSS.txt
```

The log includes:
- Installation start/end times
- Component installation status
- Error messages and warnings
- Configuration changes
- Verification results

## 🔍 Post-Installation Verification

The tool automatically verifies:
- .NET Framework 3.5 installation
- SQL Server service status
- Visual C++ Redistributables
- 7-Zip installation

## 🛠️ Troubleshooting

### Common Issues

**Issue: "This script requires administrator privileges"**
- Solution: Right-click PowerShell and select "Run as Administrator"

**Issue: "Installer file not found"**
- Solution: Ensure all installer files are in the `Installers` folder with correct names

**Issue: SQL Server installation fails**
- Solution: Check the log file for detailed error messages
- Ensure the SA password meets complexity requirements (8+ characters, mixed case, numbers, symbols)
- Verify system requirements for SQL Server

**Issue: Architecture mismatch**
- Solution: The tool automatically detects your system architecture
- Only components matching your architecture will be installed
- x64 systems can install both x86 and x64 components

### Log File Analysis

Check the log file for detailed information:
```powershell
# Open the latest log file
Get-Content .\InstallationLog_*.txt | Select-Object -Last 50
```

## ⚠️ Important Notes

1. **Administrator Rights**: The script must run with administrator privileges
2. **Antivirus**: Temporarily disable antivirus software if installations fail
3. **Internet Connection**: Not required if all installers are local
4. **Disk Space**: Ensure sufficient disk space for all components
5. **System Restart**: Some components may require a system restart
6. **Firewall**: Disabling the firewall may expose your system to security risks
7. **Backup**: Create a system restore point before running

## 🔒 Security Considerations

- SQL Server SA password is stored in memory as a SecureString
- Passwords are cleared from memory after use
- Log files may contain sensitive information - protect accordingly
- Disabling Windows Firewall reduces system security

## 📄 License

This tool is provided as-is for automated Windows component installation.

## 🤝 Support

For issues or questions:
1. Check the log file for error details
2. Review the troubleshooting section
3. Verify all prerequisites are met

## 📚 Technical Details

### Architecture Detection
The script detects the system architecture using:
```powershell
[Environment]::Is64BitOperatingSystem
```

### Silent Installation Parameters

| Component | Silent Args |
|-----------|-------------|
| .NET Framework 3.5 | `/q /norestart` |
| SQL Server | Custom configuration file |
| OpenShell | `/quiet /norestart` |
| SQL Native Client | `/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES` |
| Visual C++ | `/quiet /norestart` |
| 7-Zip | `/S` |

### SQL Server Configuration Details

The script configures SQL Server with:
```
- Mixed Mode Authentication
- SA account with custom password
- TCP/IP enabled on port 1433
- Named Pipes disabled
- SQL Server Browser enabled
- Current user as sysadmin
- Automatic service startup
```

## 🔄 Version History

### Version 1.0
- Initial release
- Support for 11 components
- GUI-based selection
- SQL Server configuration
- Windows system configuration
- Comprehensive logging
- Post-installation verification