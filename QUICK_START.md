# Guide de Démarrage Rapide

## Installation en 5 Minutes

### Étape 1 : Préparation (2 minutes)

1. **Obtenez votre code de déploiement Splashtop** :
   - Connectez-vous sur https://my.splashtop.com
   - Menu : **Management** > **Deployment**
   - Copiez votre code de déploiement (exemple: `ABC123XYZ456`)

2. **Téléchargez le script** :
   - Option A : Clone Git
     ```powershell
     git clone https://github.com/ulrich-sun/scripting_windows.git
     cd scripting_windows
     ```
   - Option B : Téléchargement direct
     - Téléchargez `Install-ClientConfiguration.ps1`
     - Placez-le dans `C:\Scripts\`

### Étape 2 : Configuration (1 minute)

Ouvrez le script dans un éditeur de texte et modifiez ces 4 lignes :

```powershell
# Ligne ~37-40 environ
$SplashtopDeployCode = "REMPLACEZ_PAR_VOTRE_CODE"
$CustomSoftwareName = "AnyDesk"  # Nom du logiciel à installer
$CustomSoftwareUrl = "https://download.anydesk.com/AnyDesk.exe"  # URL de téléchargement
$CustomSoftwareArgs = "--install --silent"  # Arguments pour installation silencieuse
```

**Note** : Si vous n'avez pas de logiciel personnalisé à installer, laissez l'URL par défaut.

### Étape 3 : Exécution (2 minutes)

1. **Sur la machine cible, via TeamViewer** :
   - Touche Windows + X
   - Sélectionnez "Windows PowerShell (Admin)"

2. **Configurez l'Execution Policy** (si nécessaire) :
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process -Force
   ```

3. **Exécutez le script** :
   ```powershell
   cd C:\Scripts
   .\Install-ClientConfiguration.ps1
   ```

4. **Attendez la fin** :
   - Le script affiche sa progression en temps réel
   - Durée moyenne : 2-5 minutes selon la connexion Internet

### Étape 4 : Vérification (30 secondes)

1. **Consultez le log** :
   ```powershell
   notepad C:\Support\installation_log.txt
   ```

2. **Vérifiez les installations** :
   - Splashtop : Cherchez l'icône dans la barre d'état système
   - Raccourci : Vérifiez le bureau (icône "Support Technique")

3. **Testez Splashtop** :
   - Ouvrez https://my.splashtop.com
   - Vérifiez que la machine apparaît avec le nom : `NOM_PC - ID_TEAMVIEWER`

## ✅ C'est Terminé !

Votre PC client est maintenant configuré et prêt pour le support à distance.

---

## Scénarios Courants

### Scénario A : Installer uniquement Splashtop

Si vous voulez uniquement déployer Splashtop sans logiciel supplémentaire :

```powershell
.\Install-ClientConfiguration.ps1 -SplashtopDeployCode "VOTRE_CODE"
```

Le script ignorera automatiquement le logiciel personnalisé si l'URL est laissée par défaut.

### Scénario B : Installer AnyDesk + Splashtop

```powershell
.\Install-ClientConfiguration.ps1 `
    -SplashtopDeployCode "VOTRE_CODE" `
    -CustomSoftwareName "AnyDesk" `
    -CustomSoftwareUrl "https://download.anydesk.com/AnyDesk.exe" `
    -CustomSoftwareArgs "--install --silent"
```

### Scénario C : Installer Chrome + Splashtop

```powershell
.\Install-ClientConfiguration.ps1 `
    -SplashtopDeployCode "VOTRE_CODE" `
    -CustomSoftwareName "Chrome" `
    -CustomSoftwareUrl "https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi" `
    -CustomSoftwareArgs "/qn /norestart"
```

### Scénario D : Déploiement sur 10+ machines

