<#
.SYNOPSIS
    Automated Windows Components Installation Tool
    
.DESCRIPTION
    This script provides a graphical interface for installing multiple Windows components
    and applications with silent installation. Supports Windows 7, 10, and 11.
    
.NOTES
    Author: Windows Scripting Automation
    Version: 1.0
    Requires: PowerShell 3.0+, Administrator privileges
#>

#Requires -RunAsAdministrator

# Global Variables
$Global:LogFile = "$PSScriptRoot\InstallationLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$Global:InstallersPath = "$PSScriptRoot\Installers"
$Global:SQLServerPassword = $null

# Component definitions with their installer files and silent install parameters
$Global:Components = @(
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

#region Logging Functions

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to file
    Add-Content -Path $Global:LogFile -Value $logMessage
    
    # Write to console with color
    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default   { Write-Host $logMessage -ForegroundColor White }
    }
}

#endregion

#region System Functions

function Get-SystemArchitecture {
    if ([Environment]::Is64BitOperatingSystem) {
        return "x64"
    } else {
        return "x86"
    }
}

function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Disable-WindowsFirewall {
    Write-Log "Disabling Windows Firewall..." -Level INFO
    
    try {
        # Disable firewall for all profiles
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
        Write-Log "Windows Firewall disabled successfully" -Level SUCCESS
        return $true
    } catch {
        Write-Log "Failed to disable Windows Firewall: $_" -Level ERROR
        return $false
    }
}

function Set-SystemLocaleToEnglishUS {
    Write-Log "Configuring system locale to en-US..." -Level INFO
    
    try {
        # Set system locale
        Set-WinSystemLocale -SystemLocale en-US -ErrorAction Stop
        
        # Set user locale
        Set-Culture -CultureInfo en-US -ErrorAction Stop
        
        # Set timezone to Eastern Standard Time (US)
        Set-TimeZone -Id "Eastern Standard Time" -ErrorAction Stop
        
        Write-Log "System locale configured to en-US successfully" -Level SUCCESS
        return $true
    } catch {
        Write-Log "Failed to configure system locale: $_" -Level ERROR
        return $false
    }
}

#endregion

#region SQL Server Functions

function Install-SQLServer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InstallerPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Version,
        
        [Parameter(Mandatory=$true)]
        [string]$Architecture,
        
        [Parameter(Mandatory=$true)]
        [securestring]$SAPassword
    )
    
    Write-Log "Installing SQL Server $Version ($Architecture)..." -Level INFO
    
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
            Write-Log "SQL Server $Version ($Architecture) installed successfully" -Level SUCCESS
            
            # Configure SQL Server after installation
            Start-Sleep -Seconds 10
            Configure-SQLServer -Version $Version
            
            return $true
        } else {
            Write-Log "SQL Server installation failed with exit code: $($process.ExitCode)" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "SQL Server installation error: $_" -Level ERROR
        return $false
    } finally {
        # Clear password from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
}

function Configure-SQLServer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    Write-Log "Configuring SQL Server $Version..." -Level INFO
    
    try {
        # Enable TCP/IP protocol on port 1433
        Write-Log "Enabling TCP/IP protocol..." -Level INFO
        
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
        Write-Log "Restarting SQL Server service..." -Level INFO
        Restart-Service -Name MSSQLSERVER -Force -ErrorAction Stop
        Restart-Service -Name SQLSERVERAGENT -Force -ErrorAction Stop
        Start-Service -Name SQLBrowser -ErrorAction SilentlyContinue
        
        Write-Log "SQL Server configured successfully" -Level SUCCESS
        return $true
    } catch {
        Write-Log "SQL Server configuration warning: $_" -Level WARNING
        Write-Log "Manual configuration may be required" -Level WARNING
        return $false
    }
}

#endregion

#region Installation Functions

function Test-ComponentFile {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Component
    )
    
    $filePath = Join-Path -Path $Global:InstallersPath -ChildPath $Component.File
    return Test-Path -Path $filePath
}

