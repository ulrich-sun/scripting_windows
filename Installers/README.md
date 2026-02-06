# Installers Directory

This directory should contain all the installer files required by the Windows Automated Installation Tool.

## Required Files

Place the following files in this directory before running the installation script:

1. **dotnet35_installer.exe** - .NET Framework 3.5
2. **sqlserver2008_x64.exe** - SQL Server 2008 (64-bit)
3. **sqlserver2008_x86.exe** - SQL Server 2008 (32-bit)
4. **sqlserver2012_x64.exe** - SQL Server 2012 (64-bit)
5. **sqlserver2012_x86.exe** - SQL Server 2012 (32-bit)
6. **OpenShellSetup_4_4_196.exe** - OpenShell 4.4.196
7. **sqlncli_2012_x64.msi** - SQL Server Native Client 2012 (64-bit)
8. **sqlncli_2012_x86.msi** - SQL Server Native Client 2012 (32-bit)
9. **vcredist_x86.exe** - Visual C++ Redistributable (32-bit)
10. **vcredist_x64.exe** - Visual C++ Redistributable (64-bit)
11. **7z2301.exe** - 7-Zip (or 7z-installer.exe)

## Download Sources

- **.NET Framework**: https://www.microsoft.com/download/
- **SQL Server**: https://www.microsoft.com/sql-server/
- **OpenShell**: https://github.com/Open-Shell/Open-Shell-Menu/releases
- **SQL Native Client**: https://www.microsoft.com/download/
- **Visual C++**: https://support.microsoft.com/help/
- **7-Zip**: https://www.7-zip.org/download.html

## Important Notes

- Ensure file names match exactly as listed above
- Verify installer checksums for security
- Test installers on a non-production system first
- Some files may require a Microsoft account or license
