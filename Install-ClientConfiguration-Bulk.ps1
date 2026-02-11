<#
.SYNOPSIS
    Script de déploiement en masse pour la configuration des PC clients
    
.DESCRIPTION
    Version optimisée du script de configuration client pour déploiement
    sur plusieurs machines simultanément via des outils de gestion centralisée
    (GPO, SCCM, PDQ Deploy, etc.)
    
.NOTES
    Auteur: Support IT
    Date: 2026-02-11
    Version: 1.0
    
    Différences avec la version standard:
    - Exécution ultra-silencieuse
    - Timeout optimisés
    - Gestion améliorée des ressources réseau
    - Logs centralisés sur serveur
    - Support du mode déconnecté
    
.PARAMETER ConfigFile
    Chemin vers le fichier de configuration JSON
    
.PARAMETER LogServer
    URL du serveur de logs centralisé (optionnel)
    
.PARAMETER OfflineMode
    Active le mode hors ligne (logiciels pré-téléchargés)
    
.EXAMPLE
    .\Install-ClientConfiguration-Bulk.ps1 -ConfigFile "\\Server\Share\config.json"
    
.EXAMPLE
    .\Install-ClientConfiguration-Bulk.ps1 -ConfigFile "C:\Deploy\config.json" -OfflineMode
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "$PSScriptRoot\config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$LogServer = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$OfflineMode,
    
    [Parameter(Mandatory=$false)]
    [string]$OfflineSourcePath = "\\Server\Share\Installers"
)

# ===================================================================
# CONFIGURATION
# ===================================================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"  # Accélère les téléchargements

# Variables globales
$Script:LogPath = "C:\Support\deployment_log.txt"
$Script:SupportFolder = "C:\Support"
$Script:TempFolder = "C:\Support\Temp"
$Script:DesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
$Script:Config = $null
$Script:StartTime = Get-Date

# ===================================================================
# FONCTIONS CORE
# ===================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$env:COMPUTERNAME] [$Level] $Message"
    
    # Créer le dossier si nécessaire
    if (-not (Test-Path $Script:SupportFolder)) {
        New-Item -Path $Script:SupportFolder -ItemType Directory -Force | Out-Null
    }
    
    # Écriture locale
    Add-Content -Path $Script:LogPath -Value $logMessage -ErrorAction SilentlyContinue
    
    # Envoi au serveur de logs si configuré
    if ($Script:LogServer) {
        Send-ToLogServer -Message $Message -Level $Level
    }
}

