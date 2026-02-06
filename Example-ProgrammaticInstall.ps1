<#
.SYNOPSIS
    Example script demonstrating programmatic use of WindowsComponentInstaller module.
    
.DESCRIPTION
    This script shows various ways to use the WindowsComponentInstaller module
    programmatically without the GUI.
    
.EXAMPLE
    .\Example-ProgrammaticInstall.ps1
#>

#Requires -RunAsAdministrator
#Requires -Version 3.0

# Import the module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "WindowsComponentInstaller"
Import-Module $modulePath -Force

Write-Host "Windows Component Installer - Programmatic Examples" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

#region Example 1: Get Component List
Write-Host "Example 1: Getting Available Components" -ForegroundColor Green
Write-Host "-" * 60
$components = Get-ComponentList
Write-Host "Available components: $($components.Count)"
foreach ($component in $components) {
    Write-Host "  - $($component.Name) [$($component.Architecture)]" -ForegroundColor White
}
Write-Host ""
#endregion

#region Example 2: Check System Architecture
Write-Host "Example 2: Checking System Architecture" -ForegroundColor Green
Write-Host "-" * 60
$arch = Get-SystemArchitecture
Write-Host "System Architecture: $arch" -ForegroundColor White
Write-Host ""
#endregion

#region Example 3: Test Component Files
Write-Host "Example 3: Testing Component File Availability" -ForegroundColor Green
Write-Host "-" * 60
$installersPath = Join-Path -Path $PSScriptRoot -ChildPath "Installers"
$componentsToCheck = Get-ComponentList | Select-Object -First 3

foreach ($component in $componentsToCheck) {
    $exists = Test-ComponentFile -Component $component -InstallersPath $installersPath
    $status = if ($exists) { "✓ Found" } else { "✗ Missing" }
    $color = if ($exists) { "Green" } else { "Red" }
    Write-Host "  $status : $($component.File)" -ForegroundColor $color
}
Write-Host ""
#endregion

#region Example 4: Install a Single Component (Simulated)
Write-Host "Example 4: Installing a Single Component" -ForegroundColor Green
Write-Host "-" * 60
Write-Host "Note: This is a demonstration. Uncomment the code to perform actual installation." -ForegroundColor Yellow
Write-Host ""
Write-Host "Code example:" -ForegroundColor Cyan
Write-Host @'
# Get 7-Zip component
$sevenZipComponent = Get-ComponentList | Where-Object { $_.Name -eq "7-Zip" }

# Install it
if ($sevenZipComponent) {
    $result = Install-WindowsComponent -Component $sevenZipComponent
    if ($result) {
        Write-Host "7-Zip installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "7-Zip installation failed!" -ForegroundColor Red
    }
}
'@ -ForegroundColor White
Write-Host ""
#endregion

#region Example 5: Install Multiple Components with Priority
Write-Host "Example 5: Batch Installation with Priority Ordering" -ForegroundColor Green
Write-Host "-" * 60
Write-Host "Note: This is a demonstration. Uncomment the code to perform actual installation." -ForegroundColor Yellow
Write-Host ""
Write-Host "Code example:" -ForegroundColor Cyan
Write-Host @'
# Select components to install
$componentsToInstall = Get-ComponentList | Where-Object { 
    $_.Name -in @("7-Zip", "Visual C++ Redistributable x64", ".NET Framework 3.5")
}

# Sort by priority
$sortedComponents = $componentsToInstall | Sort-Object -Property Priority

# Install each component
foreach ($component in $sortedComponents) {
    Write-Host "Installing $($component.Name)..." -ForegroundColor Yellow
    $result = Install-WindowsComponent -Component $component
    if ($result) {
        Write-Host "  ✓ Success" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed" -ForegroundColor Red
    }
}
'@ -ForegroundColor White
Write-Host ""
#endregion

#region Example 6: SQL Server Installation
Write-Host "Example 6: SQL Server Installation with Password" -ForegroundColor Green
Write-Host "-" * 60
Write-Host "Note: This is a demonstration. Uncomment the code to perform actual installation." -ForegroundColor Yellow
Write-Host ""
Write-Host "Code example:" -ForegroundColor Cyan
Write-Host @'
# Get SQL Server component
$sqlComponent = Get-ComponentList | Where-Object { 
    $_.Name -eq "SQL Server 2012 x64" 
}

# Create secure password
$password = ConvertTo-SecureString "MyStr0ng!Password" -AsPlainText -Force

# Install SQL Server
if ($sqlComponent) {
    $result = Install-WindowsComponent -Component $sqlComponent -SQLServerPassword $password
    if ($result) {
        Write-Host "SQL Server installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "SQL Server installation failed!" -ForegroundColor Red
    }
}
'@ -ForegroundColor White
Write-Host ""
#endregion

#region Example 7: Windows Configuration
Write-Host "Example 7: Windows System Configuration" -ForegroundColor Green
Write-Host "-" * 60
Write-Host "Note: This is a demonstration. Uncomment the code to perform actual configuration." -ForegroundColor Yellow
Write-Host ""
Write-Host "Code example:" -ForegroundColor Cyan
Write-Host @'
# Disable Windows Firewall
$firewallResult = Disable-WindowsFirewall
if ($firewallResult) {
    Write-Host "Firewall disabled successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to disable firewall!" -ForegroundColor Red
}

# Set locale to en-US
$localeResult = Set-SystemLocaleToEnglishUS
if ($localeResult) {
    Write-Host "Locale configured successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to configure locale!" -ForegroundColor Red
}
'@ -ForegroundColor White
Write-Host ""
#endregion

#region Example 8: Post-Installation Verification
Write-Host "Example 8: Post-Installation Verification" -ForegroundColor Green
Write-Host "-" * 60
Write-Host "Running verification..." -ForegroundColor Yellow
$results = Invoke-PostInstallationVerification
if ($results.Count -gt 0) {
    Write-Host "Verification results:" -ForegroundColor White
    foreach ($result in $results) {
        Write-Host "  $result" -ForegroundColor Green
    }
} else {
    Write-Host "No installed components detected." -ForegroundColor Yellow
}
Write-Host ""
#endregion

#region Example 9: Custom Logging
Write-Host "Example 9: Custom Logging" -ForegroundColor Green
Write-Host "-" * 60
Write-InstallLog -Message "This is an INFO message" -Level INFO
Write-InstallLog -Message "This is a WARNING message" -Level WARNING
Write-InstallLog -Message "This is an ERROR message" -Level ERROR
Write-InstallLog -Message "This is a SUCCESS message" -Level SUCCESS
Write-Host ""
#endregion

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Examples completed. Check the Logs folder for log files." -ForegroundColor Cyan
Write-Host ""