1. **Créez un fichier de configuration** (`config.json`) :
   ```json
   {
     "SplashtopDeployCode": "VOTRE_CODE",
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

2. **Placez les fichiers sur un partage réseau** :
   ```
   \\Server\Deploy\
   ├── Install-ClientConfiguration-Bulk.ps1
   └── config.json
   ```

3. **Exécutez sur chaque machine** :
   ```powershell
   \\Server\Deploy\Install-ClientConfiguration-Bulk.ps1 -ConfigFile "\\Server\Deploy\config.json"
   ```

---

## Arguments d'Installation Silencieuse

Petit aide-mémoire pour les logiciels courants :

| Logiciel | Arguments |
|----------|-----------|
| AnyDesk | `--install --silent` |
| Chrome (MSI) | `/qn /norestart` |
| Firefox | `-ms` |
| 7-Zip | `/S` |
| VLC | `/S` |
| Adobe Reader | `/sAll /rs /msi EULA_ACCEPT=YES` |
| LibreOffice (MSI) | `/qn /norestart` |
| Notepad++ | `/S` |

---

## Checklist de Pré-déploiement

Avant d'exécuter le script sur plusieurs machines, vérifiez :

- [ ] Code de déploiement Splashtop obtenu et testé
- [ ] URL du logiciel personnalisé valide et accessible
- [ ] Arguments d'installation testés manuellement sur une machine de test
- [ ] TeamViewer installé et fonctionnel sur les machines cibles
- [ ] Connexion Internet stable sur les machines cibles
- [ ] Droits administrateur disponibles
- [ ] Execution Policy configurée (ou script signé)

---

## En Cas de Problème

### Le script ne démarre pas

```powershell
# Vérifier l'Execution Policy
Get-ExecutionPolicy

# Si "Restricted", exécutez :
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Puis relancez le script
```

### TeamViewer ID non trouvé

```powershell
# Vérifier si TeamViewer est installé
Get-Service TeamViewer* | Select-Object Name, Status

# Si non installé, installez TeamViewer d'abord
```

### Échec du téléchargement

```powershell
# Tester la connexion Internet
Test-NetConnection -ComputerName google.com -Port 443

# Tester l'URL du logiciel
Invoke-WebRequest -Uri "VOTRE_URL" -Method Head
```

### Consulter les logs

```powershell
# Ouvrir le log
notepad C:\Support\installation_log.txt

# Filtrer uniquement les erreurs
Get-Content C:\Support\installation_log.txt | Where-Object { $_ -match "ERROR" }
```

---

## Commandes Utiles Post-Installation

### Vérifier les services

```powershell
# Service Splashtop
Get-Service SplashtopRemoteService | Select-Object Name, Status, StartType

# Redémarrer si nécessaire
Restart-Service SplashtopRemoteService
```

### Vérifier les logiciels installés

```powershell
# Liste tous les logiciels
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Sort-Object DisplayName

# Chercher un logiciel spécifique
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -like "*Splashtop*" }
```

### Supprimer les fichiers temporaires

```powershell
# Nettoyer manuellement si nécessaire
Remove-Item -Path "C:\Support\Temp" -Recurse -Force -ErrorAction SilentlyContinue
```

---

## Automatisation Avancée

### Créer une tâche planifiée

Pour exécuter le script automatiquement au démarrage :

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Install-ClientConfiguration.ps1"

$trigger = New-ScheduledTaskTrigger -AtStartup

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName "ConfigurationAutomatique" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Configuration automatique du PC client"
```

### Déploiement GPO (Group Policy)

1. Copiez le script sur SYSVOL :
   ```
   \\domain.local\SYSVOL\domain.local\scripts\Install-ClientConfiguration.ps1
   ```

2. Créez une GPO de démarrage :
   - Computer Configuration > Policies > Windows Settings > Scripts
   - Startup > Add
   - Script Name: `Install-ClientConfiguration.ps1`
   - Script Parameters: `-SplashtopDeployCode "VOTRE_CODE"`

---

## Support

Pour plus d'aide :
- 📖 Documentation complète : [README_SCRIPT.md](README_SCRIPT.md)
- 💡 Exemples : [CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md)
- 📝 Logs : `C:\Support\installation_log.txt`
- 🐛 Issues GitHub : https://github.com/ulrich-sun/scripting_windows/issues

**Bon déploiement ! 🚀**
