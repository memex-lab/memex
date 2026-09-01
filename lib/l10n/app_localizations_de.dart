// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get timesLabel => 'Mal';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Legen Sie $modelId als Standardmodell fest';
  }

  @override
  String get retry => 'Wiederholen';

  @override
  String get unknownModel => 'Unbekanntes Modell';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get confirmClear => 'Bestätigen Sie das Löschen';

  @override
  String get confirmClearTokenMessage =>
      'Aktuellen Benutzer löschen? Sie müssen die Benutzer-ID erneut eingeben.';

  @override
  String get cancel => 'Stornieren';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get tokenCleared => 'Benutzer gelöscht';

  @override
  String clearTokenFailed(Object error) {
    return 'Benutzer konnte nicht gelöscht werden: $error';
  }

  @override
  String get selectDateRangeOptional => 'Datumsbereich auswählen (optional):';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get select => 'Wählen';

  @override
  String get processLimitOptional => 'Prozesslimit (optional)';

  @override
  String get leaveEmptyForAll =>
      'Lassen Sie das Feld leer, um alles zu verarbeiten';

  @override
  String get startProcessing => 'Beginnen Sie mit der Verarbeitung';

  @override
  String get userIdNotFound => 'Benutzer-ID nicht gefunden';

  @override
  String createTaskFailed(Object error) {
    return 'Aufgabe konnte nicht erstellt werden: $error';
  }

  @override
  String get reprocessCards => 'Karten neu verarbeiten';

  @override
  String get reprocessCardsTaskCreated =>
      'Die Aufgabe „Karten erneut verarbeiten“ wurde erstellt und läuft im Hintergrund';

  @override
  String get reprocessCardsDownstreamMode => 'Downstream-Wiederholung';

  @override
  String get reprocessCardsCardOnly => 'Nur Karten neu generieren';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Standard. Erstellen Sie Karten-YAML/-Vorlagen neu, ohne nachgeschaltete Agenten zu berühren.';

  @override
  String get reprocessCardsRerunDownstream =>
      'Führen Sie auch Downstream-Agents erneut aus';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Bitten Sie Super Agent, bei Bedarf auch zugehörige PKM- und Insight-Aktualisierungen zu berücksichtigen.';

  @override
  String get reanalyzeMediaAssets => 'Analysieren Sie Medienressourcen erneut';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Aktualisiert Medienanalysedateien vor der Neugenerierung von Karten.';

  @override
  String get regenerateComments => 'Kommentare neu generieren';

  @override
  String get regenerateCommentsTaskCreated =>
      'Die Aufgabe „Kommentare neu generieren“ wurde erstellt und läuft im Hintergrund';

  @override
  String get rebuildSearchIndex => 'Suchindex neu erstellen';

  @override
  String get rebuildSearchIndexSuccess =>
      'Der Suchindex wurde erfolgreich neu erstellt';

  @override
  String get rebuildSearchIndexFailed =>
      'Der Suchindex konnte nicht neu erstellt werden';

  @override
  String get clearData => 'Daten löschen';

  @override
  String get confirmClearDataMessage => 'Daten löschen?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Alle lokalen Arbeitsbereichsdaten des aktuellen Benutzers werden gelöscht, einschließlich Karten, Medien, Wissensdateien, Erkenntnisse, Speicher, Chatverlauf und Systemstatus.\n\nDiese Aktion kann nicht rückgängig gemacht werden!';

  @override
  String get clearFailedAgentContexts =>
      'Löschen Sie den Kontext eines fehlgeschlagenen Gesprächs';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Den gespeicherten Konversationskontext für Insight- und Schedule-Agenten löschen? Dies ist nach einem Modellwechsel nützlich, wenn frühere Agentennachrichten nicht mehr kompatibel sind. Fakten, Karten, Wissen, Erinnerungen und Modelleinstellungen werden nicht gelöscht.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count gespeicherte(n) Konversationskontext(e) gelöscht';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Konversationskontext konnte nicht gelöscht werden: $error';
  }

  @override
  String get cloneToTestUser => 'In Testbenutzer klonen';

  @override
  String get confirmCloneToTestUserMessage =>
      'Kopiert den aktuellen Arbeitsbereich in einen neuen lokalen Testbenutzer und wechselt dorthin. Der Agent-Laufzeitstatus wird nicht kopiert. Ihre aktuellen Benutzerdaten werden nicht verändert.';

  @override
  String get testUserIdLabel => 'Testbenutzer-ID';

  @override
  String get testUserIdHelper =>
      'Verwenden Sie Buchstaben, Zahlen, Bindestrich oder Unterstrich.';

  @override
  String get testUserIdInvalid =>
      'Verwenden Sie nur Buchstaben, Zahlen, Bindestrich oder Unterstrich.';

  @override
  String get overwriteExistingTestUser =>
      'Vorhandenen Testbenutzer mit derselben ID ersetzen';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Zu Testbenutzer $userId gewechselt';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Testbenutzer konnte nicht geklont werden: $error';
  }

  @override
  String get dataClearedSuccess => 'Daten erfolgreich gelöscht';

  @override
  String clearDataFailed(Object error) {
    return 'Daten konnten nicht gelöscht werden: $error';
  }

  @override
  String get personalCenter => 'Persönliches Zentrum';

  @override
  String get viewLogs => 'Protokolle anzeigen';

  @override
  String get systemAuthorization => 'Systemautorisierung';

  @override
  String get aiCharacterConfig => 'KI-Charakterkonfiguration';

  @override
  String get modelConfig => 'Modellkonfiguration';

  @override
  String get agentConfig => 'Agentenkonfiguration';

  @override
  String get experimentalLab => 'Labore';

  @override
  String get experimentalLabDescription =>
      'Experimentelle Funktionen, die sich später ändern oder verschieben können.';

  @override
  String get modelUsageStats => 'Statistiken zur Modellnutzung';

  @override
  String get asyncTaskList => 'Asynchrone Aufgabenliste';

  @override
  String get clearLocalToken => 'Benutzer löschen';

  @override
  String get insightCardTemplates => 'Insight-Kartenvorlagen';

  @override
  String get timelineCardTemplates => 'Vorlagen für Zeitleistenkarten';

  @override
  String get logViewer => 'Protokollbetrachter';

  @override
  String get autoRefresh => 'Automatische Aktualisierung';

  @override
  String get lineCount => 'Zeilenanzahl:';

  @override
  String get all => 'Alle';

  @override
  String get schedule => 'Zeitplan';

  @override
  String get appLockConfig => 'App-Sperrkonfiguration';

  @override
  String loadStatsFailed(Object error) {
    return 'Statistiken konnten nicht geladen werden: $error';
  }

  @override
  String get overview => 'Überblick';

  @override
  String get daily => 'Täglich';

  @override
  String get modelStatsByAgent => 'Vom Agenten';

  @override
  String get detail => 'Details';

  @override
  String get date => 'Datum';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'Keine Daten';

  @override
  String get totalCalls => 'Gesamtanzahl der Anrufe';

  @override
  String get calls => 'Anrufe';

  @override
  String callsCount(Object count) {
    return '$count-Anrufe';
  }

  @override
  String get selectDateRange => 'Wählen Sie den Datumsbereich aus';

  @override
  String get totalTokens => 'Gesamtzahl der Token';

  @override
  String get cacheRate => 'Cache-Rate';

  @override
  String get promptTokens => 'Prompt-Token';

  @override
  String get completionTokens => 'Abschlusstoken';

  @override
  String get cachedTokens => 'Zwischengespeicherte Token';

  @override
  String get thoughtTokens => 'Gedankenmarken';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Fertigstellung';

  @override
  String get cached => 'Zwischengespeichert';

  @override
  String get thought => 'Gedanke';

  @override
  String get model => 'Modell';

  @override
  String get scene => 'Szene';

  @override
  String get sceneId => 'Szenen-ID';

  @override
  String get tokenUsage => 'Token-Nutzung';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'Modellaufschlüsselung';

  @override
  String get callDetails => 'Anrufdetails';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Datensatzdetails: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'LLM-Konfiguration konnte nicht gespeichert werden: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Die HTML-Vorschau ist im Web nicht verfügbar. Bitte auf dem Handy ansehen.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Benutzerinformationen konnten nicht gespeichert werden: $error';
  }

  @override
  String get totalEstimatedCost => 'Geschätzte Gesamtkosten';

  @override
  String get close => 'Schließen';

  @override
  String get totalTokenConsumption => 'Gesamter Tokenverbrauch';

  @override
  String get dataLoadFailedRetry =>
      'Das Laden der Daten ist fehlgeschlagen. Bitte versuchen Sie es später noch einmal.';

  @override
  String get timelineLoadFailedRetry =>
      'Das Laden der Zeitleiste ist fehlgeschlagen. Bitte versuchen Sie es später noch einmal.';

  @override
  String get newPerspective => 'Neue Perspektive';

  @override
  String get startPoint => 'Startpunkt';

  @override
  String get endPoint => 'Ende';

  @override
  String get originalInput => 'Ursprüngliche Eingabe';

  @override
  String get referenceContent => 'Referenzinhalt';

  @override
  String referenceWithTitle(Object title) {
    return 'Referenz: $title';
  }

  @override
  String get actionCenterTitle => 'Ausstehende Aktionen';

  @override
  String get noPendingActions => 'Keine ausstehenden Maßnahmen';

  @override
  String get clarificationNeeded => 'Memex will das bestätigen';

  @override
  String get clarificationTextHint => 'Geben Sie eine kurze Antwort ein';

  @override
  String get clarificationTextRequired =>
      'Fügen Sie zunächst eine kurze Antwort hinzu';

  @override
  String get clarificationAnswered => 'Beantwortet';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Antwort: $answer';
  }

  @override
  String get answerSaved => 'Antwort gespeichert';

  @override
  String get clarificationOtherAnswer => 'Manuelle Eingabe';

  @override
  String get clarificationNotSure =>
      'Ich bin mir nicht sicher / möchte es lieber nicht sagen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'NEIN';

  @override
  String get footprintMap => 'Fußabdruckkarte';

  @override
  String get waypointPlaces => 'Wegpunktorte';

  @override
  String get unknownPlace => 'Unbekannter Ort';

  @override
  String get releaseToSend => 'Zum Senden freigeben';

  @override
  String get selectFromAlbum => 'Aus Album auswählen';

  @override
  String get clipboardPreviewTitle => 'Neue Zwischenablage';

  @override
  String get clipboardPreviewImageTitle => 'Bild in der Zwischenablage';

  @override
  String get clipboardPreviewImageDescription => 'Bild kann hinzugefügt werden';

  @override
  String get clipboardPreviewUnprocessed => 'Noch nicht eingefügt';

  @override
  String get clipboardPreviewPasteToInput => 'In Eingabe einfügen';

  @override
  String get clipboardPreviewAddImageToInput => 'Bild hinzufügen';

  @override
  String get clipboardPreviewImageFailed =>
      'Das Bild in der Zwischenablage konnte nicht gelesen werden';

  @override
  String get tellAiWhatHappened => 'Sagen Sie der KI, was passiert ist ...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Aufnahme: $duration';
  }

  @override
  String get playing => 'Spielen...';

  @override
  String get sendLabel => 'Senden';

  @override
  String attachedImagesMessage(Object count) {
    return '$count Bild(er) gesendet';
  }

  @override
  String get noTaskData => 'Keine Aufgabendaten';

  @override
  String createdAtDate(Object date) {
    return 'Erstellt: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Aktualisiert: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Dauer: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Wiederholen: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Beim Laden der Details ist ein Fehler aufgetreten. Bitte versuchen Sie es später noch einmal.';

  @override
  String get loadFailed => 'Das Laden ist fehlgeschlagen';

  @override
  String loadHistoryFailed(Object error) {
    return 'Verlauf konnte nicht geladen werden: $error';
  }

  @override
  String get reload => 'Neu laden';

  @override
  String get aiInsightDetail => 'Insight-Detail';

  @override
  String relatedRecordsCount(Object count) {
    return 'Zugehörige Datensätze ($count)';
  }

  @override
  String get noRelatedRecords => 'Keine zugehörigen Datensätze';

  @override
  String get useFingerprintToUnlock =>
      'Verwenden Sie zum Entsperren den Fingerabdruck';

  @override
  String get locked => 'Gesperrt';

  @override
  String get wrongPassword => 'Falsches Passwort';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get memexLocked => 'Memex ist gesperrt';

  @override
  String get calendarShortSun => 'Sonne';

  @override
  String get calendarShortMon => 'Mo';

  @override
  String get calendarShortTue => 'Di';

  @override
  String get calendarShortWed => 'Heiraten';

  @override
  String get calendarShortThu => 'Do';

  @override
  String get calendarShortFri => 'Fr';

  @override
  String get calendarShortSat => 'Sa';

  @override
  String noRecordsOnDate(Object date) {
    return 'Keine Datensätze für $date';
  }

  @override
  String get footprintPath => 'Fußabdruckpfad';

  @override
  String get lifeCompositionTable => 'Lebenskomposition';

  @override
  String get emotionReframe => 'Emotionen neu definieren';

  @override
  String get chronicleOfThings => 'Chronik der Dinge';

  @override
  String get goalProgress => 'Zielfortschritt';

  @override
  String get trendChart => 'Trenddiagramm';

  @override
  String get comparisonChart => 'Vergleichstabelle';

  @override
  String get todayTimeFlow => 'Der heutige Zeitfluss';

  @override
  String get aiInputHint =>
      'Ob es Erinnerungen oder die Gegenwart sind, ich bin hier...';

  @override
  String get refreshSuperAgentStateTooltip => 'Memex-Agent-Kontext löschen';

  @override
  String get refreshSuperAgentStateTitle =>
      'Verlaufskontext des Memex-Agenten löschen?';

  @override
  String get refreshSuperAgentStateMessage =>
      'Der sichtbare Chatverlauf bleibt erhalten, aber der historische Laufzeitkontext des Memex-Agenten wird gelöscht und zukünftige Antworten starten mit einem frischen Kontext. Persistenter Speicher, Wissensdatenbankdateien, Karten und andere gespeicherte Daten sind nicht betroffen. Verwenden Sie dies, wenn sich der Memex-Agent weiterhin ungewöhnlich verhält. Fortfahren?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Warten Sie, bis die aktuelle Memex-Agent-Nachricht abgeschlossen ist, bevor Sie den Kontext löschen.';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex-Agent-Kontext gelöscht';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Memex-Agent-Kontext konnte nicht gelöscht werden: $error';
  }

  @override
  String get nothingHere => 'Hier ist noch nichts';

  @override
  String get nothingHereHint =>
      'Tippen Sie auf die Schaltfläche unten, um Ihre erste Karte zu erstellen';

  @override
  String get agentProcessing => 'KI verarbeitet...';

  @override
  String get keepAppOpen => 'Schließen Sie die App nicht';

  @override
  String get activityDetail => 'Aktivitätsdetails';

  @override
  String get noAgentActivityYet => 'Noch keine Agentenaktivität';

  @override
  String get processingEllipsis => 'Verarbeitung...';

  @override
  String get agentBackgroundTitle => 'Memex-Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex-Agent pausierte';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Der Memex-Agent braucht Aufmerksamkeit';

  @override
  String get agentBackgroundStageIdle => 'Leerlauf';

  @override
  String get agentBackgroundStageProcessing => 'Verarbeitung';

  @override
  String get agentBackgroundStageQueued => 'In der Warteschlange';

  @override
  String get agentBackgroundStageRetrying => 'Warte auf einen erneuten Versuch';

  @override
  String get agentBackgroundStagePaused => 'Angehalten';

  @override
  String get agentBackgroundStageCompleted => 'Vollendet';

  @override
  String get agentBackgroundStageNeedsAttention => 'Braucht Aufmerksamkeit';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Medien analysieren';

  @override
  String get agentBackgroundStageGeneratingCard => 'Karte generieren';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Wissen aktualisieren';

  @override
  String get agentBackgroundStagePreparingComment =>
      'Kommentar wird vorbereitet';

  @override
  String get agentBackgroundStageRoutingFollowUps =>
      'Weiterleitung von Folgemaßnahmen';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return '$running wird ausgeführt, $pending steht aus, $retrying erneut versuchen';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '$count-Aufgabe(n) in der Warteschlange werden verarbeitet.';
  }

  @override
  String get agentBackgroundNoTasks => 'Keine Hintergrundaufgaben.';

  @override
  String get agentBackgroundStarting => 'Die Verarbeitung beginnt.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Alle Hintergrundaufgaben abgeschlossen.';

  @override
  String get agentBackgroundFailedDetail =>
      'Die Verarbeitung wurde mit einem Fehler abgebrochen.';

  @override
  String get agentBackgroundPausedDetail =>
      'Die Verarbeitung wird angehalten und später fortgesetzt.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Warten auf den nächsten Bearbeitungsschritt.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Der aktuelle Schritt wird automatisch wiederholt.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Anhänge und lokalen Kontext lesen.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Verwandeln Sie die Aufzeichnung in eine Timeline-Karte.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Lokales Wissen und Gedächtnis aktualisieren.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Vorbereitung eines Assistenten-Follow-ups.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Folgeaktionen für diese Karte werden überprüft.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Angehalten – $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Benötigt Aufmerksamkeit – $summary';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get languageSettings => 'Sprache';

  @override
  String get languageSettingsDesc => 'Ändern Sie die Anzeigesprache der App';

  @override
  String get noPendingActionsToast => 'Keine ausstehenden Maßnahmen';

  @override
  String get knowledgeNewDiscovery => 'Wissen neue Entdeckung';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count neue Erkenntnisse entdeckt';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Aktualisierte $count vorhandene(n) Einblick(e)';
  }

  @override
  String get sectionNewInsights => 'Neue Erkenntnisse';

  @override
  String get sectionUpdatedInsights => 'Aktualisierte Erkenntnisse';

  @override
  String get unnamedInsight => 'Unbenannte Einsicht';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get copy => 'Kopie';

  @override
  String get selectedLocation => 'Ausgewählter Ort';

  @override
  String get confirmLocationName => 'Bestätigen Sie den Standortnamen';

  @override
  String get confirmLocationNameHint =>
      'Sie können den Namen bearbeiten (Koordinaten bleiben gleich)';

  @override
  String get nameLabel => 'Name';

  @override
  String get inputPlaceNameHint => 'Ortsnamen eingeben...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Koordinaten: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Standort bestätigen';

  @override
  String get welcomeToMemex => 'Willkommen bei Memex';

  @override
  String get createUserIdToStart => 'Erstellen Sie Ihr Profil';

  @override
  String get userIdLabel => 'Ihr Name/Spitzname';

  @override
  String get userIdHint => 'Geben Sie Ihren Namen oder Spitznamen ein';

  @override
  String get pleaseEnterUserId => 'Bitte geben Sie Ihren Namen ein';

  @override
  String get userIdMaxLength => 'Der Name darf 50 Zeichen nicht überschreiten';

  @override
  String get startUsing => 'Weitermachen';

  @override
  String get userIdTip =>
      'Dies wird verwendet, um Ihr Erlebnis zu personalisieren.';

  @override
  String get setupModelConfigTitle => 'Richten Sie ein KI-Modell ein';

  @override
  String get setupModelConfigSubtitle =>
      'Memex benötigt ein bahnbrechendes KI-Modell, um Aufzeichnungen zu organisieren, Bilder zu analysieren und Erkenntnisse zu generieren. Wählen Sie eine Verbindungsmethode.';

  @override
  String get setupModelConfigComplete => 'Abschließen und loslegen';

  @override
  String get aiService => 'Memex-Modellservice';

  @override
  String get aiModelHubTitle => 'KI-Modelle und -Dienste';

  @override
  String get aiModelHubSubtitle =>
      'Wählen Sie den offiziellen Service von Memex oder bringen Sie Ihren eigenen Anbieter mit. Das erweiterte Modellrouting bleibt verfügbar, wenn Sie es benötigen.';

  @override
  String get aiSetupCurrentStatusTitle => 'Aktuelles Setup';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'Der AI-Dienst ist nicht konfiguriert';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Wählen Sie eine Verbindungsmethode, um die KI-Organisation für Datensätze, Medien und Erkenntnisse zu ermöglichen.';

  @override
  String get aiSetupStatusMemexTitle =>
      'Nutzung des offiziellen MemeX-Dienstes';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex verwendet die offiziellen Verbindungs- und API-Anmeldeinformationen, die von Ihrem MemeX-Konto verwaltet werden.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Verwenden benutzerdefinierter Anbietereinstellungen';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex verwendet Ihre konfigurierten Anbieteranmeldeinformationen und Modellrollenauswahl.';

  @override
  String get aiSetupChooseConnectionTitle =>
      'Wählen Sie eine Verbindungsmethode';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Beginnen Sie mit dem Pfad, der der Art und Weise entspricht, wie Memex auf KI-Modelle zugreifen soll.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Melden Sie sich bei MemeX an und nutzen Sie den offiziellen Dienst, ohne sich für Anbieter, Schlüssel oder Modelle auf Agentenebene entscheiden zu müssen.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Fügen Sie Ihre eigenen Anbieteranmeldeinformationen hinzu, wählen Sie Text- und Visionsmodelle aus und überschreiben Sie optional Modelle pro Agent.';

  @override
  String get aiSetupCustomPageTitle => 'Benutzerdefinierter KI-Dienst';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Konfigurieren Sie zunächst die Anmeldeinformationen des Anbieters und wählen Sie dann die Text- und Bildmodelle aus, die Memex verwenden soll.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Anbieter- und API-Schlüssel';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Fügen Sie OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama oder einen anderen kompatiblen Anbieter hinzu oder bearbeiten Sie sie.';

  @override
  String get modelRolesTitle => 'Wählen Sie Modellrollen';

  @override
  String get modelRolesDescription =>
      'Die meisten Benutzer benötigen lediglich ein Textmodell und ein visionsfähiges Modell. Erweiterte Agentenüberschreibungen bleiben unten verfügbar.';

  @override
  String get textModelRoleTitle => 'Textmodell';

  @override
  String get textModelRoleDescription =>
      'Wird vom Super Agent für Text, Bilder, Karten, Wissen, Einblicke, Chat, Kommentare und Erinnerungen verwendet.';

  @override
  String get modelConnectionsTitle => 'Modellanbieter und API-Schlüssel';

  @override
  String get modelConnectionsDescription =>
      'Verbinden Sie den offiziellen Dienst von Memex oder fügen Sie Ihre eigenen Anbieter-Anmeldeinformationen hinzu.';

  @override
  String get relatedAiCapabilitiesTitle =>
      'Erweiterte und verwandte Funktionen';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Optimieren Sie Agentenzuweisungen, Standortanbieter und Sprachtranskriptionsverhalten.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Servicemöglichkeiten';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Wählen Sie die Anbieter aus, die Memex für angrenzende KI-gestützte Funktionen wie Sprache und umgekehrte Geokodierung nutzt.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Erweitertes Modellrouting';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Für Power-User, die möchten, dass einzelne Agenten unterschiedliche Anbieter oder Modellkonfigurationen verwenden.';

  @override
  String get locationProviderSettings => 'Standortanbieter';

  @override
  String get speechProviderSettings => 'Sprachtranskription';

  @override
  String get advancedAgentModelAssignments => 'Zuweisungen von Agentenmodellen';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Überschreiben Sie einzelne Agenten';

  @override
  String get noConfiguredModelOptions =>
      'Fügen Sie einen Anbieter oder API-Schlüssel hinzu, bevor Sie Modellrollen auswählen.';

  @override
  String get modelSlotUpdated => 'Modellrolle aktualisiert';

  @override
  String get aiServiceMemexRouteTitle => 'Verbinden Sie sich über Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex verwendet ein Multi-Agenten-System, um Lebensaufzeichnungen, Wissensnotizen und sozialen Kontext zu organisieren, tiefere Erkenntnisse zu gewinnen und KI-Begleitung mit dauerhaftem Gedächtnis bereitzustellen. Ihre Daten werden als Klartext-Markdown gespeichert, wodurch die Datenfreiheit und -portabilität gewahrt bleibt.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Ich habe einen API-Schlüssel';

  @override
  String get aiServiceCustomModelDescription =>
      'Wählen Sie dies zuerst, wenn Sie bereits einen API-Schlüssel von OpenAI, Anthropic, DeepSeek, Gemini oder einem anderen Anbieter haben.';

  @override
  String get enableAiService => 'Verbinden Sie sich mit Memex';

  @override
  String get aiServiceReadyToast => 'Die KI-Organisation läuft';

  @override
  String get aiServiceSettingsDescription =>
      'Wenn Sie keinen API-Schlüssel haben, verwenden Sie ein Memex-Konto, um eine Verbindung zu gängigen Modelldiensten herzustellen.';

  @override
  String get advancedModelConfiguration => 'API-Schlüssel konfigurieren';

  @override
  String get skipForNow => 'Überspringen Sie es vorerst';

  @override
  String get clearAuth => 'Authentifizierung löschen';

  @override
  String get authorizing => 'Autorisierung...';

  @override
  String authFailed(Object error) {
    return 'Authentifizierung fehlgeschlagen: $error';
  }

  @override
  String get authorized => 'Autorisiert';

  @override
  String authorizedAs(Object email) {
    return 'Autorisiert als $email';
  }

  @override
  String get authorizedSuccessfully => 'Erfolgreich autorisiert';

  @override
  String get reAuthorize => 'Erneut autorisieren';

  @override
  String get authorizeWithOpenAi => 'Mit OpenAI autorisieren';

  @override
  String get authorizeWithGoogle => 'Mit Google autorisieren';

  @override
  String get config => 'Konfig';

  @override
  String get calendar => 'Kalender';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get writeToSystemFailed =>
      'Das Schreiben in das System ist fehlgeschlagen';

  @override
  String permissionRequired(Object name) {
    return '$name-Berechtigung erforderlich';
  }

  @override
  String permissionRationale(Object name) {
    return 'Bitte erlauben Sie der App in den Einstellungen den Zugriff auf Ihr $name, damit wir es für Sie erstellen können.';
  }

  @override
  String get goToSettings => 'Gehen Sie zu Einstellungen';

  @override
  String get unknownAction => 'Unbekannte Aktion';

  @override
  String get discoveredCalendarEvent => 'Kalenderereignis gefunden';

  @override
  String get discoveredReminder => 'Erinnerung gefunden';

  @override
  String get addToCalendar => 'Zum Kalender hinzufügen';

  @override
  String get addToReminders => 'Zu Erinnerungen hinzufügen';

  @override
  String get systemActionPendingExplanation =>
      'Noch nicht hinzugefügt. Tippe unten, um die Berechtigung anzufordern und den Eintrag zu deinem Gerät hinzuzufügen.';

  @override
  String addedToSuccess(Object target) {
    return 'Erfolgreich zu $target hinzugefügt';
  }

  @override
  String get ignore => 'Ignorieren';

  @override
  String get confirmDelete => 'Bestätigen Sie das Löschen';

  @override
  String get confirmDeleteSessionMessage =>
      'Diese Konversation löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteSuccess => 'Erfolgreich gelöscht';

  @override
  String deleteFailed(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String daysAgo(Object count) {
    return 'Vor $count Tagen';
  }

  @override
  String get chatHistory => 'Chatverlauf';

  @override
  String get enterFullScreenTooltip => 'Geben Sie den Vollbildmodus ein';

  @override
  String get exitFullScreenTooltip => 'Verlassen Sie den Vollbildmodus';

  @override
  String get noConversations => 'Keine Gespräche';

  @override
  String loadSessionListFailed(Object error) {
    return 'Sitzungsliste konnte nicht geladen werden: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Gestern $time';
  }

  @override
  String get newChat => 'Neuer Chat';

  @override
  String messageCount(Object count) {
    return '$count-Nachrichten';
  }

  @override
  String get organize => 'Organisieren';

  @override
  String get pkmCategoryProject => 'Projekt';

  @override
  String get pkmCategoryProjectSubtitle => 'Kurzfristig · Ziele · Fristen';

  @override
  String get pkmCategoryArea => 'Bereich';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Langfristig · Verantwortung · Standards';

  @override
  String get pkmCategoryResource => 'Ressource';

  @override
  String get pkmCategoryResourceSubtitle =>
      'Interessen · Inspiration · Reserve';

  @override
  String get pkmCategoryArchive => 'Archiv';

  @override
  String get pkmCategoryArchiveSubtitle => 'Fertig · Ruhend · Referenz';

  @override
  String get recentChanges => 'Aktuelle Änderungen';

  @override
  String get noRecentChangesInThreeDays =>
      'Keine Änderungen in den letzten 3 Tagen';

  @override
  String get unpinned => 'Nicht angepinnt';

  @override
  String get pinnedStyle => 'Stil angepinnt';

  @override
  String operationFailed(Object error) {
    return 'Vorgang fehlgeschlagen: $error';
  }

  @override
  String get refreshingInsightData =>
      'Die Insight-Daten werden aktualisiert. Dies kann einen Moment dauern ...';

  @override
  String refreshFailed(Object error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get sortUpdated => 'Sortierreihenfolge aktualisiert';

  @override
  String sortSaveFailed(Object error) {
    return 'Sortierung konnte nicht gespeichert werden: $error';
  }

  @override
  String get insightCardDeleted => 'Insight-Karte gelöscht';

  @override
  String deleteFailedShort(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get knowledgeInsight => 'Wissenseinsicht';

  @override
  String get completeSort => 'Vollständige Sortierung';

  @override
  String get noKnowledgeInsight => 'Kein Wissenseinblick';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count-Hintergrundaufgaben werden noch verarbeitet.';
  }

  @override
  String get insightUnavailableMessage =>
      'Diese Erkenntnis wird noch generiert oder wurde aktualisiert. Aktualisieren Sie Ihre Erkenntnisse und versuchen Sie es später noch einmal.';

  @override
  String get artifactOpen => 'Offen';

  @override
  String get updating => 'Aktualisierung...';

  @override
  String get update => 'Aktualisieren';

  @override
  String get enabled => 'Ermöglicht';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get appLockOn => 'App-Sperre aktiviert';

  @override
  String get appLockOff => 'App-Sperre deaktiviert';

  @override
  String get enableAppLockFirst => 'Bitte aktivieren Sie zuerst die App-Sperre';

  @override
  String get enterFourDigitPassword => 'Geben Sie ein 4-stelliges Passwort ein';

  @override
  String get passwordSetAndLockOn =>
      'Passwort festgelegt und App-Sperre aktiviert';

  @override
  String get appLockSettings => 'Einstellungen für die App-Sperre';

  @override
  String get enableAppLock => 'App-Sperre aktivieren';

  @override
  String get enableAppLockSubtitle =>
      'Beim Starten der App ist ein Passwort erforderlich';

  @override
  String get enableBiometrics => 'Biometrische Daten aktivieren';

  @override
  String get biometricsSubtitle =>
      'Verwenden Sie zum Entsperren Face ID oder Touch ID';

  @override
  String get changePassword => 'Kennwort ändern';

  @override
  String get setFourDigitPassword => 'Legen Sie ein 4-stelliges Passwort fest';

  @override
  String get reenterPasswordToConfirm =>
      'Geben Sie das Passwort zur Bestätigung erneut ein';

  @override
  String get passwordMismatch =>
      'Passwörter stimmen nicht überein. Bitte versuchen Sie es erneut.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Zeichen „$name“ löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get configureAiCharacter => 'KI-Charakter konfigurieren';

  @override
  String get addCharacter => 'Charakter hinzufügen';

  @override
  String get addCharacterSubtitle =>
      'Wählen Sie KI-Charaktere aus, um Ihrem Insight-Team beizutreten. Sie analysieren Ihre Lebensdaten aus verschiedenen Blickwinkeln.';

  @override
  String get noCharacters => 'Keine Charaktere';

  @override
  String loadCharacterFailed(Object error) {
    return 'Fehler beim Laden der Zeichen: $error';
  }

  @override
  String get noTags => 'Keine Tags';

  @override
  String get createSuccess => 'Erfolgreich erstellt';

  @override
  String get updateSuccess => 'Erfolgreich aktualisiert';

  @override
  String saveFailed(Object error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get newCharacter => 'Neuer Charakter';

  @override
  String get editCharacter => 'Charakter bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get characterName => 'Charaktername';

  @override
  String get characterNameHint => 'Geben Sie Ihrem Charakter einen Namen';

  @override
  String get pleaseEnterCharacterName =>
      'Bitte geben Sie den Charakternamen ein';

  @override
  String get tagsLabel => 'Schlagworte';

  @override
  String get tagsHint =>
      'z.B. Weisheit, Anerkennung, Makro\nTrennen Sie mehrere Tags durch Kommas';

  @override
  String get characterPersonaLabel => 'Charakterpersönlichkeit';

  @override
  String get characterPersonaHint =>
      'Fügen Sie Persona, Styleguide, Beispieldialog, Wissensfilter usw. hinzu.\nVerwenden Sie ## für Abschnittsüberschriften.';

  @override
  String get pleaseEnterCharacterPersona =>
      'Bitte geben Sie die Persona des Charakters ein';

  @override
  String permissionRequestError(Object error) {
    return 'Fehler bei der Berechtigungsanforderung: $error';
  }

  @override
  String get permissionRequiredTitle => 'Erlaubnis erforderlich';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Sie haben diese Berechtigung dauerhaft verweigert oder das System verlangt sie. Bitte aktivieren Sie es in den Systemeinstellungen.';

  @override
  String get getting => 'Erhalten...';

  @override
  String get unauthorized => 'Nicht autorisiert';

  @override
  String get authorizedGoToSettings =>
      'Autorisiert. Gehen Sie zum Ändern zu den Systemeinstellungen.';

  @override
  String get location => 'Standort';

  @override
  String get locationPermissionReason =>
      'Zur Aufnahme von Orten und ortsbezogenen Merkmalen';

  @override
  String get photos => 'Fotos';

  @override
  String get photosPermissionReason =>
      'Zum Auswählen von Fotos, Speichern generierter Bilder usw.';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraPermissionReason => 'Zum Aufnehmen von Fotos und Videos';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get microphonePermissionReason => 'Für Spracherkennung, Aufnahme usw.';

  @override
  String get calendarPermissionReason =>
      'Zum Aufzeichnen von Terminen und Lesen von Kalenderereignissen';

  @override
  String get remindersPermissionReason =>
      'Zum Aufzeichnen und Lesen Ihrer Erinnerungen';

  @override
  String get fitnessAndMotion => 'Fitness & Bewegung';

  @override
  String get fitnessPermissionReason =>
      'Zur Aufzeichnung von Gesundheits- und Bewegungsdaten';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String get notificationPermissionReason =>
      'Zum Versenden von Terminplänen und wichtigen Erinnerungen';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Memex Agent im Hintergrund weiter ausführen';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent läuft lokal auf deinem Gerät. Mit Benachrichtigungen kann Memex den Fortschritt anzeigen und weiterarbeiten, nachdem du die App verlässt oder den Bildschirm ausschaltest. Wenn Benachrichtigungen deaktiviert sind, lasse Memex im Vordergrund geöffnet, bis die Aufgabe abgeschlossen ist.';

  @override
  String get loadDetailFailedRetryShort =>
      'Beim Laden der Details ist ein Fehler aufgetreten. Bitte versuchen Sie es später noch einmal.';

  @override
  String get total => 'Gesamt';

  @override
  String get estimatedCost => 'Geschätzte Kosten';

  @override
  String get byAgent => 'Von Agent';

  @override
  String get timeUpdated => 'Uhrzeit aktualisiert';

  @override
  String updateFailed(Object error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get locationUpdated => 'Standort aktualisiert';

  @override
  String get confirmDeleteCardMessage =>
      'Diese Karte löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get cardDetailNotFound => 'Kartendetail nicht gefunden';

  @override
  String get saySomething => 'Sag etwas...';

  @override
  String get relatedMemories => 'Verwandte Erinnerungen';

  @override
  String get viewMore => 'Mehr anzeigen';

  @override
  String get relatedRecords => 'Verwandte Datensätze';

  @override
  String get reply => 'Antwort';

  @override
  String get replySent => 'Antwort gesendet';

  @override
  String get insightTemplateGalleryTitle => 'Insight-Kartenvorlagen';

  @override
  String get timelineTemplateGalleryTitle => 'Vorlagen für Zeitleistenkarten';

  @override
  String get categoryTextual => 'Textlich';

  @override
  String get timelineFilterAll => 'ALLE';

  @override
  String get insights => 'Einblicke';

  @override
  String get memoryTitle => 'Erinnerung';

  @override
  String get longTermProfile => 'Langfristiges Profil';

  @override
  String get recentBuffer => 'Aktueller Puffer';

  @override
  String errorLoadingMemory(Object error) {
    return 'Fehler beim Laden des Speichers: $error';
  }

  @override
  String get agentConfiguration => 'Agentenkonfiguration';

  @override
  String get resetToDefaults => 'Auf Standardeinstellungen zurücksetzen';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Alle Agentenkonfigurationen zurücksetzen';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Sind Sie sicher, dass Sie alle Agentenkonfigurationen auf ihre Standardwerte zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get resetButton => 'Zurücksetzen';

  @override
  String loadDataFailed(Object error) {
    return 'Daten konnten nicht geladen werden: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Konfiguration konnte nicht gespeichert werden: $error';
  }

  @override
  String get selectLlmClient => 'LLM-Client auswählen:';

  @override
  String get agentConfigurationsReset => 'Agentenkonfigurationen zurückgesetzt';

  @override
  String resetFailed(Object error) {
    return 'Zurücksetzen fehlgeschlagen: $error';
  }

  @override
  String get modelConfiguration => 'Modellkonfiguration';

  @override
  String get resetAllConfigurationsTitle => 'Alle Konfigurationen zurücksetzen';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Sind Sie sicher, dass Sie alle Modellkonfigurationen auf ihre Standardwerte zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get modelConfigurationsReset => 'Modellkonfigurationen zurückgesetzt';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Die Standardkonfiguration kann nicht gelöscht werden';

  @override
  String get cannotDeleteConfigurationTitle =>
      'Die Konfiguration kann nicht gelöscht werden';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Diese Konfiguration wird derzeit von den folgenden Agenten verwendet:\n\n$agentList\n\nBitte weisen Sie diese Agenten vor dem Löschen neu zu.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Konfiguration löschen';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Sind Sie sicher, dass Sie „$key“ löschen möchten?';
  }

  @override
  String get defaultLabel => 'Standard';

  @override
  String get setAsDefault => 'Als Standard festlegen';

  @override
  String get invalidJsonInExtraField => 'Ungültiger JSON im Extra-Feld';

  @override
  String get keyAlreadyExists => 'Der Schlüssel ist bereits vorhanden';

  @override
  String get resetConfigurationTitle => 'Konfiguration zurücksetzen';

  @override
  String get resetConfigurationMessage =>
      'Diese Konfiguration auf ihre anfänglichen Standardwerte zurücksetzen? Aktuelle Änderungen gehen verloren.';

  @override
  String get configurationResetPressSave =>
      'Konfiguration zurückgesetzt. Klicken Sie zum Anwenden auf „Speichern“.';

  @override
  String get addConfiguration => 'Konfiguration hinzufügen';

  @override
  String get editConfiguration => 'Konfiguration bearbeiten';

  @override
  String get duplicateConfiguration => 'Doppelte Konfiguration';

  @override
  String get duplicate => 'Duplikat';

  @override
  String get keyIdLabel => 'Konfigurations-ID';

  @override
  String get keyIdHelper =>
      'Wird zur Unterscheidung mehrerer Modellkonfigurationen verwendet. Die meisten Benutzer müssen es nicht ändern.';

  @override
  String get required => 'Erforderlich';

  @override
  String get clientLabel => 'Modellanbieter';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropisch';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Beliebt';

  @override
  String get providerOpenAiApiKey => 'API-Schlüssel';

  @override
  String get providerOpenAiResponses => 'API-Schlüssel (Antworten)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API-Schlüssel';

  @override
  String get providerBedrockSecret => 'Grundgesteinsgeheimnis';

  @override
  String get providerGemini => 'Zwillinge';

  @override
  String get providerGeminiOauth => 'Zwillinge (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Moonshot)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (lokal)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Memex-Proxy-Dienst';

  @override
  String get memexSignIn => 'Anmelden';

  @override
  String get memexCreateAccount => 'Benutzerkonto erstellen';

  @override
  String get memexUsername => 'Benutzername';

  @override
  String get memexPassword => 'Passwort';

  @override
  String get memexCreateAccountLink => 'Benutzerkonto erstellen';

  @override
  String get memexSignInLink => 'Melden Sie sich stattdessen an';

  @override
  String get memexTopUp => 'Laden Sie Ihr Guthaben auf, um Memex AI zu nutzen';

  @override
  String get memexTopUpSuccess => 'Aufladen erfolgreich!';

  @override
  String get memexFillAllFields => 'Bitte füllen Sie alle Felder aus';

  @override
  String get memexUsernameTooShort =>
      'Der Benutzername muss mindestens 6 Zeichen lang sein';

  @override
  String get memexAuthFailed => 'Die Authentifizierung ist fehlgeschlagen';

  @override
  String get memexPaymentFailed => 'Die Zahlung konnte nicht erstellt werden';

  @override
  String get memexLogout => 'Abmelden';

  @override
  String get memexTopUpButton => 'Nachfüllen';

  @override
  String get memexTopUpChooseAmount => 'Wählen Sie einen Betrag';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Über $range-Datensätze';
  }

  @override
  String get memexTopUpPlanStarter => 'Anlasser';

  @override
  String get memexTopUpPlanEveryday => 'Täglich';

  @override
  String get memexTopUpPlanHighVolume => 'Hohe Lautstärke';

  @override
  String get memexTopUpPlanCustom => 'Benutzerdefinierte Credits';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Gut, um Memex AI auszuprobieren';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Gut für die regelmäßige Organisation';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Gut für größere Mengen';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Geben Sie 1-10.000 USD ein';

  @override
  String get memexTopUpCustomEstimate =>
      'Die Schätzung basiert auf dem eingegebenen Betrag';

  @override
  String get memexCustomAmount => 'Benutzerdefinierter Betrag';

  @override
  String get memexViewHistory => 'Nutzungsverlauf';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Kontostand: $amount';
  }

  @override
  String get memexConfirmPassword => 'Passwort bestätigen';

  @override
  String get memexPasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String memexPayAmount(Object amount) {
    return '$amount aufladen';
  }

  @override
  String get modelIdLabel => 'Modell';

  @override
  String get modelIdHelper => 'z.B. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Modelle werden abgerufen...';

  @override
  String get fetchModelsButton => 'Modelle abrufen';

  @override
  String get enterApiKeyFirst =>
      'Geben Sie zuerst den API-Schlüssel ein, um Modelle abzurufen';

  @override
  String get apiKeyLabel => 'API-Schlüssel';

  @override
  String get baseUrlLabel => 'API-Endpunkt';

  @override
  String get advancedSettings => 'Erweiterte Einstellungen';

  @override
  String get testConnectionSuccess => 'Verbindung erfolgreich';

  @override
  String get testConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get testTypeText => 'Text';

  @override
  String get testTypeVision => 'Vision';

  @override
  String get testButton => 'Prüfen';

  @override
  String get testing => 'Testen...';

  @override
  String get proxyUrlOptional => 'Proxy-URL (optional)';

  @override
  String get proxyUrlHelper => 'z.B. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperatur';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Maximale Token';

  @override
  String get extraParamsJson => 'Zusätzliche Parameter (JSON)';

  @override
  String get invalidJson => 'Ungültiger JSON';

  @override
  String get warning => 'Unvollständige Einrichtung';

  @override
  String get invalidConfigurationWarning =>
      'Die Konfiguration ist noch nicht vollständig (z. B. fehlt API-Schlüssel oder Modell-ID). Sie können es später noch speichern und konfigurieren. Weitermachen?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent „$agentId“ benötigt zum Betrieb eine gültige Modellkonfiguration (Schlüssel: „$configKey“). Bitte überprüfen Sie die Modelleinstellungen.';
  }

  @override
  String get discardChangesTitle => 'Diese Seite verlassen?';

  @override
  String get discardChangesMessage =>
      'Wenn Sie Änderungen vorgenommen haben, speichern Sie diese bitte vor dem Verlassen.';

  @override
  String get discardButton => 'Verwerfen';

  @override
  String get chooseLanguage => 'Wählen Sie Sprache';

  @override
  String get chooseAvatar => 'Wählen Sie Avatar';

  @override
  String get configureNow => 'Jetzt konfigurieren';

  @override
  String get modelNotConfiguredBanner =>
      'KI-Modell noch nicht konfiguriert. Richten Sie es ein, um alle Funktionen freizuschalten.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Bitte konfiguriere vor dem Veröffentlichen ein AI-Modell';

  @override
  String get processingStatus => 'Verarbeitung';

  @override
  String get failedStatus => 'Fehlgeschlagen';

  @override
  String get failureReason => 'Fehlergrund';

  @override
  String get unknownError => 'Es ist ein unbekannter Fehler aufgetreten';

  @override
  String get enableFitness => 'Aktivieren Sie Fitness';

  @override
  String get fitnessBannerMessage =>
      'Erlauben Sie den Fitnesszugriff, um Ihre Gesundheits- und Aktivitätsdaten zu verfolgen.';

  @override
  String get fitnessDismissTitle => 'Fitnesszugang überspringen?';

  @override
  String get fitnessDismissMessage =>
      'Ohne Fitnesserlaubnis kann die App Ihre Gesundheitsdaten nicht automatisch für Erkenntnisse und automatische Aufzeichnungen erfassen.';

  @override
  String get skipAnyway => 'Trotzdem überspringen';

  @override
  String get proModelHint =>
      'Dieses Modell erfordert ein ChatGPT Pro/Plus-Abonnement.';

  @override
  String get searchKnowledgeBase => 'Wissensdatenbank durchsuchen...';

  @override
  String get searchKnowledgeHint =>
      'Geben Sie ein Schlüsselwort ein, um nach Dateinamen oder Inhalten zu suchen';

  @override
  String noSearchResults(Object query) {
    return 'Keine Ergebnisse für „$query“ gefunden';
  }

  @override
  String get onlyMarkdownPreview => 'Nur Markdown-Vorschau wird unterstützt';

  @override
  String get backupAndRestore => 'Sichern und Wiederherstellen';

  @override
  String get createBackup => 'Backup erstellen';

  @override
  String get restoreBackup => 'Sicherung wiederherstellen';

  @override
  String get backupDescription =>
      'Packen Sie alle Ihre Daten (Karten, Wissensdatenbank, Erkenntnisse, Einstellungen) in eine .memex-Datei. Speichern Sie es über das Freigabeblatt auf iCloud Drive, Google Drive oder an einem beliebigen Ort.';

  @override
  String get restoreDescription =>
      'Wählen Sie eine .memex-Sicherungsdatei aus, um alle Daten wiederherzustellen. Dadurch werden die aktuellen Daten überschrieben.';

  @override
  String get selectBackupFile => 'Wählen Sie Sicherungsdatei';

  @override
  String get estimatedSize => 'Geschätzte Größe';

  @override
  String get backupComplete => 'Backup erstellt';

  @override
  String backupFailed(Object error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get confirmRestore => 'Bestätigen Sie die Wiederherstellung';

  @override
  String get confirmRestoreMessage =>
      'Beim Wiederherstellen werden alle aktuellen Daten überschrieben, einschließlich Karten, Wissensdatenbank, Einblicke und Einstellungen. Dies kann nicht rückgängig gemacht werden. Weitermachen?';

  @override
  String get restoreComplete => 'Wiederherstellung abgeschlossen';

  @override
  String get restoreRestartHint =>
      'Die Daten wurden wiederhergestellt. Bitte starten Sie die App neu, damit alle Änderungen wirksam werden.';

  @override
  String restoreFailed(Object error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get invalidBackupFile =>
      'Ungültige Sicherungsdatei. Bitte wählen Sie eine .memex-Datei aus.';

  @override
  String get automaticBackup => 'Automatische Sicherung';

  @override
  String get autoBackupDescription =>
      'Wenn diese Option aktiviert ist, erstellt Memex nach dem Start oder bei der Rückkehr in den Vordergrund höchstens einen lokalen Snapshot pro Tag.';

  @override
  String get backupSensitiveSettingsHint =>
      'Backups umfassen Einstellungen und Modellanbieterschlüssel. Bewahren Sie Sicherungsdateien an einem vertrauenswürdigen Ort auf.';

  @override
  String get backupLocation => 'Standort';

  @override
  String get backupLocationDetails => 'Standortdetails';

  @override
  String get backupLocationSummary => 'In der App angezeigt';

  @override
  String get backupLocationFullPath => 'Vollständiger Pfad';

  @override
  String get backupLocationUri => 'Ordnerzugriffs-URI';

  @override
  String get copyBackupLocationPath => 'Pfad kopieren';

  @override
  String get backupLocationCopied => 'Sicherungsspeicherort kopiert';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Ausgewählter Ordner: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Dateien > Auf meinem iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'Backup-Status';

  @override
  String get noAutoBackupYet => 'Noch kein automatisches Backup';

  @override
  String lastBackupAt(Object time) {
    return 'Letzte Sicherung: $time';
  }

  @override
  String get autoBackupRetention => 'Zurückbehaltung';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days Tage';
  }

  @override
  String get autoBackupRetentionForever => 'Für immer behalten';

  @override
  String get autoBackupMaxSize => 'Aufbewahrungskappe';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Durch die automatische Bereinigung bleiben automatische Snapshots unter $size. Sicherheitsschnappschüsse und manuelle Exporte werden getrennt aufbewahrt.';
  }

  @override
  String get createSnapshotNow => 'Machen Sie jetzt ein Backup';

  @override
  String get backupLocationMenu => 'Standort ändern';

  @override
  String get defaultBackupLocation => 'Standard-Sicherungsordner';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Verwenden Sie den App-spezifischen Ordner für externe Dateien von Memex. Keine Speichererlaubnis erforderlich.';

  @override
  String get chooseBackupLocation => 'Wählen Sie den Sicherungsordner';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Wählen Sie mit der Systemauswahl von Android einen Ordner aus und gewähren Sie Memex dauerhaften Zugriff.';

  @override
  String get storedBackups => 'Gespeicherte Backups';

  @override
  String get noStoredBackups =>
      'Nach dem ersten Snapshot werden hier automatische Backups angezeigt.';

  @override
  String get backupTypeAutoSnapshot => 'Automatischer Schnappschuss';

  @override
  String get backupTypeSafetySnapshot => 'Sicherheitsschnappschuss';

  @override
  String get backupTypeManualBackup => 'Manuelle Sicherung';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get restoreThisBackup => 'Stellen Sie dieses Backup wieder her';

  @override
  String get deleteThisBackup => 'Löschen Sie dieses Backup';

  @override
  String get confirmDeleteBackup => 'Backup löschen?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName löschen? Dadurch wird die gespeicherte Sicherungsdatei entfernt und kann nicht rückgängig gemacht werden.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Sicherung gelöscht: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Backup konnte nicht gelöscht werden: $error';
  }

  @override
  String get creatingSafetySnapshot =>
      'Sicherheitsschnappschuss wird erstellt...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Snapshot erstellt: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Sicherungsspeicherort konnte nicht aktualisiert werden: $error';
  }

  @override
  String get backupImportCreatedAt => 'Erstellt';

  @override
  String get backupImportSourceVersion => 'Quellversion';

  @override
  String get backupImportFlavor => 'Bauen';

  @override
  String get backupLegacyFormat => 'Legacy-Backup (kein Manifest)';

  @override
  String get restoreInProgress => 'Backup wird wiederhergestellt...';

  @override
  String get dataStorage => 'Datenspeicherung';

  @override
  String get dataStorageDescriptionAndroid =>
      'Wählen Sie einen benutzerdefinierten Ordner zum Speichern Ihres Arbeitsbereichs. Die Daten bleiben erhalten, wenn Sie die App erneut installieren.';

  @override
  String get dataStorageDescriptionIOS =>
      'Aktivieren Sie iCloud, um Ihren Arbeitsbereich geräteübergreifend zu synchronisieren und die Daten bei der Neuinstallation der App beizubehalten.';

  @override
  String get storageLocationApp => 'App-Speicher';

  @override
  String get storageLocationAppDesc =>
      'Die Daten werden in der App gespeichert und bei der Deinstallation gelöscht.';

  @override
  String get storageLocationCustom =>
      'Gerätespeicher (benutzerdefinierter Ordner)';

  @override
  String get storageLocationCustomDesc =>
      'Speichern Sie Daten in einem von Ihnen gewählten Ordner. Die Daten bleiben während der Neuinstallation bestehen, wenn der Ordner bestehen bleibt.';

  @override
  String get storageLocationICloud => 'In iCloud speichern';

  @override
  String get storageLocationICloudDesc =>
      'Synchronisieren Sie Ihren Arbeitsbereich auf allen Apple-Geräten. Die Daten bleiben nach der Neuinstallation erhalten.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Aktuell: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Melden Sie sich bei iCloud an und aktivieren Sie iCloud Drive, um den iCloud-Speicher zu nutzen.';

  @override
  String get loadingFromICloud => 'Daten aus iCloud wiederherstellen…';

  @override
  String get switchingToICloud => 'Wechsel zum iCloud-Speicher…';

  @override
  String get switchingStorage => 'Speicher wechseln…';

  @override
  String get customFolderAccessDenied =>
      'Dieser Ordner kann weder gelesen noch geschrieben werden. Bitte erteilen Sie die Speichererlaubnis oder wählen Sie einen anderen Ort.';

  @override
  String get configured => 'Konfiguriert';

  @override
  String get apiKeyNotSet =>
      'API-Schlüssel nicht festgelegt – zum Konfigurieren tippen';

  @override
  String get bottomNavTimeline => 'Zeitleiste';

  @override
  String get bottomNavLibrary => 'Bibliothek';

  @override
  String get aiGeneratedLabel => 'KI generiert';

  @override
  String sourceTraceWithCount(Object count) {
    return 'QUELLENVERFOLGUNG ($count)';
  }

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountDesc =>
      'Löschen Sie alle lokalen Daten dauerhaft und setzen Sie die App zurück.';

  @override
  String get deleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get deleteAccountConfirmMessage =>
      'Dadurch werden alle Ihre Daten, einschließlich Zeitleistenkarten, Wissensdatenbank, Aufzeichnungen und Einstellungen, dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Geben Sie zur Bestätigung „$name“ ein';
  }

  @override
  String get deleteAccountTypeHint =>
      'Geben Sie zur Bestätigung Ihren Benutzernamen ein';

  @override
  String get llmConsentTitle => 'Einwilligung zur Datenweitergabe';

  @override
  String llmConsentMessage(Object provider) {
    return 'Um KI-Funktionen zu aktivieren, muss Memex Ihre Daten zur Verarbeitung an $provider senden. Dazu gehört:\n\n• Von Ihnen eingegebener Text (Notizen, Sprachtranskriptionen)\n• Fotometadaten und extrahierter Text (OCR)\n• Zusammenfassungen zu Gesundheit und Fitness\n• Inhalt der Zeitleistenkarte\n\nIhre Daten werden direkt von Ihrem Gerät an $provider gesendet. Memex speichert oder leitet Ihre Daten nicht über einen anderen Server weiter.\n\nBitte lesen Sie die Datenschutzrichtlinie von $provider für den Umgang mit Ihren Daten.\n\nSind Sie damit einverstanden, Ihre Daten zur KI-Verarbeitung an $provider zu senden?';
  }

  @override
  String get llmConsentAgree => 'Ich stimme zu';

  @override
  String get llmConsentDecline => 'Abfall';

  @override
  String get customAgents => 'Benutzerdefinierte Agenten';

  @override
  String get noCustomAgents => 'Keine benutzerdefinierten Agents konfiguriert.';

  @override
  String get deleteAgent => 'Agent löschen';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Benutzerdefinierten Agent „$name“ löschen?';
  }

  @override
  String get deleted => 'Gelöscht';

  @override
  String get saved => 'Gespeichert';

  @override
  String get newAgent => 'Neuer Agent';

  @override
  String get editAgent => 'Agent bearbeiten';

  @override
  String get agentName => 'Agentenname';

  @override
  String get agentNameHint => 'mein-custom-agent';

  @override
  String get agentNameRequired => 'Erforderlich';

  @override
  String get agentNameInvalid => 'Nur Buchstaben, Ziffern und Bindestriche';

  @override
  String get agentNameExists => 'Name existiert bereits';

  @override
  String get hostAgentType => 'Host-Agent-Typ';

  @override
  String get skillDirectory => 'Kompetenzverzeichnis';

  @override
  String get skillDirInvalid =>
      'Muss ein relativer Pfad sein (ohne führendes / oder ..)';

  @override
  String get workingDirectory => 'Arbeitsverzeichnis (optional)';

  @override
  String get workingDirectoryHint =>
      'Für den Standardarbeitsbereich leer lassen';

  @override
  String get llmConfig => 'LLM-Konfiguration';

  @override
  String get eventType => 'Ereignistyp';

  @override
  String get executionMode => 'Ausführungsmodus';

  @override
  String get executionModeAsync => 'Asynchron';

  @override
  String get executionModeSync => 'Synchronisieren';

  @override
  String get dependsOn => 'Hängt davon ab';

  @override
  String get dependsOnHint => 'Wählen Sie Abhängigkeiten aus';

  @override
  String get priority => 'Priorität';

  @override
  String get maxRetries => 'Max. Wiederholungsversuche';

  @override
  String get systemPromptLabel => 'Systemaufforderung (optional)';

  @override
  String get systemPromptHint =>
      'Zusätzliche Anweisungen an die Host-Agent-Eingabeaufforderung angehängt';

  @override
  String get eventSerializer => 'Ereignisserialisierer';

  @override
  String get eventSerializerDefault => 'Standard (XML)';

  @override
  String get enabledLabel => 'Ermöglicht';

  @override
  String get skillsManagement => 'Kompetenzmanagement';

  @override
  String get skillsManagementEmpty => 'Noch keine Fähigkeiten';

  @override
  String get downloadSkill => 'Laden Sie Skill herunter';

  @override
  String get downloadFile => 'Datei herunterladen';

  @override
  String get downloading => 'Herunterladen...';

  @override
  String get downloadSuccess => 'Der Skill wurde erfolgreich heruntergeladen';

  @override
  String downloadFailed(Object error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String get deleteConfirm => 'Bestätigen Sie Löschen';

  @override
  String deleteConfirmMessage(String name) {
    return 'Sind Sie sicher, dass Sie „$name“ löschen möchten?';
  }

  @override
  String get invalidUrl => 'Bitte geben Sie eine gültige URL ein';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Neuer Ordner';

  @override
  String get newFile => 'Neue Datei';

  @override
  String get folderName => 'Ordnername';

  @override
  String get fileName => 'Dateiname';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get nameInvalid => 'Der Name darf / oder . nicht enthalten.';

  @override
  String createFailed(Object error) {
    return 'Erstellen fehlgeschlagen: $error';
  }

  @override
  String get fileContent => 'Dateiinhalt';

  @override
  String get saveSuccess => 'Erfolgreich gespeichert';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Die ZIP-Datei wird in das aktuelle Verzeichnis extrahiert: $dir';
  }

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get privacyPolicyDesc => 'Wie Memex mit Ihren Daten umgeht';

  @override
  String get llmAuthError =>
      'Die API-Authentifizierung ist fehlgeschlagen. Bitte überprüfen Sie Ihre LLM-Konfiguration in den Einstellungen.';

  @override
  String get llmBadRequestError =>
      'Der Antrag wurde vom LLM-Anbieter abgelehnt. Das Eingabeformat wird vom aktuellen Modell möglicherweise nicht unterstützt.';

  @override
  String get llmRateLimitError =>
      'API-Ratenlimit überschritten. Bitte versuchen Sie es später noch einmal.';

  @override
  String get llmServerError =>
      'Der LLM-Dienst ist vorübergehend nicht verfügbar. Bitte versuchen Sie es später noch einmal.';

  @override
  String get llmNetworkError =>
      'Netzwerkverbindung fehlgeschlagen. Bitte überprüfen Sie Ihre Internetverbindung.';

  @override
  String get llmUnknownError =>
      'Bei der Verarbeitung Ihres Inhalts ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get llmErrorDialogTitle => 'Die Verarbeitung ist fehlgeschlagen';

  @override
  String get goToModelConfig => 'Gehen Sie zu Einstellungen';

  @override
  String get speechModelDownloadTitle => 'Laden Sie das Sprachmodell herunter';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Es ist ein einmaliger Modell-Download (~${sizeMB}MB) erforderlich.\n\nNach dem Herunterladen läuft die Transkription vollständig auf dem Gerät.';
  }

  @override
  String get speechModelStartDownload => 'Starten Sie den Download';

  @override
  String get speechModelChooseSource => 'Download-Quelle wählen:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (Schneller in CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (Global)';

  @override
  String get speechModelDownloading => 'Modell wird heruntergeladen...';

  @override
  String get speechModelConnecting => 'Verbinden...';

  @override
  String get deleteSpeechModel => 'Sprachmodell löschen';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Die heruntergeladenen lokalen Spracherkennungsmodelldateien löschen? Sie werden erneut heruntergeladen, wenn die lokale Spracherkennung das nächste Mal verwendet wird.';

  @override
  String get speechModelDeletedSuccess => 'Sprachmodelldateien gelöscht';

  @override
  String get speechModelNotDownloaded =>
      'Keine heruntergeladenen Sprachmodelldateien gefunden';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Sprachmodelldateien konnten nicht gelöscht werden: $error';
  }

  @override
  String get speechTranscribing => 'Erkennen...';

  @override
  String get speechNoResult => 'Keine Sprache erkannt';

  @override
  String get useLocalSpeechToTextTitle =>
      'Verwenden Sie lokale Sprache für Text';

  @override
  String get useLocalSpeechToTextDesc =>
      'Wenn diese Option aktiviert ist, wird der Ton vor dem Senden auf dem Gerät transkribiert – nützlich für Modelle, die keinen Audioeingang unterstützen. Bei Deaktivierung wird der Originalton direkt an das Modell gesendet.';

  @override
  String get pendingAiProcessingHint =>
      'Richten Sie ein KI-Modell für die Verarbeitung ein';

  @override
  String get demoWelcome =>
      'Willkommen bei Memex!\nLassen Sie uns einen kurzen Überblick darüber geben, was KI für Ihre Unterlagen tun kann.';

  @override
  String get demoTapAdd =>
      'Tippen Sie hier, um Ihren ersten Datensatz zu erstellen';

  @override
  String get demoTapSend =>
      'Tippen Sie hier, um Ihren ersten Datensatz zu senden';

  @override
  String get demoTapCard =>
      'Tippen Sie hier, um zu sehen, wie die KI Ihren Datensatz organisiert hat';

  @override
  String get demoDetailHint =>
      'Dies sind die von der KI organisierten Datensatzdetails. Scrolle herum und gehe dann zurück, um die Tour fortzusetzen.';

  @override
  String get demoTapInsight =>
      'Tippen Sie hier, um KI-generierte Erkenntnisse anzuzeigen';

  @override
  String get demoTapInsightUpdate =>
      'Tippen Sie hier, um Erkenntnisse aus Ihren Datensätzen zu generieren';

  @override
  String get demoTapKnowledge =>
      'Überprüfen Sie Ihre automatisch organisierten Wissensdateien';

  @override
  String get demoDone => 'Fangen Sie an, Ihr Leben aufzuzeichnen.';

  @override
  String get demoStartTour => 'Tour starten';

  @override
  String get demoGetStarted => 'Legen Sie los';

  @override
  String get demoSkip => 'Überspringen';

  @override
  String get demoPrefillText => 'Hallo Memex! Das ist meine erste Platte 🎉';

  @override
  String get visionBadge => 'Vision';

  @override
  String get notMultimodalHint =>
      'Memex setzt bei der Medienanalyse auf multimodale Modellfunktionen. Wenn Ihre Datensätze Bilder enthalten, stellen Sie bitte sicher, dass das von Ihnen konfigurierte Modell die Bildeingabe unterstützt.';

  @override
  String get defaultModelPrefix => 'Standard';

  @override
  String get recommendedBadge => 'Empfohlen';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Begleiter wechseln';

  @override
  String get personaChatInputHint => 'Geben Sie eine Nachricht ein...';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get yesterday => 'Gestern';

  @override
  String get showInsightTextTitle => 'Memex Insight-Kommentar anzeigen';

  @override
  String get showInsightTextDesc =>
      'Ob der Memex-Einblick als angehefteter Kommentar im Kommentarbereich mit den Kartendetails angezeigt werden soll.';

  @override
  String get enableCharacterCommentTitle => 'Automatischer Charakterkommentar';

  @override
  String get enableCharacterCommentDesc =>
      'Charaktere kommentieren neue Datensätze automatisch.';

  @override
  String get maxCommentCharactersTitle => 'Max. kommentierende Zeichen';

  @override
  String get maxCommentCharactersDesc =>
      'Wie viele Zeichen können jeden Datensatz kommentieren?';

  @override
  String replyTo(String name) {
    return 'Antworte auf $name';
  }

  @override
  String get cdnSignalsComments => 'Neue Antwort erhalten';

  @override
  String get cdnSignalsInsight => 'Neue Erkenntnisse generiert';

  @override
  String get cdnSignalsBoth => 'Neue Antwort und Einsicht';

  @override
  String get untitledCard => 'Karte ohne Titel';

  @override
  String get locationContextTitle => 'Standortkontext';

  @override
  String get locationContextDescription =>
      'Aktueller Stadt- und Nachbarschaftskontext für den Agenten-Chat';

  @override
  String get locationContextAttachTitle =>
      'Hängen Sie den aktuellen Standort an den Chat an';

  @override
  String get locationContextAttachDesc =>
      'Verwendet Geräte-GPS und umgekehrte Geokodierung, um dem Agenten Stadt-, Bezirks- und Nachbarschaftskontext bereitzustellen.';

  @override
  String get reverseGeocodingProvider => 'Anbieter für umgekehrte Geokodierung';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap-API-Schlüssel';

  @override
  String get amapGcj02Note =>
      'Amap verwendet GCJ-02-Koordinaten. Das Geräte-GPS wird vor der umgekehrten Geokodierung konvertiert.';

  @override
  String get contextGranularity => 'Kontextgranularität';

  @override
  String get granularityCity => 'Stadt';

  @override
  String get granularityDistrict => 'Bezirk';

  @override
  String get granularityNeighborhood => 'Nachbarschaft';

  @override
  String get granularityStreet => 'Straße';

  @override
  String get granularityFullAddress => 'Vollständiger Adresskandidat';

  @override
  String get locationFreshness => 'Standortfrische';

  @override
  String minutesShort(int minutes) {
    return '$minutes Minuten';
  }

  @override
  String get oneHour => '1 Stunde';

  @override
  String get testCurrentLocation => 'Testen Sie den aktuellen Standort';

  @override
  String locationTestFailed(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Geokodierung umkehren';

  @override
  String get locationDebugProvider => 'Anbieter';

  @override
  String get locationDebugAgentContext => 'Agentenkontext';

  @override
  String get locationDebugSource => 'Quelle';

  @override
  String get locationDebugAddressSummary => 'Adressübersicht';

  @override
  String get locationDebugFullAddress => 'Vollständige Adresse';

  @override
  String get locationDebugCoordinates => 'Koordinaten';

  @override
  String get locationDebugAccuracy => 'Genauigkeit';

  @override
  String get locationDebugReason => 'Grund';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'nicht verfügbar';

  @override
  String get locationDebugInjected => 'gespritzt';

  @override
  String get locationDebugNotInjected => 'nicht gespritzt';

  @override
  String get locationStatusUpdatedAt => 'Aktualisiert';

  @override
  String get locationStatusSuccessTitle => 'Der aktuelle Standort ist bereit';

  @override
  String get locationStatusSuccessBody =>
      'Memex kann diese Standortzusammenfassung anhängen, wenn der Standortkontext relevant ist.';

  @override
  String get locationStatusApproximateTitle => 'Nur ungefährer Standort';

  @override
  String get locationStatusApproximateBody =>
      'Die Genauigkeit entspricht der Stadt- oder Gebietsebene. Sie können es weiterhin verwenden oder für einen engeren Kontext „Precise Location“ in den Systemeinstellungen aktivieren.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'Der Systemstandort ist deaktiviert';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex verwendet nur das Geräte-GPS und leitet den Standort nicht aus dem Netzwerk oder der IP ab. Öffnen Sie unter Android die Standorteinstellungen. Aktivieren Sie unter iOS Einstellungen > Datenschutz und Sicherheit > Ortungsdienste.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Eine Standortgenehmigung ist erforderlich';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Erlauben Sie Memex, den Standort beim Testen oder wenn Standortkontext benötigt wird, zu verwenden. Es wird immer kein Zugriff angefordert.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'Die Standortberechtigung ist blockiert';

  @override
  String get locationStatusPermissionForeverBody =>
      'Öffnen Sie die App-Einstellungen und erlauben Sie den Standort für Memex. Unter iOS reicht die Verwendung der App aus.';

  @override
  String get locationStatusDisabledTitle =>
      'Der Standortkontext ist deaktiviert';

  @override
  String get locationStatusDisabledBody =>
      'Aktivieren Sie den Schalter oben und speichern Sie, wenn Memex den Gerätestandort mit dem Agentenkontext verknüpfen soll.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS funktioniert, Adresssuche ist fehlgeschlagen';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex verfügt über Koordinaten, fügt dem Agenten jedoch keinen reinen GPS-Kontext hinzu. Überprüfen Sie den Reverse-Geokodierungsanbieter und versuchen Sie es erneut.';

  @override
  String get locationStatusUnavailableTitle => 'Standort nicht verfügbar';

  @override
  String get locationStatusUnavailableBody =>
      'Überprüfen Sie die Ortungsdienste und App-Berechtigungen des Systems und testen Sie es dann erneut.';

  @override
  String get allowLocationPermissionButton => 'Standortberechtigung zulassen';

  @override
  String get openAppSettingsButton => 'App-Einstellungen öffnen';

  @override
  String get openLocationSettingsButton => 'Standorteinstellungen öffnen';

  @override
  String get locationSettingsOpenFailed =>
      'Die Systemeinstellungen konnten nicht geöffnet werden.';

  @override
  String locationActionFailed(String error) {
    return 'Standortaktion fehlgeschlagen: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Sucheinstellungen...';

  @override
  String get settingsSearchEmpty => 'Keine passenden Einstellungen gefunden';

  @override
  String get importCharacterCard => 'Charakterkarte importieren';

  @override
  String get firstMessageLabel => 'Erste Nachricht';

  @override
  String get firstMessageHint =>
      'Begrüßung beim ersten Gespräch gesendet (optional)';

  @override
  String get systemPromptOverrideLabel =>
      'Überschreibung der Systemaufforderung';

  @override
  String get systemPromptOverrideHint =>
      'Standard-Systemaufforderung überschreiben (erweitert, optional)';

  @override
  String get postHistoryInstructionsLabel => 'Anweisungen zur Nachgeschichte';

  @override
  String get postHistoryInstructionsHint =>
      'Anweisungen werden nach dem Chatverlauf und vor der Antwort eingefügt (optional)';

  @override
  String get mesExampleLabel => 'Nachrichtenbeispiele';

  @override
  String get mesExampleHint => 'Beispieldialoge mit Charakterstil (optional)';

  @override
  String get worldBookTitle => 'Weltbuch';

  @override
  String get worldBookSubtitle =>
      'Hintergrundwissen wird eingefügt, wenn Schlüsselwörter ausgelöst werden';

  @override
  String get characterMemoryTitle => 'Charaktergedächtnis';

  @override
  String get characterMemorySubtitle =>
      'Beziehungsdynamik und Interaktionserinnerungen zwischen Charakter und Benutzer';

  @override
  String get addTooltip => 'Hinzufügen';

  @override
  String get constantBadge => 'Konstante';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Eintrag $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Schlüsselwörter: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Speicher $index';
  }

  @override
  String get addWorldEntry => 'Weltbucheintrag hinzufügen';

  @override
  String get editWorldEntry => 'Weltbucheintrag bearbeiten';

  @override
  String get commentTitleLabel => 'Kommentar / Titel';

  @override
  String get entryDescriptionHint => 'Eintragsbeschreibung (optional)';

  @override
  String get triggerKeywordsLabel => 'Trigger-Schlüsselwörter';

  @override
  String get triggerKeywordsHint =>
      'Durch Kommas getrennt, z. B.: Magie, Zauber';

  @override
  String get contentLabel => 'Inhalt';

  @override
  String get worldEntryContentHint =>
      'Hintergrundwissen wird eingefügt, wenn Schlüsselwörter ausgelöst werden';

  @override
  String get enabledCheckbox => 'Ermöglicht';

  @override
  String get addMemory => 'Speicher hinzufügen';

  @override
  String get editMemory => 'Speicher bearbeiten';

  @override
  String get memoryLabelField => 'Etikett';

  @override
  String get memoryLabelHint =>
      'Eindeutiger Bezeichner, z. B.: Namenspräferenz';

  @override
  String get memoryContentHint => 'Speicherinhalte';

  @override
  String get salienceLabel => 'Besonderheit:';

  @override
  String get labelCannotBeEmpty => 'Das Etikett darf nicht leer sein';

  @override
  String importSuccess(Object name) {
    return '$name erfolgreich importiert';
  }

  @override
  String importFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get supportedFormats => 'Unterstützte Formate';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2-Charakterkarten (.json)\n• PNG-Bilder mit eingebetteten Karten (.png)\n\nFelder wie Persona, Weltbuch usw. werden automatisch dem Memex-Zeichenformat zugeordnet.';

  @override
  String get pickCharacterFile => 'Wählen Sie Zeichendatei';

  @override
  String get repickFile => 'Wählen Sie eine andere Datei';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'Systemaufforderung';

  @override
  String worldEntriesCount(Object count) {
    return 'Weltbuch: $count Einträge';
  }

  @override
  String fileLabel(Object filename) {
    return 'Datei: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Charakter mit demselben Namen existiert bereits: $names. Beim Importieren wird ein neuer Charakter erstellt, ohne dass vorhandene überschrieben werden.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Als Hauptbegleiter festlegen';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Wird nach dem Import automatisch als Ihr primärer Begleiter festgelegt';

  @override
  String get confirmImport => 'Bestätigen Sie den Import';

  @override
  String get chatBackground => 'Chat-Hintergrund';

  @override
  String get chooseChatBackgroundImage => 'Wählen Sie ein Hintergrundbild';

  @override
  String get earlyUpdateSettingsTitle => 'Frühzeitige Zugriffsaktualisierungen';

  @override
  String get earlyUpdateSettingsDesc =>
      'Suchen Sie in den GitHub-Vorabversionen nach der passenden Early APK, laden Sie sie herunter und geben Sie sie an das Android-Installationsprogramm weiter.';

  @override
  String get earlyUpdateUnsupported =>
      'Frühe Updates sind nur im Android Early-Build verfügbar.';

  @override
  String get earlyUpdateAutoCheckTitle => 'Automatische Suche nach Updates';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Beim Start höchstens alle 12 Stunden prüfen.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Nur über WLAN herunterladen';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Überspringen Sie Update-Downloads, während Sie mobile Daten nutzen.';

  @override
  String get earlyUpdateAutoInstallTitle =>
      'Automatischer Download und Installation';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Wenn ein neuer Build gefunden wird, laden Sie ihn herunter und öffnen Sie das Android-Installationsprogramm automatisch.';

  @override
  String get earlyUpdateCheckNow => 'Jetzt prüfen';

  @override
  String get earlyUpdateChecking => 'GitHub-Vorabversionen prüfen...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Übersprungen, da reine WLAN-Downloads aktiviert sind.';

  @override
  String get earlyUpdateNoUpdate =>
      'Sie befinden sich bereits im neuesten Early Build.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Der frühe Build $version+$build ist verfügbar.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Herunterladen und installieren';

  @override
  String get earlyUpdateDownloadInProgress => 'Update wird heruntergeladen...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Update wird heruntergeladen: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Update-Paket heruntergeladen. Bereit zur Installation.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Installieren Sie das heruntergeladene Paket';

  @override
  String get earlyUpdateClearDownloadedPackage =>
      'Löschen Sie das heruntergeladene Paket';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Heruntergeladenes Update-Paket gelöscht.';

  @override
  String get earlyUpdateInstallStarted =>
      'Android-Installationsprogramm geöffnet.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Erlauben Sie Memex, unbekannte Apps zu installieren, und tippen Sie dann auf „Herunterladen und erneut installieren“.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Zuletzt überprüft: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Update-Prüfung fehlgeschlagen: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Frühes Update verfügbar';

  @override
  String get earlyUpdateReleaseNotes => 'Versionshinweise';

  @override
  String get dismissAllNotifications => 'Alles löschen';

  @override
  String get dismissByType => 'Nach Typ löschen';

  @override
  String get dismissTypeSystemAction => 'Erinnerungen und Ereignisse';

  @override
  String get dismissTypeClarification => 'Erläuterungen';

  @override
  String get dismissTypeCardUpdate => 'Kartenaktualisierungen';

  @override
  String dismissedCount(Object count) {
    return '$count gelöscht';
  }

  @override
  String get dataImportTitle => 'Dateien importieren';

  @override
  String get dataImportSettingsDescription =>
      'Bringe alte Dateien in Memex und entscheide danach, ob sie organisiert werden sollen.';

  @override
  String get dataImportDescription =>
      'Wähle alte Notizen, exportierte Einträge, Dokumente oder ZIP-Archive aus. Memex speichert zuerst eine Kopie und lässt die Originaldateien unverändert. Danach kannst du entscheiden, ob Memex beim Organisieren helfen soll.';

  @override
  String get dataImportSelectFiles => 'Dateien zum Importieren auswählen';

  @override
  String get dataImportImporting => 'Dateien werden gespeichert...';

  @override
  String get dataImportSuccess => 'Dateien in Memex gespeichert';

  @override
  String get dataImportOnlyStored =>
      'Dateien gespeichert. Es wurde keine Organisation gestartet.';

  @override
  String get dataImportQueued =>
      'Memex organisiert diesen Import im Hintergrund.';

  @override
  String get dataImportResultTitle => 'Import abgeschlossen';

  @override
  String dataImportResultSummary(Object count) {
    return '$count Dateien wurden gespeichert. Du kannst sie jetzt organisieren oder als ursprüngliches Quellenmaterial behalten.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count gleichnamige Elemente wurden umbenannt, damit nichts überschrieben wird.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count ungewöhnliche Archivelemente wurden übersprungen; der Rest wurde normal importiert.';
  }

  @override
  String get dataImportChooseProcessing => 'Diese Dateien organisieren';

  @override
  String get dataImportProcessTitle => 'Diesen Import organisieren?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Du hast $count Dateien importiert. Wähle, ob Memex sie jetzt organisieren oder nur die Originale behalten soll.';
  }

  @override
  String get dataImportProcessKnowledgeBase =>
      'In der Wissensbasis organisieren';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Geeignet für Dokumente, Notizen, Projektmaterial und Referenzen. Memex extrahiert nützliche Informationen und gruppiert sie für später.';

  @override
  String get dataImportProcessTimelineCards => 'Timeline-Einträge erstellen';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Geeignet für Tagebücher, Chatverläufe, Aktivitätsverläufe und alte Exporte. Memex macht daraus zeitbezogene Einträge, wenn es sinnvoll ist.';

  @override
  String get dataImportImpactNone =>
      'Memex behält nur diese Originaldateien. Es wird keine KI-Organisation gestartet.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex liest diese Dateien und organisiert langfristig nützliche Informationen in der Wissensbasis. Timeline-Einträge werden nicht aktiv erstellt.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex liest diese Dateien und erstellt bei passenden Lebensereignissen oder datierten Verläufen Timeline-Einträge. Die Wissensbasis wird nicht aktiv organisiert.';

  @override
  String get dataImportImpactBoth =>
      'Memex versucht, Timeline-Einträge zu erstellen und wiederverwendbare Informationen in der Wissensbasis zu organisieren. Das passt gut zu vollständigen persönlichen Archiven.';

  @override
  String get dataImportFinish => 'Nur speichern';

  @override
  String get noImages => 'Keine Bilder';

  @override
  String get noMessages => 'Keine Nachrichten';

  @override
  String get sketchContent => 'Skizzeninhalt';

  @override
  String get emptyFolder => 'Leerer Ordner';

  @override
  String get usernameAlreadyTaken => 'Benutzername bereits vergeben';

  @override
  String get registrationFailed => 'Registrierung fehlgeschlagen';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get paymentCreationFailed => 'Zahlung konnte nicht gestartet werden';

  @override
  String get completePayment => 'Zahlung abschließen';

  @override
  String get commentReplyToYou => 'Du';

  @override
  String get commentAuthorUser => 'Benutzer';

  @override
  String get commentAuthorAi => 'KI';

  @override
  String get authorizationCancelled => 'Autorisierung abgebrochen';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Woche $week';
  }

  @override
  String get timelineWeekLabel => 'Woche';

  @override
  String get eventCardDefaultTitle => 'Ereignis';

  @override
  String get memoryNoLongTermYet => 'Noch keine Langzeit-Erinnerungen.';

  @override
  String get memoryNoRecentBuffer => 'Keine recenten Erinnerungen im Puffer.';

  @override
  String get memoryGeneralSubject => 'Allgemein';
}
