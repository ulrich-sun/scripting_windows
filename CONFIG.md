# Installation Configuration Guide

## Overview
This document provides detailed configuration information for the Windows Automated Installation Tool.

## Directory Structure

```
scripting_windows/
├── Install-WindowsComponents.ps1   # Main script
├── README.md                        # Documentation
├── CONFIG.md                        # This file
├── Installers/                      # Place installer files here
│   ├── dotnet35_installer.exe
│   ├── sqlserver2008_x64.exe
│   ├── sqlserver2008_x86.exe
│   ├── sqlserver2012_x64.exe
│   ├── sqlserver2012_x86.exe
│   ├── OpenShellSetup_4_4_196.exe
│   ├── sqlncli_2012_x64.msi
│   ├── sqlncli_2012_x86.msi
│   ├── vcredist_x86.exe
│   ├── vcredist_x64.exe
│   └── 7z2301.exe
└── InstallationLog_*.txt            # Generated log files
```

## Component Configuration

### 1. .NET Framework 3.5
- **File**: dotnet35_installer.exe
- **Priority**: 1 (Installed first)
- **Architecture**: Any
- **Silent Args**: `/q /norestart`
- **Notes**: Required for many legacy applications

### 2. SQL Server 2008 x64
- **File**: sqlserver2008_x64.exe
- **Priority**: 3
- **Architecture**: x64 only
- **Type**: SQLServer
- **Configuration**: Automatic (Mixed Mode, TCP/IP, Port 1433)

### 3. SQL Server 2008 x86
- **File**: sqlserver2008_x86.exe
- **Priority**: 3
- **Architecture**: x86 only
- **Type**: SQLServer
- **Configuration**: Automatic (Mixed Mode, TCP/IP, Port 1433)

### 4. SQL Server 2012 x64
- **File**: sqlserver2012_x64.exe
- **Priority**: 3
- **Architecture**: x64 only
- **Type**: SQLServer
- **Configuration**: Automatic (Mixed Mode, TCP/IP, Port 1433)

### 5. SQL Server 2012 x86
- **File**: sqlserver2012_x86.exe
- **Priority**: 3
- **Architecture**: x86 only
- **Type**: SQLServer
- **Configuration**: Automatic (Mixed Mode, TCP/IP, Port 1433)

### 6. OpenShell 4.4.196
- **File**: OpenShellSetup_4_4_196.exe
- **Priority**: 5
- **Architecture**: Any
- **Silent Args**: `/quiet /norestart`
- **Notes**: Classic Start Menu for Windows

### 7. SQL Server Native Client 2012 x64
- **File**: sqlncli_2012_x64.msi
- **Priority**: 2
- **Architecture**: x64 only
- **Silent Args**: `/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES`
- **Notes**: Required for SQL Server connectivity

### 8. SQL Server Native Client 2012 x86
- **File**: sqlncli_2012_x86.msi
- **Priority**: 2
- **Architecture**: x86 only
- **Silent Args**: `/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES`
- **Notes**: Required for SQL Server connectivity

### 9. Visual C++ Redistributable x86
- **File**: vcredist_x86.exe
- **Priority**: 2
- **Architecture**: x86
- **Silent Args**: `/quiet /norestart`
- **Notes**: Required by many applications

### 10. Visual C++ Redistributable x64
- **File**: vcredist_x64.exe
- **Priority**: 2
- **Architecture**: x64 only
- **Silent Args**: `/quiet /norestart`
- **Notes**: Required by many applications

### 11. 7-Zip
- **File**: 7z2301.exe (or 7z-installer.exe)
- **Priority**: 4
- **Architecture**: Any
- **Silent Args**: `/S`
- **Notes**: File compression utility

## SQL Server Configuration Details

### Authentication Mode
- **Type**: Mixed Mode (Windows + SQL Authentication)
- **SA Password**: User-defined via GUI (must meet complexity requirements)

### Network Configuration
- **Protocol**: TCP/IP
- **Port**: 1433 (fixed)
- **Named Pipes**: Disabled
- **Dynamic Ports**: Disabled

### Service Configuration
- **SQL Server Service**: Automatic startup
- **SQL Server Agent**: Automatic startup
- **SQL Browser**: Automatic startup
- **Service Account**: NT AUTHORITY\SYSTEM

### Security Configuration
- **SA Password**: Required, user-defined
- **Windows Admin**: Current user added as sysadmin
- **License Terms**: Automatically accepted

### Features Installed
- SQL Engine
- Replication
- Full-Text Search
- Connectivity Components

## Windows System Configuration

### Firewall Settings
When "Disable Windows Firewall" is checked:
- Domain profile: Disabled
- Public profile: Disabled
- Private profile: Disabled

**Warning**: Disabling the firewall may expose your system to security risks.

