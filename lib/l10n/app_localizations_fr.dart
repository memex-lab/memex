// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get timesLabel => 'Fois';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Définir $modelId comme modèle par défaut';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get unknownModel => 'Modèle inconnu';

  @override
  String get notSet => 'Non défini';

  @override
  String get confirmClear => 'Confirmer l\'effacement';

  @override
  String get confirmClearTokenMessage =>
      'Effacer l\'utilisateur actuel ? Vous devrez saisir à nouveau l\'ID utilisateur.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get tokenCleared => 'Utilisateur effacé';

  @override
  String clearTokenFailed(Object error) {
    return 'Échec de l\'effacement de l\'utilisateur : $error';
  }

  @override
  String get selectDateRangeOptional =>
      'Sélectionner une plage de dates (facultatif) :';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get select => 'Sélectionner';

  @override
  String get processLimitOptional => 'Limite de traitement (facultatif)';

  @override
  String get leaveEmptyForAll => 'Laissez vide pour tout traiter';

  @override
  String get startProcessing => 'Démarrer le traitement';

  @override
  String get userIdNotFound => 'ID utilisateur introuvable';

  @override
  String createTaskFailed(Object error) {
    return 'Échec de la création de la tâche : $error';
  }

  @override
  String get reprocessCards => 'Retraiter les cartes';

  @override
  String get reprocessCardsTaskCreated =>
      'Demande de retraitement ajoutée à la file du Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Portée';

  @override
  String get reprocessCardsCardOnly => 'Cartes uniquement';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Demander au Super Agent de réviser et régénérer les cartes de timeline sélectionnées.';

  @override
  String get reprocessCardsRerunDownstream => 'Cartes et suivis liés';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Demander au Super Agent de prendre aussi en compte les mises à jour liées de PKM et d\'insights si nécessaire.';

  @override
  String get reanalyzeMediaAssets => 'Relire les pièces jointes média';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Demander au Super Agent d\'inspecter à nouveau les médias joints lors de la régénération des cartes.';

  @override
  String get regenerateComments => 'Régénérer les commentaires';

  @override
  String get regenerateCommentsTaskCreated =>
      'Tâche de régénération des commentaires créée, en cours en arrière-plan';

  @override
  String get rebuildSearchIndex => 'Reconstruire l\'index de recherche';

  @override
  String get rebuildSearchIndexSuccess =>
      'Index de recherche reconstruit avec succès';

  @override
  String get rebuildSearchIndexFailed =>
      'Échec de la reconstruction de l\'index de recherche';

  @override
  String get clearData => 'Effacer les données';

  @override
  String get confirmClearDataMessage => 'Effacer les données ?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Toutes les données locales de l\'espace de travail de l\'utilisateur actuel seront supprimées, y compris les cartes, médias, fichiers de connaissance, insights, mémoire, historique de chat et état système.\n\nCette action est irréversible !';

  @override
  String get clearFailedAgentContexts =>
      'Effacer le contexte de conversation en échec';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Effacer le contexte de conversation sauvegardé des agents Insight et Schedule ? C\'est utile après un changement de modèle lorsque les anciens messages d\'agent ne sont plus compatibles. Les faits, cartes, connaissances, mémoires et paramètres de modèle ne seront pas supprimés.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count contexte(s) de conversation sauvegardé(s) effacé(s)';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Échec de l\'effacement du contexte de conversation : $error';
  }

  @override
  String get cloneToTestUser => 'Cloner vers un utilisateur de test';

  @override
  String get confirmCloneToTestUserMessage =>
      'Copier l\'espace de travail actuel dans un nouvel utilisateur local de test et basculer dessus. L\'état runtime des agents ne sera pas copié. Vos données actuelles ne seront pas modifiées.';

  @override
  String get testUserIdLabel => 'ID utilisateur de test';

  @override
  String get testUserIdHelper =>
      'Utilisez lettres, chiffres, tiret ou underscore.';

  @override
  String get testUserIdInvalid =>
      'Utilisez uniquement lettres, chiffres, tiret ou underscore.';

  @override
  String get overwriteExistingTestUser =>
      'Remplacer l\'utilisateur de test existant avec le même ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Basculé vers l\'utilisateur de test $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Échec du clonage de l\'utilisateur de test : $error';
  }

  @override
  String get dataClearedSuccess => 'Données effacées avec succès';

  @override
  String clearDataFailed(Object error) {
    return 'Échec de l\'effacement des données : $error';
  }

  @override
  String get personalCenter => 'Centre personnel';

  @override
  String get viewLogs => 'Voir les logs';

  @override
  String get systemAuthorization => 'Autorisation système';

  @override
  String get aiCharacterConfig => 'Configuration des personnages AI';

  @override
  String get modelConfig => 'Configuration du modèle';

  @override
  String get agentConfig => 'Configuration de l\'agent';

  @override
  String get experimentalLab => 'Laboratoire';

  @override
  String get experimentalLabDescription =>
      'Fonctionnalités expérimentales susceptibles de changer ou d\'être déplacées.';

  @override
  String get modelUsageStats => 'Statistiques d\'utilisation du modèle';

  @override
  String get asyncTaskList => 'Liste des tâches asynchrones';

  @override
  String get clearLocalToken => 'Effacer l\'utilisateur';

  @override
  String get insightCardTemplates => 'Modèles de cartes insight';

  @override
  String get timelineCardTemplates => 'Modèles de cartes timeline';

  @override
  String get logViewer => 'Visionneuse de logs';

  @override
  String get autoRefresh => 'Actualisation automatique';

  @override
  String get lineCount => 'Nombre de lignes : ';

  @override
  String get all => 'Tout';

  @override
  String get schedule => 'Planning';

  @override
  String get appLockConfig => 'Configuration du verrouillage de l\'app';

  @override
  String loadStatsFailed(Object error) {
    return 'Échec du chargement des statistiques : $error';
  }

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get daily => 'Quotidien';

  @override
  String get modelStatsByAgent => 'Par agent';

  @override
  String get detail => 'Détail';

  @override
  String get date => 'Date du jour';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get totalCalls => 'Appels totaux';

  @override
  String get calls => 'Appels';

  @override
  String callsCount(Object count) {
    return '$count appels';
  }

  @override
  String get selectDateRange => 'Sélectionner une plage de dates';

  @override
  String get totalTokens => 'Total des tokens';

  @override
  String get cacheRate => 'Taux de cache';

  @override
  String get promptTokens => 'Tokens de prompt';

  @override
  String get completionTokens => 'Tokens de completion';

  @override
  String get cachedTokens => 'Tokens en cache';

  @override
  String get thoughtTokens => 'Tokens de pensée';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Completion';

  @override
  String get cached => 'Cached';

  @override
  String get thought => 'Thought';

  @override
  String get model => 'Modèle';

  @override
  String get scene => 'Scène';

  @override
  String get sceneId => 'ID de scène';

  @override
  String get tokenUsage => 'Utilisation des tokens';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'Répartition par modèle';

  @override
  String get callDetails => 'Détails de l\'appel';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Détails de l\'enregistrement : $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Échec de l\'enregistrement de la configuration LLM : $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'L\'aperçu HTML n\'est pas disponible sur le web. Veuillez le consulter sur mobile.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Échec de l\'enregistrement des informations utilisateur : $error';
  }

  @override
  String get totalEstimatedCost => 'Coût estimé total';

  @override
  String get close => 'Fermer';

  @override
  String get totalTokenConsumption => 'Consommation totale de tokens';

  @override
  String get dataLoadFailedRetry =>
      'Échec du chargement des données, veuillez réessayer plus tard.';

  @override
  String get timelineLoadFailedRetry =>
      'Échec du chargement de la timeline, veuillez réessayer plus tard.';

  @override
  String get newPerspective => 'Nouvelle perspective';

  @override
  String get startPoint => 'Début';

  @override
  String get endPoint => 'Fin';

  @override
  String get originalInput => 'Entrée originale';

  @override
  String get referenceContent => 'Contenu de référence';

  @override
  String referenceWithTitle(Object title) {
    return 'Référence : $title';
  }

  @override
  String get actionCenterTitle => 'Actions en attente';

  @override
  String get noPendingActions => 'Aucune action en attente';

  @override
  String get clarificationNeeded => 'Memex veut confirmer';

  @override
  String get clarificationTextHint => 'Tapez une réponse courte';

  @override
  String get clarificationTextRequired => 'Ajoutez d\'abord une réponse courte';

  @override
  String get clarificationAnswered => 'Répondu';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Réponse : $answer';
  }

  @override
  String get answerSaved => 'Réponse enregistrée';

  @override
  String get clarificationOtherAnswer => 'Saisie manuelle';

  @override
  String get clarificationNotSure => 'Pas sûr / préfère ne pas répondre';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get footprintMap => 'Carte des traces';

  @override
  String get waypointPlaces => 'Lieux de passage';

  @override
  String get unknownPlace => 'Lieu inconnu';

  @override
  String get releaseToSend => 'Relâcher pour envoyer';

  @override
  String get selectFromAlbum => 'Sélectionner depuis l\'album';

  @override
  String get clipboardPreviewTitle => 'Nouveau presse-papiers';

  @override
  String get clipboardPreviewImageTitle => 'Image du presse-papiers';

  @override
  String get clipboardPreviewImageDescription => 'Image prête à ajouter';

  @override
  String get clipboardPreviewUnprocessed => 'Pas encore collé';

  @override
  String get clipboardPreviewPasteToInput => 'Coller dans l\'entrée';

  @override
  String get clipboardPreviewAddImageToInput => 'Ajouter l\'image';

  @override
  String get clipboardPreviewImageFailed =>
      'Impossible de lire l\'image du presse-papiers';

  @override
  String get tellAiWhatHappened => 'Dites à l\'AI ce qui s\'est passé...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Enregistrement : $duration';
  }

  @override
  String get playing => 'Lecture...';

  @override
  String get sendLabel => 'Envoyer';

  @override
  String attachedImagesMessage(Object count) {
    return '$count image(s) envoyée(s)';
  }

  @override
  String get noTaskData => 'Aucune donnée de tâche';

  @override
  String createdAtDate(Object date) {
    return 'Créé : $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Mis à jour : $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Durée : $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Tentative : $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Échec du chargement des détails, veuillez réessayer plus tard.';

  @override
  String get loadFailed => 'Échec du chargement';

  @override
  String loadHistoryFailed(Object error) {
    return 'Échec du chargement de l\'historique : $error';
  }

  @override
  String get reload => 'Recharger';

  @override
  String get aiInsightDetail => 'Détail de l\'insight';

  @override
  String relatedRecordsCount(Object count) {
    return 'Enregistrements liés ($count)';
  }

  @override
  String get noRelatedRecords => 'Aucun enregistrement lié';

  @override
  String get useFingerprintToUnlock =>
      'Utiliser l\'empreinte pour déverrouiller';

  @override
  String get locked => 'Verrouillé';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get enterPassword => 'Saisir le mot de passe';

  @override
  String get memexLocked => 'Memex est verrouillé';

  @override
  String get calendarShortSun => 'Dim';

  @override
  String get calendarShortMon => 'Lun';

  @override
  String get calendarShortTue => 'Mar';

  @override
  String get calendarShortWed => 'Mer';

  @override
  String get calendarShortThu => 'Jeu';

  @override
  String get calendarShortFri => 'Ven';

  @override
  String get calendarShortSat => 'Sam';

  @override
  String noRecordsOnDate(Object date) {
    return 'Aucun enregistrement le $date';
  }

  @override
  String get footprintPath => 'Chemin des traces';

  @override
  String get lifeCompositionTable => 'Composition de vie';

  @override
  String get emotionReframe => 'Reformulation émotionnelle';

  @override
  String get chronicleOfThings => 'Chronique des choses';

  @override
  String get goalProgress => 'Progression de l\'objectif';

  @override
  String get trendChart => 'Graphique de tendance';

  @override
  String get comparisonChart => 'Graphique de comparaison';

  @override
  String get todayTimeFlow => 'Flux du temps d\'aujourd\'hui';

  @override
  String get aiInputHint =>
      'Qu\'il s\'agisse de souvenirs ou du présent, je suis là...';

  @override
  String get refreshSuperAgentStateTooltip => 'Effacer le contexte Memex Agent';

  @override
  String get refreshSuperAgentStateTitle =>
      'Effacer le contexte historique de Memex Agent ?';

  @override
  String get refreshSuperAgentStateMessage =>
      'L\'historique visible du chat restera, mais le contexte runtime historique de Memex Agent sera effacé et les futures réponses repartiront d\'un contexte neuf. La mémoire persistante, les fichiers de base de connaissances, les cartes et autres données sauvegardées ne sont pas affectés. Utilisez ceci lorsque Memex Agent continue à se comporter anormalement. Continuer ?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Attendez la fin du message actuel de Memex Agent avant d\'effacer le contexte.';

  @override
  String get refreshSuperAgentStateSuccess => 'Contexte Memex Agent effacé';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Échec de l\'effacement du contexte Memex Agent : $error';
  }

  @override
  String get nothingHere => 'Rien ici pour l\'instant';

  @override
  String get nothingHereHint =>
      'Touchez le bouton ci-dessous pour créer votre première carte';

  @override
  String get agentProcessing => 'AI traite...';

  @override
  String get keepAppOpen => 'Ne fermez pas l\'app';

  @override
  String get activityDetail => 'Détail d\'activité';

  @override
  String get noAgentActivityYet => 'Aucune activité d\'agent pour l\'instant';

  @override
  String get processingEllipsis => 'Traitement...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent en pause';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent a besoin d\'attention';

  @override
  String get agentBackgroundStageIdle => 'Inactif';

  @override
  String get agentBackgroundStageProcessing => 'Traitement';

  @override
  String get agentBackgroundStageQueued => 'En file';

  @override
  String get agentBackgroundStageRetrying => 'En attente de nouvelle tentative';

  @override
  String get agentBackgroundStagePaused => 'En pause';

  @override
  String get agentBackgroundStageCompleted => 'Terminé';

  @override
  String get agentBackgroundStageNeedsAttention => 'Besoin d\'attention';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Analyse des médias';

  @override
  String get agentBackgroundStageGeneratingCard => 'Génération de carte';

  @override
  String get agentBackgroundStageUpdatingKnowledge =>
      'Mise à jour de la connaissance';

  @override
  String get agentBackgroundStagePreparingComment =>
      'Préparation du commentaire';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Routage des suivis';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'En cours $running, en attente $pending, nouvelle tentative $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Traitement de $count tâche(s) en file.';
  }

  @override
  String get agentBackgroundNoTasks => 'Aucune tâche en arrière-plan.';

  @override
  String get agentBackgroundStarting => 'Le traitement démarre.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Toutes les tâches en arrière-plan sont terminées.';

  @override
  String get agentBackgroundFailedDetail =>
      'Le traitement s\'est arrêté avec une erreur.';

  @override
  String get agentBackgroundPausedDetail =>
      'Le traitement est en pause et continuera plus tard.';

  @override
  String get agentBackgroundQueuedDetail =>
      'En attente de la prochaine étape de traitement.';

  @override
  String get agentBackgroundRetryingDetail =>
      'L\'étape actuelle sera retentée automatiquement.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Lecture des pièces jointes et du contexte local.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Transformation de l\'enregistrement en carte de timeline.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Mise à jour de la connaissance et de la mémoire locales.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Préparation d\'un suivi assistant.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Vérification des actions de suivi pour cette carte.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'En pause - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Besoin d\'attention - $summary';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get languageSettings => 'Langue';

  @override
  String get languageSettingsDesc => 'Changer la langue d\'affichage de l\'app';

  @override
  String get noPendingActionsToast => 'Aucune action en attente';

  @override
  String get knowledgeNewDiscovery => 'Nouvelle découverte de connaissance';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count nouvel/nouveaux insight(s) découvert(s)';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count insight(s) existant(s) mis à jour';
  }

  @override
  String get sectionNewInsights => 'Nouveaux insights';

  @override
  String get sectionUpdatedInsights => 'Insights mis à jour';

  @override
  String get unnamedInsight => 'Insight sans nom';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get copy => 'Copier';

  @override
  String get selectedLocation => 'Lieu sélectionné';

  @override
  String get confirmLocationName => 'Confirmer le nom du lieu';

  @override
  String get confirmLocationNameHint =>
      'Vous pouvez modifier le nom (les coordonnées restent identiques)';

  @override
  String get nameLabel => 'Nom';

  @override
  String get inputPlaceNameHint => 'Saisir le nom du lieu...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Coordonnées : $lat, $lng';
  }

  @override
  String get confirmLocation => 'Confirmer le lieu';

  @override
  String get welcomeToMemex => 'Bienvenue dans Memex';

  @override
  String get createUserIdToStart => 'Créez votre profil';

  @override
  String get userIdLabel => 'Votre nom / surnom';

  @override
  String get userIdHint => 'Entrez votre nom ou surnom';

  @override
  String get pleaseEnterUserId => 'Veuillez entrer votre nom';

  @override
  String get userIdMaxLength => 'Le nom ne doit pas dépasser 50 caractères';

  @override
  String get startUsing => 'Continuer';

  @override
  String get userIdTip => 'Cela servira à personnaliser votre expérience.';

  @override
  String get setupModelConfigTitle => 'Configurer un modèle AI';

  @override
  String get setupModelConfigSubtitle =>
      'Memex a besoin d\'un modèle AI avancé pour organiser les enregistrements, analyser les images et générer des insights. Choisissez une méthode de connexion.';

  @override
  String get setupModelConfigComplete => 'Terminer et continuer';

  @override
  String get aiService => 'Service de modèles Memex';

  @override
  String get aiModelHubTitle => 'Modèles et services AI';

  @override
  String get aiModelHubSubtitle =>
      'Choisissez le service officiel de Memex ou apportez votre propre fournisseur. Le routage avancé des modèles reste disponible quand vous en avez besoin.';

  @override
  String get aiSetupCurrentStatusTitle => 'Configuration actuelle';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'Service AI non configuré';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Choisissez une méthode de connexion pour activer l\'organisation AI des enregistrements, médias et insights.';

  @override
  String get aiSetupStatusMemexTitle => 'Utilisation du service officiel Memex';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex utilisera la connexion officielle et les identifiants API gérés par votre compte Memex.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Utilisation de paramètres de fournisseur personnalisé';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex utilisera vos identifiants de fournisseur configurés et vos choix de rôles de modèle.';

  @override
  String get aiSetupChooseConnectionTitle => 'Choisir une méthode de connexion';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Commencez par le chemin qui correspond à la façon dont vous voulez que Memex accède aux modèles AI.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Connectez-vous à Memex pour utiliser le service d’IA officiel.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Ajoutez votre propre fournisseur et votre clé API.';

  @override
  String get aiSetupCustomPageTitle => 'Service AI personnalisé';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Configurez d\'abord les identifiants du fournisseur, puis choisissez le modèle que Memex doit utiliser.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Fournisseur et clés API';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Ajoutez ou modifiez OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama ou un autre fournisseur compatible.';

  @override
  String get modelRolesTitle => 'Choisir le modèle principal';

  @override
  String get modelRolesDescription =>
      'Super Agent utilise un modèle pour les entrées texte et image. Les overrides avancés par agent restent disponibles ci-dessous.';

  @override
  String get textModelRoleTitle => 'Modèle principal';

  @override
  String get textModelRoleDescription =>
      'Utilisé par Super Agent pour le texte, les images, les cartes, la connaissance, les insights, le chat, les commentaires et la mémoire.';

  @override
  String get modelConnectionsTitle => 'Fournisseurs de modèles et clés API';

  @override
  String get modelConnectionsDescription =>
      'Connectez le service officiel de Memex ou ajoutez vos propres identifiants de fournisseur.';

  @override
  String get relatedAiCapabilitiesTitle => 'Capacités avancées et liées';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Affinez les attributions d\'agents, le fournisseur de localisation et le comportement de speech transcription.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Capacités du service';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Choisissez les fournisseurs utilisés par Memex pour des capacités AI adjacentes comme speech et reverse geocoding.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Routage avancé des modèles';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Pour les utilisateurs avancés qui veulent que certains agents utilisent des fournisseurs ou configurations de modèles différents.';

  @override
  String get locationProviderSettings => 'Fournisseur de localisation';

  @override
  String get speechProviderSettings => 'Transcription vocale';

  @override
  String get advancedAgentModelAssignments =>
      'Attributions de modèles aux agents';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Remplacer des agents individuels';

  @override
  String get noConfiguredModelOptions =>
      'Ajoutez un fournisseur ou une clé API avant de choisir les rôles de modèle.';

  @override
  String get modelSlotUpdated => 'Rôle de modèle mis à jour';

  @override
  String get aiServiceMemexRouteTitle => 'Se connecter via Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex utilise un système multiagent pour organiser les enregistrements de vie, notes de connaissance et contexte social, découvrir des insights plus profonds et fournir une compagnie AI avec mémoire persistante. Vos données sont stockées en Markdown texte brut, préservant liberté et portabilité des données.';

  @override
  String get aiServiceCustomApiRouteTitle => 'J\'ai une clé API';

  @override
  String get aiServiceCustomModelDescription =>
      'Choisissez ceci d\'abord si vous avez déjà une clé API d\'OpenAI, Anthropic, DeepSeek, Gemini ou d\'un autre fournisseur.';

  @override
  String get enableAiService => 'Se connecter avec Memex';

  @override
  String get aiServiceReadyToast => 'Organisation AI activée';

  @override
  String get aiServiceSettingsDescription =>
      'Si vous n\'avez pas de clé API, utilisez un compte Memex pour vous connecter aux services de modèles courants.';

  @override
  String get advancedModelConfiguration => 'Configurer la clé API';

  @override
  String get skipForNow => 'Ignorer pour l\'instant';

  @override
  String get clearAuth => 'Effacer l\'autorisation';

  @override
  String get authorizing => 'Autorisation...';

  @override
  String authFailed(Object error) {
    return 'Échec de l\'autorisation : $error';
  }

  @override
  String get authorized => 'Autorisé';

  @override
  String authorizedAs(Object email) {
    return 'Autorisé en tant que $email';
  }

  @override
  String get authorizedSuccessfully => 'Autorisation réussie';

  @override
  String get reAuthorize => 'Ré-autoriser';

  @override
  String get authorizeWithOpenAi => 'Autoriser avec OpenAI';

  @override
  String get authorizeWithGoogle => 'Autoriser avec Google';

  @override
  String get config => 'Configuration';

  @override
  String get calendar => 'Calendrier';

  @override
  String get reminders => 'Rappels';

  @override
  String get writeToSystemFailed => 'Échec d\'écriture dans le système';

  @override
  String permissionRequired(Object name) {
    return 'Permission $name requise';
  }

  @override
  String permissionRationale(Object name) {
    return 'Veuillez autoriser l\'app à accéder à $name dans les Paramètres pour que nous puissions le créer pour vous.';
  }

  @override
  String get goToSettings => 'Aller aux Paramètres';

  @override
  String get unknownAction => 'Action inconnue';

  @override
  String get discoveredCalendarEvent => 'Événement de calendrier trouvé';

  @override
  String get discoveredReminder => 'Rappel trouvé';

  @override
  String get addToCalendar => 'Ajouter au calendrier';

  @override
  String get addToReminders => 'Ajouter aux rappels';

  @override
  String get systemActionPendingExplanation =>
      'Pas encore ajouté. Touchez ci-dessous pour demander l’autorisation et l’ajouter à votre appareil.';

  @override
  String addedToSuccess(Object target) {
    return 'Ajouté à $target avec succès';
  }

  @override
  String get ignore => 'Ignorer';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmDeleteSessionMessage =>
      'Supprimer cette conversation ? Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteSuccess => 'Supprimé avec succès';

  @override
  String deleteFailed(Object error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String daysAgo(Object count) {
    return 'Il y a $count jours';
  }

  @override
  String get chatHistory => 'Historique de chat';

  @override
  String get enterFullScreenTooltip => 'Passer en plein écran';

  @override
  String get exitFullScreenTooltip => 'Quitter le plein écran';

  @override
  String get noConversations => 'Aucune conversation';

  @override
  String loadSessionListFailed(Object error) {
    return 'Échec du chargement de la liste des sessions : $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Hier $time';
  }

  @override
  String get newChat => 'Nouveau chat';

  @override
  String messageCount(Object count) {
    return '$count message(s)';
  }

  @override
  String get organize => 'Organiser';

  @override
  String get pkmCategoryProject => 'Project (projet)';

  @override
  String get pkmCategoryProjectSubtitle =>
      'Court terme · Objectifs · Échéances';

  @override
  String get pkmCategoryArea => 'Area (domaine)';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Long terme · Responsabilité · Standards';

  @override
  String get pkmCategoryResource => 'Resource (ressource)';

  @override
  String get pkmCategoryResourceSubtitle => 'Intérêts · Inspiration · Réserve';

  @override
  String get pkmCategoryArchive => 'Archive (archives)';

  @override
  String get pkmCategoryArchiveSubtitle => 'Terminé · Dormant · Référence';

  @override
  String get recentChanges => 'Changements récents';

  @override
  String get noRecentChangesInThreeDays =>
      'Aucun changement dans les 3 derniers jours';

  @override
  String get unpinned => 'Détaché';

  @override
  String get pinnedStyle => 'Style épinglé';

  @override
  String operationFailed(Object error) {
    return 'Opération échouée : $error';
  }

  @override
  String get refreshingInsightData =>
      'Actualisation des données d\'insight, cela peut prendre un moment...';

  @override
  String refreshFailed(Object error) {
    return 'Échec de l\'actualisation : $error';
  }

  @override
  String get sortUpdated => 'Ordre de tri mis à jour';

  @override
  String sortSaveFailed(Object error) {
    return 'Échec de l\'enregistrement du tri : $error';
  }

  @override
  String get insightCardDeleted => 'Carte insight supprimée';

  @override
  String deleteFailedShort(Object error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String get knowledgeInsight => 'Insight de connaissance';

  @override
  String get completeSort => 'Terminer le tri';

  @override
  String get noKnowledgeInsight => 'Aucun insight de connaissance';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count tâches d\'arrière-plan sont encore en traitement.';
  }

  @override
  String get insightUnavailableMessage =>
      'Cet insight est encore en génération ou a été mis à jour. Actualisez les insights et réessayez plus tard.';

  @override
  String get artifactOpen => 'Ouvrir';

  @override
  String get updating => 'Mise à jour...';

  @override
  String get update => 'Mettre à jour';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get appLockOn => 'Verrouillage de l\'app activé';

  @override
  String get appLockOff => 'Verrouillage de l\'app désactivé';

  @override
  String get enableAppLockFirst =>
      'Veuillez d\'abord activer le verrouillage de l\'app';

  @override
  String get enterFourDigitPassword => 'Entrez un mot de passe à 4 chiffres';

  @override
  String get passwordSetAndLockOn =>
      'Mot de passe défini et verrouillage de l\'app activé';

  @override
  String get appLockSettings => 'Paramètres de verrouillage de l\'app';

  @override
  String get enableAppLock => 'Activer le verrouillage de l\'app';

  @override
  String get enableAppLockSubtitle =>
      'Mot de passe requis au lancement de l\'app';

  @override
  String get enableBiometrics => 'Activer la biométrie';

  @override
  String get biometricsSubtitle =>
      'Utiliser Face ID ou Touch ID pour déverrouiller';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get setFourDigitPassword => 'Définir un mot de passe à 4 chiffres';

  @override
  String get reenterPasswordToConfirm =>
      'Saisissez à nouveau le mot de passe pour confirmer';

  @override
  String get passwordMismatch =>
      'Les mots de passe ne correspondent pas. Veuillez réessayer.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Supprimer le personnage \"$name\" ? Cette action est irréversible.';
  }

  @override
  String get configureAiCharacter => 'Configurer un personnage AI';

  @override
  String get addCharacter => 'Ajouter un personnage';

  @override
  String get addCharacterSubtitle =>
      'Choisissez des personnages AI pour rejoindre votre équipe d\'insights. Ils analyseront vos données de vie sous différents angles.';

  @override
  String get noCharacters => 'Aucun personnage';

  @override
  String loadCharacterFailed(Object error) {
    return 'Échec du chargement des personnages : $error';
  }

  @override
  String get noTags => 'Aucun tag';

  @override
  String get createSuccess => 'Créé avec succès';

  @override
  String get updateSuccess => 'Mis à jour avec succès';

  @override
  String saveFailed(Object error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get newCharacter => 'Nouveau personnage';

  @override
  String get editCharacter => 'Modifier le personnage';

  @override
  String get save => 'Enregistrer';

  @override
  String get characterName => 'Nom du personnage';

  @override
  String get characterNameHint => 'Donnez un nom à votre personnage';

  @override
  String get pleaseEnterCharacterName => 'Veuillez saisir le nom du personnage';

  @override
  String get tagsLabel => 'Tags / étiquettes';

  @override
  String get tagsHint =>
      'ex. : wisdom, recognition, macro\nSéparez plusieurs tags par des virgules';

  @override
  String get characterPersonaLabel => 'Persona du personnage';

  @override
  String get characterPersonaHint =>
      'Incluez persona, guide de style, dialogue exemple, filtres de connaissance, etc.\nUtilisez ## pour les titres de section.';

  @override
  String get pleaseEnterCharacterPersona =>
      'Veuillez saisir la persona du personnage';

  @override
  String permissionRequestError(Object error) {
    return 'Erreur de demande de permission : $error';
  }

  @override
  String get permissionRequiredTitle => 'Permission requise';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Vous avez refusé définitivement cette permission ou le système l\'exige. Veuillez l\'activer dans les paramètres système.';

  @override
  String get getting => 'Obtention...';

  @override
  String get unauthorized => 'Non autorisé';

  @override
  String get authorizedGoToSettings =>
      'Autorisé. Allez dans les paramètres système pour changer.';

  @override
  String get location => 'Localisation';

  @override
  String get locationPermissionReason =>
      'Pour enregistrer des lieux et les fonctionnalités liées à la localisation';

  @override
  String get photos => 'Photos stockées';

  @override
  String get photosPermissionReason =>
      'Pour sélectionner des photos, enregistrer des images générées, etc.';

  @override
  String get camera => 'Appareil photo';

  @override
  String get cameraPermissionReason => 'Pour prendre des photos et vidéos';

  @override
  String get microphone => 'Microphone système';

  @override
  String get microphonePermissionReason =>
      'Pour reconnaissance vocale, enregistrement, etc.';

  @override
  String get calendarPermissionReason =>
      'Pour enregistrer le planning et lire les événements du calendrier';

  @override
  String get remindersPermissionReason =>
      'Pour enregistrer et lire vos rappels';

  @override
  String get fitnessAndMotion => 'Fitness et mouvement';

  @override
  String get fitnessPermissionReason =>
      'Pour enregistrer les données de santé et mouvement';

  @override
  String get notification => 'Notification app';

  @override
  String get notificationPermissionReason =>
      'Pour envoyer planning et rappels importants';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Laisser Memex Agent fonctionner en arrière-plan';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent s\'exécute localement sur votre appareil. Avec les notifications, Memex peut afficher la progression et continuer le traitement après que vous quittez l\'app ou éteignez l\'écran. Si les notifications sont désactivées, gardez Memex ouvert au premier plan jusqu\'à la fin de la tâche.';

  @override
  String get loadDetailFailedRetryShort =>
      'Échec du chargement des détails, veuillez réessayer plus tard.';

  @override
  String get total => 'Total général';

  @override
  String get estimatedCost => 'Coût estimé';

  @override
  String get byAgent => 'Par agent';

  @override
  String get timeUpdated => 'Heure mise à jour';

  @override
  String updateFailed(Object error) {
    return 'Échec de la mise à jour : $error';
  }

  @override
  String get locationUpdated => 'Localisation mise à jour';

  @override
  String get confirmDeleteCardMessage =>
      'Supprimer cette carte ? Cette action est irréversible.';

  @override
  String get cardDetailNotFound => 'Détail de carte introuvable';

  @override
  String get saySomething => 'Dites quelque chose...';

  @override
  String get relatedMemories => 'Mémoires liées';

  @override
  String get viewMore => 'Voir plus';

  @override
  String get relatedRecords => 'Enregistrements liés';

  @override
  String get reply => 'Répondre';

  @override
  String get replySent => 'Réponse envoyée';

  @override
  String get insightTemplateGalleryTitle => 'Modèles de cartes insight';

  @override
  String get timelineTemplateGalleryTitle => 'Modèles de cartes timeline';

  @override
  String get categoryTextual => 'Textuel';

  @override
  String get timelineFilterAll => 'TOUT';

  @override
  String get insights => 'Insights générés';

  @override
  String get memoryTitle => 'Mémoire';

  @override
  String get longTermProfile => 'Profil long terme';

  @override
  String get recentBuffer => 'Buffer récent';

  @override
  String errorLoadingMemory(Object error) {
    return 'Erreur de chargement de la mémoire : $error';
  }

  @override
  String get agentConfiguration => 'Configuration d\'agent';

  @override
  String get resetToDefaults => 'Réinitialiser par défaut';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Réinitialiser toutes les configurations d\'agents';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Voulez-vous vraiment réinitialiser toutes les configurations d\'agents à leurs valeurs par défaut ? Cette action est irréversible.';

  @override
  String get resetButton => 'Réinitialiser';

  @override
  String loadDataFailed(Object error) {
    return 'Échec du chargement des données : $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Échec de l\'enregistrement de la configuration : $error';
  }

  @override
  String get selectLlmClient => 'Sélectionner le LLM Client :';

  @override
  String get agentConfigurationsReset =>
      'Configurations d\'agents réinitialisées';

  @override
  String resetFailed(Object error) {
    return 'Échec de la réinitialisation : $error';
  }

  @override
  String get modelConfiguration => 'Configuration du modèle';

  @override
  String get resetAllConfigurationsTitle =>
      'Réinitialiser toutes les configurations';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Voulez-vous vraiment réinitialiser toutes les configurations de modèle à leurs valeurs par défaut ? Cette action est irréversible.';

  @override
  String get modelConfigurationsReset =>
      'Configurations de modèle réinitialisées';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Impossible de supprimer la configuration par défaut';

  @override
  String get cannotDeleteConfigurationTitle =>
      'Impossible de supprimer la configuration';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Cette configuration est actuellement utilisée par les agents suivants :\n\n$agentList\n\nVeuillez réassigner ces agents avant suppression.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Supprimer la configuration';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Voulez-vous vraiment supprimer \"$key\" ?';
  }

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get setAsDefault => 'Définir par défaut';

  @override
  String get invalidJsonInExtraField => 'JSON invalide dans le champ Extra';

  @override
  String get keyAlreadyExists => 'La clé existe déjà';

  @override
  String get resetConfigurationTitle => 'Réinitialiser la configuration';

  @override
  String get resetConfigurationMessage =>
      'Réinitialiser cette configuration à ses valeurs par défaut initiales ? Les changements actuels seront perdus.';

  @override
  String get configurationResetPressSave =>
      'Configuration réinitialisée. Appuyez sur Enregistrer pour appliquer.';

  @override
  String get addConfiguration => 'Ajouter une configuration';

  @override
  String get editConfiguration => 'Modifier la configuration';

  @override
  String get duplicateConfiguration => 'Dupliquer la configuration';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get keyIdLabel => 'ID de configuration';

  @override
  String get keyIdHelper =>
      'Nommez cette configuration, par exemple deepseek ou work-gpt.';

  @override
  String get required => 'Requis';

  @override
  String get clientLabel => 'Fournisseur de modèle';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Populaires';

  @override
  String get providerOpenAiApiKey => 'API Key';

  @override
  String get providerOpenAiResponses => 'API Key (mode Responses)';

  @override
  String get providerChatGptOauth => 'Compte ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API Key';

  @override
  String get providerBedrockSecret => 'Bedrock Secret key';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini via Google OAuth';

  @override
  String get providerKimi => 'Kimi par Moonshot';

  @override
  String get providerQwen => 'Fournisseur Aliyun';

  @override
  String get providerSeed => 'Fournisseur Volcengine';

  @override
  String get providerZhipu => 'Fournisseur Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama local';

  @override
  String get providerMimo => 'Fournisseur Xiaomi MIMO';

  @override
  String get providerMemex => 'Service proxy Memex';

  @override
  String get memexSignIn => 'Se connecter';

  @override
  String get memexCreateAccount => 'Créer un compte';

  @override
  String get memexUsername => 'Nom d\'utilisateur';

  @override
  String get memexPassword => 'Mot de passe';

  @override
  String get memexCreateAccountLink => 'Créer un compte';

  @override
  String get memexSignInLink => 'Se connecter plutôt';

  @override
  String get memexTopUp => 'Recharger pour commencer à utiliser Memex AI';

  @override
  String get memexTopUpSuccess => 'Recharge réussie !';

  @override
  String get memexFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get memexUsernameTooShort =>
      'Le nom d\'utilisateur doit contenir au moins 6 caractères';

  @override
  String get memexAuthFailed => 'Échec de l\'authentification';

  @override
  String get memexPaymentFailed => 'Échec de la création du paiement';

  @override
  String get memexLogout => 'Se déconnecter';

  @override
  String get memexTopUpButton => 'Recharger';

  @override
  String get memexTopUpChooseAmount => 'Choisir un montant';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Environ $range enregistrements';
  }

  @override
  String get memexTopUpPlanStarter => 'Plan Starter';

  @override
  String get memexTopUpPlanEveryday => 'Plan Everyday';

  @override
  String get memexTopUpPlanHighVolume => 'Plan High volume';

  @override
  String get memexTopUpPlanCustom => 'Crédits personnalisés';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Idéal pour essayer Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Idéal pour une organisation régulière';

  @override
  String get memexTopUpPlanHighVolumeSubtitle =>
      'Idéal pour des lots plus importants';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Saisissez USD 1-10 000';

  @override
  String get memexTopUpCustomEstimate =>
      'L\'estimation se base sur le montant saisi';

  @override
  String get memexCustomAmount => 'Montant personnalisé';

  @override
  String get memexViewHistory => 'Voir l\'historique d\'utilisation';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Solde : $amount';
  }

  @override
  String get memexConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get memexPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String memexPayAmount(Object amount) {
    return 'Recharger $amount';
  }

  @override
  String get modelIdLabel => 'Modèle';

  @override
  String get modelIdHelper => 'ex. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Récupération des modèles...';

  @override
  String get fetchModelsButton => 'Récupérer les modèles';

  @override
  String get enterApiKeyFirst =>
      'Saisissez d\'abord l\'API Key pour récupérer les modèles';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Endpoint API';

  @override
  String get advancedSettings => 'Paramètres avancés';

  @override
  String get testConnectionSuccess => 'Connexion réussie';

  @override
  String get testConnectionFailed => 'Connexion échouée';

  @override
  String get testTypeText => 'Texte';

  @override
  String get testTypeVision => 'Vision';

  @override
  String get testButton => 'Tester';

  @override
  String get testing => 'Test...';

  @override
  String get proxyUrlOptional => 'Proxy URL (facultatif)';

  @override
  String get proxyUrlHelper => 'ex. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Valeur Temperature';

  @override
  String get topPLabel => 'Valeur Top P';

  @override
  String get maxTokensLabel => 'Limite Max Tokens';

  @override
  String get extraParamsJson => 'Extra Params au format JSON';

  @override
  String get invalidJson => 'JSON invalide';

  @override
  String get warning => 'Configuration incomplète';

  @override
  String get invalidConfigurationWarning =>
      'La configuration n\'est pas encore complète (par ex. API Key ou Model ID manquant). Vous pouvez tout de même enregistrer et configurer plus tard. Continuer ?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" a besoin d\'une configuration de modèle valide (key: \"$configKey\") pour fonctionner. Vérifiez les paramètres de modèle.';
  }

  @override
  String get discardChangesTitle => 'Quitter cette page ?';

  @override
  String get discardChangesMessage =>
      'Si vous avez effectué des changements, enregistrez-les avant de partir.';

  @override
  String get discardButton => 'Ignorer';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get chooseAvatar => 'Choisir l\'avatar';

  @override
  String get configureNow => 'Configurer maintenant';

  @override
  String get modelNotConfiguredBanner =>
      'Modèle AI pas encore configuré. Configurez-le pour déverrouiller toutes les fonctionnalités.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Veuillez configurer un modèle AI avant de publier';

  @override
  String get processingStatus => 'Traitement';

  @override
  String get failedStatus => 'Échec';

  @override
  String get failureReason => 'Raison de l\'échec';

  @override
  String get unknownError => 'Une erreur inconnue est survenue';

  @override
  String get enableFitness => 'Activer Fitness';

  @override
  String get fitnessBannerMessage =>
      'Autorisez l\'accès fitness pour suivre vos données de santé et d\'activité.';

  @override
  String get fitnessDismissTitle => 'Ignorer l\'accès Fitness ?';

  @override
  String get fitnessDismissMessage =>
      'Sans permission fitness, l\'app ne pourra pas collecter automatiquement vos données de santé pour les insights et l\'auto-recording.';

  @override
  String get skipAnyway => 'Ignorer quand même';

  @override
  String get proModelHint =>
      'Ce modèle nécessite un abonnement ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase =>
      'Rechercher dans la base de connaissances...';

  @override
  String get searchKnowledgeHint =>
      'Saisissez un mot-clé pour rechercher des noms de fichiers ou du contenu';

  @override
  String noSearchResults(Object query) {
    return 'Aucun résultat trouvé pour \"$query\"';
  }

  @override
  String get onlyMarkdownPreview =>
      'Seul l\'aperçu Markdown est pris en charge';

  @override
  String get backupAndRestore => 'Sauvegarde et restauration';

  @override
  String get createBackup => 'Créer une sauvegarde';

  @override
  String get restoreBackup => 'Restaurer une sauvegarde';

  @override
  String get backupDescription =>
      'Regroupez toutes vos données (cartes, base de connaissances, insights, paramètres) dans un fichier .memex. Enregistrez-le sur iCloud Drive, Google Drive ou n\'importe quel emplacement via la feuille de partage.';

  @override
  String get restoreDescription =>
      'Sélectionnez un fichier de sauvegarde .memex pour restaurer toutes les données. Cela écrasera les données actuelles.';

  @override
  String get selectBackupFile => 'Sélectionner le fichier de sauvegarde';

  @override
  String get estimatedSize => 'Taille estimée';

  @override
  String get backupComplete => 'Sauvegarde créée';

  @override
  String backupFailed(Object error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get confirmRestore => 'Confirmer la restauration';

  @override
  String get confirmRestoreMessage =>
      'La restauration écrasera toutes les données actuelles, y compris cartes, base de connaissances, insights et paramètres. Cette action est irréversible. Continuer ?';

  @override
  String get restoreComplete => 'Restauration terminée';

  @override
  String get restoreRestartHint =>
      'Les données ont été restaurées. Veuillez redémarrer l\'app pour appliquer tous les changements.';

  @override
  String restoreFailed(Object error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get invalidBackupFile =>
      'Fichier de sauvegarde invalide. Sélectionnez un fichier .memex.';

  @override
  String get automaticBackup => 'Sauvegarde automatique';

  @override
  String get autoBackupDescription =>
      'Lorsque c\'est activé, Memex crée au maximum un snapshot local par jour après le démarrage ou le retour au premier plan.';

  @override
  String get backupSensitiveSettingsHint =>
      'Les sauvegardes incluent paramètres et clés de fournisseurs de modèles. Gardez les fichiers de sauvegarde dans un endroit fiable.';

  @override
  String get backupLocation => 'Emplacement';

  @override
  String get backupLocationDetails => 'Détails de l\'emplacement';

  @override
  String get backupLocationSummary => 'Affiché dans l\'app';

  @override
  String get backupLocationFullPath => 'Chemin complet';

  @override
  String get backupLocationUri => 'URI d\'accès au dossier';

  @override
  String get copyBackupLocationPath => 'Copier le chemin';

  @override
  String get backupLocationCopied => 'Emplacement de sauvegarde copié';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Dossier sélectionné : $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups folder';

  @override
  String get autoBackupStatus => 'Statut';

  @override
  String get noAutoBackupYet => 'Aucune sauvegarde automatique pour l\'instant';

  @override
  String lastBackupAt(Object time) {
    return 'Dernière sauvegarde : $time';
  }

  @override
  String get autoBackupRetention => 'Rétention';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days jours';
  }

  @override
  String get autoBackupRetentionForever => 'Conserver pour toujours';

  @override
  String get autoBackupMaxSize => 'Limite de stockage';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Le nettoyage automatique garde les snapshots automatiques sous $size. Les snapshots de sécurité et exports manuels sont conservés séparément.';
  }

  @override
  String get createSnapshotNow => 'Sauvegarder maintenant';

  @override
  String get backupLocationMenu => 'Changer l\'emplacement';

  @override
  String get defaultBackupLocation => 'Dossier de sauvegarde par défaut';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Utilisez le dossier de fichiers externes propre à Memex. Aucune permission de stockage requise.';

  @override
  String get chooseBackupLocation => 'Choisir un dossier de sauvegarde';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Choisissez un dossier avec le sélecteur système Android et accordez à Memex un accès persistant.';

  @override
  String get storedBackups => 'Sauvegardes stockées';

  @override
  String get noStoredBackups =>
      'Les sauvegardes automatiques apparaîtront ici après le premier snapshot.';

  @override
  String get backupTypeAutoSnapshot => 'Snapshot automatique';

  @override
  String get backupTypeSafetySnapshot => 'Snapshot de sécurité';

  @override
  String get backupTypeManualBackup => 'Sauvegarde manuelle';

  @override
  String get refresh => 'Actualiser';

  @override
  String get restoreThisBackup => 'Restaurer cette sauvegarde';

  @override
  String get deleteThisBackup => 'Supprimer cette sauvegarde';

  @override
  String get confirmDeleteBackup => 'Supprimer la sauvegarde ?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Supprimer $fileName ? Cela supprime le fichier de sauvegarde stocké et ne peut pas être annulé.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Sauvegarde supprimée : $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Impossible de supprimer la sauvegarde : $error';
  }

  @override
  String get creatingSafetySnapshot => 'Création du snapshot de sécurité...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Snapshot créé : $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Impossible de mettre à jour l\'emplacement de sauvegarde : $error';
  }

  @override
  String get backupImportCreatedAt => 'Créé';

  @override
  String get backupImportSourceVersion => 'Version source';

  @override
  String get backupImportFlavor => 'Build';

  @override
  String get backupLegacyFormat => 'Sauvegarde legacy (sans manifest)';

  @override
  String get restoreInProgress => 'Restauration de la sauvegarde...';

  @override
  String get dataStorage => 'Stockage des données';

  @override
  String get dataStorageDescriptionAndroid =>
      'Choisissez un dossier personnalisé pour stocker votre workspace. Les données restent après réinstallation de l\'app.';

  @override
  String get dataStorageDescriptionIOS =>
      'Activez iCloud pour synchroniser votre workspace entre appareils et garder les données après réinstallation.';

  @override
  String get storageLocationApp => 'Stockage de l\'app';

  @override
  String get storageLocationAppDesc =>
      'Les données sont stockées dans l\'app et seront supprimées à la désinstallation.';

  @override
  String get storageLocationCustom =>
      'Stockage de l\'appareil (dossier personnalisé)';

  @override
  String get storageLocationCustomDesc =>
      'Stockez les données dans un dossier de votre choix. Elles persistent après réinstallation si le dossier reste.';

  @override
  String get storageLocationICloud => 'Stocker dans iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Synchronisez votre workspace entre appareils Apple. Les données restent après réinstallation.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Actuel : $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Connectez-vous à iCloud et activez iCloud Drive pour utiliser le stockage iCloud.';

  @override
  String get loadingFromICloud => 'Restauration des données depuis iCloud…';

  @override
  String get switchingToICloud => 'Passage au stockage iCloud…';

  @override
  String get switchingStorage => 'Changement de stockage…';

  @override
  String get customFolderAccessDenied =>
      'Impossible de lire ou écrire dans ce dossier. Accordez la permission de stockage ou choisissez un autre emplacement.';

  @override
  String get configured => 'Configuré';

  @override
  String get apiKeyNotSet => 'API Key non définie — touchez pour configurer';

  @override
  String get bottomNavTimeline => 'Onglet Timeline';

  @override
  String get bottomNavLibrary => 'Bibliothèque';

  @override
  String get aiGeneratedLabel => 'Généré par AI';

  @override
  String sourceTraceWithCount(Object count) {
    return 'TRACE SOURCE ($count)';
  }

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountDesc =>
      'Supprimer définitivement toutes les données locales et réinitialiser l\'app.';

  @override
  String get deleteAccountConfirmTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountConfirmMessage =>
      'Cela supprimera définitivement toutes vos données, y compris cartes de timeline, base de connaissances, enregistrements et paramètres. Cette action est irréversible.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Tapez \"$name\" pour confirmer';
  }

  @override
  String get deleteAccountTypeHint =>
      'Saisissez votre nom d\'utilisateur pour confirmer';

  @override
  String get llmConsentTitle => 'Consentement au partage des données';

  @override
  String llmConsentMessage(Object provider) {
    return 'Pour activer les fonctionnalités AI, Memex doit envoyer vos données à $provider pour traitement. Cela inclut :\n\n• Le texte que vous saisissez (notes, transcriptions vocales)\n• Les métadonnées photo et le texte extrait (OCR)\n• Les résumés santé et fitness\n• Le contenu des cartes de timeline\n\nVos données sont envoyées directement de votre appareil à $provider. Memex ne stocke ni ne relaie vos données via aucun autre serveur.\n\nVeuillez consulter la politique de confidentialité de $provider pour savoir comment vos données sont traitées.\n\nAcceptez-vous d\'envoyer vos données à $provider pour le traitement AI ?';
  }

  @override
  String get llmConsentAgree => 'J\'accepte';

  @override
  String get llmConsentDecline => 'Refuser';

  @override
  String get customAgents => 'Agents personnalisés';

  @override
  String get noCustomAgents => 'Aucun agent personnalisé configuré.';

  @override
  String get deleteAgent => 'Supprimer l\'agent';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Supprimer l\'agent personnalisé \"$name\" ?';
  }

  @override
  String get deleted => 'Supprimé';

  @override
  String get saved => 'Enregistré';

  @override
  String get newAgent => 'Nouvel agent';

  @override
  String get editAgent => 'Modifier l\'agent';

  @override
  String get agentName => 'Nom de l\'agent';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Requis';

  @override
  String get agentNameInvalid => 'Lettres, chiffres et tirets uniquement';

  @override
  String get agentNameExists => 'Le nom existe déjà';

  @override
  String get hostAgentType => 'Type d\'agent hôte';

  @override
  String get skillDirectory => 'Dossier de skill';

  @override
  String get skillDirInvalid =>
      'Doit être un chemin relatif (pas de / initial ni ..)';

  @override
  String get workingDirectory => 'Dossier de travail (facultatif)';

  @override
  String get workingDirectoryHint =>
      'Laissez vide pour le workspace par défaut';

  @override
  String get llmConfig => 'Configuration LLM';

  @override
  String get eventType => 'Type d\'événement';

  @override
  String get executionMode => 'Mode d\'exécution';

  @override
  String get executionModeAsync => 'Asynchrone';

  @override
  String get executionModeSync => 'Synchrone';

  @override
  String get dependsOn => 'Dépend de';

  @override
  String get dependsOnHint => 'Sélectionner les dépendances';

  @override
  String get priority => 'Priorité';

  @override
  String get maxRetries => 'Tentatives max';

  @override
  String get systemPromptLabel => 'System Prompt (facultatif)';

  @override
  String get systemPromptHint =>
      'Instructions supplémentaires ajoutées au prompt de l\'agent hôte';

  @override
  String get eventSerializer => 'Event Serializer réglage';

  @override
  String get eventSerializerDefault => 'Default serializer (XML)';

  @override
  String get enabledLabel => 'Activé';

  @override
  String get skillsManagement => 'Gestion des skills';

  @override
  String get skillsManagementEmpty => 'Aucune skill pour l\'instant';

  @override
  String get downloadSkill => 'Télécharger la skill';

  @override
  String get downloadFile => 'Télécharger le fichier';

  @override
  String get downloading => 'Téléchargement...';

  @override
  String get downloadSuccess => 'Skill téléchargée avec succès';

  @override
  String downloadFailed(Object error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get deleteConfirm => 'Confirmer la suppression';

  @override
  String deleteConfirmMessage(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get invalidUrl => 'Veuillez saisir une URL valide';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Nouveau dossier';

  @override
  String get newFile => 'Nouveau fichier';

  @override
  String get folderName => 'Nom du dossier';

  @override
  String get fileName => 'Nom du fichier';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get nameInvalid => 'Le nom ne peut pas contenir / ou ..';

  @override
  String createFailed(Object error) {
    return 'Échec de la création : $error';
  }

  @override
  String get fileContent => 'Contenu du fichier';

  @override
  String get saveSuccess => 'Enregistré avec succès';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Le zip sera extrait dans le dossier actuel : $dir';
  }

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicyDesc => 'Comment Memex traite vos données';

  @override
  String get llmAuthError =>
      'Échec d\'authentification API. Vérifiez votre configuration LLM dans les Paramètres.';

  @override
  String get llmBadRequestError =>
      'La requête a été rejetée par le fournisseur LLM. Le format d\'entrée n\'est peut-être pas pris en charge par le modèle actuel.';

  @override
  String get llmRateLimitError =>
      'Limite de taux API dépassée. Veuillez réessayer plus tard.';

  @override
  String get llmServerError =>
      'Le service LLM est temporairement indisponible. Veuillez réessayer plus tard.';

  @override
  String get llmNetworkError =>
      'Échec de la connexion réseau. Vérifiez votre connexion Internet.';

  @override
  String get llmUnknownError =>
      'Une erreur inattendue est survenue pendant le traitement de votre contenu.';

  @override
  String get llmErrorDialogTitle => 'Traitement échoué';

  @override
  String get goToModelConfig => 'Aller aux Paramètres';

  @override
  String get speechModelDownloadTitle => 'Télécharger le modèle vocal';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Un téléchargement unique du modèle (~${sizeMB}MB) est requis.\n\nUne fois téléchargée, la transcription s\'exécute entièrement sur l\'appareil.';
  }

  @override
  String get speechModelStartDownload => 'Démarrer le téléchargement';

  @override
  String get speechModelChooseSource => 'Choisir la source de téléchargement :';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (plus rapide en CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (source globale)';

  @override
  String get speechModelDownloading => 'Téléchargement du modèle...';

  @override
  String get speechModelConnecting => 'Connexion...';

  @override
  String get deleteSpeechModel => 'Supprimer le modèle vocal';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Supprimer les fichiers du modèle local de reconnaissance vocale téléchargé ? Ils seront téléchargés à nouveau la prochaine fois que local speech-to-text sera utilisé.';

  @override
  String get speechModelDeletedSuccess => 'Fichiers du modèle vocal supprimés';

  @override
  String get speechModelNotDownloaded =>
      'Aucun fichier de modèle vocal téléchargé trouvé';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Échec de la suppression des fichiers du modèle vocal : $error';
  }

  @override
  String get speechTranscribing => 'Reconnaissance...';

  @override
  String get speechNoResult => 'Aucune parole détectée';

  @override
  String get useLocalSpeechToTextTitle => 'Utiliser speech to text local';

  @override
  String get useLocalSpeechToTextDesc =>
      'Lorsque c\'est activé, l\'audio est transcrit sur l\'appareil avant envoi — utile pour les modèles qui ne prennent pas en charge l\'entrée audio. Désactivé, l\'audio original est envoyé directement au modèle.';

  @override
  String get pendingAiProcessingHint => 'Configurer un modèle AI pour traiter';

  @override
  String get demoWelcome =>
      'Bienvenue dans Memex !\nFaisons un rapide tour de ce que l\'AI peut faire pour vos enregistrements.';

  @override
  String get demoTapAdd =>
      'Touchez ici pour créer votre premier enregistrement';

  @override
  String get demoTapSend => 'Touchez pour envoyer votre premier enregistrement';

  @override
  String get demoTapCard =>
      'Touchez pour voir comment AI a organisé votre enregistrement';

  @override
  String get demoDetailHint =>
      'Voici le détail de votre enregistrement organisé par l\'AI. Parcourez-le, puis revenez pour continuer la visite.';

  @override
  String get demoTapInsight => 'Touchez pour voir les insights générés par AI';

  @override
  String get demoTapInsightUpdate =>
      'Touchez pour générer des insights depuis vos enregistrements';

  @override
  String get demoTapKnowledge =>
      'Consultez vos fichiers de connaissance organisés automatiquement';

  @override
  String get demoDone => 'Commencez à enregistrer votre vie.';

  @override
  String get demoStartTour => 'Démarrer le tour';

  @override
  String get demoGetStarted => 'Commencer';

  @override
  String get demoSkip => 'Ignorer';

  @override
  String get demoPrefillText =>
      'Bonjour Memex ! Ceci est mon premier enregistrement 🎉';

  @override
  String get visionBadge => 'Vision';

  @override
  String get notMultimodalHint =>
      'Memex dépend des capacités multimodales des modèles pour l\'analyse média. Si vos enregistrements contiennent des images, assurez-vous que le modèle configuré prend en charge l\'entrée image.';

  @override
  String get defaultModelPrefix => 'Par défaut';

  @override
  String get recommendedBadge => 'Recommandé';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Changer de compagnon';

  @override
  String get personaChatInputHint => 'Tapez un message...';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

  @override
  String get showInsightTextTitle => 'Afficher le commentaire insight de Memex';

  @override
  String get showInsightTextDesc =>
      'Indique s\'il faut afficher l\'insight Memex comme commentaire épinglé dans la section commentaires du détail de la carte.';

  @override
  String get enableCharacterCommentTitle =>
      'Commentaire automatique des personnages';

  @override
  String get enableCharacterCommentDesc =>
      'Les personnages commentent automatiquement les nouveaux enregistrements.';

  @override
  String get maxCommentCharactersTitle =>
      'Nombre max de personnages commentateurs';

  @override
  String get maxCommentCharactersDesc =>
      'Combien de personnages peuvent commenter chaque enregistrement.';

  @override
  String replyTo(String name) {
    return 'Répondre à $name';
  }

  @override
  String get cdnSignalsComments => 'Nouvelle réponse reçue';

  @override
  String get cdnSignalsInsight => 'Nouvel insight généré';

  @override
  String get cdnSignalsBoth => 'Nouvelle réponse et nouvel insight';

  @override
  String get untitledCard => 'Carte sans titre';

  @override
  String get locationContextTitle => 'Contexte de localisation';

  @override
  String get locationContextDescription =>
      'Contexte de ville et quartier actuels pour le chat avec agent';

  @override
  String get locationContextAttachTitle =>
      'Joindre la localisation actuelle au chat';

  @override
  String get locationContextAttachDesc =>
      'Utilise le GPS de l\'appareil et le reverse geocoding pour fournir ville, district et quartier à l\'agent.';

  @override
  String get reverseGeocodingProvider => 'Fournisseur de reverse geocoding';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Valeur Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap utilise les coordonnées GCJ-02. Le GPS de l\'appareil est converti avant le reverse geocoding.';

  @override
  String get contextGranularity => 'Granularité du contexte';

  @override
  String get granularityCity => 'Ville';

  @override
  String get granularityDistrict => 'District niveau';

  @override
  String get granularityNeighborhood => 'Quartier';

  @override
  String get granularityStreet => 'Rue';

  @override
  String get granularityFullAddress => 'Candidat d\'adresse complète';

  @override
  String get locationFreshness => 'Fraîcheur de la localisation';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get oneHour => '1 heure';

  @override
  String get testCurrentLocation => 'Tester la localisation actuelle';

  @override
  String locationTestFailed(String error) {
    return 'Échec : $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Étape reverse geocode';

  @override
  String get locationDebugProvider => 'Fournisseur';

  @override
  String get locationDebugAgentContext => 'Contexte agent';

  @override
  String get locationDebugSource => 'Source donnée';

  @override
  String get locationDebugAddressSummary => 'Résumé de l\'adresse';

  @override
  String get locationDebugFullAddress => 'Adresse complète';

  @override
  String get locationDebugCoordinates => 'Coordonnées';

  @override
  String get locationDebugAccuracy => 'Précision';

  @override
  String get locationDebugReason => 'Raison';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'indisponible';

  @override
  String get locationDebugInjected => 'injecté';

  @override
  String get locationDebugNotInjected => 'non injecté';

  @override
  String get locationStatusUpdatedAt => 'Mis à jour';

  @override
  String get locationStatusSuccessTitle => 'La localisation actuelle est prête';

  @override
  String get locationStatusSuccessBody =>
      'Memex peut joindre ce résumé de localisation lorsque le contexte est pertinent.';

  @override
  String get locationStatusApproximateTitle =>
      'Localisation approximative uniquement';

  @override
  String get locationStatusApproximateBody =>
      'La précision semble être au niveau ville ou zone. Vous pouvez continuer à l\'utiliser, ou activer Precise Location dans les paramètres système pour un contexte plus précis.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'La localisation système est désactivée';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex utilise seulement le GPS de l\'appareil et n\'infère pas la localisation depuis le réseau ou l\'IP. Sur Android, ouvrez Location settings ; sur iOS, activez Settings > Privacy & Security > Location Services.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Permission de localisation nécessaire';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Autorisez Memex à utiliser la localisation pendant les tests ou lorsque le contexte de localisation est nécessaire. Always access n\'est pas demandé.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'Permission de localisation bloquée';

  @override
  String get locationStatusPermissionForeverBody =>
      'Ouvrez les paramètres de l\'app et autorisez la localisation pour Memex. Sur iOS, While Using the App suffit.';

  @override
  String get locationStatusDisabledTitle =>
      'Contexte de localisation désactivé';

  @override
  String get locationStatusDisabledBody =>
      'Activez le switch ci-dessus et enregistrez lorsque vous voulez que Memex joigne la localisation de l\'appareil au contexte de l\'agent.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS fonctionne, recherche d\'adresse échouée';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex a des coordonnées mais n\'injectera pas de contexte GPS-only dans l\'agent. Vérifiez le fournisseur de reverse geocoding et réessayez.';

  @override
  String get locationStatusUnavailableTitle => 'Localisation indisponible';

  @override
  String get locationStatusUnavailableBody =>
      'Vérifiez les services de localisation système et la permission de l\'app, puis testez à nouveau.';

  @override
  String get allowLocationPermissionButton => 'Autoriser la localisation';

  @override
  String get openAppSettingsButton => 'Ouvrir les paramètres de l\'app';

  @override
  String get openLocationSettingsButton =>
      'Ouvrir les paramètres de localisation';

  @override
  String get locationSettingsOpenFailed =>
      'Impossible d\'ouvrir les paramètres système.';

  @override
  String locationActionFailed(String error) {
    return 'Échec de l\'action de localisation : $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Rechercher dans les paramètres...';

  @override
  String get settingsSearchEmpty => 'Aucun paramètre correspondant trouvé';

  @override
  String get importCharacterCard => 'Importer Character Card';

  @override
  String get firstMessageLabel => 'Premier message';

  @override
  String get firstMessageHint =>
      'Salutation envoyée lors de la première conversation (facultatif)';

  @override
  String get systemPromptOverrideLabel => 'Override de System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'Remplacer le system prompt par défaut (avancé, facultatif)';

  @override
  String get postHistoryInstructionsLabel => 'Instructions post-historique';

  @override
  String get postHistoryInstructionsHint =>
      'Instructions injectées après l\'historique de chat et avant la réponse (facultatif)';

  @override
  String get mesExampleLabel => 'Exemples de messages';

  @override
  String get mesExampleHint =>
      'Dialogues exemples montrant le style du personnage (facultatif)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Connaissance de fond injectée lorsque des mots-clés sont déclenchés';

  @override
  String get characterMemoryTitle => 'Mémoire du personnage';

  @override
  String get characterMemorySubtitle =>
      'Dynamiques de relation et souvenirs d\'interaction entre personnage et utilisateur';

  @override
  String get addTooltip => 'Ajouter';

  @override
  String get constantBadge => 'Badge constant';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Entrée $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Mots-clés : $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Mémoire $index';
  }

  @override
  String get addWorldEntry => 'Ajouter une entrée World Book';

  @override
  String get editWorldEntry => 'Modifier une entrée World Book';

  @override
  String get commentTitleLabel => 'Commentaire / titre';

  @override
  String get entryDescriptionHint => 'Description de l\'entrée (facultatif)';

  @override
  String get triggerKeywordsLabel => 'Mots-clés déclencheurs';

  @override
  String get triggerKeywordsHint =>
      'Séparés par des virgules, ex. : magic, spell';

  @override
  String get contentLabel => 'Contenu';

  @override
  String get worldEntryContentHint =>
      'Connaissance de fond injectée lorsque les mots-clés se déclenchent';

  @override
  String get enabledCheckbox => 'Activé';

  @override
  String get addMemory => 'Ajouter une mémoire';

  @override
  String get editMemory => 'Modifier la mémoire';

  @override
  String get memoryLabelField => 'Libellé';

  @override
  String get memoryLabelHint => 'Identifiant unique, ex. : préférence de nom';

  @override
  String get memoryContentHint => 'Contenu de la mémoire';

  @override
  String get salienceLabel => 'Saillance : ';

  @override
  String get labelCannotBeEmpty => 'Le libellé ne peut pas être vide';

  @override
  String importSuccess(Object name) {
    return '$name importé avec succès';
  }

  @override
  String importFailed(Object error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get supportedFormats => 'Formats pris en charge';

  @override
  String get tavernImportDescription =>
      '• Cartes de personnage SillyTavern V2 (.json)\n• Images PNG avec cartes intégrées (.png)\n\nLes champs comme persona, world book, etc. seront automatiquement mappés au format de personnage Memex.';

  @override
  String get pickCharacterFile => 'Choisir un fichier de personnage';

  @override
  String get repickFile => 'Choisir un autre fichier';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book : $count entrées';
  }

  @override
  String fileLabel(Object filename) {
    return 'Fichier : $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Un personnage du même nom existe déjà : $names. L\'import créera un nouveau personnage sans écraser ceux qui existent.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Définir comme compagnon principal';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Le définir automatiquement comme compagnon principal après import';

  @override
  String get confirmImport => 'Confirmer l\'import';

  @override
  String get chatBackground => 'Fond du chat';

  @override
  String get chooseChatBackgroundImage => 'Choisir une image de fond';

  @override
  String get earlyUpdateSettingsTitle => 'Mises à jour Early access';

  @override
  String get earlyUpdateSettingsDesc =>
      'Vérifier les pre-releases GitHub pour l\'Early APK correspondant, le télécharger et le transmettre à l\'installateur Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Les mises à jour Early ne sont disponibles que dans le build Android Early.';

  @override
  String get earlyUpdateAutoCheckTitle =>
      'Vérifier automatiquement les mises à jour';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Vérifier au démarrage au maximum une fois toutes les 12 heures.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Télécharger uniquement en Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Ignorer les téléchargements de mise à jour avec données mobiles.';

  @override
  String get earlyUpdateAutoInstallTitle =>
      'Télécharger et installer automatiquement';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Lorsqu\'un nouveau build est trouvé, le télécharger et ouvrir automatiquement l\'installateur Android.';

  @override
  String get earlyUpdateCheckNow => 'Vérifier maintenant';

  @override
  String get earlyUpdateChecking => 'Vérification des GitHub pre-releases...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Ignoré car les téléchargements Wi-Fi-only sont activés.';

  @override
  String get earlyUpdateNoUpdate => 'Vous avez déjà le dernier Early build.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early build $version+$build disponible.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Télécharger et installer';

  @override
  String get earlyUpdateDownloadInProgress =>
      'Téléchargement de la mise à jour...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Téléchargement de la mise à jour : $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Paquet de mise à jour téléchargé. Prêt à installer.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Installer le paquet téléchargé';

  @override
  String get earlyUpdateClearDownloadedPackage =>
      'Effacer le paquet téléchargé';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Paquet de mise à jour téléchargé effacé.';

  @override
  String get earlyUpdateInstallStarted => 'Installateur Android ouvert.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Autorisez Memex à installer des apps inconnues, puis touchez télécharger et installer à nouveau.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Dernière vérification : $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Échec de la vérification de mise à jour : $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Mise à jour Early disponible';

  @override
  String get earlyUpdateReleaseNotes => 'Notes de version';

  @override
  String get dismissAllNotifications => 'Tout effacer';

  @override
  String get dismissByType => 'Effacer par type';

  @override
  String get dismissTypeSystemAction => 'Rappels et événements';

  @override
  String get dismissTypeClarification => 'Clarifications à effacer';

  @override
  String get dismissTypeCardUpdate => 'Mises à jour de cartes';

  @override
  String dismissedCount(Object count) {
    return '$count effacés';
  }

  @override
  String get dataImportTitle => 'Importer des fichiers';

  @override
  String get dataImportSettingsDescription =>
      'Ajoutez d\'anciens fichiers à Memex, puis décidez s\'il faut les organiser.';

  @override
  String get dataImportDescription =>
      'Choisissez d\'anciennes notes, des exports, des documents ou des archives ZIP. Memex enregistre d\'abord une copie et ne modifie pas les originaux. Vous pourrez ensuite décider si Memex doit vous aider à les organiser.';

  @override
  String get dataImportSelectFiles => 'Choisir les fichiers à importer';

  @override
  String get dataImportImporting => 'Enregistrement des fichiers...';

  @override
  String get dataImportSuccess => 'Fichiers enregistrés dans Memex';

  @override
  String get dataImportOnlyStored =>
      'Fichiers enregistrés. Aucune organisation lancée.';

  @override
  String get dataImportQueued => 'Memex organisera cet import en arrière-plan.';

  @override
  String get dataImportResultTitle => 'Import terminé';

  @override
  String dataImportResultSummary(Object count) {
    return '$count fichiers ont été enregistrés. Vous pouvez les organiser maintenant ou les garder comme source d\'origine.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count éléments portant le même nom ont été renommés pour éviter tout écrasement.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count éléments inhabituels de l\'archive ont été ignorés ; le reste a été importé normalement.';
  }

  @override
  String get dataImportChooseProcessing => 'Organiser ces fichiers';

  @override
  String get dataImportProcessTitle => 'Organiser cet import ?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Vous avez importé $count fichiers. Choisissez si Memex doit les organiser maintenant ou simplement conserver les originaux.';
  }

  @override
  String get dataImportProcessKnowledgeBase =>
      'Organiser dans la base de connaissances';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Idéal pour les documents, notes, ressources de projet et références. Memex extraira les informations utiles et les regroupera pour plus tard.';

  @override
  String get dataImportProcessTimelineCards =>
      'Créer des entrées de chronologie';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Idéal pour les journaux, discussions, historiques d\'activité et anciens exports. Memex transformera le contenu daté en entrées quand c\'est pertinent.';

  @override
  String get dataImportImpactNone =>
      'Memex conservera seulement ces fichiers originaux. Aucune organisation par IA ne sera lancée.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex lira ces fichiers et organisera les informations utiles à long terme dans la base de connaissances. Il ne créera pas d\'entrées de chronologie de lui-même.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex lira ces fichiers et créera des entrées de chronologie pour les événements ou historiques datés quand c\'est pertinent. Il n\'organisera pas la base de connaissances de lui-même.';

  @override
  String get dataImportImpactBoth =>
      'Memex essaiera de créer des entrées de chronologie et d\'organiser les informations réutilisables dans la base de connaissances. C\'est le meilleur choix pour une archive personnelle complète.';

  @override
  String get dataImportFinish => 'Seulement enregistrer';

  @override
  String get noImages => 'Aucune image';

  @override
  String get noMessages => 'Aucun message';

  @override
  String get sketchContent => 'Contenu du croquis';

  @override
  String get emptyFolder => 'Dossier vide';

  @override
  String get usernameAlreadyTaken => 'Ce nom d’utilisateur est déjà pris';

  @override
  String get registrationFailed => 'Échec de l’inscription';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get paymentCreationFailed => 'Impossible de lancer le paiement';

  @override
  String get completePayment => 'Finaliser le paiement';

  @override
  String get commentReplyToYou => 'Vous';

  @override
  String get commentAuthorUser => 'Utilisateur';

  @override
  String get commentAuthorAi => 'IA';

  @override
  String get authorizationCancelled => 'Autorisation annulée';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Semaine $week';
  }

  @override
  String get timelineWeekLabel => 'Semaine';

  @override
  String get eventCardDefaultTitle => 'Événement';

  @override
  String get memoryNoLongTermYet => 'Pas encore de souvenirs à long terme.';

  @override
  String get memoryNoRecentBuffer => 'Aucun souvenir récent dans le tampon.';

  @override
  String get memoryGeneralSubject => 'Général';

  @override
  String get debugging => 'Débogage';

  @override
  String get agentStates => 'États de l\'agent';

  @override
  String get logLevel => 'Niveau : ';

  @override
  String taskIdLabel(Object id) {
    return 'ID : $id';
  }

  @override
  String taskBizIdLabel(Object bizId) {
    return 'BizID : $bizId';
  }

  @override
  String taskStatusLabel(Object status) {
    return 'Statut : $status';
  }

  @override
  String taskScheduledLabel(Object date) {
    return 'Planifié : $date';
  }

  @override
  String taskCompletedLabel(Object date) {
    return 'Terminé : $date';
  }

  @override
  String get oauthCouldNotLaunchBrowser =>
      'Impossible de lancer le navigateur pour OAuth';

  @override
  String get authorizationTimedOut => 'Autorisation expirée';
}