function Send-ToLogServer {
    param(
        [string]$Message,
        [string]$Level
    )
    
    try {
        $logEntry = @{
            Timestamp = (Get-Date).ToString("o")
            Computer = $env:COMPUTERNAME
            User = $env:USERNAME
            Level = $Level
            Message = $Message
        } | ConvertTo-Json -Compress
        
        Invoke-RestMethod -Uri "$Script:LogServer/api/logs" `
            -Method Post `
            -Body $logEntry `
            -ContentType "application/json" `
            -TimeoutSec 5 `
            -ErrorAction SilentlyContinue
    }
    catch {
        # Échec silencieux pour ne pas bloquer le script
    }
}

function Import-Configuration {
    try {
        Write-Log "Chargement de la configuration depuis: $ConfigFile" -Level INFO
        
        if (-not (Test-Path $ConfigFile)) {
            throw "Fichier de configuration non trouvé: $ConfigFile"
        }
        
        $Script:Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        Write-Log "Configuration chargée avec succès" -Level SUCCESS
        
        return $true
    }
    catch {
        Write-Log "Erreur lors du chargement de la configuration: $($_.Exception.Message)" -Level ERROR
        
        # Configuration par défaut en cas d'échec
        $Script:Config = @{
            SplashtopDeployCode = "VOTRE_CODE"
            CustomSoftware = @{
                Name = "DefaultSoftware"
                Url = ""
                Args = "/S"
                Hash = ""
            }
            SupportUrl = "https://sso.splashtop.com"
            TimeoutSeconds = 300
        }
        
        return $false
    }
}

function Initialize-BulkEnvironment {
    try {
        Write-Log "Initialisation de l'environnement de déploiement..." -Level INFO
        
        # Création des dossiers
        @($Script:SupportFolder, $Script:TempFolder) | ForEach-Object {
            if (-not (Test-Path $_)) {
                New-Item -Path $_ -ItemType Directory -Force | Out-Null
            }
        }
        
        # Désactiver le pare-feu Windows temporairement pour les téléchargements
        # (Sera réactivé en fin de script)
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction SilentlyContinue
        
        # Forcer TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Configurer le proxy si nécessaire
        $proxy = [System.Net.WebRequest]::GetSystemWebProxy()
        $proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        
        Write-Log "Environnement initialisé" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Erreur d'initialisation: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Get-InstalledSoftware {
    param([string]$SoftwareName)
    
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    return Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$SoftwareName*" } |
        Select-Object -First 1
}

function Get-TeamViewerID {
    try {
        # Méthode rapide via registre
        $paths = @(
            "HKLM:\SOFTWARE\WOW6432Node\TeamViewer",
            "HKLM:\SOFTWARE\TeamViewer"
        )
        
        foreach ($path in $paths) {
            if (Test-Path $path) {
                $clientID = (Get-ItemProperty -Path $path -Name ClientID -ErrorAction SilentlyContinue).ClientID
                if ($clientID) {
                    return $clientID
                }
            }
        }
        
        return "ID_NON_TROUVE"
    }
    catch {
        return "ID_ERREUR"
    }
}

function Install-FromUrl {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Arguments,
        [string]$ExpectedHash = "",
        [int]$TimeoutSeconds = 300
    )
    
    try {
        # Vérifier si déjà installé
        $installed = Get-InstalledSoftware -SoftwareName $Name
        if ($installed) {
            Write-Log "$Name déjà installé (v$($installed.DisplayVersion))" -Level INFO
            return $true
        }
        
        $installerPath = Join-Path $Script:TempFolder "$Name.exe"
        
        # Mode hors ligne
        if ($OfflineMode -and $OfflineSourcePath) {
            $offlineFile = Join-Path $OfflineSourcePath "$Name.exe"
            if (Test-Path $offlineFile) {
                Copy-Item $offlineFile $installerPath -Force
                Write-Log "Installeur copié depuis source hors ligne" -Level INFO
            }
            else {
                throw "Fichier hors ligne non trouvé: $offlineFile"
            }
        }
        else {
            # Téléchargement avec retry
            $maxRetries = 3
            $retryCount = 0
            $downloaded = $false
            
            while (-not $downloaded -and $retryCount -lt $maxRetries) {
                try {
                    Write-Log "Téléchargement de $Name (tentative $($retryCount + 1)/$maxRetries)..." -Level INFO
                    
                    $webClient = New-Object System.Net.WebClient
                    $webClient.Proxy = [System.Net.WebRequest]::GetSystemWebProxy()
                    $webClient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
                    $webClient.DownloadFile($Url, $installerPath)
                    
                    $downloaded = $true
                }
                catch {
                    $retryCount++
                    if ($retryCount -lt $maxRetries) {
                        Write-Log "Échec du téléchargement, nouvelle tentative dans 5s..." -Level WARNING
                        Start-Sleep -Seconds 5
                    }
                    else {
                        throw "Échec du téléchargement après $maxRetries tentatives"
                    }
                }
            }
        }
        
        # Vérification du hash si fourni
        if ($ExpectedHash) {
            $actualHash = (Get-FileHash -Path $installerPath -Algorithm SHA256).Hash
            if ($actualHash -ne $ExpectedHash) {
                throw "Hash invalide pour $Name. Attendu: $ExpectedHash, Obtenu: $actualHash"
            }
            Write-Log "Vérification hash OK" -Level SUCCESS
        }
        
        # Installation avec timeout
        Write-Log "Installation de $Name..." -Level INFO
        
        $job = Start-Job -ScriptBlock {
            param($Path, $Args)
            $process = Start-Process -FilePath $Path -ArgumentList $Args -Wait -PassThru -NoNewWindow
            return $process.ExitCode
        } -ArgumentList $installerPath, $Arguments
        
        $completed = Wait-Job -Job $job -Timeout $TimeoutSeconds
        
        if ($completed) {
            $exitCode = Receive-Job -Job $job
            Remove-Job -Job $job
            
            if ($exitCode -eq 0 -or $exitCode -eq 3010) {
                Write-Log "$Name installé avec succès (Code: $exitCode)" -Level SUCCESS
                return $true
            }
            else {
                Write-Log "$Name installation terminée avec code: $exitCode" -Level WARNING
                return $false
            }
        }
        else {
            Write-Log "Timeout lors de l'installation de $Name" -Level ERROR
            Stop-Job -Job $job
            Remove-Job -Job $job
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de l'installation de $Name : $($_.Exception.Message)" -Level ERROR
        return $false
    }
    finally {
        # Nettoyage
        if (Test-Path $installerPath) {
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-SplashtopBulk {
    try {
        $splashtopUrl = "https://download.splashtop.com/streamer/SplashtopStreamer.exe"
        $args = "preverify deploy -q --code $($Script:Config.SplashtopDeployCode)"
        
        $result = Install-FromUrl -Name "Splashtop Streamer" `
            -Url $splashtopUrl `
            -Arguments $args `
            -TimeoutSeconds $Script:Config.TimeoutSeconds
        
        if ($result) {
            # Attendre le démarrage du service
            $maxWait = 30
            $waited = 0
            while ($waited -lt $maxWait) {
                $service = Get-Service "SplashtopRemoteService" -ErrorAction SilentlyContinue
                if ($service -and $service.Status -eq "Running") {
                    Write-Log "Service Splashtop démarré" -Level SUCCESS
                    break
                }
                Start-Sleep -Seconds 2
                $waited += 2
            }
        }
        
        return $result
    }
    catch {
        Write-Log "Erreur Splashtop: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Set-SplashtopName {
    param(
        [string]$ComputerName,
        [string]$TeamViewerID
    )
    
    try {
        $newName = "$ComputerName - $TeamViewerID"
        
        # Tentative de modification directe du registre Splashtop
        $regPaths = @(
            "HKLM:\SOFTWARE\Splashtop Inc.\Splashtop Remote Server",
            "HKLM:\SOFTWARE\WOW6432Node\Splashtop Inc.\Splashtop Remote Server"
        )
        
        foreach ($regPath in $regPaths) {
            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "ComputerName" -Value $newName -ErrorAction SilentlyContinue
                Write-Log "Nom Splashtop configuré via registre: $newName" -Level SUCCESS
            }
        }
        
        # Redémarrage rapide du service
        Restart-Service "SplashtopRemoteService" -Force -ErrorAction SilentlyContinue
        
        return $true
    }
    catch {
        Write-Log "Erreur configuration nom Splashtop: $($_.Exception.Message)" -Level WARNING
        return $false
    }
}

