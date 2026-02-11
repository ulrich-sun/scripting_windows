# Script d'Automatisation Windows - Configuration Client

## 📋 Vue d'ensemble

Ce repository contient des scripts PowerShell professionnels pour automatiser la configuration des PC clients Windows après connexion via TeamViewer. Solution idéale pour les équipes de support IT, MSP (Managed Service Providers) et administrateurs système.

## ✨ Fonctionnalités

- ✅ Installation automatique de logiciels personnalisés
- ✅ Déploiement de Splashtop Streamer avec enregistrement automatique
- ✅ Récupération de l'ID TeamViewer et du nom de machine
- ✅ Renommage automatique dans Splashtop (format: `NOM_PC - ID_TEAMVIEWER`)
- ✅ Création de raccourci "Support Technique" sur le bureau
- ✅ Journalisation détaillée des opérations
- ✅ Gestion d'erreurs complète avec try/catch
- ✅ Vérification des logiciels déjà installés
- ✅ Exécution 100% silencieuse
- ✅ Compatible Windows 10 et Windows 11

## 📁 Structure du Repository

```
scripting_windows/
├── Install-ClientConfiguration.ps1       # Script principal pour déploiement unitaire
├── Install-ClientConfiguration-Bulk.ps1  # Version optimisée pour déploiement en masse
├── config.json                           # Fichier de configuration template
├── README.md                             # Ce fichier
├── README_SCRIPT.md                      # Documentation détaillée et complète
└── CONFIG_EXAMPLES.md                    # Exemples de configuration
```

## 🚀 Démarrage Rapide

### Prérequis

- Windows 10 ou Windows 11
- Droits Administrateur
- PowerShell 5.1 ou supérieur
- Execution Policy: `RemoteSigned` ou `Bypass`
- TeamViewer installé sur la machine cible
- Code de déploiement Splashtop (obtenu sur https://my.splashtop.com)

### Configuration Rapide

1. **Téléchargez le script** :
   ```powershell
   git clone https://github.com/ulrich-sun/scripting_windows.git
   cd scripting_windows
   ```

2. **Configurez vos paramètres** :
   
   Modifiez `config.json` ou éditez directement le script :
   ```powershell
   notepad Install-ClientConfiguration.ps1
   ```

   Variables à modifier :
   - `$SplashtopDeployCode` : Votre code de déploiement Splashtop
   - `$CustomSoftwareName` : Nom du logiciel à installer
   - `$CustomSoftwareUrl` : URL de téléchargement du logiciel
   - `$CustomSoftwareArgs` : Arguments pour installation silencieuse

3. **Exécutez le script** :
   ```powershell
   # Depuis PowerShell en tant qu'administrateur
   .\Install-ClientConfiguration.ps1
   
   # Ou avec paramètres
   .\Install-ClientConfiguration.ps1 `
       -SplashtopDeployCode "VOTRE_CODE" `
       -CustomSoftwareName "AnyDesk" `
       -CustomSoftwareUrl "https://download.anydesk.com/AnyDesk.exe" `
       -CustomSoftwareArgs "--install --silent"
   ```

4. **Vérifiez les logs** :
   ```powershell
   notepad C:\Support\installation_log.txt
   ```

## 📖 Documentation

### Documentation Complète
Consultez [README_SCRIPT.md](README_SCRIPT.md) pour :
- Explication détaillée de chaque fonction
- Guide d'utilisation complet
- Conseils d'amélioration
- Considérations de sécurité
- Guide de dépannage

### Exemples de Configuration
Consultez [CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md) pour :
- Exemples de configuration JSON
- Arguments d'installation pour logiciels populaires
- Configuration pour déploiement en masse
- Mode hors ligne

## 🎯 Cas d'Usage

### 1. Déploiement Unitaire

Idéal pour configurer une seule machine via TeamViewer :
```powershell
.\Install-ClientConfiguration.ps1
```

### 2. Déploiement en Masse

Pour configurer plusieurs machines simultanément :
```powershell
.\Install-ClientConfiguration-Bulk.ps1 -ConfigFile "\\Server\Share\config.json"
```

### 3. Mode Hors Ligne

Pour les environnements sans Internet :
```powershell
.\Install-ClientConfiguration-Bulk.ps1 `
    -ConfigFile "config.json" `
    -OfflineMode `
    -OfflineSourcePath "\\Server\Share\Installers"
```

## 🔐 Sécurité

- ✅ Vérification des droits administrateur
- ✅ Support de vérification hash SHA256
- ✅ Pas de stockage de credentials en clair
- ✅ Journalisation sécurisée
- ✅ Validation des URLs de téléchargement
- ✅ Gestion sécurisée des codes de déploiement

## 📊 Logs

Tous les scripts génèrent des logs détaillés dans :
- **Emplacement** : `C:\Support\installation_log.txt`
- **Format** : `[TIMESTAMP] [NIVEAU] Message`
- **Niveaux** : INFO, WARNING, ERROR, SUCCESS

Exemple de log :
```
[2026-02-11 14:30:15] [INFO] DÉBUT DE LA CONFIGURATION CLIENT
[2026-02-11 14:30:16] [SUCCESS] Droits administrateur confirmés
[2026-02-11 14:30:17] [INFO] Nom de la machine: PC-COMPTA-01
[2026-02-11 14:30:18] [SUCCESS] TeamViewer ID trouvé: 123456789
[2026-02-11 14:30:45] [SUCCESS] Splashtop Streamer installé avec succès
[2026-02-11 14:31:02] [SUCCESS] CONFIGURATION TERMINÉE AVEC SUCCÈS
```

## 🛠️ Dépannage

### Problème : "Execution Policy" bloque le script

**Solution** :
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### Problème : ID TeamViewer non trouvé

**Vérification** :
```powershell
# Vérifier si TeamViewer est installé
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*TeamViewer*" }
```

### Problème : Échec du téléchargement

**Diagnostic** :
```powershell
# Tester la connexion
Test-NetConnection -ComputerName download.splashtop.com -Port 443

# Vérifier le proxy
[System.Net.WebRequest]::GetSystemWebProxy()
```

Pour plus de solutions, consultez la [section Dépannage](README_SCRIPT.md#dépannage) dans la documentation complète.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Améliorer la documentation
- Partager vos cas d'usage

## 📝 Licence

Ce projet est fourni "tel quel" sans garantie d'aucune sorte.
Utilisez-le à vos propres risques.

## 🔗 Liens Utiles

- [Documentation Splashtop](https://support-splashtopbusiness.splashtop.com/)
- [Téléchargement TeamViewer](https://www.teamviewer.com/fr/telecharger/)
- [Documentation PowerShell](https://docs.microsoft.com/powershell/)

## 📞 Support

Pour toute question ou problème :
1. Consultez la [documentation complète](README_SCRIPT.md)
2. Vérifiez les [exemples de configuration](CONFIG_EXAMPLES.md)
3. Consultez les logs dans `C:\Support\installation_log.txt`
4. Ouvrez une issue sur GitHub

---

**Version** : 1.0  
**Dernière mise à jour** : 2026-02-11  
**Auteur** : Support IT  
**Repository** : https://github.com/ulrich-sun/scripting_windows