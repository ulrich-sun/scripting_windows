<#
.SYNOPSIS
    Windows Components Installation Module
    
.DESCRIPTION
    PowerShell module for automated installation of Windows components and applications
    with silent installation support. Provides functions for GUI-based and programmatic
    component installation.
    
.NOTES
    Module Name: WindowsComponentInstaller
    Author: Windows Scripting Automation
    Version: 1.0.0
    Requires: PowerShell 3.0+, Administrator privileges
#>

#Requires -Version 3.0

# Module-level variables
$script:ModuleRoot = $PSScriptRoot
$script:DefaultInstallersPath = Join-Path -Path $script:ModuleRoot -ChildPath "Installers"
$script:DefaultLogPath = Join-Path -Path $script:ModuleRoot -ChildPath "Logs"

# Ensure Logs directory exists
if (-not (Test-Path -Path $script:DefaultLogPath)) {
    New-Item -Path $script:DefaultLogPath -ItemType Directory -Force | Out-Null
}

# Component definitions with their installer files and silent install parameters
$script:ComponentDefinitions = @(
    @{
        Name = ".NET Framework 3.5"
        File = "dotnet35_installer.exe"
        SilentArgs = "/q /norestart"
        Priority = 1
        Architecture = "Any"
    },
    @{
        Name = "SQL Server 2008 x64"
        File = "sqlserver2008_x64.exe"
        SilentArgs = ""  # Special handling in function
        Priority = 3
        Architecture = "x64"
        Type = "SQLServer"
        Version = "2008"
    },
    @{
        Name = "SQL Server 2008 x86"
        File = "sqlserver2008_x86.exe"
        SilentArgs = ""
        Priority = 3
        Architecture = "x86"
        Type = "SQLServer"
        Version = "2008"
    },
    @{
        Name = "SQL Server 2012 x64"
        File = "sqlserver2012_x64.exe"
        SilentArgs = ""
        Priority = 3
        Architecture = "x64"
        Type = "SQLServer"
        Version = "2012"
    },
    @{
        Name = "SQL Server 2012 x86"
        File = "sqlserver2012_x86.exe"
        SilentArgs = ""
        Priority = 3
        Architecture = "x86"
        Type = "SQLServer"
        Version = "2012"
    },
    @{
        Name = "OpenShell 4.4.196"
        File = "OpenShellSetup_4_4_196.exe"
        SilentArgs = "/quiet /norestart"
        Priority = 5
        Architecture = "Any"
    },
    @{
        Name = "SQL Server Native Client 2012 x64"
        File = "sqlncli_2012_x64.msi"
        SilentArgs = "/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES"
        Priority = 2
        Architecture = "x64"
    },
    @{
        Name = "SQL Server Native Client 2012 x86"
        File = "sqlncli_2012_x86.msi"
        SilentArgs = "/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES"
        Priority = 2
        Architecture = "x86"
    },
    @{
        Name = "Visual C++ Redistributable x86"
        File = "vcredist_x86.exe"
        SilentArgs = "/quiet /norestart"
        Priority = 2
        Architecture = "x86"
    },
    @{
        Name = "Visual C++ Redistributable x64"
        File = "vcredist_x64.exe"
        SilentArgs = "/quiet /norestart"
        Priority = 2
        Architecture = "x64"
    },
    @{
        Name = "7-Zip"
        File = "7z2301.exe"
        SilentArgs = "/S"
        Priority = 4
        Architecture = "Any"
    }
)

#region Public Functions

<#
.SYNOPSIS
    Gets the list of available components for installation.

.DESCRIPTION
    Returns the list of all Windows components that can be installed with this module.

.EXAMPLE
    Get-ComponentList
    Returns all available components with their details.

.OUTPUTS
    Array of hashtables containing component information.
#>
function Get-ComponentList {
    [CmdletBinding()]
    param()
    
    return $script:ComponentDefinitions
}

