# Windows Automated Installation Tool - Architecture & Flow

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Windows Forms GUI                          │    │
│  │  - CheckedListBox (11 Components)                  │    │
│  │  - Password Field (SQL SA)                         │    │
│  │  - Progress Bar & Status                           │    │
│  │  - Configuration Checkboxes                        │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Installation Engine                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Component Manager                                 │    │
│  │  - Priority Ordering (1-5)                         │    │
│  │  - Architecture Detection                          │    │
│  │  - Dependency Resolution                           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Generic Installer (Install-Component)             │    │
│  │  - EXE handler                                      │    │
│  │  - MSI handler (via msiexec)                       │    │
│  │  - Exit code checking                              │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  SQL Server Installer (Install-SQLServer)          │    │
│  │  - Configuration builder                           │    │
│  │  - Service management                              │    │
│  │  - Post-install configuration                      │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                Configuration Layer                           │
│  ┌───────────────────┐  ┌────────────────────────────┐    │
│  │ SQL Server Config │  │ Windows System Config      │    │
│  │ - Mixed Mode      │  │ - Firewall Management      │    │
│  │ - TCP/IP:1433     │  │ - Locale (en-US)           │    │
│  │ - Named Pipes OFF │  │ - Timezone                 │    │
│  │ - Services        │  │ - Date/Time Format         │    │
│  └───────────────────┘  └────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Logging & Verification                       │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Logging System (Write-Log)                        │    │
│  │  - File output (timestamped)                       │    │
│  │  - Console output (colored)                        │    │
│  │  - Log levels: INFO/WARNING/ERROR/SUCCESS          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Verification System                               │    │
│  │  - Service checks                                  │    │
│  │  - Registry checks                                 │    │
│  │  - Feature checks                                  │    │
│  │  - Summary report                                  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Installation Flow

```
START
  │
  ├─→ Check Administrator Privileges
  │    └─→ [FAIL] → Show Error & Exit
  │    └─→ [PASS] → Continue
  │
  ├─→ Detect System Architecture (x86/x64)
  │
  ├─→ Show GUI
  │    │
  │    ├─→ User Selects Components
  │    ├─→ User Enters SQL Password (if SQL selected)
  │    ├─→ User Selects Windows Config Options
  │    └─→ User Clicks "Install"
  │
  ├─→ Apply Windows Configuration (if selected)
  │    ├─→ Disable Firewall
  │    └─→ Set Locale to en-US
  │
  ├─→ Sort Components by Priority
  │    │
  │    ├─→ Priority 1: .NET Framework 3.5
  │    ├─→ Priority 2: VC++, SQL Native Client
  │    ├─→ Priority 3: SQL Server
  │    ├─→ Priority 4: 7-Zip
  │    └─→ Priority 5: OpenShell
  │
  ├─→ For Each Component:
  │    │
  │    ├─→ Check Architecture Compatibility
  │    │    └─→ [INCOMPATIBLE] → Skip
  │    │
  │    ├─→ Check Installer File Exists
  │    │    └─→ [NOT FOUND] → Log Error & Skip
  │    │
  │    ├─→ Determine Installer Type
  │    │    ├─→ [SQL Server] → Use Install-SQLServer
  │    │    └─→ [Others] → Use Install-Component
  │    │
  │    ├─→ Execute Silent Installation
  │    │    ├─→ [EXE] → Start-Process with SilentArgs
  │    │    └─→ [MSI] → msiexec /i with SilentArgs
  │    │
  │    ├─→ Check Exit Code
  │    │    ├─→ [0 or 3010] → Success
  │    │    └─→ [Other] → Warning/Error
  │    │
  │    └─→ Update Progress Bar
  │
  ├─→ Post-Installation Verification
  │    ├─→ Check .NET Framework 3.5
  │    ├─→ Check SQL Server Services
  │    ├─→ Check VC++ Redistributables
  │    └─→ Check 7-Zip
  │
  └─→ Show Installation Summary
       ├─→ Success Count
       ├─→ Failure Count
       ├─→ Log File Location
       └─→ Verification Results
  │
END
```

## 🔄 SQL Server Configuration Flow

