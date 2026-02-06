# Example Usage Scenarios

This document provides practical examples of using the Windows Automated Installation Tool in different scenarios.

## Scenario 1: Setting Up a Development Workstation

### Objective
Install essential development tools on a fresh Windows 10 machine.

### Components to Install
- .NET Framework 3.5 (for legacy application support)
- Visual C++ Redistributables (both x86 and x64)
- 7-Zip (for file compression)

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Check the following boxes:
   - ☑ .NET Framework 3.5
   - ☑ Visual C++ Redistributable x86
   - ☑ Visual C++ Redistributable x64
   - ☑ 7-Zip
4. Click Install
5. Wait approximately 5-10 minutes

### Expected Result
```
Installation Summary:
✓ Successful: 4
✗ Failed: 0

Verification Results:
✓ .NET Framework 3.5: Installed
✓ Visual C++ Redistributables: Installed
✓ 7-Zip: Installed
```

---

## Scenario 2: SQL Server Database Server Setup

### Objective
Set up a SQL Server 2012 database server on Windows Server.

### Components to Install
- SQL Server Native Client 2012
- SQL Server 2012 x64
- Visual C++ Redistributable x64

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Enter SA password: `MySecure!Password123`
4. Check the following boxes:
   - ☑ Visual C++ Redistributable x64
   - ☑ SQL Server Native Client 2012 x64
   - ☑ SQL Server 2012 x64
5. Optionally check:
   - ☑ Disable Windows Firewall (if on private network)
6. Click Install
7. Wait approximately 20-30 minutes

### Post-Installation Verification
```powershell
# Check SQL Server service status
Get-Service MSSQLSERVER, SQLSERVERAGENT, SQLBrowser

# Test connection
sqlcmd -S localhost -U sa -P MySecure!Password123 -Q "SELECT @@VERSION"

# Verify TCP/IP on port 1433
netstat -an | findstr 1433
```

### Expected Result
- SQL Server service running
- SQL Agent service running
- SQL Browser service running
- TCP/IP listening on port 1433
- Mixed mode authentication enabled
- Current user has sysadmin privileges

---

## Scenario 3: Preparing a Test Environment

### Objective
Set up a complete test environment for legacy application testing.

### Components to Install
- All components except OpenShell

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Enter SA password: `TestEnvironment!2024`
4. Check all boxes except OpenShell
5. Check Windows configuration options:
   - ☑ Configure locale to English (US)
6. Click Install
7. Wait approximately 45-60 minutes

### Expected Result
Complete test environment with:
- Legacy framework support (.NET 3.5)
- Database server (SQL Server 2012)
- All required runtime libraries
- File compression utilities
- English (US) locale

---

## Scenario 4: Minimal SQL Server 2008 Installation

### Objective
Install SQL Server 2008 x86 on a 32-bit Windows 7 machine.

### Components to Install
- SQL Server 2008 x86
- SQL Server Native Client 2012 x86
- Visual C++ Redistributable x86

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Enter SA password: `Legacy!Server2008`
4. Check the following boxes:
   - ☑ Visual C++ Redistributable x86
   - ☑ SQL Server Native Client 2012 x86
   - ☑ SQL Server 2008 x86
5. Click Install
6. Wait approximately 20-30 minutes

### Notes
- Only x86 components will be available on 32-bit systems
- The script automatically detects architecture
- x64 components will be grayed out or hidden

---

## Scenario 5: OpenShell for Classic Start Menu

### Objective
Install OpenShell to provide a classic start menu on Windows 10/11.

### Components to Install
- OpenShell only

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Check only:
   - ☑ OpenShell 4.4.196
4. Click Install
5. Wait approximately 1-2 minutes

### Post-Installation
- Configure OpenShell settings:
  - Right-click Start button
  - Select "Settings" from OpenShell menu
  - Customize appearance and behavior

---

## Scenario 6: Secure Production Server Setup

### Objective
Set up a production SQL Server with security best practices.

### Components to Install
- SQL Server 2012 x64 with dependencies

### Steps
1. Launch PowerShell as Administrator
2. Run `.\Install-WindowsComponents.ps1`
3. Enter strong SA password: `Pr0duction!2024#SecureDB`
4. Check the following boxes:
   - ☑ .NET Framework 3.5
   - ☑ Visual C++ Redistributable x64
   - ☑ SQL Server Native Client 2012 x64
   - ☑ SQL Server 2012 x64
5. **DO NOT** check:
   - ☐ Disable Windows Firewall (keep firewall enabled)
6. Click Install
7. Wait approximately 25-35 minutes

