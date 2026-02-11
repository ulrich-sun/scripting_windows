# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2026-02-11

### Ajouté
- Script principal `Install-ClientConfiguration.ps1` pour déploiement unitaire
  - Installation automatique de logiciels personnalisés
  - Déploiement et enregistrement de Splashtop Streamer
  - Récupération de l'ID TeamViewer
  - Renommage automatique dans Splashtop (format: NOM_PC - ID_TEAMVIEWER)
  - Création de raccourci "Support Technique" sur le bureau
  - Journalisation complète dans C:\Support\installation_log.txt
  - Gestion d'erreurs avec try/catch
  - Vérification des logiciels déjà installés
  - Mode 100% silencieux (aucune interaction utilisateur)

- Script de déploiement en masse `Install-ClientConfiguration-Bulk.ps1`
  - Optimisé pour déploiement simultané sur plusieurs machines
  - Support de fichiers de configuration JSON
  - Mode hors ligne pour environnements sans Internet
  - Envoi de logs vers serveur centralisé (optionnel)
  - Gestion améliorée des timeouts et ressources réseau
  - Retry automatique en cas d'échec de téléchargement
  - Vérification d'intégrité des fichiers (hash SHA256)

- Documentation complète
  - `README.md` : Vue d'ensemble et démarrage rapide
  - `README_SCRIPT.md` : Documentation technique détaillée
  - `QUICK_START.md` : Guide de démarrage en 5 minutes
  - `CONFIG_EXAMPLES.md` : Exemples de configuration pour logiciels courants

- Fichiers de configuration
  - `config.json` : Template de configuration
  - Exemples pour logiciels populaires (Chrome, Firefox, AnyDesk, etc.)

- Fonctionnalités de sécurité
  - Vérification des droits administrateur
  - Validation des URLs de téléchargement
  - Support de vérification hash SHA256
  - Protection du code de déploiement Splashtop
  - Journalisation sécurisée (pas de credentials en clair)

- Compatibilité
  - Windows 10 (toutes versions supportées)
  - Windows 11 (toutes versions)
  - PowerShell 5.1+
  - Architectures 32-bit et 64-bit

- Gestion d'erreurs robuste
  - Try/catch sur toutes les opérations critiques
  - Messages d'erreur détaillés avec numéros de ligne
  - Codes de sortie appropriés pour intégration CI/CD

### Fonctionnalités Testées
- ✅ Installation Splashtop Streamer
- ✅ Récupération ID TeamViewer depuis registre
- ✅ Récupération ID TeamViewer depuis fichier .ini
- ✅ Renommage station Splashtop
- ✅ Création raccourci bureau
- ✅ Téléchargement fichiers avec retry
- ✅ Vérification hash SHA256
- ✅ Mode hors ligne
- ✅ Journalisation multi-niveaux
- ✅ Exécution silencieuse

### Notes de Version
Cette première version stable inclut toutes les fonctionnalités demandées dans le cahier des charges :
1. ✅ Installation automatique d'un logiciel
2. ✅ Installation de Splashtop Streamer
3. ✅ Enregistrement automatique dans le compte Splashtop
4. ✅ Récupération du nom du poste (hostname)
5. ✅ Récupération de l'ID TeamViewer
6. ✅ Renommage de la station Splashtop
7. ✅ Création du raccourci "Support Technique"
8. ✅ Vérification des erreurs et fichier log
9. ✅ Exécution silencieuse
10. ✅ Compatible Windows 10 et 11

### Limitations Connues
- Le renommage Splashtop peut nécessiter quelques minutes pour se synchroniser avec le cloud
- Certains antivirus peuvent bloquer le téléchargement d'exécutables (ajoutez une exception si nécessaire)
- Le script nécessite une connexion Internet pour télécharger les logiciels (sauf en mode hors ligne)

### Prochaines Versions Prévues

#### [1.1.0] - À venir
- Support de l'installation de plusieurs logiciels en une seule exécution
- Interface graphique optionnelle pour la configuration
- Génération automatique de rapports en HTML
- Support de notifications par email
- Intégration avec Active Directory

#### [1.2.0] - À venir
- Mode de reprise après échec (checkpoints)
- Support de configurations par groupe de machines
- Validation pré-déploiement automatique
- Statistiques et métriques de déploiement
- API REST pour intégration avec outils tiers

---

## Guide de Contribution

Pour proposer une amélioration ou signaler un bug :

1. Vérifiez que le problème n'existe pas déjà dans les [Issues](https://github.com/ulrich-sun/scripting_windows/issues)
2. Créez une nouvelle issue avec :
   - Description détaillée du problème ou de la fonctionnalité
   - Version de Windows utilisée
   - Extrait du fichier de log si applicable
   - Étapes de reproduction pour les bugs
3. Pour les Pull Requests :
   - Suivez le style de code existant
   - Ajoutez des commentaires clairs
   - Testez sur Windows 10 et 11
   - Mettez à jour la documentation si nécessaire

---

## Crédits

- Script développé pour automatiser la configuration de PC clients
- Compatible avec TeamViewer et Splashtop
- Conçu pour les équipes de support IT et MSP

---

## Licence

Ce projet est fourni "tel quel" sans garantie d'aucune sorte.
Utilisez-le à vos propres risques.