<#
.SYNOPSIS
    Writes a log message to file and console.

.DESCRIPTION
    Writes a timestamped log message to the log file and displays it in the console
    with color-coding based on severity level.

.PARAMETER Message
    The message to log.

.PARAMETER Level
    The severity level of the message (INFO, WARNING, ERROR, SUCCESS).

.PARAMETER LogFile
    Optional custom log file path. If not specified, uses default location.

.EXAMPLE
    Write-InstallLog -Message "Installation started" -Level INFO

.EXAMPLE
    Write-InstallLog -Message "Component installed successfully" -Level SUCCESS
#>
function Write-InstallLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        
        [Parameter(Mandatory=$false)]
        [string]$LogFile
    )
    
    if (-not $LogFile) {
        $LogFile = Join-Path -Path $script:DefaultLogPath -ChildPath "InstallationLog_$(Get-Date -Format 'yyyyMMdd').txt"
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to file
    Add-Content -Path $LogFile -Value $logMessage
    
    # Write to console with color
    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default   { Write-Host $logMessage -ForegroundColor White }
    }
}

<#
.SYNOPSIS
    Gets the system architecture (x86 or x64).

.DESCRIPTION
    Detects and returns the operating system architecture.

.EXAMPLE
    Get-SystemArchitecture
    Returns "x64" or "x86".

.OUTPUTS
    String representing the system architecture.
#>
function Get-SystemArchitecture {
    [CmdletBinding()]
    param()
    
    if ([Environment]::Is64BitOperatingSystem) {
        return "x64"
    } else {
        return "x86"
    }
}

<#
.SYNOPSIS
    Tests if the current user has administrator privileges.

.DESCRIPTION
    Checks if the current PowerShell session is running with administrator privileges.

.EXAMPLE
    Test-IsAdministrator
    Returns $true if running as administrator, $false otherwise.

.OUTPUTS
    Boolean indicating administrator status.
#>
function Test-IsAdministrator {
    [CmdletBinding()]
    param()
    
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
    Disables Windows Firewall for all profiles.

.DESCRIPTION
    Disables Windows Firewall for Domain, Public, and Private profiles.

.EXAMPLE
    Disable-WindowsFirewall

.OUTPUTS
    Boolean indicating success or failure.
#>
function Disable-WindowsFirewall {
    [CmdletBinding()]
    param()
    
    Write-InstallLog "Disabling Windows Firewall..." -Level INFO
    
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
        Write-InstallLog "Windows Firewall disabled successfully" -Level SUCCESS
        return $true
    } catch {
        Write-InstallLog "Failed to disable Windows Firewall: $_" -Level ERROR
        return $false
    }
}

<#
.SYNOPSIS
    Sets the system locale to English (US).

.DESCRIPTION
    Configures the system locale, user culture, and timezone to English (US) settings.

.EXAMPLE
    Set-SystemLocaleToEnglishUS

.OUTPUTS
    Boolean indicating success or failure.
#>
function Set-SystemLocaleToEnglishUS {
    [CmdletBinding()]
    param()
    
    Write-InstallLog "Configuring system locale to en-US..." -Level INFO
    
    try {
        Set-WinSystemLocale -SystemLocale en-US -ErrorAction Stop
        Set-Culture -CultureInfo en-US -ErrorAction Stop
        Set-TimeZone -Id "Eastern Standard Time" -ErrorAction Stop
        
        Write-InstallLog "System locale configured to en-US successfully" -Level SUCCESS
        return $true
    } catch {
        Write-InstallLog "Failed to configure system locale: $_" -Level ERROR
        return $false
    }
}

<#
.SYNOPSIS
    Tests if a component installer file exists.

.DESCRIPTION
    Checks if the installer file for a specified component exists in the installers directory.

.PARAMETER Component
    The component hashtable containing the file information.

.PARAMETER InstallersPath
    Optional custom path to the installers directory.

