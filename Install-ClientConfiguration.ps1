<#
.SYNOPSIS
    Script d'automatisation de configuration des PC clients via TeamViewer
    
.DESCRIPTION
    Ce script PowerShell configure automatiquement un PC client en installant:
    - Un logiciel personnalisé
    - Splashtop Streamer
    - Enregistrement dans le compte Splashtop
    - Renommage avec format: NOM_PC - ID_TEAMVIEWER
    - Création d'un raccourci Support Technique
    
.NOTES
    Auteur: Support IT
    Date: 2026-02-11
    Version: 1.0
    Prérequis:
        - Windows 10/11
        - Droits Administrateur
        - Execution Policy: RemoteSigned ou Bypass
        
.EXAMPLE
    .\Install-ClientConfiguration.ps1
    
    Exécute le script avec les paramètres par défaut
#>

#Requires -RunAsAdministrator

# ===================================================================
# SECTION 1: VARIABLES DE CONFIGURATION
# ===================================================================
# Modifiez ces variables selon vos besoins

param(
    [string]$SplashtopDeployCode = "VOTRE_CODE_DEPLOIEMENT",
    [string]$CustomSoftwareName = "NomDuLogiciel",
    [string]$CustomSoftwareUrl = "https://example.com/software.exe",
    [string]$CustomSoftwareArgs = "/S /v/qn"
)

# Variables globales
$Script:LogPath = "C:\Support\installation_log.txt"
$Script:SupportFolder = "C:\Support"
$Script:TempFolder = "C:\Support\Temp"
$Script:SplashtopInstallerUrl = "https://download.splashtop.com/streamer/SplashtopStreamer.exe"
$Script:SplashtopInstallerPath = "$TempFolder\SplashtopStreamer.exe"
$Script:CustomSoftwareInstallerPath = "$TempFolder\$CustomSoftwareName.exe"
$Script:DesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
$Script:ShortcutName = "Support Technique"
$Script:SupportUrl = "https://sso.splashtop.com"

# ===================================================================
# SECTION 2: FONCTIONS UTILITAIRES
# ===================================================================

function Write-Log {
    <#
    .SYNOPSIS
        Écrit un message dans le fichier de log et affiche dans la console
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Création du dossier de log si nécessaire
    if (-not (Test-Path -Path $Script:SupportFolder)) {
        New-Item -Path $Script:SupportFolder -ItemType Directory -Force | Out-Null
    }
    
    # Écriture dans le fichier de log
    Add-Content -Path $Script:LogPath -Value $logMessage
    
    # Affichage coloré dans la console
    switch ($Level) {
        "INFO"    { Write-Host $logMessage -ForegroundColor Cyan }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
    }
}

