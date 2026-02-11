# Documentation Détaillée - Script de Configuration Client

## Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Installation et Configuration](#installation-et-configuration)
4. [Explication Détaillée du Code](#explication-détaillée-du-code)
5. [Utilisation](#utilisation)
6. [Conseils d'Amélioration](#conseils-damélioration)
7. [Considérations de Sécurité](#considérations-de-sécurité)
8. [Dépannage](#dépannage)

---

## Vue d'ensemble

Ce script PowerShell automatise la configuration complète d'un PC client Windows après une connexion via TeamViewer. Il effectue les tâches suivantes :

- ✅ Installation automatique d'un logiciel personnalisé
- ✅ Installation de Splashtop Streamer
- ✅ Enregistrement automatique dans le compte Splashtop
- ✅ Récupération du nom de la machine (hostname)
- ✅ Récupération de l'ID TeamViewer
- ✅ Renommage de la station Splashtop (format: `NOM_PC - ID_TEAMVIEWER`)
- ✅ Création d'un raccourci "Support Technique" vers https://sso.splashtop.com
- ✅ Génération de logs détaillés dans `C:\Support\installation_log.txt`
- ✅ Exécution silencieuse (aucune interaction utilisateur requise)
- ✅ Compatible Windows 10 et Windows 11

---

## Prérequis

### Système d'exploitation
- **Windows 10** (version 1809 ou supérieure)
- **Windows 11** (toutes versions)

### Droits et permissions
- **Droits Administrateur** : Le script DOIT être exécuté en tant qu'administrateur
- **Execution Policy** : Doit être configurée à `RemoteSigned` ou `Bypass`

Pour vérifier l'Execution Policy actuelle :
```powershell
Get-ExecutionPolicy
```

Pour modifier l'Execution Policy (en tant qu'administrateur) :
```powershell
Set-ExecutionPolicy RemoteSigned -Force
```

### Connexion réseau
- Accès Internet pour télécharger :
  - Le logiciel personnalisé
  - Splashtop Streamer
- Ports sortants requis :
  - HTTP (80)
  - HTTPS (443)

### Logiciels requis
- **TeamViewer** doit être installé sur la machine cible
- **.NET Framework 4.5** ou supérieur (généralement déjà présent sur Windows 10/11)

### Informations requises
- **Code de déploiement Splashtop** : Disponible dans votre compte Splashtop Business
  - Connectez-vous sur https://my.splashtop.com
  - Allez dans **Management** > **Deployment**
  - Copiez votre code de déploiement
- **URL du logiciel personnalisé** : Lien de téléchargement direct
- **Arguments d'installation** : Paramètres pour installation silencieuse

---

## Installation et Configuration

### Étape 1 : Télécharger le script

Téléchargez le fichier `Install-ClientConfiguration.ps1` sur la machine cible ou sur un partage réseau accessible.

### Étape 2 : Configurer les paramètres

Ouvrez le script dans un éditeur de texte et modifiez les variables au début du fichier :

```powershell
# Code de déploiement Splashtop (OBLIGATOIRE)
$SplashtopDeployCode = "VOTRE_CODE_ICI"

# Logiciel personnalisé à installer
$CustomSoftwareName = "VotreLogiciel"
$CustomSoftwareUrl = "https://exemple.com/logiciel.exe"
$CustomSoftwareArgs = "/S /v/qn"  # Arguments pour installation silencieuse
```

**Exemples de paramètres d'installation silencieuse courants :**

| Type d'installeur | Arguments typiques |
|-------------------|-------------------|
| NSIS | `/S` |
| Inno Setup | `/VERYSILENT /SUPPRESSMSGBOXES` |
| MSI | `/qn /norestart` |
| InstallShield | `/s /v"/qn"` |

### Étape 3 : Exécution via TeamViewer

Deux méthodes possibles :

#### Méthode A : Exécution directe
1. Connectez-vous via TeamViewer
2. Transférez le script sur la machine distante
3. Ouvrez PowerShell en tant qu'administrateur
4. Naviguez vers le dossier contenant le script
5. Exécutez :
```powershell
.\Install-ClientConfiguration.ps1
```

#### Méthode B : Exécution avec paramètres
```powershell
.\Install-ClientConfiguration.ps1 `
    -SplashtopDeployCode "VOTRE_CODE" `
    -CustomSoftwareName "MonLogiciel" `
    -CustomSoftwareUrl "https://exemple.com/logiciel.exe" `
    -CustomSoftwareArgs "/S"
```

#### Méthode C : Exécution en une ligne (depuis TeamViewer)
```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Chemin\Vers\Install-ClientConfiguration.ps1"
```

---

## Explication Détaillée du Code

### Section 1 : Variables de Configuration

```powershell
$Script:LogPath = "C:\Support\installation_log.txt"
$Script:SupportFolder = "C:\Support"
$Script:TempFolder = "C:\Support\Temp"
```

**Pourquoi des variables au niveau script ?**
- Accessibles dans toutes les fonctions
- Facilite la modification centralisée
- Améliore la maintenabilité

### Section 2 : Fonctions Utilitaires

#### 2.1 `Write-Log`
**Objectif :** Centraliser la journalisation des événements

**Fonctionnalités :**
- Horodatage automatique
- Niveaux de log (INFO, WARNING, ERROR, SUCCESS)
- Affichage coloré dans la console
- Écriture simultanée dans le fichier de log

**Code clé :**
```powershell
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logMessage = "[$timestamp] [$Level] $Message"
Add-Content -Path $Script:LogPath -Value $logMessage
```

#### 2.2 `Test-Administrator`
**Objectif :** Vérifier les privilèges administrateur

**Méthode :**
```powershell
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

**Pourquoi c'est important ?**
- Installation de logiciels nécessite des droits élevés
- Modification du registre et des services système
- Évite les erreurs cryptiques en cours d'exécution

#### 2.3 `Initialize-Environment`
**Objectif :** Préparer l'environnement d'exécution

**Actions effectuées :**
1. Création des dossiers nécessaires (`C:\Support`, `C:\Support\Temp`)
2. Vérification de la version de Windows
3. Initialisation du fichier de log

**Gestion d'erreurs :**
```powershell
try {
    # Code principal
}
catch {
    Write-Log "Erreur: $($_.Exception.Message)" -Level ERROR
    return $false
}
```

#### 2.4 `Get-InstalledSoftware`
**Objectif :** Vérifier si un logiciel est déjà installé

**Méthode :**
- Interroge 3 emplacements du registre :
  - `HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*` (64-bit)
  - `HKLM:\Software\WOW6432Node\...\Uninstall\*` (32-bit sur 64-bit)
  - `HKCU:\Software\...\Uninstall\*` (utilisateur courant)

**Avantages :**
- Évite les installations en double
- Gain de temps
- Réduit les risques d'erreur

#### 2.5 `Get-TeamViewerID`
**Objectif :** Récupérer l'ID TeamViewer unique de la machine

**Méthode 1 : Registre Windows**
```powershell
$clientID = (Get-ItemProperty -Path "HKLM:\SOFTWARE\TeamViewer" -Name ClientID).ClientID
```

**Méthode 2 : Fichier de configuration**
```powershell
$content = Get-Content "$env:ProgramFiles\TeamViewer\TeamViewer.ini"
$idLine = $content | Where-Object { $_ -match "ClientID\s*=\s*(\d+)" }
```

**Pourquoi deux méthodes ?**
- Redondance en cas d'échec
- Compatibilité avec différentes versions de TeamViewer
- Augmente la fiabilité globale

#### 2.6 `Install-CustomSoftware`
**Objectif :** Installer le logiciel personnalisé

**Processus :**
1. Vérification si déjà installé
2. Téléchargement depuis l'URL configurée
3. Installation silencieuse avec arguments
4. Vérification du code de sortie

**Code clé :**
```powershell
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($CustomSoftwareUrl, $installerPath)

$process = Start-Process -FilePath $installerPath `
                         -ArgumentList $CustomSoftwareArgs `
                         -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    # Succès
}
```

#### 2.7 `Install-SplashtopStreamer`
**Objectif :** Installer et configurer Splashtop Streamer

**Commande d'installation :**
```powershell
$arguments = "preverify deploy -q --code $SplashtopDeployCode"
```

**Paramètres expliqués :**
- `preverify` : Vérification des prérequis avant installation
- `deploy` : Mode de déploiement automatique
- `-q` : Mode silencieux (quiet)
- `--code` : Code de déploiement pour enregistrement automatique

**Post-installation :**
```powershell
Start-Sleep -Seconds 10  # Attendre le démarrage du service
```

#### 2.8 `Set-SplashtopComputerName`
**Objectif :** Renommer la machine dans Splashtop

**Format du nom :**
```powershell
$newName = "$ComputerName - $TeamViewerID"
# Exemple : "PC-COMPTABILITE - 123456789"
```

**Méthode :**
1. Localisation du fichier de configuration Splashtop
2. Modification de la ligne `ComputerName=`
3. Redémarrage du service Splashtop

**Code de modification :**
```powershell
$config = Get-Content $configPath
$newConfig = $config | ForEach-Object {
    if ($_ -match "^ComputerName\s*=") {
        "ComputerName=$newName"
    }
    else {
        $_
    }
}
$newConfig | Set-Content $configPath -Force
```

#### 2.9 `New-SupportShortcut`
**Objectif :** Créer un raccourci sur le bureau commun

**Utilisation de WScript.Shell :**
```powershell
$wshell = New-Object -ComObject WScript.Shell
$shortcut = $wshell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "https://sso.splashtop.com"
$shortcut.IconLocation = "C:\Program Files\Internet Explorer\iexplore.exe,0"
$shortcut.Save()
```

**Pourquoi le bureau commun ?**
- Visible pour tous les utilisateurs de la machine
- `[Environment]::GetFolderPath("CommonDesktopDirectory")`

#### 2.10 `Clear-TempFiles`
**Objectif :** Nettoyer les fichiers temporaires téléchargés

**Avantages :**
- Libère de l'espace disque
- Sécurité : supprime les fichiers d'installation
- Bonne pratique de nettoyage

### Section 3 : Fonction Principale

#### `Start-ClientConfiguration`

**Architecture :**
```
1. Vérification des prérequis
   ├─ Droits administrateur
   └─ Initialisation environnement

2. Collecte d'informations
   ├─ Nom de la machine
   └─ ID TeamViewer

3. Installations
   ├─ Logiciel personnalisé
   └─ Splashtop Streamer

4. Configuration
   ├─ Renommage Splashtop
   └─ Création raccourci

5. Finalisation
   ├─ Nettoyage
   └─ Rapport final
```

**Gestion des erreurs :**
```powershell
try {
    # Tout le code de configuration
}
catch {
    Write-Log "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
    Write-Log "Ligne: $($_.InvocationInfo.ScriptLineNumber)" -Level ERROR
    return $false
}
```

**Rapport final :**
- Durée totale d'exécution
- Nom de la machine
- ID TeamViewer
- Emplacement du fichier de log

---

## Utilisation

### Scénario 1 : Configuration standard

```powershell
# 1. Modifier les variables dans le script
# 2. Exécuter en tant qu'administrateur
.\Install-ClientConfiguration.ps1
```

### Scénario 2 : Configuration avec paramètres

```powershell
.\Install-ClientConfiguration.ps1 `
    -SplashtopDeployCode "ABC123XYZ" `
    -CustomSoftwareName "AnyDesk" `
    -CustomSoftwareUrl "https://download.anydesk.com/AnyDesk.exe" `
    -CustomSoftwareArgs "--install --silent"
```

### Scénario 3 : Exécution à distance via TeamViewer

1. Connectez-vous via TeamViewer
2. Ouvrez une session PowerShell administrateur :
   - Touche Windows + X
   - Sélectionner "Windows PowerShell (Admin)"
3. Naviguez vers le script :
   ```powershell
   cd C:\Chemin\Vers\Script
   ```
4. Exécutez :
   ```powershell
   .\Install-ClientConfiguration.ps1
   ```

### Vérification post-installation

Consultez le fichier de log :
```powershell
notepad C:\Support\installation_log.txt
```

Vérifiez les installations :
```powershell
# Splashtop
Get-Service -Name "SplashtopRemoteService"

# Logiciel personnalisé
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*VotreLogiciel*" }

# Raccourci
Test-Path "$env:PUBLIC\Desktop\Support Technique.lnk"
```

---

## Conseils d'Amélioration

### 1. Déploiement en Masse

Pour déployer sur plusieurs machines, créez une version optimisée :

**Fichier de configuration CSV :**
```csv
ComputerName,SplashtopCode,SoftwareUrl
PC-COMPTA-01,ABC123,https://example.com/soft.exe
PC-COMPTA-02,ABC123,https://example.com/soft.exe
PC-VENTES-01,ABC123,https://example.com/soft.exe
```

**Script de déploiement :**
```powershell
$computers = Import-Csv "computers.csv"

foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer.ComputerName -ScriptBlock {
        param($code, $url)
        # Exécution du script principal
        & "\\Serveur\Scripts\Install-ClientConfiguration.ps1" `
            -SplashtopDeployCode $code `
            -CustomSoftwareUrl $url
    } -ArgumentList $computer.SplashtopCode, $computer.SoftwareUrl
}
```

### 2. Planification de tâches

Créez une tâche planifiée pour exécution automatique :

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Install-ClientConfiguration.ps1"

$trigger = New-ScheduledTaskTrigger -AtStartup

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName "ConfigurationClient" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal
```

### 3. Notification par email

Ajoutez une fonction d'envoi d'email :

```powershell
function Send-ReportEmail {
    param($ComputerName, $Status, $LogContent)
    
    $emailParams = @{
        From = "support@entreprise.com"
        To = "admin@entreprise.com"
        Subject = "Configuration $ComputerName - $Status"
        Body = $LogContent
        SmtpServer = "smtp.entreprise.com"
        Port = 587
        UseSsl = $true
        Credential = Get-Credential
    }
    
    Send-MailMessage @emailParams
}
```

### 4. Intégration avec un serveur de logs centralisé

```powershell
function Send-ToLogServer {
    param($Message, $Level)
    
    $logEntry = @{
        Timestamp = Get-Date -Format "o"
        Computer = $env:COMPUTERNAME
        Level = $Level
        Message = $Message
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "https://logserver.entreprise.com/api/logs" `
        -Method Post `
        -Body $logEntry `
        -ContentType "application/json"
}
```

### 5. Vérification de signature numérique

Signez le script pour plus de sécurité :

```powershell
# Obtenir un certificat de signature de code
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert

# Signer le script
Set-AuthenticodeSignature -FilePath "Install-ClientConfiguration.ps1" `
    -Certificate $cert
```

### 6. Mode de reprise après échec

Ajoutez un mécanisme de checkpoint :

```powershell
function Set-Checkpoint {
    param($Step)
    $checkpointFile = "C:\Support\checkpoint.txt"
    $Step | Out-File $checkpointFile
}

function Get-LastCheckpoint {
    $checkpointFile = "C:\Support\checkpoint.txt"
    if (Test-Path $checkpointFile) {
        return Get-Content $checkpointFile
    }
    return $null
}

# Utilisation
$lastStep = Get-LastCheckpoint
if ($lastStep -ne "CustomSoftware") {
    Install-CustomSoftware
    Set-Checkpoint "CustomSoftware"
}
```

### 7. Validation post-installation

Ajoutez une fonction de validation :

```powershell
function Test-Installation {
    $checks = @{
        SplashtopService = (Get-Service "SplashtopRemoteService" -ErrorAction SilentlyContinue) -ne $null
        SupportShortcut = Test-Path "$env:PUBLIC\Desktop\Support Technique.lnk"
        LogFile = Test-Path "C:\Support\installation_log.txt"
    }
    
    $allPassed = $true
    foreach ($check in $checks.GetEnumerator()) {
        if (-not $check.Value) {
            Write-Log "ÉCHEC: $($check.Key)" -Level ERROR
            $allPassed = $false
        }
    }
    
    return $allPassed
}
```

---

## Considérations de Sécurité

### 1. Gestion des identifiants

**❌ À ÉVITER :**
```powershell
$username = "admin"
$password = "MonMotDePasse123"  # JAMAIS en clair !
```

**✅ RECOMMANDÉ :**
```powershell
# Utiliser des identifiants chiffrés
$credential = Get-Credential
# ou
$securePassword = ConvertTo-SecureString "MotDePasse" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)
```

### 2. Code de déploiement Splashtop

**Protéger le code de déploiement :**
- Ne jamais le stocker en clair dans le code
- Utiliser des variables d'environnement
- Chiffrer avec DPAPI

```powershell
# Chiffrement du code
$secureCode = Read-Host "Code Splashtop" -AsSecureString
$encryptedCode = ConvertFrom-SecureString $secureCode
$encryptedCode | Out-File "C:\Secure\splashtop_code.txt"

# Déchiffrement lors de l'utilisation
$encryptedCode = Get-Content "C:\Secure\splashtop_code.txt"
$secureCode = ConvertTo-SecureString $encryptedCode
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureCode)
$SplashtopDeployCode = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
```

### 3. Validation des téléchargements

**Vérifier l'intégrité des fichiers téléchargés :**

```powershell
function Test-FileHash {
    param(
        [string]$FilePath,
        [string]$ExpectedHash,
        [string]$Algorithm = "SHA256"
    )
    
    $actualHash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
    
    if ($actualHash -eq $ExpectedHash) {
        Write-Log "Vérification hash OK: $FilePath" -Level SUCCESS
        return $true
    }
    else {
        Write-Log "ALERTE: Hash invalide pour $FilePath" -Level ERROR
        Write-Log "Attendu: $ExpectedHash" -Level ERROR
        Write-Log "Obtenu: $actualHash" -Level ERROR
        return $false
    }
}

# Utilisation
$expectedHash = "ABC123DEF456..."
if (Test-FileHash -FilePath $installerPath -ExpectedHash $expectedHash) {
    # Procéder à l'installation
}
```

### 4. Utilisation de TLS 1.2+

```powershell
# Forcer TLS 1.2 ou supérieur
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

### 5. Journalisation sécurisée

**Ne jamais logger :**
- Mots de passe
- Codes de déploiement complets
- Informations personnelles sensibles

**Exemple de masquage :**
```powershell
function Write-SecureLog {
    param($Code)
    
    # Masquer une partie du code
    $maskedCode = $Code.Substring(0, 3) + "***" + $Code.Substring($Code.Length - 3)
    Write-Log "Code de déploiement: $maskedCode" -Level INFO
}
```

### 6. Permissions des fichiers

```powershell
# Restreindre l'accès au dossier Support
$acl = Get-Acl "C:\Support"
$acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage

# Ajouter uniquement Administrateurs et SYSTEM
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "BUILTIN\Administrators",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($adminRule)

Set-Acl "C:\Support" $acl
```

### 7. Validation des entrées

```powershell
function Test-ValidUrl {
    param([string]$Url)
    
    if ($Url -match "^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$") {
        return $true
    }
    else {
        Write-Log "URL invalide: $Url" -Level ERROR
        return $false
    }
}

# Utilisation
if (-not (Test-ValidUrl -Url $CustomSoftwareUrl)) {
    throw "URL de téléchargement invalide"
}
```

### 8. Audit et conformité

**Activer la transcription PowerShell :**
```powershell
Start-Transcript -Path "C:\Support\transcript_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Tout votre code ici

Stop-Transcript
```

### 9. Liste blanche des sources de téléchargement

```powershell
$allowedDomains = @(
    "download.splashtop.com",
    "downloads.yourcompany.com",
    "secure.softwareprovider.com"
)

function Test-AllowedDomain {
    param([string]$Url)
    
    $uri = [System.Uri]$Url
    $domain = $uri.Host
    
    if ($allowedDomains -contains $domain) {
        return $true
    }
    else {
        Write-Log "Domaine non autorisé: $domain" -Level ERROR
        return $false
    }
}
```

### 10. Protection contre l'injection de commandes

```powershell
# Ne JAMAIS utiliser Invoke-Expression avec des entrées utilisateur
# ❌ Invoke-Expression $userInput

# ✅ Utiliser des paramètres typés et validés
param(
    [ValidatePattern("^[a-zA-Z0-9\-]+$")]
    [string]$SoftwareName
)
```

---

## Dépannage

### Problème 1 : "Script non signé"

**Erreur :**
```
File cannot be loaded because running scripts is disabled on this system
```

**Solution :**
```powershell
# Temporaire (session actuelle)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Permanent (nécessite admin)
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned
```

### Problème 2 : ID TeamViewer non trouvé

**Causes possibles :**
- TeamViewer pas installé
- Version portable de TeamViewer
- Permissions insuffisantes pour lire le registre

**Solution :**
```powershell
# Vérifier l'installation
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*TeamViewer*" }

# Vérifier le processus
Get-Process TeamViewer -ErrorAction SilentlyContinue
```

### Problème 3 : Échec du téléchargement

**Erreur :**
```
Exception calling "DownloadFile" : The remote server returned an error
```

**Solutions :**
1. Vérifier la connexion Internet :
   ```powershell
   Test-NetConnection -ComputerName google.com -Port 443
   ```

2. Vérifier le proxy :
   ```powershell
   # Utiliser le proxy système
   $webClient.Proxy = [System.Net.WebRequest]::GetSystemWebProxy()
   $webClient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
   ```

3. Vérifier TLS :
   ```powershell
   [Net.ServicePointManager]::SecurityProtocol
   # Si nécessaire
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   ```

### Problème 4 : Installation silencieuse échoue

**Vérification :**
```powershell
# Tester l'installation manuellement
Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru

# Vérifier le code de sortie
$process.ExitCode
```

**Codes de sortie courants :**
- 0 : Succès
- 1603 : Erreur fatale
- 1641 : Redémarrage requis
- 3010 : Redémarrage requis (succès)

### Problème 5 : Service Splashtop ne démarre pas

**Diagnostic :**
```powershell
Get-Service SplashtopRemoteService | Select-Object *

# Logs d'événements
Get-EventLog -LogName Application -Source "Splashtop*" -Newest 50
```

**Solution :**
```powershell
# Redémarrer le service
Restart-Service SplashtopRemoteService -Force

# Vérifier les dépendances
Get-Service SplashtopRemoteService | Select-Object -ExpandProperty ServicesDependedOn
```

### Problème 6 : Permissions insuffisantes

**Erreur :**
```
Access to the path is denied
```

**Solution :**
```powershell
# Vérifier si administrateur
if (-not (Test-Administrator)) {
    Write-Host "Relancez le script en tant qu'administrateur" -ForegroundColor Red
    # Relancer automatiquement
    Start-Process powershell -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    exit
}
```

### Problème 7 : Le raccourci ne fonctionne pas

**Vérification :**
```powershell
# Vérifier l'existence
Test-Path "$env:PUBLIC\Desktop\Support Technique.lnk"

# Lire les propriétés
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:PUBLIC\Desktop\Support Technique.lnk")
$shortcut.TargetPath
```

### Consultez les logs

En cas de problème, consultez toujours le fichier de log :

```powershell
# Ouvrir le log
notepad C:\Support\installation_log.txt

# Filtrer les erreurs
Get-Content C:\Support\installation_log.txt | Where-Object { $_ -match "ERROR" }
```

---

## Support et Contact

Pour toute question ou problème :
- Consultez les logs dans `C:\Support\installation_log.txt`
- Vérifiez que tous les prérequis sont remplis
- Contactez votre service IT avec le fichier de log

---

## Licence

Ce script est fourni "tel quel" sans garantie d'aucune sorte.
Utilisez-le à vos propres risques.

**Version :** 1.0  
**Dernière mise à jour :** 2026-02-11
