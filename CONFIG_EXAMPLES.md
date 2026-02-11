# Exemples de Configuration

Ce fichier contient des exemples de configuration pour différents scénarios de déploiement.

## Configuration de Base

```json
{
  "SplashtopDeployCode": "ABC123XYZ456",
  "CustomSoftware": {
    "Name": "AnyDesk",
    "Url": "https://download.anydesk.com/AnyDesk.exe",
    "Args": "--install --silent",
    "Hash": ""
  },
  "SupportUrl": "https://sso.splashtop.com",
  "TimeoutSeconds": 300
}
```

## Configuration avec Hash SHA256

Pour plus de sécurité, vous pouvez spécifier le hash SHA256 attendu du fichier :

```json
{
  "SplashtopDeployCode": "ABC123XYZ456",
  "CustomSoftware": {
    "Name": "Chrome",
    "Url": "https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi",
    "Args": "/qn /norestart",
    "Hash": "ABC123DEF456789..."
  },
  "SupportUrl": "https://sso.splashtop.com",
  "TimeoutSeconds": 600
}
```

## Configuration pour Plusieurs Logiciels

Si vous devez installer plusieurs logiciels, créez des fichiers de configuration séparés :

**config-anydesk.json :**
```json
{
  "SplashtopDeployCode": "ABC123XYZ456",
  "CustomSoftware": {
    "Name": "AnyDesk",
    "Url": "https://download.anydesk.com/AnyDesk.exe",
    "Args": "--install --silent",
    "Hash": ""
  },
  "SupportUrl": "https://sso.splashtop.com",
  "TimeoutSeconds": 300
}
```

**config-chrome.json :**
```json
{
  "SplashtopDeployCode": "ABC123XYZ456",
  "CustomSoftware": {
    "Name": "Chrome",
    "Url": "https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi",
    "Args": "/qn /norestart",
    "Hash": ""
  },
  "SupportUrl": "https://sso.splashtop.com",
  "TimeoutSeconds": 300
}
```

## Arguments d'Installation Silencieuse Courants

### Installeurs NSIS (Nullsoft Scriptable Install System)
```json
"Args": "/S"
```

### Installeurs Inno Setup
```json
"Args": "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"
```

### Installeurs MSI (Windows Installer)
```json
"Args": "/qn /norestart"
```

### Installeurs InstallShield
```json
"Args": "/s /v\"/qn\""
```

## Exemples de Logiciels Populaires

### Adobe Acrobat Reader DC
```json
{
  "Name": "Adobe Acrobat Reader",
  "Url": "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/misc/AcroRdrDC.exe",
  "Args": "/sAll /rs /msi EULA_ACCEPT=YES",
  "Hash": ""
}
```

### 7-Zip
```json
{
  "Name": "7-Zip",
  "Url": "https://www.7-zip.org/a/7z2301-x64.exe",
  "Args": "/S",
  "Hash": ""
}
```

### Mozilla Firefox ESR
```json
{
  "Name": "Firefox",
  "Url": "https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=win64&lang=fr",
  "Args": "-ms",
  "Hash": ""
}
```

### VLC Media Player
```json
{
  "Name": "VLC",
  "Url": "https://get.videolan.org/vlc/last/win64/vlc-win64.exe",
  "Args": "/S",
  "Hash": ""
}
```

### LibreOffice
```json
{
  "Name": "LibreOffice",
  "Url": "https://download.documentfoundation.org/libreoffice/stable/latest/win/x86_64/LibreOffice_latest_Win_x64.msi",
  "Args": "/qn /norestart",
  "Hash": ""
}
```

### Notepad++
```json
{
  "Name": "Notepad++",
  "Url": "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6/npp.8.6.Installer.x64.exe",
  "Args": "/S",
  "Hash": ""
}
```

## Comment Obtenir le Hash SHA256

### Méthode 1 : PowerShell
```powershell
Get-FileHash -Path "C:\Path\To\installer.exe" -Algorithm SHA256
```

### Méthode 2 : Via le script
```powershell
# Télécharger le fichier
$url = "https://example.com/software.exe"
$output = "C:\Temp\software.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Calculer le hash
$hash = (Get-FileHash -Path $output -Algorithm SHA256).Hash
Write-Host "Hash SHA256: $hash"
```

### Méthode 3 : CertUtil (Windows natif)
```cmd
certutil -hashfile "C:\Path\To\installer.exe" SHA256
```

## Configuration pour Déploiement en Masse

Pour un déploiement sur plusieurs machines, créez un fichier CSV avec les informations spécifiques à chaque machine :

**computers.csv :**
```csv
ComputerName,ConfigFile,LogServer
PC-COMPTA-01,\\Server\Deploy\config-anydesk.json,https://logs.company.com
PC-COMPTA-02,\\Server\Deploy\config-anydesk.json,https://logs.company.com
PC-VENTES-01,\\Server\Deploy\config-chrome.json,https://logs.company.com
```

Puis utilisez ce script PowerShell pour déployer :

```powershell
$computers = Import-Csv "computers.csv"

foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer.ComputerName -ScriptBlock {
        param($ConfigFile, $LogServer)
        
        & "\\Server\Deploy\Install-ClientConfiguration-Bulk.ps1" `
            -ConfigFile $ConfigFile `
            -LogServer $LogServer
            
    } -ArgumentList $computer.ConfigFile, $computer.LogServer
}
```

## Configuration avec Serveur de Logs Centralisé

```json
{
  "SplashtopDeployCode": "ABC123XYZ456",
  "CustomSoftware": {
    "Name": "MonLogiciel",
    "Url": "https://example.com/software.exe",
    "Args": "/S",
    "Hash": ""
  },
  "SupportUrl": "https://sso.splashtop.com",
  "TimeoutSeconds": 300,
  "LogServer": "https://logs.company.com"
}
```

Utilisation :
```powershell
.\Install-ClientConfiguration-Bulk.ps1 `
    -ConfigFile "config.json" `
    -LogServer "https://logs.company.com"
```

## Mode Hors Ligne (Offline)

Pour les environnements sans connexion Internet :

1. Pré-téléchargez tous les installeurs sur un partage réseau
2. Organisez-les dans un dossier :
   ```
   \\Server\Share\Installers\
   ├── Splashtop Streamer.exe
   ├── AnyDesk.exe
   └── Chrome.exe
   ```

3. Exécutez avec le paramètre `-OfflineMode` :
   ```powershell
   .\Install-ClientConfiguration-Bulk.ps1 `
       -ConfigFile "config.json" `
       -OfflineMode `
       -OfflineSourcePath "\\Server\Share\Installers"
   ```

## Notes Importantes

1. **Codes de Déploiement Splashtop** :
   - Obtenez votre code sur https://my.splashtop.com
   - Menu : Management > Deployment
   - Le code reste valide pour tous vos déploiements

2. **Timeout** :
   - Ajustez selon la vitesse de la connexion Internet
   - 300 secondes (5 minutes) est généralement suffisant
   - Pour les gros fichiers : 600-900 secondes (10-15 minutes)

3. **URLs de Téléchargement** :
   - Utilisez toujours HTTPS
   - Préférez les liens de téléchargement direct
   - Évitez les redirections multiples

4. **Hash SHA256** :
   - Optionnel mais fortement recommandé
   - Garantit l'intégrité du fichier téléchargé
   - Protège contre les fichiers corrompus ou modifiés