function Test-Administrator {
    <#
    .SYNOPSIS
        Vérifie si le script est exécuté en tant qu'administrateur
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Initialize-Environment {
    <#
    .SYNOPSIS
        Initialise l'environnement de travail (dossiers, log, etc.)
    #>
    try {
        Write-Log "Initialisation de l'environnement..." -Level INFO
        
        # Création des dossiers nécessaires
        @($Script:SupportFolder, $Script:TempFolder) | ForEach-Object {
            if (-not (Test-Path -Path $_)) {
                New-Item -Path $_ -ItemType Directory -Force | Out-Null
                Write-Log "Dossier créé: $_" -Level SUCCESS
            }
        }
        
        # Vérification Windows 10/11
        $osVersion = [System.Environment]::OSVersion.Version
        if ($osVersion.Major -lt 10) {
            throw "Ce script nécessite Windows 10 ou supérieur. Version détectée: $($osVersion.Major).$($osVersion.Minor)"
        }
        Write-Log "Système d'exploitation compatible: Windows $($osVersion.Major).$($osVersion.Minor)" -Level SUCCESS
        
        return $true
    }
    catch {
        Write-Log "Erreur lors de l'initialisation: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Récupère la liste des logiciels installés
    #>
    param(
        [string]$SoftwareName
    )
    
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$SoftwareName*" } |
        Select-Object -First 1
    
    return $installed
}

function Get-TeamViewerID {
    <#
    .SYNOPSIS
        Récupère l'ID TeamViewer de la machine
    #>
    try {
        Write-Log "Récupération de l'ID TeamViewer..." -Level INFO
        
        # Méthode 1: Registre
        $tvPaths = @(
            "HKLM:\SOFTWARE\WOW6432Node\TeamViewer",
            "HKLM:\SOFTWARE\TeamViewer"
        )
        
        foreach ($path in $tvPaths) {
            if (Test-Path $path) {
                $clientID = (Get-ItemProperty -Path $path -Name ClientID -ErrorAction SilentlyContinue).ClientID
                if ($clientID) {
                    Write-Log "TeamViewer ID trouvé: $clientID" -Level SUCCESS
                    return $clientID
                }
            }
        }
        
        # Méthode 2: Fichier de configuration
        $configPaths = @(
            "$env:ProgramFiles\TeamViewer\TeamViewer.ini",
            "${env:ProgramFiles(x86)}\TeamViewer\TeamViewer.ini"
        )
        
        foreach ($configPath in $configPaths) {
            if (Test-Path $configPath) {
                $content = Get-Content $configPath
                $idLine = $content | Where-Object { $_ -match "ClientID\s*=\s*(\d+)" }
                if ($idLine -and $Matches[1]) {
                    Write-Log "TeamViewer ID trouvé dans le fichier de configuration: $($Matches[1])" -Level SUCCESS
                    return $Matches[1]
                }
            }
        }
        
        Write-Log "TeamViewer ID non trouvé. TeamViewer est-il installé?" -Level WARNING
        return "ID_NON_TROUVE"
    }
    catch {
        Write-Log "Erreur lors de la récupération de l'ID TeamViewer: $($_.Exception.Message)" -Level ERROR
        return "ID_ERREUR"
    }
}

function Install-CustomSoftware {
    <#
    .SYNOPSIS
        Installe le logiciel personnalisé
    #>
    try {
        Write-Log "Vérification de l'installation de $CustomSoftwareName..." -Level INFO
        
        # Vérifier si déjà installé
        $installed = Get-InstalledSoftware -SoftwareName $CustomSoftwareName
        if ($installed) {
            Write-Log "$CustomSoftwareName est déjà installé. Version: $($installed.DisplayVersion)" -Level INFO
            return $true
        }
        
        Write-Log "Téléchargement de $CustomSoftwareName depuis $CustomSoftwareUrl..." -Level INFO
        
        # Téléchargement
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($CustomSoftwareUrl, $Script:CustomSoftwareInstallerPath)
        
        if (-not (Test-Path $Script:CustomSoftwareInstallerPath)) {
            throw "Échec du téléchargement de $CustomSoftwareName"
        }
        
        Write-Log "Installation de $CustomSoftwareName en cours..." -Level INFO
        
        # Installation silencieuse
        $process = Start-Process -FilePath $Script:CustomSoftwareInstallerPath -ArgumentList $CustomSoftwareArgs -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "$CustomSoftwareName installé avec succès" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "$CustomSoftwareName installation terminée avec le code: $($process.ExitCode)" -Level WARNING
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de l'installation de $CustomSoftwareName: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Install-SplashtopStreamer {
    <#
    .SYNOPSIS
        Installe Splashtop Streamer si non présent
    #>
    try {
        Write-Log "Vérification de l'installation de Splashtop Streamer..." -Level INFO
        
        # Vérifier si déjà installé
        $installed = Get-InstalledSoftware -SoftwareName "Splashtop Streamer"
        if ($installed) {
            Write-Log "Splashtop Streamer est déjà installé. Version: $($installed.DisplayVersion)" -Level INFO
            return $true
        }
        
        Write-Log "Téléchargement de Splashtop Streamer..." -Level INFO
        
        # Téléchargement
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Script:SplashtopInstallerUrl, $Script:SplashtopInstallerPath)
        
        if (-not (Test-Path $Script:SplashtopInstallerPath)) {
            throw "Échec du téléchargement de Splashtop Streamer"
        }
        
        Write-Log "Installation de Splashtop Streamer en cours..." -Level INFO
        
        # Installation avec code de déploiement
        $arguments = "preverify deploy -q --code $SplashtopDeployCode"
        $process = Start-Process -FilePath $Script:SplashtopInstallerPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Splashtop Streamer installé avec succès" -Level SUCCESS
            # Attendre que le service démarre
            Start-Sleep -Seconds 10
            return $true
        }
        else {
            Write-Log "Splashtop Streamer installation terminée avec le code: $($process.ExitCode)" -Level WARNING
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de l'installation de Splashtop Streamer: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Set-SplashtopComputerName {
    <#
    .SYNOPSIS
        Renomme la machine dans Splashtop avec le format: NOM_PC - ID_TEAMVIEWER
    #>
    param(
        [string]$ComputerName,
        [string]$TeamViewerID
    )
    
    try {
        Write-Log "Configuration du nom de la machine dans Splashtop..." -Level INFO
        
        $newName = "$ComputerName - $TeamViewerID"
        Write-Log "Nouveau nom Splashtop: $newName" -Level INFO
        
        # Chemin du fichier de configuration Splashtop
        $splashtopConfigPaths = @(
            "$env:ProgramFiles\Splashtop\Splashtop Remote\Server\config.ini",
            "${env:ProgramFiles(x86)}\Splashtop\Splashtop Remote\Server\config.ini",
            "$env:ProgramData\Splashtop\Splashtop Remote Server\config.ini"
        )
        
        $configFound = $false
        foreach ($configPath in $splashtopConfigPaths) {
            if (Test-Path $configPath) {
                $configFound = $true
                # Lecture du fichier de configuration
                $config = Get-Content $configPath
                
                # Mise à jour du nom de l'ordinateur
                $updated = $false
                $newConfig = $config | ForEach-Object {
                    if ($_ -match "^ComputerName\s*=") {
                        "ComputerName=$newName"
                        $updated = $true
                    }
                    else {
                        $_
                    }
                }
                
                # Si la ligne n'existe pas, l'ajouter
                if (-not $updated) {
                    $newConfig += "ComputerName=$newName"
                }
                
                # Sauvegarde du fichier
                $newConfig | Set-Content $configPath -Force
                Write-Log "Configuration Splashtop mise à jour: $configPath" -Level SUCCESS
                break
            }
        }
        
        if (-not $configFound) {
            Write-Log "Fichier de configuration Splashtop non trouvé. Le renommage sera effectué via le portail web." -Level WARNING
        }
        
        # Redémarrage du service Splashtop pour appliquer les changements
        $service = Get-Service -Name "SplashtopRemoteService" -ErrorAction SilentlyContinue
        if ($service) {
            Restart-Service -Name "SplashtopRemoteService" -Force -ErrorAction SilentlyContinue
            Write-Log "Service Splashtop redémarré" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "Service Splashtop non trouvé" -Level WARNING
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de la configuration du nom Splashtop: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function New-SupportShortcut {
    <#
    .SYNOPSIS
        Crée un raccourci "Support Technique" sur le bureau
    #>
    try {
        Write-Log "Création du raccourci Support Technique..." -Level INFO
        
        $shortcutPath = Join-Path $Script:DesktopPath "$Script:ShortcutName.lnk"
        
        # Supprimer l'ancien raccourci s'il existe
        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
        }
        
        # Création du raccourci avec WScript.Shell
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $Script:SupportUrl
        $shortcut.Description = "Accès au portail de support technique Splashtop"
        
        # Utiliser l'icône du navigateur par défaut
        $browserPath = "C:\Program Files\Internet Explorer\iexplore.exe"
        if (Test-Path $browserPath) {
            $shortcut.IconLocation = "$browserPath,0"
        }
        
        $shortcut.Save()
        
        Write-Log "Raccourci créé avec succès: $shortcutPath" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Erreur lors de la création du raccourci: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Clear-TempFiles {
    <#
    .SYNOPSIS
        Nettoie les fichiers temporaires téléchargés
    #>
    try {
        Write-Log "Nettoyage des fichiers temporaires..." -Level INFO
        
        if (Test-Path $Script:TempFolder) {
            Remove-Item -Path $Script:TempFolder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Fichiers temporaires supprimés" -Level SUCCESS
        }
        
        return $true
    }
    catch {
        Write-Log "Erreur lors du nettoyage: $($_.Exception.Message)" -Level WARNING
        return $false
    }
}

# ===================================================================
# SECTION 3: FONCTION PRINCIPALE
# ===================================================================

function Start-ClientConfiguration {
    <#
    .SYNOPSIS
        Fonction principale qui orchestre toute la configuration
    #>
    
    $startTime = Get-Date
    Write-Log "========================================" -Level INFO
    Write-Log "DÉBUT DE LA CONFIGURATION CLIENT" -Level INFO
    Write-Log "========================================" -Level INFO
    
    try {
        # Vérification des prérequis
        if (-not (Test-Administrator)) {
            throw "Ce script doit être exécuté en tant qu'administrateur"
        }
        Write-Log "Droits administrateur confirmés" -Level SUCCESS
        
        # Initialisation
        if (-not (Initialize-Environment)) {
            throw "Échec de l'initialisation de l'environnement"
        }
        
        # Récupération du nom de la machine
        $computerName = $env:COMPUTERNAME
        Write-Log "Nom de la machine: $computerName" -Level INFO
        
        # Récupération de l'ID TeamViewer
        $teamViewerID = Get-TeamViewerID
        Write-Log "ID TeamViewer: $teamViewerID" -Level INFO
        
        # Installation du logiciel personnalisé
        if ($CustomSoftwareUrl -ne "https://example.com/software.exe") {
            Write-Log "Installation du logiciel personnalisé..." -Level INFO
            Install-CustomSoftware
        }
        else {
            Write-Log "Aucun logiciel personnalisé configuré (URL par défaut)" -Level WARNING
        }
        
        # Installation de Splashtop Streamer
        if ($SplashtopDeployCode -ne "VOTRE_CODE_DEPLOIEMENT") {
            Write-Log "Installation de Splashtop Streamer..." -Level INFO
            $splashtopInstalled = Install-SplashtopStreamer
            
            if ($splashtopInstalled) {
                # Renommage de la machine dans Splashtop
                Set-SplashtopComputerName -ComputerName $computerName -TeamViewerID $teamViewerID
            }
        }
        else {
            Write-Log "Code de déploiement Splashtop non configuré" -Level WARNING
        }
        
        # Création du raccourci Support Technique
        New-SupportShortcut
        
        # Nettoyage
        Clear-TempFiles
        
        # Résumé final
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Log "========================================" -Level INFO
        Write-Log "CONFIGURATION TERMINÉE AVEC SUCCÈS" -Level SUCCESS
        Write-Log "Durée totale: $($duration.TotalMinutes) minutes" -Level INFO
        Write-Log "Nom de la machine: $computerName" -Level INFO
        Write-Log "ID TeamViewer: $teamViewerID" -Level INFO
        Write-Log "Log complet: $Script:LogPath" -Level INFO
        Write-Log "========================================" -Level INFO
        
        return $true
    }
    catch {
        Write-Log "========================================" -Level ERROR
        Write-Log "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
        Write-Log "Ligne: $($_.InvocationInfo.ScriptLineNumber)" -Level ERROR
        Write-Log "========================================" -Level ERROR
        return $false
    }
}

# ===================================================================
# SECTION 4: EXÉCUTION
# ===================================================================

# Démarrage de la configuration
$result = Start-ClientConfiguration

# Code de sortie
if ($result) {
    exit 0
}
else {
    exit 1
}