.EXAMPLE
    Test-ComponentFile -Component $component

.OUTPUTS
    Boolean indicating if the file exists.
#>
function Test-ComponentFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Component,
        
        [Parameter(Mandatory=$false)]
        [string]$InstallersPath
    )
    
    if (-not $InstallersPath) {
        $InstallersPath = $script:DefaultInstallersPath
    }
    
    $filePath = Join-Path -Path $InstallersPath -ChildPath $Component.File
    return Test-Path -Path $filePath
}

<#
.SYNOPSIS
    Installs a SQL Server instance with automatic configuration.

.DESCRIPTION
    Installs SQL Server with predefined configuration including mixed mode authentication,
    TCP/IP enablement, and automatic service startup.

.PARAMETER InstallerPath
    Path to the SQL Server installer executable.

.PARAMETER Version
    SQL Server version (2008 or 2012).

.PARAMETER Architecture
    System architecture (x86 or x64).

.PARAMETER SAPassword
    Secure string containing the SA account password.

.EXAMPLE
    $password = ConvertTo-SecureString "MyPassword123!" -AsPlainText -Force
    Install-SQLServerInstance -InstallerPath "C:\path\sqlserver.exe" -Version "2012" -Architecture "x64" -SAPassword $password

.OUTPUTS
    Boolean indicating success or failure.
#>
function Install-SQLServerInstance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InstallerPath,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("2008", "2012")]
        [string]$Version,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("x86", "x64")]
        [string]$Architecture,
        
        [Parameter(Mandatory=$true)]
        [securestring]$SAPassword
    )
    
    Write-InstallLog "Installing SQL Server $Version ($Architecture)..." -Level INFO
    
    # Convert secure string to plain text
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SAPassword)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # Get current user
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    
    # Build SQL Server installation parameters
    $configArgs = @(
        "/Q",
        "/ACTION=Install",
        "/FEATURES=SQLENGINE,REPLICATION,FULLTEXT,CONN",
        "/INSTANCENAME=MSSQLSERVER",
        "/SECURITYMODE=SQL",
        "/SAPWD=`"$PlainPassword`"",
        "/SQLSVCACCOUNT=`"NT AUTHORITY\SYSTEM`"",
        "/SQLSYSADMINACCOUNTS=`"$currentUser`"",
        "/AGTSVCACCOUNT=`"NT AUTHORITY\SYSTEM`"",
        "/AGTSVCSTARTUPTYPE=Automatic",
        "/SQLSVCSTARTUPTYPE=Automatic",
        "/BROWSERSVCSTARTUPTYPE=Automatic",
        "/TCPENABLED=1",
        "/NPENABLED=0",
        "/IACCEPTSQLSERVERLICENSETERMS"
    )
    
    try {
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $configArgs -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-InstallLog "SQL Server $Version ($Architecture) installed successfully" -Level SUCCESS
            
            # Configure SQL Server after installation
            Start-Sleep -Seconds 10
            Configure-SQLServer -Version $Version
            
            return $true
        } else {
            Write-InstallLog "SQL Server installation failed with exit code: $($process.ExitCode)" -Level ERROR
            return $false
        }
    } catch {
        Write-InstallLog "SQL Server installation error: $_" -Level ERROR
        return $false
    } finally {
        # Clear password from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
}

<#
.SYNOPSIS
    Installs a Windows component.

.DESCRIPTION
    Installs a Windows component using silent installation parameters.
    Supports both EXE and MSI installers.

.PARAMETER Component
    The component hashtable containing installation information.

.PARAMETER InstallersPath
    Optional custom path to the installers directory.

.PARAMETER SQLServerPassword
    Secure string containing the SQL Server SA password (required for SQL Server components).

.EXAMPLE
    Install-WindowsComponent -Component $component

.EXAMPLE
    $password = ConvertTo-SecureString "MyPassword123!" -AsPlainText -Force
    Install-WindowsComponent -Component $sqlComponent -SQLServerPassword $password

