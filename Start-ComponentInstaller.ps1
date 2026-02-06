<#
.SYNOPSIS
    Windows Components Installer - Wrapper Script
    
.DESCRIPTION
    This script provides backward compatibility by importing the WindowsComponentInstaller
    module and launching the GUI. This maintains the same user experience as the original
    script while using the new module architecture.
    
.NOTES
    Author: Windows Scripting Automation
    Version: 1.0.0
    Requires: PowerShell 3.0+, Administrator privileges
    
.EXAMPLE
    .\Start-ComponentInstaller.ps1
    Launches the graphical installation interface.
#>

#Requires -RunAsAdministrator
#Requires -Version 3.0

# Import the module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "WindowsComponentInstaller"
Import-Module $modulePath -Force

# Display header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Components Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Installers directory exists
$installersPath = Join-Path -Path $PSScriptRoot -ChildPath "Installers"
if (-not (Test-Path -Path $installersPath)) {
    Write-Host "Creating Installers directory: $installersPath" -ForegroundColor Yellow
    New-Item -Path $installersPath -ItemType Directory -Force | Out-Null
}

# Display system information
$arch = Get-SystemArchitecture
Write-Host "System Architecture: $arch" -ForegroundColor White
Write-Host "Operating System: $([Environment]::OSVersion.VersionString)" -ForegroundColor White
Write-Host ""

# Launch the GUI
Show-ComponentInstallerGUI -InstallersPath $installersPath
