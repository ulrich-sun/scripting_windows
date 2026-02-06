# 📦 Installers Directory

This directory should contain all the installer files required by the Windows Automated Installation Tool.

## ✅ Required Files Checklist

Place the following files in this directory before running the installation script:

### .NET Framework
- [ ] **dotnet35_installer.exe** - .NET Framework 3.5
  - Size: ~50 MB
  - Required: For legacy application support

### SQL Server Engines
- [ ] **sqlserver2008_x64.exe** - SQL Server 2008 (64-bit)
  - Size: ~1.5 GB
  - Architecture: x64 only
  
- [ ] **sqlserver2008_x86.exe** - SQL Server 2008 (32-bit)
  - Size: ~1.3 GB
  - Architecture: x86 only

- [ ] **sqlserver2012_x64.exe** - SQL Server 2012 (64-bit)
  - Size: ~1.5 GB
  - Architecture: x64 only
  
- [ ] **sqlserver2012_x86.exe** - SQL Server 2012 (32-bit)
  - Size: ~1.3 GB
  - Architecture: x86 only

### Shell Enhancement
- [ ] **OpenShellSetup_4_4_196.exe** - OpenShell 4.4.196
  - Size: ~8 MB
  - Required: For classic Start Menu

### SQL Server Connectivity
- [ ] **sqlncli_2012_x64.msi** - SQL Server Native Client 2012 (64-bit)
  - Size: ~12 MB
  - Architecture: x64 only
  - Required: For SQL Server connectivity

- [ ] **sqlncli_2012_x86.msi** - SQL Server Native Client 2012 (32-bit)
  - Size: ~10 MB
  - Architecture: x86 only
  - Required: For SQL Server connectivity

### Runtime Libraries
- [ ] **vcredist_x86.exe** - Visual C++ Redistributable (32-bit)
  - Size: ~14 MB
  - Architecture: x86
  - Required: For many applications

- [ ] **vcredist_x64.exe** - Visual C++ Redistributable (64-bit)
  - Size: ~16 MB
  - Architecture: x64 only
  - Required: For many applications

### Utilities
- [ ] **7z2301.exe** - 7-Zip
  - Size: ~1.5 MB
  - Alternative name: 7z-installer.exe
  - Required: File compression utility

## 📥 Download Sources

### Official Microsoft Downloads
- **.NET Framework 3.5**: 
  - https://www.microsoft.com/download/details.aspx?id=21
  - Or enable via Windows Features

- **SQL Server 2008/2012**: 
  - https://www.microsoft.com/sql-server/
  - Evaluation versions: https://www.microsoft.com/en-us/evalcenter/
  - MSDN Subscribers: https://my.visualstudio.com/

- **SQL Native Client 2012**:
  - https://www.microsoft.com/en-us/download/details.aspx?id=50402

- **Visual C++ Redistributables**:
  - https://support.microsoft.com/en-us/help/2977003/
  - Latest versions: https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist

### Open Source Downloads
- **OpenShell**:
  - GitHub: https://github.com/Open-Shell/Open-Shell-Menu/releases
  - Latest: https://github.com/Open-Shell/Open-Shell-Menu/releases/tag/v4.4.196

- **7-Zip**:
  - Official: https://www.7-zip.org/download.html
  - Version 23.01: https://www.7-zip.org/a/7z2301.exe

## 📋 Quick Download Commands

For PowerShell download automation:

```powershell
# Create Installers directory
New-Item -Path ".\Installers" -ItemType Directory -Force

# Example download (adjust URLs to actual sources)
# 7-Zip
Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2301.exe" -OutFile ".\Installers\7z2301.exe"

# OpenShell (check latest release)
# Invoke-WebRequest -Uri "https://github.com/Open-Shell/Open-Shell-Menu/releases/download/v4.4.196/OpenShellSetup_4_4_196.exe" -OutFile ".\Installers\OpenShellSetup_4_4_196.exe"
```

## ⚠️ Important Notes

### File Naming
- ✅ Ensure file names match **exactly** as listed above
- ✅ File names are case-sensitive on some systems
- ✅ Do not rename files after downloading

### Security
- ✅ Verify installer checksums (SHA256) for security
- ✅ Download only from official sources
- ✅ Scan files with antivirus before use
- ✅ Keep installers in a secure location

### Licensing
- ⚠️ SQL Server may require valid license or evaluation key
- ⚠️ Some downloads require a Microsoft account
- ⚠️ Check license terms before deployment
- ⚠️ Evaluation versions have time limits (180 days)

### Testing
- ✅ Test installers on a non-production system first
- ✅ Verify installer compatibility with your Windows version
- ✅ Keep backup copies of installers
- ✅ Document installer versions used

## 📊 Disk Space Requirements

| Component | Size | Notes |
|-----------|------|-------|
| .NET Framework 3.5 | ~50 MB | May already be on system |
| SQL Server 2008 | ~1.5 GB | Plus ~2 GB installation space |
| SQL Server 2012 | ~1.5 GB | Plus ~2 GB installation space |
| OpenShell | ~8 MB | Minimal |
| SQL Native Client | ~12 MB | Per architecture |
| Visual C++ | ~16 MB | Per architecture |
| 7-Zip | ~1.5 MB | Minimal |
| **Total** | ~3-4 GB | For all installers |

**Recommended**: 10 GB free disk space for installers + installation

## 🔍 Verification

After downloading, verify files:

```powershell
# List all files with sizes
Get-ChildItem .\Installers\* -File | Select-Object Name, Length, LastWriteTime

# Count files (should be 11)
(Get-ChildItem .\Installers\*.exe, .\Installers\*.msi).Count

# Verify specific file exists
Test-Path ".\Installers\dotnet35_installer.exe"
```

## 🆘 Troubleshooting

### File Not Found During Installation
- Check that the file exists in the Installers folder
- Verify the file name matches exactly
- Ensure no extra spaces in the file name

### Download Blocked
- Check your internet connection
- Verify URLs are accessible
- Try downloading from alternative sources
- Check if corporate firewall is blocking downloads

### File Corruption
- Re-download the file
- Verify checksums
- Try a different download source
- Check disk space during download

## 📝 Version Notes

### Recommended Versions
- **SQL Server 2012 SP4** (latest service pack) for production
- **SQL Server 2008 R2 SP3** for legacy compatibility
- **Visual C++ 2015-2022 Redistributable** (latest combined version)
- **7-Zip 23.01** (latest stable)
- **OpenShell 4.4.196** (latest release)

### Alternative Versions
If the exact versions are not available:
- 7-Zip: Any recent version (rename to 7z2301.exe or update script)
- Visual C++: Any 2015-2022 version (same redistributable)
- SQL Native Client: 2008 or 2012 version both work

## 🔗 Additional Resources

- [SQL Server Installation Guide](https://docs.microsoft.com/sql/database-engine/install-windows/)
- [Visual C++ Redistributable Information](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist)
- [.NET Framework Installation Guide](https://docs.microsoft.com/dotnet/framework/install/)

---

**Note**: This tool automatically detects system architecture and will only install compatible components.