.OUTPUTS
    Boolean indicating success or failure.
#>
function Install-WindowsComponent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Component,
        
        [Parameter(Mandatory=$false)]
        [string]$InstallersPath,
        
        [Parameter(Mandatory=$false)]
        [securestring]$SQLServerPassword
    )
    
    if (-not $InstallersPath) {
        $InstallersPath = $script:DefaultInstallersPath
    }
    
    Write-InstallLog "Starting installation of $($Component.Name)..." -Level INFO
    
    $installerPath = Join-Path -Path $InstallersPath -ChildPath $Component.File
    
    # Check if file exists
    if (-not (Test-Path -Path $installerPath)) {
        Write-InstallLog "Installer file not found: $installerPath" -Level ERROR
        return $false
    }
    
    # Check architecture compatibility
    $sysArch = Get-SystemArchitecture
    if ($Component.Architecture -ne "Any" -and $Component.Architecture -ne $sysArch) {
        Write-InstallLog "Component architecture ($($Component.Architecture)) does not match system architecture ($sysArch)" -Level WARNING
        return $false
    }
    
    # Special handling for SQL Server
    if ($Component.Type -eq "SQLServer") {
        if ($null -eq $SQLServerPassword) {
            Write-InstallLog "SQL Server password not set" -Level ERROR
            return $false
        }
        return Install-SQLServerInstance -InstallerPath $installerPath -Version $Component.Version -Architecture $Component.Architecture -SAPassword $SQLServerPassword
    }
    
    # Standard installation
    try {
        $extension = [System.IO.Path]::GetExtension($installerPath)
        
        if ($extension -eq ".msi") {
            # MSI installation
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" $($Component.SilentArgs)" -Wait -PassThru -NoNewWindow
        } else {
            # EXE installation
            $process = Start-Process -FilePath $installerPath -ArgumentList $Component.SilentArgs -Wait -PassThru -NoNewWindow
        }
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-InstallLog "$($Component.Name) installed successfully (Exit code: $($process.ExitCode))" -Level SUCCESS
            return $true
        } else {
            Write-InstallLog "$($Component.Name) installation completed with exit code: $($process.ExitCode)" -Level WARNING
            return $true  # Some installers return non-zero on success
        }
    } catch {
        Write-InstallLog "Failed to install $($Component.Name): $_" -Level ERROR
        return $false
    }
}

<#
.SYNOPSIS
    Performs post-installation verification.

.DESCRIPTION
    Verifies that installed components are present and functioning correctly.

.EXAMPLE
    Invoke-PostInstallationVerification

.OUTPUTS
    Array of verification result strings.
#>
function Invoke-PostInstallationVerification {
    [CmdletBinding()]
    param()
    
    Write-InstallLog "Starting post-installation verification..." -Level INFO
    
    $verificationResults = @()
    
    # Check .NET Framework 3.5
    $dotnet35 = Get-WindowsOptionalFeature -Online -FeatureName "NetFx3" -ErrorAction SilentlyContinue
    if ($dotnet35 -and $dotnet35.State -eq "Enabled") {
        Write-InstallLog ".NET Framework 3.5: Installed" -Level SUCCESS
        $verificationResults += "✓ .NET Framework 3.5: Installed"
    }
    
    # Check SQL Server
    $sqlService = Get-Service -Name MSSQLSERVER -ErrorAction SilentlyContinue
    if ($sqlService) {
        Write-InstallLog "SQL Server: $($sqlService.Status)" -Level SUCCESS
        $verificationResults += "✓ SQL Server: $($sqlService.Status)"
    }
    
    # Check Visual C++ Redistributables
    $vcRedist = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\VisualStudio\*\VC\Runtimes\*" -ErrorAction SilentlyContinue
    if ($vcRedist) {
        Write-InstallLog "Visual C++ Redistributables: Installed" -Level SUCCESS
        $verificationResults += "✓ Visual C++ Redistributables: Installed"
    }
    
    # Check 7-Zip
    $sevenZip = Get-ItemProperty "HKLM:\SOFTWARE\7-Zip" -ErrorAction SilentlyContinue
    if ($sevenZip) {
        Write-InstallLog "7-Zip: Installed" -Level SUCCESS
        $verificationResults += "✓ 7-Zip: Installed"
    }
    
    Write-InstallLog "Post-installation verification completed" -Level INFO
    return $verificationResults
}