### Locale Configuration
When "Configure locale to English (US)" is checked:
- System Locale: en-US
- User Culture: en-US
- Time Zone: Eastern Standard Time
- Date Format: MM/DD/YYYY
- Time Format: 12-hour with AM/PM

## Customizing the Script

### Adding New Components

To add a new component, edit the `$Global:Components` array:

```powershell
@{
    Name = "Your Component Name"
    File = "installer_filename.exe"
    SilentArgs = "/silent /norestart"
    Priority = 3  # Installation order (1-5)
    Architecture = "Any"  # "x86", "x64", or "Any"
}
```

### Modifying Installation Priorities

Priorities determine installation order (lower number = earlier):
1. **Priority 1**: Core frameworks (.NET)
2. **Priority 2**: Runtime libraries (VC++, SQL Native Client)
3. **Priority 3**: Major applications (SQL Server)
4. **Priority 4**: Utilities (7-Zip)
5. **Priority 5**: Optional components (OpenShell)

### Changing Silent Installation Parameters

Edit the `SilentArgs` property for each component:
- EXE files: Arguments passed directly to the executable
- MSI files: Arguments passed to msiexec.exe (automatically handled)

## Advanced Configuration

### Changing the Installers Path

Edit the global variable in the script:
```powershell
$Global:InstallersPath = "C:\CustomPath\Installers"
```

### Modifying Log File Location

Edit the log file path:
```powershell
$Global:LogFile = "C:\Logs\Install_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
```

### Custom SQL Server Configuration

To modify SQL Server installation parameters, edit the `Install-SQLServer` function:
```powershell
$configArgs = @(
    "/Q",
    "/ACTION=Install",
    "/FEATURES=SQLENGINE,REPLICATION,FULLTEXT,CONN",
    # Add or modify parameters here
)
```

## Installation Testing

### Test Mode
For testing without actual installations, you can add a test mode:
1. Comment out the `Start-Process` lines in `Install-Component`
2. Replace with logging statements
3. Run the script to test the GUI and flow

### Verification Commands

After installation, verify components manually:

```powershell
# Check .NET Framework 3.5
Get-WindowsOptionalFeature -Online -FeatureName NetFx3

# Check SQL Server
Get-Service -Name MSSQLSERVER, SQLSERVERAGENT, SQLBrowser

# Check registry for installed programs
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Select-Object DisplayName, DisplayVersion

# Check 64-bit programs (on x64 systems)
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Select-Object DisplayName, DisplayVersion
```

## Troubleshooting Configuration

### Log Level Adjustment

The script logs with different levels:
- **INFO**: General information
- **SUCCESS**: Successful operations
- **WARNING**: Non-critical issues
- **ERROR**: Critical failures

To add more verbose logging, modify the `Write-Log` function calls.

### SQL Server Installation Issues

Common configuration problems:
1. **SA Password**: Must be 8+ characters with complexity
2. **Permissions**: User must be local administrator
3. **Services**: Ensure WMI service is running
4. **Ports**: Port 1433 must not be in use

### Architecture Conflicts

The script automatically handles architecture:
- x64 systems: Can install both x86 and x64 components
- x86 systems: Can only install x86 components
- Components with wrong architecture are skipped

## Performance Optimization

### Parallel Installation
Currently, components install sequentially. To enable parallel installation:
- Modify the installation loop to use PowerShell jobs
- Group components by priority
- Install all same-priority components in parallel

### Progress Tracking
The progress bar updates after each component. To add more granular tracking:
- Update the progress bar during component installation
- Add sub-steps for SQL Server configuration

## Security Best Practices

1. **SA Password**: Use a strong password (16+ characters recommended)
2. **Firewall**: Only disable if absolutely necessary
3. **Logs**: Protect log files (may contain sensitive info)
4. **Installers**: Verify installer checksums before use
5. **Backup**: Create system restore point before running

## Download Links

### Official Sources
- **.NET Framework 3.5**: Microsoft Download Center
- **SQL Server**: Microsoft Evaluation Center or MSDN
- **OpenShell**: GitHub releases
- **SQL Native Client**: Microsoft Download Center
- **Visual C++ Redistributables**: Microsoft Download Center
- **7-Zip**: 7-zip.org

### Version Compatibility
Ensure installer versions match your Windows version:
- Windows 7: SQL Server 2008/2012 supported
- Windows 10: All versions supported
- Windows 11: May require SQL Server 2016+ for best compatibility

## Support and Maintenance

### Regular Updates
Check for updates to:
- Installer versions
- Silent installation parameters
- Windows compatibility
- Security patches

### Backup Strategy
Before running:
1. Create system restore point
2. Backup critical data
3. Document current system state
4. Test on non-production system first

## Appendix: Exit Codes

Common installer exit codes:
- **0**: Success
- **3010**: Success, reboot required
- **1603**: Fatal error during installation
- **1641**: Success, reboot initiated
- **5100**: Pre-requisites not met

The script treats 0 and 3010 as successful installations.