### Post-Installation Security Steps
```powershell
# Configure firewall rule for SQL Server
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow

# Disable SA account (use Windows Authentication only)
# Connect via SSMS and run:
# ALTER LOGIN sa DISABLE;

# Review security settings
# Check SQL Server Configuration Manager for:
# - SSL/TLS encryption
# - Certificate configuration
# - Hide instance settings
```

---

## Scenario 7: Automated Deployment via Script

### Objective
Automate the installation without GUI interaction.

### Method
Modify the script to accept command-line parameters (requires script customization):

```powershell
# Example custom script: Install-Automated.ps1
param(
    [string[]]$Components,
    [string]$SAPassword
)

# Set components programmatically
# Modify the GUI to accept parameters or bypass GUI
# This is an advanced scenario requiring script modification
```

### Alternative: Silent Mode
Currently, the script requires GUI interaction. To make it fully automated:

1. Edit `Install-WindowsComponents.ps1`
2. Add parameter support:
```powershell
param(
    [switch]$Silent,
    [string[]]$ComponentNames,
    [string]$SAPassword
)
```
3. Add logic to skip GUI if `-Silent` is specified
4. Use component names to select installations

---

## Scenario 8: Troubleshooting Failed Installation

### Objective
Diagnose and fix a failed installation.

### Steps
1. Check the installation log:
```powershell
# Open the latest log
Get-ChildItem .\InstallationLog_*.txt | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

2. Identify the failed component:
```
[2024-02-06 14:30:45] [ERROR] Failed to install SQL Server 2012 x64: Exit code 1603
```

3. Common issues and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| Exit code 1603 | Prerequisites not met | Install dependencies first |
| Exit code 5100 | WMI service not running | Start WMI service |
| File not found | Installer missing | Check Installers folder |
| Permission denied | Not admin | Run as Administrator |
| Password error | Weak SA password | Use stronger password (8+ chars) |

4. Re-run installation:
   - Fix the identified issue
   - Launch the script again
   - Select only the failed component
   - Click Install

---

## Scenario 9: Batch Installation on Multiple Servers

### Objective
Install components on multiple servers efficiently.

### Approach
1. Prepare a shared network location with installers
2. Modify the script to use network path:
```powershell
$Global:InstallersPath = "\\fileserver\installers"
```

3. Use PowerShell remoting:
```powershell
# On management workstation
$servers = @("Server1", "Server2", "Server3")

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -FilePath ".\Install-WindowsComponents.ps1" -ArgumentList @{
        # Pass parameters here
    }
}
```

### Notes
- Requires PowerShell remoting enabled
- All servers need access to installer files
- Consider using configuration management tools (SCCM, Ansible, etc.)

---

## Best Practices

### Before Installation
1. ✅ Create system restore point
2. ✅ Backup critical data
3. ✅ Verify disk space (20GB+ recommended)
4. ✅ Check system requirements
5. ✅ Download all installer files
6. ✅ Test on non-production system first

### During Installation
1. ✅ Run as Administrator
2. ✅ Monitor progress via log file
3. ✅ Don't interrupt the installation
4. ✅ Keep system powered on
5. ✅ Disable antivirus temporarily

### After Installation
1. ✅ Review installation log
2. ✅ Verify all services are running
3. ✅ Test application connectivity
4. ✅ Re-enable antivirus
5. ✅ Restart system if required
6. ✅ Document configuration
7. ✅ Update firewall rules if needed

---

## Performance Tips

### Faster Installation
- Use local installers (not network)
- Close unnecessary applications
- Ensure adequate RAM (4GB+ minimum)
- Use SSD for faster disk I/O

### Reliability Tips
- Stable network connection
- Uninterrupted power supply
- Disable sleep/hibernation during install
- Run outside business hours for servers

---

## Support Matrix

| Windows Version | .NET 3.5 | SQL 2008 | SQL 2012 | OpenShell | VC++ | 7-Zip |
|----------------|----------|----------|----------|-----------|------|-------|
| Windows 7 SP1  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Windows 8.1    | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Windows 10     | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ |
| Windows 11     | ✅ | ❌ | ⚠️ | ✅ | ✅ | ✅ |
| Server 2008 R2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Server 2012 R2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Server 2016    | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ |
| Server 2019    | ✅ | ❌ | ⚠️ | ✅ | ✅ | ✅ |
| Server 2022    | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ |

Legend:
- ✅ Fully supported
- ⚠️ Limited support or requires workarounds
- ❌ Not supported

---

## Additional Resources

- [Microsoft SQL Server Documentation](https://docs.microsoft.com/sql/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [OpenShell Documentation](https://github.com/Open-Shell/Open-Shell-Menu/wiki)
- [Windows Admin Center](https://docs.microsoft.com/windows-server/manage/windows-admin-center/)