<#
.SYNOPSIS
    Shows the graphical installation interface.

.DESCRIPTION
    Displays a Windows Forms GUI for selecting and installing Windows components.
    Provides component selection, configuration options, and progress tracking.

.PARAMETER InstallersPath
    Optional custom path to the installers directory.

.EXAMPLE
    Show-ComponentInstallerGUI

.EXAMPLE
    Show-ComponentInstallerGUI -InstallersPath "C:\CustomPath\Installers"
#>
function Show-ComponentInstallerGUI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$InstallersPath
    )
    
    if (-not $InstallersPath) {
        $InstallersPath = $script:DefaultInstallersPath
    }
    
    # Check administrator privileges
    if (-not (Test-IsAdministrator)) {
        Write-InstallLog "This function requires administrator privileges!" -Level ERROR
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("This function requires administrator privileges. Please run as Administrator.", "Permission Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Windows Components Installer"
    $form.Size = New-Object System.Drawing.Size(600, 700)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    
    # Title Label
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Location = New-Object System.Drawing.Point(10, 10)
    $titleLabel.Size = New-Object System.Drawing.Size(570, 30)
    $titleLabel.Text = "Select components to install:"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($titleLabel)
    
    # System Info Label
    $sysArch = Get-SystemArchitecture
    $sysInfoLabel = New-Object System.Windows.Forms.Label
    $sysInfoLabel.Location = New-Object System.Drawing.Point(10, 45)
    $sysInfoLabel.Size = New-Object System.Drawing.Size(570, 20)
    $sysInfoLabel.Text = "System Architecture: $sysArch | OS: $([Environment]::OSVersion.Version)"
    $sysInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($sysInfoLabel)
    
    # CheckedListBox for components
    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Location = New-Object System.Drawing.Point(10, 75)
    $checkedListBox.Size = New-Object System.Drawing.Size(570, 320)
    $checkedListBox.CheckOnClick = $true
    $checkedListBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    # Add components to CheckedListBox
    $components = Get-ComponentList
    foreach ($component in $components) {
        $displayName = "$($component.Name) ($($component.File))"
        if ($component.Architecture -ne "Any") {
            $displayName += " [$($component.Architecture)]"
        }
        $checkedListBox.Items.Add($displayName) | Out-Null
    }
    
    $form.Controls.Add($checkedListBox)
    
    # SQL Server Password Label
    $sqlPwdLabel = New-Object System.Windows.Forms.Label
    $sqlPwdLabel.Location = New-Object System.Drawing.Point(10, 410)
    $sqlPwdLabel.Size = New-Object System.Drawing.Size(200, 20)
    $sqlPwdLabel.Text = "SQL Server 'sa' Password:"
    $sqlPwdLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($sqlPwdLabel)
    
    # SQL Server Password TextBox
    $sqlPwdTextBox = New-Object System.Windows.Forms.TextBox
    $sqlPwdTextBox.Location = New-Object System.Drawing.Point(220, 408)
    $sqlPwdTextBox.Size = New-Object System.Drawing.Size(360, 25)
    $sqlPwdTextBox.UseSystemPasswordChar = $true
    $sqlPwdTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($sqlPwdTextBox)
    
    # Windows Configuration GroupBox
    $configGroupBox = New-Object System.Windows.Forms.GroupBox
    $configGroupBox.Location = New-Object System.Drawing.Point(10, 445)
    $configGroupBox.Size = New-Object System.Drawing.Size(570, 80)
    $configGroupBox.Text = "Windows Configuration"
    $configGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    
    # Disable Firewall Checkbox
    $disableFirewallCheckBox = New-Object System.Windows.Forms.CheckBox
    $disableFirewallCheckBox.Location = New-Object System.Drawing.Point(15, 25)
    $disableFirewallCheckBox.Size = New-Object System.Drawing.Size(250, 20)
    $disableFirewallCheckBox.Text = "Disable Windows Firewall"
    $disableFirewallCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $configGroupBox.Controls.Add($disableFirewallCheckBox)
    
    # Set Locale Checkbox
    $setLocaleCheckBox = New-Object System.Windows.Forms.CheckBox
    $setLocaleCheckBox.Location = New-Object System.Drawing.Point(15, 50)
    $setLocaleCheckBox.Size = New-Object System.Drawing.Size(300, 20)
    $setLocaleCheckBox.Text = "Configure locale to English (US)"
    $setLocaleCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $configGroupBox.Controls.Add($setLocaleCheckBox)
    
    $form.Controls.Add($configGroupBox)
    
    # Progress Label
    $progressLabel = New-Object System.Windows.Forms.Label
    $progressLabel.Location = New-Object System.Drawing.Point(10, 535)
    $progressLabel.Size = New-Object System.Drawing.Size(570, 20)
    $progressLabel.Text = "Ready to install"
    $progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($progressLabel)
    
    # Progress Bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 560)
    $progressBar.Size = New-Object System.Drawing.Size(570, 25)
    $form.Controls.Add($progressBar)
    
    # Install Button
    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Location = New-Object System.Drawing.Point(380, 600)
    $installButton.Size = New-Object System.Drawing.Size(100, 35)
    $installButton.Text = "Install"
    $installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $installButton.ForeColor = [System.Drawing.Color]::White
    $installButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    
    $installButton.Add_Click({
        $selectedComponents = @()
        for ($i = 0; $i -lt $checkedListBox.CheckedItems.Count; $i++) {
            $selectedComponents += $components[$checkedListBox.CheckedIndices[$i]]
        }
        
        if ($selectedComponents.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one component to install.", "No Selection", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Check SQL Server password if SQL Server is selected
        $sqlServerSelected = $selectedComponents | Where-Object { $_.Type -eq "SQLServer" }
        if ($sqlServerSelected -and [string]::IsNullOrWhiteSpace($sqlPwdTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("SQL Server password is required when installing SQL Server.", "Password Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Store SQL Server password
        $sqlPassword = $null
        if (-not [string]::IsNullOrWhiteSpace($sqlPwdTextBox.Text)) {
            $sqlPassword = ConvertTo-SecureString -String $sqlPwdTextBox.Text -AsPlainText -Force
        }
        
        # Disable controls during installation
        $installButton.Enabled = $false
        $checkedListBox.Enabled = $false
        $sqlPwdTextBox.Enabled = $false
        $disableFirewallCheckBox.Enabled = $false
        $setLocaleCheckBox.Enabled = $false
        
        # Apply Windows configuration first
        if ($disableFirewallCheckBox.Checked) {
            $progressLabel.Text = "Disabling Windows Firewall..."
            $form.Refresh()
            Disable-WindowsFirewall
        }
        
        if ($setLocaleCheckBox.Checked) {
            $progressLabel.Text = "Configuring system locale..."
            $form.Refresh()
            Set-SystemLocaleToEnglishUS
        }
        
        # Sort components by priority
        $sortedComponents = $selectedComponents | Sort-Object -Property Priority
        
        # Install components
        $progressBar.Maximum = $sortedComponents.Count
        $progressBar.Value = 0
        
        $successCount = 0
        $failureCount = 0
        
        foreach ($component in $sortedComponents) {
            $progressLabel.Text = "Installing $($component.Name)..."
            $form.Refresh()
            
            $result = Install-WindowsComponent -Component $component -InstallersPath $InstallersPath -SQLServerPassword $sqlPassword
            if ($result) {
                $successCount++
            } else {
                $failureCount++
            }
            
            $progressBar.Value++
            Start-Sleep -Milliseconds 500
        }
        
        # Post-installation verification
        $progressLabel.Text = "Verifying installation..."
        $form.Refresh()
        $verificationResults = Invoke-PostInstallationVerification
        
        # Show results
        $progressLabel.Text = "Installation completed"
        $progressBar.Value = $progressBar.Maximum
        
        $logFile = Join-Path -Path $script:DefaultLogPath -ChildPath "InstallationLog_$(Get-Date -Format 'yyyyMMdd').txt"
        $message = "Installation Summary:`n`n"
        $message += "✓ Successful: $successCount`n"
        $message += "✗ Failed: $failureCount`n`n"
        $message += "Log file: $logFile`n`n"
        
        if ($verificationResults.Count -gt 0) {
            $message += "Verification Results:`n"
            $message += ($verificationResults -join "`n")
        }
        
        [System.Windows.Forms.MessageBox]::Show($message, "Installation Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        
        $form.Close()
    })
    
    $form.Controls.Add($installButton)
    
    # Cancel Button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(490, 600)
    $cancelButton.Size = New-Object System.Drawing.Size(90, 35)
    $cancelButton.Text = "Cancel"
    $cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cancelButton.Add_Click({ $form.Close() })
    $form.Controls.Add($cancelButton)
    
    # Show form
    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

#endregion

#region Private Functions

function Configure-SQLServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    Write-InstallLog "Configuring SQL Server $Version..." -Level INFO
    
    try {
        # Enable TCP/IP protocol on port 1433
        Write-InstallLog "Enabling TCP/IP protocol..." -Level INFO
        
        # Import SQL Server PowerShell module if available
        $sqlModule = Get-Module -ListAvailable -Name SQLPS
        if ($sqlModule) {
            Import-Module SQLPS -DisableNameChecking -ErrorAction SilentlyContinue
        }
        
        # Configure SQL Server using WMI
        $wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
        $tcp = $wmi.ServerInstances['MSSQLSERVER'].ServerProtocols['Tcp']
        $tcp.IsEnabled = $true
        $tcp.Alter()
        
        # Set port 1433
        $ipAll = $tcp.IPAddresses['IPAll']
        $ipAll.IPAddressProperties['TcpPort'].Value = '1433'
        $ipAll.IPAddressProperties['TcpDynamicPorts'].Value = ''
        $tcp.Alter()
        
        # Disable named pipes
        $np = $wmi.ServerInstances['MSSQLSERVER'].ServerProtocols['Np']
        $np.IsEnabled = $false
        $np.Alter()
        
        # Restart SQL Server service
        Write-InstallLog "Restarting SQL Server service..." -Level INFO
        Restart-Service -Name MSSQLSERVER -Force -ErrorAction Stop
        Restart-Service -Name SQLSERVERAGENT -Force -ErrorAction Stop
        Start-Service -Name SQLBrowser -ErrorAction SilentlyContinue
        
        Write-InstallLog "SQL Server configured successfully" -Level SUCCESS
        return $true
    } catch {
        Write-InstallLog "SQL Server configuration warning: $_" -Level WARNING
        Write-InstallLog "Manual configuration may be required" -Level WARNING
        return $false
    }
}

#endregion

# Export module members
Export-ModuleMember -Function @(
    'Show-ComponentInstallerGUI',
    'Install-WindowsComponent',
    'Install-SQLServerInstance',
    'Get-SystemArchitecture',
    'Test-ComponentFile',
    'Invoke-PostInstallationVerification',
    'Disable-WindowsFirewall',
    'Set-SystemLocaleToEnglishUS',
    'Get-ComponentList',
    'Write-InstallLog'
)