function New-SupportShortcut {
    try {
        $shortcutPath = Join-Path $Script:DesktopPath "Support Technique.lnk"
        
        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
        }
        
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $Script:Config.SupportUrl
        $shortcut.Save()
        
        Write-Log "Raccourci créé: $shortcutPath" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Erreur création raccourci: $($_.Exception.Message)" -Level WARNING
        return $false
    }
}

function Restore-SystemSettings {
    try {
        Write-Log "Restauration des paramètres système..." -Level INFO
        
        # Réactiver le pare-feu
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
        
        # Nettoyage
        if (Test-Path $Script:TempFolder) {
            Remove-Item -Path $Script:TempFolder -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        Write-Log "Paramètres système restaurés" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Erreur restauration: $($_.Exception.Message)" -Level WARNING
        return $false
    }
}

function Send-CompletionReport {
    param(
        [bool]$Success,
        [hashtable]$Results
    )
    
    try {
        $report = @{
            Timestamp = (Get-Date).ToString("o")
            Computer = $env:COMPUTERNAME
            TeamViewerID = $Results.TeamViewerID
            Duration = ((Get-Date) - $Script:StartTime).TotalMinutes
            Success = $Success
            Details = $Results
        } | ConvertTo-Json -Depth 3
        
        # Sauvegarde locale
        $reportPath = Join-Path $Script:SupportFolder "deployment_report.json"
        $report | Out-File $reportPath -Force
        
        # Envoi au serveur si configuré
        if ($Script:LogServer) {
            Invoke-RestMethod -Uri "$Script:LogServer/api/reports" `
                -Method Post `
                -Body $report `
                -ContentType "application/json" `
                -TimeoutSec 10 `
                -ErrorAction SilentlyContinue
        }
        
        Write-Log "Rapport de déploiement généré: $reportPath" -Level SUCCESS
    }
    catch {
        Write-Log "Erreur génération rapport: $($_.Exception.Message)" -Level WARNING
    }
}

# ===================================================================
# FONCTION PRINCIPALE
# ===================================================================

function Start-BulkDeployment {
    Write-Log "========================================" -Level INFO
    Write-Log "DÉPLOIEMENT EN MASSE - DÉBUT" -Level INFO
    Write-Log "Machine: $env:COMPUTERNAME" -Level INFO
    Write-Log "Utilisateur: $env:USERNAME" -Level INFO
    Write-Log "========================================" -Level INFO
    
    $results = @{
        ComputerName = $env:COMPUTERNAME
        TeamViewerID = ""
        CustomSoftware = $false
        Splashtop = $false
        Shortcut = $false
    }
    
    try {
        # Charger la configuration
        if (-not (Import-Configuration)) {
            throw "Impossible de charger la configuration"
        }
        
        # Initialiser l'environnement
        if (-not (Initialize-BulkEnvironment)) {
            throw "Échec de l'initialisation"
        }
        
        # Récupérer les informations
        $computerName = $env:COMPUTERNAME
        $teamViewerID = Get-TeamViewerID
        $results.TeamViewerID = $teamViewerID
        
        Write-Log "Nom machine: $computerName" -Level INFO
        Write-Log "ID TeamViewer: $teamViewerID" -Level INFO
        
        # Installer le logiciel personnalisé
        if ($Script:Config.CustomSoftware.Url) {
            Write-Log "Installation du logiciel personnalisé..." -Level INFO
            $results.CustomSoftware = Install-FromUrl `
                -Name $Script:Config.CustomSoftware.Name `
                -Url $Script:Config.CustomSoftware.Url `
                -Arguments $Script:Config.CustomSoftware.Args `
                -ExpectedHash $Script:Config.CustomSoftware.Hash `
                -TimeoutSeconds $Script:Config.TimeoutSeconds
        }
        
        # Installer Splashtop
        if ($Script:Config.SplashtopDeployCode -ne "VOTRE_CODE") {
            Write-Log "Installation de Splashtop..." -Level INFO
            $results.Splashtop = Install-SplashtopBulk
            
            if ($results.Splashtop) {
                Set-SplashtopName -ComputerName $computerName -TeamViewerID $teamViewerID
            }
        }
        
        # Créer le raccourci
        $results.Shortcut = New-SupportShortcut
        
        # Restaurer les paramètres
        Restore-SystemSettings
        
        # Rapport final
        $duration = ((Get-Date) - $Script:StartTime).TotalMinutes
        $success = $results.Splashtop -or $results.CustomSoftware
        
        Write-Log "========================================" -Level INFO
        Write-Log "DÉPLOIEMENT TERMINÉ" -Level $(if($success){"SUCCESS"}else{"WARNING"})
        Write-Log "Durée: $([math]::Round($duration, 2)) minutes" -Level INFO
        Write-Log "Logiciel personnalisé: $(if($results.CustomSoftware){'OK'}else{'ÉCHEC'})" -Level INFO
        Write-Log "Splashtop: $(if($results.Splashtop){'OK'}else{'ÉCHEC'})" -Level INFO
        Write-Log "Raccourci: $(if($results.Shortcut){'OK'}else{'ÉCHEC'})" -Level INFO
        Write-Log "========================================" -Level INFO
        
        # Envoyer le rapport
        Send-CompletionReport -Success $success -Results $results
        
        return $success
    }
    catch {
        Write-Log "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
        Write-Log "Ligne: $($_.InvocationInfo.ScriptLineNumber)" -Level ERROR
        
        Send-CompletionReport -Success $false -Results $results
        
        return $false
    }
}

# ===================================================================
# EXÉCUTION
# ===================================================================

$result = Start-BulkDeployment

# Code de sortie pour intégration avec outils de déploiement
exit $(if($result){0}else{1})
