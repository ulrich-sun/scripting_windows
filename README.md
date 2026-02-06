# Windows Automated Installation Tool

## 📋 Description

This tool provides a graphical interface for automated installation of multiple Windows components and applications. It supports silent installations, dependency management, SQL Server configuration, and Windows system configuration.

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

### Step 1: Prepare Installers
1. Create the `Installers` folder in the script directory
2. Download and place all required installer files
3. Ensure file names match the configuration

### Step 2: Run as Administrator
```powershell
# Right-click PowerShell and select "Run as Administrator"
# Navigate to the script directory
cd C:\Path\To\Script

# Run the script
.\Install-WindowsComponents.ps1
```

### Step 3: Select Components
1. The GUI will display all available components
2. Check the boxes for components you want to install
3. If installing SQL Server, enter the SA password
4. Optionally enable Windows configuration options:
   - Disable Windows Firewall
   - Configure locale to en-US

### Step 4: Start Installation
1. Click the **Install** button
2. Wait for the installation to complete
3. Review the installation summary
4. Check the log file for detailed information

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