```
SQL Server Installation
  │
  ├─→ Validate SA Password
  │
  ├─→ Build Configuration Arguments
  │    ├─→ Action: Install
  │    ├─→ Features: SQLENGINE, REPLICATION, FULLTEXT, CONN
  │    ├─→ Instance: MSSQLSERVER
  │    ├─→ Security: Mixed Mode
  │    ├─→ SA Password: [User Provided]
  │    ├─→ Service Accounts: NT AUTHORITY\SYSTEM
  │    ├─→ Startup: Automatic
  │    └─→ TCP/IP: Enabled
  │
  ├─→ Execute SQL Server Setup
  │
  ├─→ Wait for Installation
  │
  ├─→ Post-Installation Configuration
  │    │
  │    ├─→ Enable TCP/IP Protocol
  │    │    ├─→ Connect via WMI
  │    │    ├─→ Set TCP Port: 1433
  │    │    ├─→ Clear Dynamic Ports
  │    │    └─→ Apply Changes
  │    │
  │    ├─→ Disable Named Pipes
  │    │
  │    └─→ Restart Services
  │         ├─→ MSSQLSERVER
  │         ├─→ SQLSERVERAGENT
  │         └─→ SQLBrowser
  │
  └─→ Return Success/Failure
```

## 🗂️ Component Priority System

```
┌─────────────────────────────────────────────────┐
│ PRIORITY 1 - Foundation Components              │
│ ┌─────────────────────────────────────────┐    │
│ │ .NET Framework 3.5                      │    │
│ │ (Required by many applications)         │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│ PRIORITY 2 - Runtime Libraries                  │
│ ┌─────────────────────────────────────────┐    │
│ │ Visual C++ Redistributable x86/x64      │    │
│ │ SQL Server Native Client 2012 x86/x64   │    │
│ │ (Required by SQL Server & applications) │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│ PRIORITY 3 - Major Applications                 │
│ ┌─────────────────────────────────────────┐    │
│ │ SQL Server 2008/2012 x86/x64            │    │
│ │ (Core database engine)                  │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│ PRIORITY 4 - Utility Tools                      │
│ ┌─────────────────────────────────────────┐    │
│ │ 7-Zip                                    │    │
│ │ (File compression utility)              │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│ PRIORITY 5 - Optional Components                │
│ ┌─────────────────────────────────────────┐    │
│ │ OpenShell 4.4.196                       │    │
│ │ (Classic Start Menu)                    │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

## 🛡️ Security Architecture

```
┌─────────────────────────────────────────────────┐
│              Security Layers                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │ Level 1: Execution Security             │    │
│  │ - Administrator privilege check         │    │
│  │ - Script execution policy validation    │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │ Level 2: Password Security              │    │
│  │ - SecureString for SA password          │    │
│  │ - Memory clearing after use             │    │
│  │ - No plain text logging                 │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │ Level 3: File Security                  │    │
│  │ - Installer file validation             │    │
│  │ - Path security checks                  │    │
│  │ - Log file protection guidance          │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │ Level 4: SQL Server Security            │    │
│  │ - Mixed mode authentication             │    │
│  │ - Strong password requirements          │    │
│  │ - Current user as sysadmin              │    │
│  │ - Service account: NT AUTHORITY\SYSTEM  │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │ Level 5: Network Security               │    │
│  │ - Firewall disable warning              │    │
│  │ - TCP/IP configuration                  │    │
│  │ - Port management (1433)                │    │
│  └────────────────────────────────────────┘    │
│                                                  │
└─────────────────────────────────────────────────┘
```

## 📝 Logging Architecture

```
┌──────────────────────────────────────────────┐
│           Logging System                     │
│                                              │
│  Input: Message + Level                     │
│     │                                        │
│     ├─→ Generate Timestamp                  │
│     │                                        │
│     ├─→ Format Log Entry                    │
│     │    [YYYY-MM-DD HH:MM:SS] [LEVEL] MSG  │
│     │                                        │
│     ├─→ Write to File                       │
│     │    InstallationLog_YYYYMMDD_HHMMSS.txt│
│     │                                        │
│     └─→ Write to Console                    │
│          │                                   │
│          ├─→ [INFO]    → White              │
│          ├─→ [WARNING] → Yellow             │
│          ├─→ [ERROR]   → Red                │
│          └─→ [SUCCESS] → Green              │
│                                              │
└──────────────────────────────────────────────┘
```

## 🔍 Verification Flow

```
Post-Installation Verification
  │
  ├─→ Check Windows Features
  │    └─→ .NET Framework 3.5
  │         └─→ Get-WindowsOptionalFeature
  │
  ├─→ Check Services
  │    ├─→ MSSQLSERVER
  │    ├─→ SQLSERVERAGENT
  │    └─→ SQLBrowser
  │         └─→ Get-Service
  │
  ├─→ Check Registry
  │    ├─→ Visual C++ Redistributables
  │    │    └─→ HKLM:\SOFTWARE\Microsoft\VisualStudio\*
  │    │
  │    └─→ 7-Zip
  │         └─→ HKLM:\SOFTWARE\7-Zip
  │
  └─→ Generate Report
       ├─→ ✓ Successful installations
       ├─→ ✗ Failed installations
       └─→ Summary with details
