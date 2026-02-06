# Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- ✅ Windows 7 or later
- ✅ PowerShell 3.0+ (included in Windows)
- ✅ Administrator privileges
- ✅ Installer files downloaded

### Step 1: Prepare Installer Files (5 minutes)
1. Download required installer files (see Installers/README.md for sources)
2. Place all files in the `Installers` folder
3. Verify file names match exactly:
   - dotnet35_installer.exe
   - sqlserver2008_x64.exe or sqlserver2008_x86.exe
   - sqlserver2012_x64.exe or sqlserver2012_x86.exe
   - OpenShellSetup_4_4_196.exe
   - sqlncli_2012_x64.msi or sqlncli_2012_x86.msi
   - vcredist_x86.exe and/or vcredist_x64.exe
   - 7z2301.exe

### Step 2: Run the Script (30 seconds)
1. Right-click on PowerShell and select **"Run as Administrator"**
2. Navigate to the script directory:
   ```powershell
   cd C:\Path\To\scripting_windows
   ```
3. Run the script:
   ```powershell
   .\Install-WindowsComponents.ps1
   ```

### Step 3: Select Components (1 minute)
1. GUI window will open automatically
2. Check the boxes for components you want to install
3. If installing SQL Server:
   - Enter a strong SA password (8+ characters)
   - Example: `MyStr0ng!Pass`
4. Optional: Check Windows configuration options
   - ☐ Disable Windows Firewall
   - ☐ Configure locale to English (US)

### Step 4: Install (Variable time)
1. Click the **"Install"** button
2. Wait for installation to complete
3. Review the installation summary
4. Check the log file for details

### Step 5: Verify (1 minute)
1. Check the installation summary dialog
2. Review the log file:
   ```powershell
   notepad .\InstallationLog_*.txt
   ```
3. Verify services are running (for SQL Server):
   ```powershell
   Get-Service MSSQLSERVER, SQLSERVERAGENT
   ```

## 📋 Common Scenarios

### Scenario 1: Install Only SQL Server 2012 x64
1. Check only: `SQL Server 2012 x64`
2. Enter SA password
3. Click Install
4. Wait ~15-30 minutes

### Scenario 2: Install Development Tools
1. Check:
   - ✓ .NET Framework 3.5
   - ✓ Visual C++ Redistributable x86
   - ✓ Visual C++ Redistributable x64
   - ✓ 7-Zip
2. No SA password needed
3. Click Install
4. Wait ~5-10 minutes

### Scenario 3: Complete SQL Server Setup
1. Check:
   - ✓ .NET Framework 3.5
   - ✓ Visual C++ Redistributable x64
   - ✓ SQL Server Native Client 2012 x64
   - ✓ SQL Server 2012 x64
2. Enter SA password
3. Click Install
4. Wait ~20-40 minutes

### Scenario 4: Full Installation
1. Check all components
2. Enter SA password
3. Optionally check:
   - ✓ Disable Windows Firewall
   - ✓ Configure locale to English (US)
4. Click Install
5. Wait ~30-60 minutes

## ⚠️ Important Tips

1. **Administrator Rights**: Always run as administrator
2. **Antivirus**: Temporarily disable if installations fail
3. **Backup**: Create a system restore point first
4. **Testing**: Test on a non-production system first
5. **Password**: Use a strong SA password (8+ characters, mixed case, numbers, symbols)
6. **Time**: SQL Server installation takes 15-30 minutes
7. **Restart**: Some components may require a system restart

## 🔍 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Not administrator" error | Right-click PowerShell → "Run as Administrator" |
| "File not found" error | Check Installers folder and file names |
| SQL Server fails | Verify SA password meets complexity requirements |
| Script won't run | Check execution policy: `Set-ExecutionPolicy RemoteSigned` |
| Installation freezes | Check log file for errors, wait for timeout |

## 📝 After Installation

### Verify SQL Server (if installed)
```powershell
# Check services
Get-Service MSSQLSERVER, SQLSERVERAGENT, SQLBrowser

# Test connection (from SQL Server Management Studio)
Server: localhost
Authentication: SQL Server Authentication
Login: sa
Password: [your password]
```

### Verify Other Components
```powershell
# Check installed programs
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object {$_.DisplayName -like "*SQL*" -or $_.DisplayName -like "*Visual C++*" -or $_.DisplayName -like "*7-Zip*"} |
    Select-Object DisplayName, DisplayVersion

# Check .NET Framework 3.5
Get-WindowsOptionalFeature -Online -FeatureName NetFx3
```

### Connect to SQL Server
```powershell
# Using sqlcmd (if installed)
sqlcmd -S localhost -U sa -P [your password]

# Test query
SELECT @@VERSION
GO
```

## 🎯 Next Steps

1. **Test Applications**: Verify your applications work with installed components
2. **Configure Firewall**: If disabled, configure firewall rules for SQL Server
3. **Backup Settings**: Document your configuration
4. **Update**: Check for updates to installed components
5. **Monitor**: Watch services and check logs regularly

## 📚 More Information

- Full documentation: See [README.md](README.md)
- Configuration details: See [CONFIG.md](CONFIG.md)
- Installer sources: See [Installers/README.md](Installers/README.md)

## 🆘 Need Help?

1. Check the log file: `InstallationLog_*.txt`
2. Review the README.md troubleshooting section
3. Verify all prerequisites are met
4. Test with a minimal component selection first

## ⏱️ Estimated Installation Times

| Component | Approximate Time |
|-----------|-----------------|
| .NET Framework 3.5 | 2-5 minutes |
| Visual C++ Redistributables | 1-2 minutes each |
| SQL Native Client | 1-2 minutes |
| SQL Server 2008/2012 | 15-30 minutes |
| OpenShell | 1-2 minutes |
| 7-Zip | 30 seconds |
| **Total (all components)** | 30-60 minutes |

---

**Ready to start?** Run the script and follow the on-screen instructions!