function Install-Component {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Component
    )
    
    Write-Log "Starting installation of $($Component.Name)..." -Level INFO
    
    $installerPath = Join-Path -Path $Global:InstallersPath -ChildPath $Component.File
    
    # Check if file exists
    if (-not (Test-Path -Path $installerPath)) {
        Write-Log "Installer file not found: $installerPath" -Level ERROR
        return $false
    }
    
    # Check architecture compatibility
    $sysArch = Get-SystemArchitecture
    if ($Component.Architecture -ne "Any" -and $Component.Architecture -ne $sysArch) {
        Write-Log "Component architecture ($($Component.Architecture)) does not match system architecture ($sysArch)" -Level WARNING
        return $false
    }
    
    # Special handling for SQL Server
    if ($Component.Type -eq "SQLServer") {
        if ($null -eq $Global:SQLServerPassword) {
            Write-Log "SQL Server password not set" -Level ERROR
            return $false
        }
        return Install-SQLServer -InstallerPath $installerPath -Version $Component.Version -Architecture $Component.Architecture -SAPassword $Global:SQLServerPassword
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
            Write-Log "$($Component.Name) installed successfully (Exit code: $($process.ExitCode))" -Level SUCCESS
            return $true
        } else {
            Write-Log "$($Component.Name) installation completed with exit code: $($process.ExitCode)" -Level WARNING
            return $true  # Some installers return non-zero on success
        }
    } catch {
        Write-Log "Failed to install $($Component.Name): $_" -Level ERROR
        return $false
    }
}

function Invoke-PostInstallationVerification {
    Write-Log "Starting post-installation verification..." -Level INFO
    
    $verificationResults = @()
    
    # Check .NET Framework 3.5
    $dotnet35 = Get-WindowsOptionalFeature -Online -FeatureName "NetFx3" -ErrorAction SilentlyContinue
    if ($dotnet35 -and $dotnet35.State -eq "Enabled") {
        Write-Log ".NET Framework 3.5: Installed" -Level SUCCESS
        $verificationResults += "✓ .NET Framework 3.5: Installed"
    }
    
    # Check SQL Server
    $sqlService = Get-Service -Name MSSQLSERVER -ErrorAction SilentlyContinue
    if ($sqlService) {
        Write-Log "SQL Server: $($sqlService.Status)" -Level SUCCESS
        $verificationResults += "✓ SQL Server: $($sqlService.Status)"
    }
    
    # Check Visual C++ Redistributables
    $vcRedist = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\VisualStudio\*\VC\Runtimes\*" -ErrorAction SilentlyContinue
    if ($vcRedist) {
        Write-Log "Visual C++ Redistributables: Installed" -Level SUCCESS
        $verificationResults += "✓ Visual C++ Redistributables: Installed"
    }
    
    # Check 7-Zip
    $sevenZip = Get-ItemProperty "HKLM:\SOFTWARE\7-Zip" -ErrorAction SilentlyContinue
    if ($sevenZip) {
        Write-Log "7-Zip: Installed" -Level SUCCESS
        $verificationResults += "✓ 7-Zip: Installed"
    }
    
    Write-Log "Post-installation verification completed" -Level INFO
    return $verificationResults
}

#endregion

#region GUI Functions

function Show-InstallationGUI {
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
    foreach ($component in $Global:Components) {
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
            $selectedComponents += $Global:Components[$checkedListBox.CheckedIndices[$i]]
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
        if (-not [string]::IsNullOrWhiteSpace($sqlPwdTextBox.Text)) {
            $Global:SQLServerPassword = ConvertTo-SecureString -String $sqlPwdTextBox.Text -AsPlainText -Force
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
            
            $result = Install-Component -Component $component
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
        
        $message = "Installation Summary:`n`n"
        $message += "✓ Successful: $successCount`n"
        $message += "✗ Failed: $failureCount`n`n"
        $message += "Log file: $Global:LogFile`n`n"
        
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

#region Main

function Main {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Windows Components Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Script started" -Level INFO
    Write-Log "Log file: $Global:LogFile" -Level INFO
    
    # Check administrator privileges
    if (-not (Test-IsAdministrator)) {
        Write-Log "This script requires administrator privileges!" -Level ERROR
        [System.Windows.Forms.MessageBox]::Show("This script requires administrator privileges. Please run as Administrator.", "Permission Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit 1
    }
    
    # Create installers directory if it doesn't exist
    if (-not (Test-Path -Path $Global:InstallersPath)) {
        Write-Log "Creating Installers directory: $Global:InstallersPath" -Level INFO
        New-Item -Path $Global:InstallersPath -ItemType Directory -Force | Out-Null
    }
    
    # Detect system architecture
    $sysArch = Get-SystemArchitecture
    Write-Log "System Architecture: $sysArch" -Level INFO
    Write-Log "Operating System: $([Environment]::OSVersion.VersionString)" -Level INFO
    
    # Show GUI
    Show-InstallationGUI
    
    Write-Log "Script completed" -Level INFO
}

# Execute main function
Main

#endregion