```

## 💾 Data Flow

```
User Input
  │
  ├─→ Component Selection → CheckedListBox.CheckedIndices
  ├─→ SQL Password → SecureString
  └─→ Windows Config → Checkbox States
  │
  ▼
Global Variables
  │
  ├─→ $Global:Components (Array of Hashtables)
  ├─→ $Global:SQLServerPassword (SecureString)
  ├─→ $Global:LogFile (String)
  └─→ $Global:InstallersPath (String)
  │
  ▼
Installation Engine
  │
  ├─→ Priority Sorting
  ├─→ Architecture Filtering
  └─→ Sequential Installation
  │
  ▼
Installers (Silent Mode)
  │
  ├─→ Exit Code
  ├─→ Log Output
  └─→ Installation Status
  │
  ▼
Verification
  │
  ├─→ Service Status
  ├─→ Registry Entries
  └─→ Feature States
  │
  ▼
Results
  │
  ├─→ Installation Summary (GUI Dialog)
  ├─→ Log File (Persistent)
  └─→ Console Output (Real-time)
```

## 🎨 GUI Layout

```
┌─────────────────────────────────────────────────────────┐
│  Windows Components Installer                     [_][□][X]│
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Select components to install:                           │
│  System Architecture: x64 | OS: 10.0.19045.0            │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ☐ .NET Framework 3.5 (dotnet35_installer.exe)  │   │
│  │ ☐ SQL Server 2008 x64 (sqlserver2008_x64.exe)  │   │
│  │ ☐ SQL Server 2008 x86 (sqlserver2008_x86.exe)  │   │
│  │ ☐ SQL Server 2012 x64 (sqlserver2012_x64.exe)  │   │
│  │ ☐ SQL Server 2012 x86 (sqlserver2012_x86.exe)  │   │
│  │ ☐ OpenShell 4.4.196                             │   │
│  │ ☐ SQL Native Client 2012 x64 [x64]              │   │
│  │ ☐ SQL Native Client 2012 x86 [x86]              │   │
│  │ ☐ Visual C++ Redistributable x86 [x86]          │   │
│  │ ☐ Visual C++ Redistributable x64 [x64]          │   │
│  │ ☐ 7-Zip (7z2301.exe)                            │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
│  SQL Server 'sa' Password: [*********************]       │
│                                                           │
│  ┌─ Windows Configuration ──────────────────────────┐   │
│  │ ☐ Disable Windows Firewall                      │   │
│  │ ☐ Configure locale to English (US)              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  Ready to install                                        │
│  [████████████████████░░░░░░░░░░] 70%                   │
│                                                           │
│               [  Install  ]  [ Cancel ]                  │
└─────────────────────────────────────────────────────────┘
```

---

**Architecture Version**: 1.0  
**Last Updated**: 2024-02-06  
**Complexity**: Medium-High  
**Lines of Code**: 640+  
**External Dependencies**: .NET Framework (built-in), Windows Forms
