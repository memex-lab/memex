// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get timesLabel => 'Volte';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Imposta $modelId come modello predefinito';
  }

  @override
  String get retry => 'Riprova';

  @override
  String get unknownModel => 'Modello sconosciuto';

  @override
  String get notSet => 'Non impostato';

  @override
  String get confirmClear => 'Conferma chiaro';

  @override
  String get confirmClearTokenMessage =>
      'Cancellare l\'utente corrente? Dovrai inserire nuovamente l\'ID utente.';

  @override
  String get cancel => 'Cancellare';

  @override
  String get confirm => 'Confermare';

  @override
  String get tokenCleared => 'Utente cancellato';

  @override
  String clearTokenFailed(Object error) {
    return 'Impossibile cancellare l\'utente: $error';
  }

  @override
  String get selectDateRangeOptional =>
      'Seleziona l\'intervallo di date (facoltativo):';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get endDate => 'Data di fine';

  @override
  String get select => 'Selezionare';

  @override
  String get processLimitOptional => 'Limite di processo (facoltativo)';

  @override
  String get leaveEmptyForAll => 'Lascia vuoto per elaborare tutto';

  @override
  String get startProcessing => 'Inizia l\'elaborazione';

  @override
  String get userIdNotFound => 'ID utente non trovato';

  @override
  String createTaskFailed(Object error) {
    return 'Impossibile creare l\'attività: $error';
  }

  @override
  String get reprocessCards => 'Rielaborare le carte';

  @override
  String get reprocessCardsTaskCreated =>
      'Richiesta di rielaborazione in coda nel Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Ambito';

  @override
  String get reprocessCardsCardOnly => 'Solo carte';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Chiedi al Super Agent di rivedere e rigenerare le carte della sequenza temporale selezionate.';

  @override
  String get reprocessCardsRerunDownstream => 'Schede e relativi seguiti';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Chiedi a Super Agent di prendere in considerazione anche il PKM correlato e gli aggiornamenti approfonditi quando necessario.';

  @override
  String get reanalyzeMediaAssets => 'Rileggere gli allegati multimediali';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Chiedi al Super Agent di ispezionare nuovamente il supporto allegato durante la rigenerazione delle carte.';

  @override
  String get regenerateComments => 'Rigenera i commenti';

  @override
  String get regenerateCommentsTaskCreated =>
      'Rigenera l\'attività di commenti creata, in esecuzione in background';

  @override
  String get rebuildSearchIndex => 'Ricostruisci l\'indice di ricerca';

  @override
  String get rebuildSearchIndexSuccess =>
      'Indice di ricerca ricostruito correttamente';

  @override
  String get rebuildSearchIndexFailed =>
      'Impossibile ricostruire l\'indice di ricerca';

  @override
  String get clearData => 'Cancella dati';

  @override
  String get confirmClearDataMessage => 'Cancellare i dati?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Tutti i dati dell\'area di lavoro locale per l\'utente corrente verranno eliminati, inclusi schede, contenuti multimediali, file della conoscenza, approfondimenti, memoria, cronologia chat e stato del sistema.\n\nQuesta azione non può essere annullata!';

  @override
  String get clearFailedAgentContexts =>
      'Cancella il contesto della conversazione non riuscita';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Cancellare il contesto della conversazione salvata per gli agenti Insight e Pianificazione? Ciò è utile dopo aver modificato i modelli quando i messaggi dell\'agente precedenti non sono più compatibili. Fatti, carte, conoscenze, ricordi e impostazioni del modello non verranno cancellati.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'Cancellato $count contesto/i di conversazione salvato/i';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Impossibile cancellare il contesto della conversazione: $error';
  }

  @override
  String get cloneToTestUser => 'Clona per testare l\'utente';

  @override
  String get confirmCloneToTestUserMessage =>
      'Copia l\'area di lavoro corrente in un nuovo utente di prova locale e passa ad esso. Lo stato di runtime dell\'agente non viene copiato. I tuoi attuali dati utente non verranno modificati.';

  @override
  String get testUserIdLabel => 'Testare l\'ID utente';

  @override
  String get testUserIdHelper =>
      'Utilizza lettere, numeri, trattini o trattini bassi.';

  @override
  String get testUserIdInvalid =>
      'Utilizza solo lettere, numeri, trattini o trattini bassi.';

  @override
  String get overwriteExistingTestUser =>
      'Sostituisci l\'utente di prova esistente con lo stesso ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Passato all\'utente di prova $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Impossibile clonare l\'utente di prova: $error';
  }

  @override
  String get dataClearedSuccess => 'Dati cancellati con successo';

  @override
  String clearDataFailed(Object error) {
    return 'Impossibile cancellare i dati: $error';
  }

  @override
  String get personalCenter => 'Centro personale';

  @override
  String get viewLogs => 'Visualizza i registri';

  @override
  String get systemAuthorization => 'Autorizzazione del sistema';

  @override
  String get aiCharacterConfig => 'Configurazione dei caratteri AI';

  @override
  String get modelConfig => 'Configurazione del modello';

  @override
  String get agentConfig => 'Configurazione dell\'agente';

  @override
  String get experimentalLab => 'Laboratori';

  @override
  String get experimentalLabDescription =>
      'Funzionalità sperimentali che potrebbero cambiare o spostarsi in seguito.';

  @override
  String get modelUsageStats => 'Statistiche sull\'utilizzo del modello';

  @override
  String get asyncTaskList => 'Elenco attività asincrone';

  @override
  String get clearLocalToken => 'Cancella utente';

  @override
  String get insightCardTemplates => 'Modelli di schede informative';

  @override
  String get timelineCardTemplates =>
      'Modelli di carte della sequenza temporale';

  @override
  String get logViewer => 'Visualizzatore di registro';

  @override
  String get autoRefresh => 'Aggiornamento automatico';

  @override
  String get lineCount => 'Conteggio righe:';

  @override
  String get all => 'Tutto';

  @override
  String get schedule => 'Programma';

  @override
  String get appLockConfig => 'Configurazione del blocco dell\'app';

  @override
  String loadStatsFailed(Object error) {
    return 'Impossibile caricare le statistiche: $error';
  }

  @override
  String get overview => 'Panoramica';

  @override
  String get daily => 'Quotidiano';

  @override
  String get modelStatsByAgent => 'Per agente';

  @override
  String get detail => 'Dettaglio';

  @override
  String get date => 'Data';

  @override
  String get agent => 'Agente';

  @override
  String get noData => 'Nessun dato';

  @override
  String get totalCalls => 'Chiamate totali';

  @override
  String get calls => 'Chiamate';

  @override
  String callsCount(Object count) {
    return '$count chiama';
  }

  @override
  String get selectDateRange => 'Seleziona l\'intervallo di date';

  @override
  String get totalTokens => 'Gettoni totali';

  @override
  String get cacheRate => 'Tasso di cache';

  @override
  String get promptTokens => 'Gettoni di richiesta';

  @override
  String get completionTokens => 'Gettoni di completamento';

  @override
  String get cachedTokens => 'Token memorizzati nella cache';

  @override
  String get thoughtTokens => 'Gettoni di pensiero';

  @override
  String get prompt => 'Richiesta';

  @override
  String get completion => 'Completamento';

  @override
  String get cached => 'Memorizzato nella cache';

  @override
  String get thought => 'Pensiero';

  @override
  String get model => 'Modello';

  @override
  String get scene => 'Scena';

  @override
  String get sceneId => 'Identificativo della scena';

  @override
  String get tokenUsage => 'Utilizzo dei gettoni';

  @override
  String get handler => 'Gestore';

  @override
  String get modelBreakdown => 'Ripartizione del modello';

  @override
  String get callDetails => 'Dettagli della chiamata';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Dettagli registrazione: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Impossibile salvare la configurazione LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'L\'anteprima HTML non è disponibile sul Web. Si prega di visualizzare sul cellulare.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Impossibile salvare le informazioni dell\'utente: $error';
  }

  @override
  String get totalEstimatedCost => 'Costo totale stimato';

  @override
  String get close => 'Vicino';

  @override
  String get totalTokenConsumption => 'Consumo totale di token';

  @override
  String get dataLoadFailedRetry =>
      'Caricamento dati non riuscito, riprova più tardi.';

  @override
  String get timelineLoadFailedRetry =>
      'Caricamento della sequenza temporale non riuscito, riprova più tardi.';

  @override
  String get newPerspective => 'Nuova prospettiva';

  @override
  String get startPoint => 'Inizio';

  @override
  String get endPoint => 'FINE';

  @override
  String get originalInput => 'Ingresso originale';

  @override
  String get referenceContent => 'Contenuto di riferimento';

  @override
  String referenceWithTitle(Object title) {
    return 'Riferimento: $title';
  }

  @override
  String get actionCenterTitle => 'Azioni in sospeso';

  @override
  String get noPendingActions => 'Nessuna azione in sospeso';

  @override
  String get clarificationNeeded => 'Memex vuole confermare';

  @override
  String get clarificationTextHint => 'Digita una risposta breve';

  @override
  String get clarificationTextRequired => 'Aggiungi prima una risposta breve';

  @override
  String get clarificationAnswered => 'Risposto';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Risposta: $answer';
  }

  @override
  String get answerSaved => 'Risposta salvata';

  @override
  String get clarificationOtherAnswer => 'Inserimento manuale';

  @override
  String get clarificationNotSure => 'Non sono sicuro/preferisco non dirlo';

  @override
  String get yes => 'SÌ';

  @override
  String get no => 'NO';

  @override
  String get footprintMap => 'Mappa delle impronte';

  @override
  String get waypointPlaces => 'Luoghi di passaggio';

  @override
  String get unknownPlace => 'Luogo sconosciuto';

  @override
  String get releaseToSend => 'Rilascia per inviare';

  @override
  String get selectFromAlbum => 'Seleziona dall\'album';

  @override
  String get clipboardPreviewTitle => 'Nuovi appunti';

  @override
  String get clipboardPreviewImageTitle => 'Immagine negli appunti';

  @override
  String get clipboardPreviewImageDescription =>
      'Immagine pronta per essere aggiunta';

  @override
  String get clipboardPreviewUnprocessed => 'Non ancora incollato';

  @override
  String get clipboardPreviewPasteToInput => 'Incolla nell\'input';

  @override
  String get clipboardPreviewAddImageToInput => 'Aggiungi immagine';

  @override
  String get clipboardPreviewImageFailed =>
      'Impossibile leggere l\'immagine negli appunti';

  @override
  String get tellAiWhatHappened => 'Racconta all\'IA cosa è successo...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Registrazione: $duration';
  }

  @override
  String get playing => 'Giocando...';

  @override
  String get sendLabel => 'Inviare';

  @override
  String attachedImagesMessage(Object count) {
    return 'Inviato/i immagini $count';
  }

  @override
  String get noTaskData => 'Nessun dato sull\'attività';

  @override
  String createdAtDate(Object date) {
    return 'Creato: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Aggiornato: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Durata: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Riprova: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Caricamento dettagli non riuscito, riprova più tardi.';

  @override
  String get loadFailed => 'Caricamento non riuscito';

  @override
  String loadHistoryFailed(Object error) {
    return 'Impossibile caricare la cronologia: $error';
  }

  @override
  String get reload => 'Ricaricare';

  @override
  String get aiInsightDetail => 'Dettaglio approfondimento';

  @override
  String relatedRecordsCount(Object count) {
    return 'Record correlati ($count)';
  }

  @override
  String get noRelatedRecords => 'Nessun record correlato';

  @override
  String get useFingerprintToUnlock => 'Usa l\'impronta digitale per sbloccare';

  @override
  String get locked => 'Bloccato';

  @override
  String get wrongPassword => 'Password errata';

  @override
  String get enterPassword => 'Inserisci la password';

  @override
  String get memexLocked => 'Memex è bloccato';

  @override
  String get calendarShortSun => 'Sole';

  @override
  String get calendarShortMon => 'Lun';

  @override
  String get calendarShortTue => 'Mar';

  @override
  String get calendarShortWed => 'Mercoledì';

  @override
  String get calendarShortThu => 'Gio';

  @override
  String get calendarShortFri => 'Ven';

  @override
  String get calendarShortSat => 'Sab';

  @override
  String noRecordsOnDate(Object date) {
    return 'Nessun record su $date';
  }

  @override
  String get footprintPath => 'Percorso dell\'impronta';

  @override
  String get lifeCompositionTable => 'Composizione della vita';

  @override
  String get emotionReframe => 'Riformulazione delle emozioni';

  @override
  String get chronicleOfThings => 'Cronaca delle cose';

  @override
  String get goalProgress => 'Progresso dell\'obiettivo';

  @override
  String get trendChart => 'Grafico delle tendenze';

  @override
  String get comparisonChart => 'Grafico comparativo';

  @override
  String get todayTimeFlow => 'Il flusso del tempo di oggi';

  @override
  String get aiInputHint =>
      'Che si tratti di ricordi o del presente, sono qui...';

  @override
  String get refreshSuperAgentStateTooltip =>
      'Cancella il contesto dell\'agente Memex';

  @override
  String get refreshSuperAgentStateTitle =>
      'Cancellare il contesto della cronologia dell\'agente Memex?';

  @override
  String get refreshSuperAgentStateMessage =>
      'La cronologia chat visibile rimarrà, ma il contesto storico di runtime di Memex Agent verrà cancellato e le risposte future inizieranno da un nuovo contesto. La memoria persistente, i file della knowledge base, le schede e gli altri dati salvati non sono interessati. Utilizzare questo quando Memex Agent continua a comportarsi in modo anomalo. Continuare?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Attendere fino al termine del messaggio corrente di Memex Agent prima di cancellare il contesto.';

  @override
  String get refreshSuperAgentStateSuccess =>
      'Il contesto dell\'agente Memex è stato cancellato';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Impossibile cancellare il contesto dell\'agente Memex: $error';
  }

  @override
  String get nothingHere => 'Niente qui ancora';

  @override
  String get nothingHereHint =>
      'Tocca il pulsante qui sotto per creare la tua prima carta';

  @override
  String get agentProcessing => 'L\'intelligenza artificiale sta elaborando...';

  @override
  String get keepAppOpen => 'Non chiudere l\'app';

  @override
  String get activityDetail => 'Dettaglio attività';

  @override
  String get noAgentActivityYet => 'Nessuna attività dell\'agente ancora';

  @override
  String get processingEllipsis => 'Elaborazione...';

  @override
  String get agentBackgroundTitle => 'Agente Memex';

  @override
  String get agentBackgroundPausedTitle =>
      'L\'agente Memex è stato messo in pausa';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'L\'agente Memex ha bisogno di attenzione';

  @override
  String get agentBackgroundStageIdle => 'Oziare';

  @override
  String get agentBackgroundStageProcessing => 'Elaborazione';

  @override
  String get agentBackgroundStageQueued => 'In coda';

  @override
  String get agentBackgroundStageRetrying => 'In attesa di riprovare';

  @override
  String get agentBackgroundStagePaused => 'In pausa';

  @override
  String get agentBackgroundStageCompleted => 'Completato';

  @override
  String get agentBackgroundStageNeedsAttention => 'Ha bisogno di attenzione';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Analisi dei media';

  @override
  String get agentBackgroundStageGeneratingCard => 'Scheda generatrice';

  @override
  String get agentBackgroundStageUpdatingKnowledge =>
      'Aggiornamento della conoscenza';

  @override
  String get agentBackgroundStagePreparingComment =>
      'Preparazione del commento';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Follow-up del percorso';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'In esecuzione $running, In sospeso $pending, Riprova $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Elaborazione delle attività in coda $count.';
  }

  @override
  String get agentBackgroundNoTasks => 'Nessuna attività in background.';

  @override
  String get agentBackgroundStarting => 'L\'elaborazione è in corso.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Tutte le attività in background sono state completate.';

  @override
  String get agentBackgroundFailedDetail =>
      'L\'elaborazione è stata interrotta con un errore.';

  @override
  String get agentBackgroundPausedDetail =>
      'L\'elaborazione è sospesa e continuerà più tardi.';

  @override
  String get agentBackgroundQueuedDetail =>
      'In attesa della fase di lavorazione successiva.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Il passaggio corrente verrà riprovato automaticamente.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Lettura degli allegati e contesto locale.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Trasformare il record in una scheda della sequenza temporale.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Aggiornamento della conoscenza e della memoria locale.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Preparazione di un follow-up dell\'assistente.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Controllo delle azioni successive per questa carta.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'In pausa - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Ha bisogno di attenzione - $summary';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get languageSettings => 'Lingua';

  @override
  String get languageSettingsDesc =>
      'Cambia la lingua di visualizzazione dell\'app';

  @override
  String get noPendingActionsToast => 'Nessuna azione in sospeso';

  @override
  String get knowledgeNewDiscovery => 'Conoscenza nuova scoperta';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Scoperto/i $count nuovi approfondimenti';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Aggiornati $count approfondimenti esistenti';
  }

  @override
  String get sectionNewInsights => 'Nuovi approfondimenti';

  @override
  String get sectionUpdatedInsights => 'Approfondimenti aggiornati';

  @override
  String get unnamedInsight => 'Intuizione senza nome';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get copy => 'Copia';

  @override
  String get selectedLocation => 'Località selezionata';

  @override
  String get confirmLocationName => 'Conferma il nome della posizione';

  @override
  String get confirmLocationNameHint =>
      'Puoi modificare il nome (le coordinate rimangono le stesse)';

  @override
  String get nameLabel => 'Nome';

  @override
  String get inputPlaceNameHint => 'Inserisci il nome del luogo...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Coordinate: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Conferma la posizione';

  @override
  String get welcomeToMemex => 'Benvenuti in Memex';

  @override
  String get createUserIdToStart => 'Crea il tuo profilo';

  @override
  String get userIdLabel => 'Il tuo nome/soprannome';

  @override
  String get userIdHint => 'Inserisci il tuo nome o soprannome';

  @override
  String get pleaseEnterUserId => 'Per favore inserisci il tuo nome';

  @override
  String get userIdMaxLength => 'Il nome non deve superare i 50 caratteri';

  @override
  String get startUsing => 'Continuare';

  @override
  String get userIdTip =>
      'Questo verrà utilizzato per personalizzare la tua esperienza.';

  @override
  String get setupModelConfigTitle =>
      'Configura un modello di intelligenza artificiale';

  @override
  String get setupModelConfigSubtitle =>
      'Memex ha bisogno di un modello di intelligenza artificiale di frontiera per organizzare record, analizzare immagini e generare approfondimenti. Scegli un metodo di connessione.';

  @override
  String get setupModelConfigComplete => 'Completa e vai';

  @override
  String get aiService => 'Servizio modelli Memex';

  @override
  String get aiModelHubTitle => 'Modelli e servizi di intelligenza artificiale';

  @override
  String get aiModelHubSubtitle =>
      'Scegli il servizio ufficiale di Memex o porta il tuo fornitore. Il routing avanzato dei modelli rimane disponibile quando ne hai bisogno.';

  @override
  String get aiSetupCurrentStatusTitle => 'Configurazione attuale';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'Il servizio AI non è configurato';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Scegli un metodo di connessione per abilitare l\'organizzazione AI per record, contenuti multimediali e approfondimenti.';

  @override
  String get aiSetupStatusMemexTitle =>
      'Utilizzando il servizio ufficiale Memex';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex utilizzerà la connessione ufficiale e le credenziali API gestite dal tuo account Memex.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Utilizzo delle impostazioni personalizzate del provider';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex utilizzerà le credenziali del fornitore configurato e le selezioni del ruolo del modello.';

  @override
  String get aiSetupChooseConnectionTitle => 'Scegli un metodo di connessione';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Inizia con il percorso che corrisponde al modo in cui desideri che Memex acceda ai modelli IA.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Accedi a Memex per utilizzare il servizio AI ufficiale.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Aggiungi il tuo provider e la chiave API.';

  @override
  String get aiSetupCustomPageTitle => 'Servizio IA personalizzato';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Configura prima le credenziali del provider, quindi scegli il modello che Memex dovrà utilizzare.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Provider e chiavi API';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Aggiungi o modifica OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama o un altro provider compatibile.';

  @override
  String get modelRolesTitle => 'Scegli il modello principale';

  @override
  String get modelRolesDescription =>
      'Super Agent utilizza un modello per gli input di testo e immagini. Le sostituzioni avanzate dell\'agente rimangono disponibili di seguito.';

  @override
  String get textModelRoleTitle => 'Modello primario';

  @override
  String get textModelRoleDescription =>
      'Utilizzato da Super Agent per testo, immagini, schede, conoscenza, approfondimenti, chat, commenti e memoria.';

  @override
  String get modelConnectionsTitle => 'Provider di modelli e chiavi API';

  @override
  String get modelConnectionsDescription =>
      'Connetti il ​​servizio ufficiale di Memex o aggiungi le credenziali del tuo fornitore.';

  @override
  String get relatedAiCapabilitiesTitle => 'Funzionalità avanzate e correlate';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Ottimizza le assegnazioni degli agenti, il provider di posizione e il comportamento di trascrizione vocale.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Capacità di servizio';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Scegli i fornitori utilizzati da Memex per le funzionalità adiacenti basate sull\'intelligenza artificiale come il parlato e la geocodifica inversa.';

  @override
  String get aiSetupAdvancedCustomizationTitle =>
      'Routing avanzato del modello';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Per utenti esperti che desiderano che i singoli agenti utilizzino provider o configurazioni di modelli diversi.';

  @override
  String get locationProviderSettings => 'Fornitore di posizione';

  @override
  String get speechProviderSettings => 'Trascrizione del discorso';

  @override
  String get advancedAgentModelAssignments =>
      'Assegnazioni del modello di agente';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Sostituisci i singoli agenti';

  @override
  String get noConfiguredModelOptions =>
      'Aggiungi un provider o una chiave API prima di scegliere i ruoli del modello.';

  @override
  String get modelSlotUpdated => 'Ruolo del modello aggiornato';

  @override
  String get aiServiceMemexRouteTitle => 'Connettiti tramite Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex utilizza un sistema multi-agente per organizzare documenti di vita, note di conoscenza e contesto sociale, scoprire approfondimenti più profondi e fornire compagnia all\'intelligenza artificiale con memoria persistente. I tuoi dati vengono archiviati come Markdown in testo semplice, preservando la libertà e la portabilità dei dati.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Ho una chiave API';

  @override
  String get aiServiceCustomModelDescription =>
      'Scegli prima questa se disponi già di una chiave API di OpenAI, Anthropic, DeepSeek, Gemini o un altro provider.';

  @override
  String get enableAiService => 'Connettiti con Memex';

  @override
  String get aiServiceReadyToast =>
      'L\'organizzazione dell\'intelligenza artificiale è attiva';

  @override
  String get aiServiceSettingsDescription =>
      'Se non disponi di una chiave API, utilizza un account Memex per connetterti ai servizi del modello tradizionale.';

  @override
  String get advancedModelConfiguration => 'Configura la chiave API';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get clearAuth => 'Cancella autenticazione';

  @override
  String get authorizing => 'Autorizzando...';

  @override
  String authFailed(Object error) {
    return 'Autenticazione non riuscita: $error';
  }

  @override
  String get authorized => 'Autorizzato';

  @override
  String authorizedAs(Object email) {
    return 'Autorizzato come $email';
  }

  @override
  String get authorizedSuccessfully => 'Autorizzato con successo';

  @override
  String get reAuthorize => 'Riautorizza';

  @override
  String get authorizeWithOpenAi => 'Autorizza con OpenAI';

  @override
  String get authorizeWithGoogle => 'Autorizza con Google';

  @override
  String get config => 'Configurazione';

  @override
  String get calendar => 'Calendario';

  @override
  String get reminders => 'Promemoria';

  @override
  String get writeToSystemFailed => 'Impossibile scrivere sul sistema';

  @override
  String permissionRequired(Object name) {
    return 'È richiesta l\'autorizzazione $name';
  }

  @override
  String permissionRationale(Object name) {
    return 'Consenti all\'app di accedere al tuo $name nelle Impostazioni in modo che possiamo crearlo per te.';
  }

  @override
  String get goToSettings => 'Vai su Impostazioni';

  @override
  String get unknownAction => 'Azione sconosciuta';

  @override
  String get discoveredCalendarEvent =>
      'Evento in calendario in attesa di conferma';

  @override
  String get discoveredReminder => 'Promemoria in attesa di conferma';

  @override
  String get addToCalendar => 'Aggiungi al calendario';

  @override
  String get addToReminders => 'Aggiungi ai promemoria';

  @override
  String get systemActionPendingExplanation =>
      'Non ancora aggiunto. Tocca di seguito per richiedere l\'autorizzazione e aggiungerla al tuo dispositivo.';

  @override
  String addedToSuccess(Object target) {
    return 'Aggiunto con successo a $target';
  }

  @override
  String get ignore => 'Ignorare';

  @override
  String get confirmDelete => 'Conferma l\'eliminazione';

  @override
  String get confirmDeleteSessionMessage =>
      'Eliminare questa conversazione? Questa operazione non può essere annullata.';

  @override
  String get delete => 'Eliminare';

  @override
  String get deleteSuccess => 'Eliminato con successo';

  @override
  String deleteFailed(Object error) {
    return 'Eliminazione non riuscita: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count giorni fa';
  }

  @override
  String get chatHistory => 'Cronologia chat';

  @override
  String get enterFullScreenTooltip => 'Entra a schermo intero';

  @override
  String get exitFullScreenTooltip => 'Esci dallo schermo intero';

  @override
  String get noConversations => 'Nessuna conversazione';

  @override
  String loadSessionListFailed(Object error) {
    return 'Impossibile caricare l\'elenco delle sessioni: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Ieri $time';
  }

  @override
  String get newChat => 'Nuova chiacchierata';

  @override
  String messageCount(Object count) {
    return '$count messaggi';
  }

  @override
  String get organize => 'Organizzare';

  @override
  String get pkmCategoryProject => 'Progetto';

  @override
  String get pkmCategoryProjectSubtitle =>
      'A breve termine · Obiettivi · Scadenze';

  @override
  String get pkmCategoryArea => 'Zona';

  @override
  String get pkmCategoryAreaSubtitle =>
      'A lungo termine · Responsabilità · Standard';

  @override
  String get pkmCategoryResource => 'Risorsa';

  @override
  String get pkmCategoryResourceSubtitle => 'Interessi · Ispirazione · Riserva';

  @override
  String get pkmCategoryArchive => 'Archivio';

  @override
  String get pkmCategoryArchiveSubtitle => 'Fatto · Inattivo · Riferimento';

  @override
  String get recentChanges => 'Cambiamenti recenti';

  @override
  String get noRecentChangesInThreeDays =>
      'Nessun cambiamento negli ultimi 3 giorni';

  @override
  String get unpinned => 'Sbloccato';

  @override
  String get pinnedStyle => 'Stile appuntato';

  @override
  String operationFailed(Object error) {
    return 'Operazione non riuscita: $error';
  }

  @override
  String get refreshingInsightData =>
      'Aggiornamento dei dati approfonditi. L\'operazione potrebbe richiedere qualche istante...';

  @override
  String refreshFailed(Object error) {
    return 'Aggiornamento non riuscito: $error';
  }

  @override
  String get sortUpdated => 'Ordinamento aggiornato';

  @override
  String sortSaveFailed(Object error) {
    return 'Impossibile salvare l\'ordinamento: $error';
  }

  @override
  String get insightCardDeleted => 'Scheda informativa eliminata';

  @override
  String deleteFailedShort(Object error) {
    return 'Eliminazione non riuscita: $error';
  }

  @override
  String get knowledgeInsight => 'Approfondimento della conoscenza';

  @override
  String get completeSort => 'Ordinamento completo';

  @override
  String get noKnowledgeInsight => 'Nessuna conoscenza approfondita';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return 'Le attività in background $count sono ancora in fase di elaborazione.';
  }

  @override
  String get insightUnavailableMessage =>
      'Questo insight è ancora in fase di generazione o è stato aggiornato. Aggiorna gli approfondimenti e riprova più tardi.';

  @override
  String get artifactOpen => 'Aprire';

  @override
  String get updating => 'Aggiornamento...';

  @override
  String get update => 'Aggiornamento';

  @override
  String get enabled => 'Abilitato';

  @override
  String get disabled => 'Disabilitato';

  @override
  String get appLockOn => 'Blocco app abilitato';

  @override
  String get appLockOff => 'Blocco app disabilitato';

  @override
  String get enableAppLockFirst => 'Abilita prima il blocco dell\'app';

  @override
  String get enterFourDigitPassword => 'Inserisci la password di 4 cifre';

  @override
  String get passwordSetAndLockOn =>
      'Password impostata e blocco app abilitato';

  @override
  String get appLockSettings => 'Impostazioni di blocco dell\'app';

  @override
  String get enableAppLock => 'Abilita il blocco dell\'app';

  @override
  String get enableAppLockSubtitle => 'Password richiesta all\'avvio dell\'app';

  @override
  String get enableBiometrics => 'Abilita la biometria';

  @override
  String get biometricsSubtitle => 'Utilizza Face ID o Touch ID per sbloccare';

  @override
  String get changePassword => 'Cambiare la password';

  @override
  String get setFourDigitPassword => 'Imposta una password di 4 cifre';

  @override
  String get reenterPasswordToConfirm =>
      'Reinserire la password per confermare';

  @override
  String get passwordMismatch =>
      'Le password non corrispondono. Per favore riprova.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Eliminare il carattere \"$name\"? Questa operazione non può essere annullata.';
  }

  @override
  String get configureAiCharacter => 'Configura il personaggio AI';

  @override
  String get addCharacter => 'Aggiungi carattere';

  @override
  String get addCharacterSubtitle =>
      'Scegli i personaggi IA per unirti al tuo team di intuizione. Analizzeranno i dati della tua vita da diverse angolazioni.';

  @override
  String get noCharacters => 'Nessun personaggio';

  @override
  String loadCharacterFailed(Object error) {
    return 'Impossibile caricare i caratteri: $error';
  }

  @override
  String get noTags => 'Nessun tag';

  @override
  String get createSuccess => 'Creato con successo';

  @override
  String get updateSuccess => 'Aggiornato con successo';

  @override
  String saveFailed(Object error) {
    return 'Salvataggio non riuscito: $error';
  }

  @override
  String get newCharacter => 'Nuovo personaggio';

  @override
  String get editCharacter => 'Modifica personaggio';

  @override
  String get save => 'Salva';

  @override
  String get characterName => 'Nome del personaggio';

  @override
  String get characterNameHint => 'Dai un nome al tuo personaggio';

  @override
  String get pleaseEnterCharacterName => 'Inserisci il nome del personaggio';

  @override
  String get tagsLabel => 'Tag';

  @override
  String get tagsHint =>
      'per esempio. saggezza, riconoscimento, macro\nSepara più tag con virgole';

  @override
  String get characterPersonaLabel => 'Persona di carattere';

  @override
  String get characterPersonaHint =>
      'Includi persona, guida di stile, dialogo di esempio, filtri di conoscenza, ecc.\nUtilizzare ## per le intestazioni delle sezioni.';

  @override
  String get pleaseEnterCharacterPersona =>
      'Inserisci il personaggio del personaggio';

  @override
  String permissionRequestError(Object error) {
    return 'Errore nella richiesta di autorizzazione: $error';
  }

  @override
  String get permissionRequiredTitle => 'Permesso richiesto';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Hai negato permanentemente questa autorizzazione oppure il sistema la richiede. Si prega di abilitarlo nelle impostazioni di sistema.';

  @override
  String get getting => 'Ottenere...';

  @override
  String get unauthorized => 'Non autorizzato';

  @override
  String get authorizedGoToSettings =>
      'Autorizzato. Vai alle impostazioni di sistema per modificare.';

  @override
  String get location => 'Posizione';

  @override
  String get locationPermissionReason =>
      'Per registrare luoghi e caratteristiche relative alla posizione';

  @override
  String get photos => 'Foto';

  @override
  String get photosPermissionReason =>
      'Per selezionare foto, salvare immagini generate, ecc.';

  @override
  String get camera => 'Telecamera';

  @override
  String get cameraPermissionReason => 'Per scattare foto e video';

  @override
  String get microphone => 'Microfono';

  @override
  String get microphonePermissionReason =>
      'Per il riconoscimento vocale, la registrazione, ecc.';

  @override
  String get calendarPermissionReason =>
      'Per registrare il programma e leggere gli eventi del calendario';

  @override
  String get remindersPermissionReason =>
      'Per registrare e leggere i tuoi promemoria';

  @override
  String get fitnessAndMotion => 'Fitness e movimento';

  @override
  String get fitnessPermissionReason =>
      'Per la registrazione di dati sulla salute e sul movimento';

  @override
  String get notification => 'Notifica';

  @override
  String get notificationPermissionReason =>
      'Per inviare programmi e promemoria importanti';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Mantieni Memex Agent in esecuzione in background';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent viene eseguito localmente sul tuo dispositivo. Le notifiche consentono a Memex di mostrare i progressi e di continuare l\'elaborazione dopo aver lasciato l\'app o spento lo schermo. Se le notifiche sono disattivate, mantieni Memex aperto in primo piano fino al termine dell\'attività.';

  @override
  String get loadDetailFailedRetryShort =>
      'Caricamento dettagli non riuscito, riprova più tardi.';

  @override
  String get total => 'Totale';

  @override
  String get estimatedCost => 'Costo stimato';

  @override
  String get byAgent => 'Per Agente';

  @override
  String get timeUpdated => 'Ora aggiornata';

  @override
  String updateFailed(Object error) {
    return 'Aggiornamento non riuscito: $error';
  }

  @override
  String get locationUpdated => 'Posizione aggiornata';

  @override
  String get confirmDeleteCardMessage =>
      'Eliminare questa carta? Questa operazione non può essere annullata.';

  @override
  String get cardDetailNotFound => 'Dettagli della carta non trovati';

  @override
  String get saySomething => 'Di \'qualcosa...';

  @override
  String get relatedMemories => 'Ricordi correlati';

  @override
  String get viewMore => 'Visualizza altro';

  @override
  String get relatedRecords => 'Record correlati';

  @override
  String get reply => 'Rispondere';

  @override
  String get replySent => 'Risposta inviata';

  @override
  String get insightTemplateGalleryTitle => 'Modelli di schede informative';

  @override
  String get timelineTemplateGalleryTitle =>
      'Modelli di carte della sequenza temporale';

  @override
  String get categoryTextual => 'Testuale';

  @override
  String get timelineFilterAll => 'TUTTO';

  @override
  String get insights => 'Approfondimenti';

  @override
  String get memoryTitle => 'Memoria';

  @override
  String get longTermProfile => 'Profilo a lungo termine';

  @override
  String get recentBuffer => 'Buffer recente';

  @override
  String errorLoadingMemory(Object error) {
    return 'Errore durante il caricamento della memoria: $error';
  }

  @override
  String get agentConfiguration => 'Configurazione dell\'agente';

  @override
  String get resetToDefaults => 'Ripristina le impostazioni predefinite';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Reimposta tutte le configurazioni dell\'agente';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Sei sicuro di voler reimpostare tutte le configurazioni dell\'agente sui valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get resetButton => 'Reset';

  @override
  String loadDataFailed(Object error) {
    return 'Impossibile caricare i dati: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Impossibile salvare la configurazione: $error';
  }

  @override
  String get selectLlmClient => 'Seleziona cliente LLM:';

  @override
  String get agentConfigurationsReset =>
      'Ripristino delle configurazioni dell\'agente';

  @override
  String resetFailed(Object error) {
    return 'Impossibile reimpostare: $error';
  }

  @override
  String get modelConfiguration => 'Configurazione del modello';

  @override
  String get resetAllConfigurationsTitle =>
      'Ripristina tutte le configurazioni';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Sei sicuro di voler reimpostare tutte le configurazioni del modello sui valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get modelConfigurationsReset =>
      'Ripristino delle configurazioni del modello';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Impossibile eliminare la configurazione predefinita';

  @override
  String get cannotDeleteConfigurationTitle =>
      'Impossibile eliminare la configurazione';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Questa configurazione è attualmente utilizzata dai seguenti agenti:\n\n$agentList\n\nRiassegna questi agenti prima di eliminarli.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Elimina configurazione';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Sei sicuro di voler eliminare \"$key\"?';
  }

  @override
  String get defaultLabel => 'Predefinito';

  @override
  String get setAsDefault => 'Imposta come predefinito';

  @override
  String get invalidJsonInExtraField => 'JSON non valido nel campo Extra';

  @override
  String get keyAlreadyExists => 'La chiave esiste già';

  @override
  String get resetConfigurationTitle => 'Ripristina configurazione';

  @override
  String get resetConfigurationMessage =>
      'Ripristinare questa configurazione ai valori predefiniti iniziali? Le modifiche attuali andranno perse.';

  @override
  String get configurationResetPressSave =>
      'Ripristino della configurazione. Premi Salva per applicare.';

  @override
  String get addConfiguration => 'Aggiungi configurazione';

  @override
  String get editConfiguration => 'Modifica configurazione';

  @override
  String get duplicateConfiguration => 'Configurazione duplicata';

  @override
  String get duplicate => 'Duplicato';

  @override
  String get keyIdLabel => 'ID di configurazione';

  @override
  String get keyIdHelper =>
      'Assegna un nome a questa configurazione, ad esempio deepseek o work-gpt.';

  @override
  String get required => 'Necessario';

  @override
  String get clientLabel => 'Fornitore di modelli';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Antropico';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Popolare';

  @override
  String get providerOpenAiApiKey => 'Chiave API';

  @override
  String get providerOpenAiResponses => 'Chiave API (risposte)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'Chiave API';

  @override
  String get providerBedrockSecret => 'Segreto del fondamento roccioso';

  @override
  String get providerGemini => 'Gemelli';

  @override
  String get providerGeminiOauth => 'Gemelli (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Moonshot)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'ZhipuGLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (locale)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Servizio proxy Memex';

  @override
  String get memexSignIn => 'Registrazione';

  @override
  String get memexCreateAccount => 'Creare un account';

  @override
  String get memexUsername => 'Nome utente';

  @override
  String get memexPassword => 'Password';

  @override
  String get memexCreateAccountLink => 'Creare un account';

  @override
  String get memexSignInLink => 'Accedi invece';

  @override
  String get memexTopUp => 'Ricarica per iniziare a utilizzare Memex AI';

  @override
  String get memexTopUpSuccess => 'Ricarica riuscita!';

  @override
  String get memexFillAllFields => 'Si prega di compilare tutti i campi';

  @override
  String get memexUsernameTooShort =>
      'Il nome utente deve contenere almeno 6 caratteri';

  @override
  String get memexAuthFailed => 'Autenticazione non riuscita';

  @override
  String get memexPaymentFailed => 'Impossibile creare il pagamento';

  @override
  String get memexLogout => 'Esci';

  @override
  String get memexTopUpButton => 'Ricaricare';

  @override
  String get memexTopUpChooseAmount => 'Scegli un importo';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Informazioni sui record $range';
  }

  @override
  String get memexTopUpPlanStarter => 'Antipasto';

  @override
  String get memexTopUpPlanEveryday => 'Ogni giorno';

  @override
  String get memexTopUpPlanHighVolume => 'Alto volume';

  @override
  String get memexTopUpPlanCustom => 'Crediti personalizzati';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Buono per provare Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Buono per l\'organizzazione regolare';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Buono per lotti più grandi';

  @override
  String get memexTopUpPlanCustomSubtitle =>
      'Inserisci un valore compreso tra 1 e 10.000 USD';

  @override
  String get memexTopUpCustomEstimate =>
      'La stima si basa sull\'importo inserito';

  @override
  String get memexCustomAmount => 'Importo personalizzato';

  @override
  String get memexViewHistory => 'Cronologia dell\'utilizzo';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Saldo: $amount';
  }

  @override
  String get memexConfirmPassword => 'Conferma password';

  @override
  String get memexPasswordMismatch => 'Le password non corrispondono';

  @override
  String memexPayAmount(Object amount) {
    return 'Ricarica $amount';
  }

  @override
  String get modelIdLabel => 'Modello';

  @override
  String get modelIdHelper => 'per esempio. gemini-3.1-pro-anteprima, gpt-4o';

  @override
  String get fetchingModels => 'Recupero modelli in corso...';

  @override
  String get fetchModelsButton => 'Recupera modelli';

  @override
  String get enterApiKeyFirst =>
      'Inserisci prima la chiave API per recuperare i modelli';

  @override
  String get apiKeyLabel => 'Chiave API';

  @override
  String get baseUrlLabel => 'Endpoint API';

  @override
  String get advancedSettings => 'Impostazioni avanzate';

  @override
  String get testConnectionSuccess => 'Connessione riuscita';

  @override
  String get testConnectionFailed => 'Connessione non riuscita';

  @override
  String get testTypeText => 'Testo';

  @override
  String get testTypeVision => 'Visione';

  @override
  String get testButton => 'Test';

  @override
  String get testing => 'Prova...';

  @override
  String get proxyUrlOptional => 'URL proxy (facoltativo)';

  @override
  String get proxyUrlHelper => 'per esempio. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperatura';

  @override
  String get topPLabel => 'Superiore P';

  @override
  String get maxTokensLabel => 'Gettoni massimi';

  @override
  String get extraParamsJson => 'Parametri aggiuntivi (JSON)';

  @override
  String get invalidJson => 'JSON non valido';

  @override
  String get warning => 'Configurazione incompleta';

  @override
  String get invalidConfigurationWarning =>
      'La configurazione non è ancora completa (ad esempio, manca la chiave API o l\'ID modello). Puoi comunque salvarlo e configurarlo in seguito. Continuare?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'L\'agente AI \"$agentId\" necessita di una configurazione del modello valida (chiave: \"$configKey\") per funzionare. Si prega di verificare le impostazioni del modello.';
  }

  @override
  String get discardChangesTitle => 'Lasciare questa pagina?';

  @override
  String get discardChangesMessage =>
      'Se hai apportato modifiche, salvale prima di uscire.';

  @override
  String get discardButton => 'Scartare';

  @override
  String get chooseLanguage => 'Scegli la lingua';

  @override
  String get chooseAvatar => 'Scegli Avatar';

  @override
  String get configureNow => 'Configura ora';

  @override
  String get modelNotConfiguredBanner =>
      'Modello AI non ancora configurato. Configuralo per sbloccare tutte le funzionalità.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Configura un modello AI prima della pubblicazione';

  @override
  String get processingStatus => 'Elaborazione';

  @override
  String get failedStatus => 'Fallito';

  @override
  String get failureReason => 'Motivo del fallimento';

  @override
  String get unknownError => 'Si è verificato un errore sconosciuto';

  @override
  String get enableFitness => 'Abilita Fitness';

  @override
  String get fitnessBannerMessage =>
      'Consenti l\'accesso al fitness per monitorare i dati relativi alla tua salute e alle tue attività.';

  @override
  String get fitnessDismissTitle => 'Saltare l\'accesso al fitness?';

  @override
  String get fitnessDismissMessage =>
      'Senza l\'autorizzazione per l\'attività fisica, l\'app non sarà in grado di raccogliere automaticamente i tuoi dati sanitari per approfondimenti e registrazioni automatiche.';

  @override
  String get skipAnyway => 'Salta comunque';

  @override
  String get proModelHint =>
      'Questo modello richiede un abbonamento ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Cerca nella base di conoscenza...';

  @override
  String get searchKnowledgeHint =>
      'Inserisci la parola chiave per cercare nomi di file o contenuti';

  @override
  String noSearchResults(Object query) {
    return 'Nessun risultato trovato per \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'È supportata solo l\'anteprima Markdown';

  @override
  String get backupAndRestore => 'Backup e ripristino';

  @override
  String get createBackup => 'Crea backup';

  @override
  String get restoreBackup => 'Ripristina backup';

  @override
  String get backupDescription =>
      'Raccogli tutti i tuoi dati (schede, knowledge base, approfondimenti, impostazioni) in un file .memex. Salvalo su iCloud Drive, Google Drive o qualsiasi posizione tramite il foglio di condivisione.';

  @override
  String get restoreDescription =>
      'Seleziona un file di backup .memex per ripristinare tutti i dati. Ciò sovrascriverà i dati correnti.';

  @override
  String get selectBackupFile => 'Seleziona File di backup';

  @override
  String get estimatedSize => 'Dimensioni stimate';

  @override
  String get backupComplete => 'Backup creato';

  @override
  String backupFailed(Object error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String get confirmRestore => 'Conferma ripristino';

  @override
  String get confirmRestoreMessage =>
      'Il ripristino sovrascriverà tutti i dati correnti, incluse schede, knowledge base, approfondimenti e impostazioni. Questa operazione non può essere annullata. Continuare?';

  @override
  String get restoreComplete => 'Ripristino completato';

  @override
  String get restoreRestartHint =>
      'I dati sono stati ripristinati. Riavvia l\'app affinché tutte le modifiche abbiano effetto.';

  @override
  String restoreFailed(Object error) {
    return 'Ripristino non riuscito: $error';
  }

  @override
  String get invalidBackupFile =>
      'File di backup non valido. Seleziona un file .memex.';

  @override
  String get automaticBackup => 'Backup automatico';

  @override
  String get autoBackupDescription =>
      'Se abilitato, Memex crea al massimo uno snapshot locale al giorno dopo l\'avvio o quando torna in primo piano.';

  @override
  String get backupSensitiveSettingsHint =>
      'I backup includono le impostazioni e le chiavi del provider del modello. Conserva i file di backup in un posto di cui ti fidi.';

  @override
  String get backupLocation => 'Posizione';

  @override
  String get backupLocationDetails => 'Dettagli sulla posizione';

  @override
  String get backupLocationSummary => 'Mostrato nell\'app';

  @override
  String get backupLocationFullPath => 'Percorso completo';

  @override
  String get backupLocationUri => 'URI di accesso alla cartella';

  @override
  String get copyBackupLocationPath => 'Copia percorso';

  @override
  String get backupLocationCopied => 'Posizione del backup copiata';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Cartella selezionata: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backup';

  @override
  String get iosAppDocumentsBackupLocation =>
      'File > Sul mio iPhone > Memex > Backup';

  @override
  String get autoBackupStatus => 'Stato';

  @override
  String get noAutoBackupYet => 'Nessun backup automatico ancora';

  @override
  String lastBackupAt(Object time) {
    return 'Ultimo backup: $time';
  }

  @override
  String get autoBackupRetention => 'Conservazione';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days giorni';
  }

  @override
  String get autoBackupRetentionForever => 'Conserva per sempre';

  @override
  String get autoBackupMaxSize => 'Tappo di stoccaggio';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'La pulizia automatica mantiene gli snapshot automatici in $size. Le istantanee di sicurezza e le esportazioni manuali vengono conservate separatamente.';
  }

  @override
  String get createSnapshotNow => 'Esegui il backup adesso';

  @override
  String get backupLocationMenu => 'Cambia posizione';

  @override
  String get defaultBackupLocation => 'Cartella di backup predefinita';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Utilizza la cartella dei file esterni specifica dell\'app di Memex. Non è necessaria alcuna autorizzazione di archiviazione.';

  @override
  String get chooseBackupLocation => 'Scegli la cartella di backup';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Scegli una cartella con il selettore di sistema di Android e concedi l\'accesso permanente a Memex.';

  @override
  String get storedBackups => 'Backup archiviati';

  @override
  String get noStoredBackups =>
      'I backup automatici verranno visualizzati qui dopo la prima istantanea.';

  @override
  String get backupTypeAutoSnapshot => 'Istantanea automatica';

  @override
  String get backupTypeSafetySnapshot => 'Istantanea sulla sicurezza';

  @override
  String get backupTypeManualBackup => 'Backup manuale';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get restoreThisBackup => 'Ripristina questo backup';

  @override
  String get deleteThisBackup => 'Elimina questo backup';

  @override
  String get confirmDeleteBackup => 'Eliminare il backup?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Eliminare $fileName? Questa operazione rimuove il file di backup archiviato e non può essere annullata.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Backup eliminato: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Impossibile eliminare il backup: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Creazione istantanea di sicurezza...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Istantanea creata: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Impossibile aggiornare la posizione del backup: $error';
  }

  @override
  String get backupImportCreatedAt => 'Creato';

  @override
  String get backupImportSourceVersion => 'Versione sorgente';

  @override
  String get backupImportFlavor => 'Costruire';

  @override
  String get backupLegacyFormat => 'Backup legacy (nessun manifest)';

  @override
  String get restoreInProgress => 'Ripristino del backup...';

  @override
  String get dataStorage => 'Archiviazione dei dati';

  @override
  String get dataStorageDescriptionAndroid =>
      'Scegli una cartella personalizzata in cui archiviare il tuo spazio di lavoro. I dati vengono conservati quando reinstalli l\'app.';

  @override
  String get dataStorageDescriptionIOS =>
      'Attiva iCloud per sincronizzare il tuo spazio di lavoro su tutti i dispositivi e conservare i dati quando reinstalli l\'app.';

  @override
  String get storageLocationApp => 'Archiviazione dell\'app';

  @override
  String get storageLocationAppDesc =>
      'I dati vengono archiviati all\'interno dell\'app e verranno rimossi durante la disinstallazione.';

  @override
  String get storageLocationCustom =>
      'Archiviazione del dispositivo (cartella personalizzata)';

  @override
  String get storageLocationCustomDesc =>
      'Memorizza i dati in una cartella di tua scelta. I dati persistono durante la reinstallazione se la cartella rimane.';

  @override
  String get storageLocationICloud => 'Archivia su iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Sincronizza il tuo spazio di lavoro su tutti i dispositivi Apple. I dati rimangono dopo la reinstallazione.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Attuale: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Accedi a iCloud e attiva iCloud Drive per utilizzare lo spazio di archiviazione di iCloud.';

  @override
  String get loadingFromICloud => 'Ripristino dei dati da iCloud…';

  @override
  String get switchingToICloud =>
      'Passaggio allo spazio di archiviazione iCloud…';

  @override
  String get switchingStorage => 'Cambio di spazio di archiviazione…';

  @override
  String get customFolderAccessDenied =>
      'Impossibile leggere o scrivere in questa cartella. Concedi l\'autorizzazione di archiviazione o scegli un\'altra posizione.';

  @override
  String get configured => 'Configurato';

  @override
  String get apiKeyNotSet => 'Chiave API non impostata: tocca per configurare';

  @override
  String get bottomNavTimeline => 'Cronologia';

  @override
  String get bottomNavLibrary => 'Biblioteca';

  @override
  String get aiGeneratedLabel => 'Generato dall\'intelligenza artificiale';

  @override
  String sourceTraceWithCount(Object count) {
    return 'TRACCIA ORIGINE ($count)';
  }

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountDesc =>
      'Elimina definitivamente tutti i dati locali e ripristina l\'app.';

  @override
  String get deleteAccountConfirmTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountConfirmMessage =>
      'Ciò eliminerà definitivamente tutti i tuoi dati, comprese le schede della sequenza temporale, la knowledge base, le registrazioni e le impostazioni. Questa azione non può essere annullata.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Digita \"$name\" per confermare';
  }

  @override
  String get deleteAccountTypeHint =>
      'Inserisci il tuo nome utente per confermare';

  @override
  String get llmConsentTitle => 'Consenso alla condivisione dei dati';

  @override
  String llmConsentMessage(Object provider) {
    return 'Per abilitare le funzionalità AI, Memex deve inviare i tuoi dati a $provider per l\'elaborazione. Ciò include:\n\n• Testo inserito (note, trascrizioni vocali)\n• Metadati delle foto e testo estratto (OCR)\n• Riepiloghi di salute e forma fisica\n• Contenuto della scheda Cronologia\n\nI tuoi dati vengono inviati direttamente dal tuo dispositivo a $provider. Memex non memorizza né trasmette i tuoi dati attraverso nessun altro server.\n\nConsulta l\'informativa sulla privacy di $provider per sapere come gestiscono i tuoi dati.\n\nAccetti di inviare i tuoi dati a $provider per l\'elaborazione AI?';
  }

  @override
  String get llmConsentAgree => 'Sono d\'accordo';

  @override
  String get llmConsentDecline => 'Declino';

  @override
  String get customAgents => 'Agenti personalizzati';

  @override
  String get noCustomAgents => 'Nessun agente personalizzato configurato.';

  @override
  String get deleteAgent => 'Elimina agente';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Eliminare l\'agente personalizzato \"$name\"?';
  }

  @override
  String get deleted => 'Eliminato';

  @override
  String get saved => 'Salvato';

  @override
  String get newAgent => 'Nuovo agente';

  @override
  String get editAgent => 'Modifica agente';

  @override
  String get agentName => 'Nome dell\'agente';

  @override
  String get agentNameHint => 'il mio agente personalizzato';

  @override
  String get agentNameRequired => 'Necessario';

  @override
  String get agentNameInvalid => 'Solo lettere, cifre e trattini';

  @override
  String get agentNameExists => 'Il nome esiste già';

  @override
  String get hostAgentType => 'Tipo di agente host';

  @override
  String get skillDirectory => 'Elenco delle competenze';

  @override
  String get skillDirInvalid =>
      'Deve essere un percorso relativo (non iniziale / o ..)';

  @override
  String get workingDirectory => 'Directory di lavoro (facoltativo)';

  @override
  String get workingDirectoryHint =>
      'Lasciare vuoto per impostazione predefinita dell\'area di lavoro';

  @override
  String get llmConfig => 'Configurazione LLM';

  @override
  String get eventType => 'Tipo di evento';

  @override
  String get executionMode => 'Modalità di esecuzione';

  @override
  String get executionModeAsync => 'Asincrono';

  @override
  String get executionModeSync => 'Sincronizzazione';

  @override
  String get dependsOn => 'Dipende';

  @override
  String get dependsOnHint => 'Seleziona dipendenze';

  @override
  String get priority => 'Priorità';

  @override
  String get maxRetries => 'Numero massimo di tentativi';

  @override
  String get systemPromptLabel => 'Prompt del sistema (facoltativo)';

  @override
  String get systemPromptHint =>
      'Ulteriori istruzioni aggiunte al prompt dell\'agente host';

  @override
  String get eventSerializer => 'Serializzatore di eventi';

  @override
  String get eventSerializerDefault => 'Predefinito (XML)';

  @override
  String get enabledLabel => 'Abilitato';

  @override
  String get skillsManagement => 'Gestione delle competenze';

  @override
  String get skillsManagementEmpty => 'Nessuna competenza ancora';

  @override
  String get downloadSkill => 'Scarica Abilità';

  @override
  String get downloadFile => 'Scarica file';

  @override
  String get downloading => 'Download in corso...';

  @override
  String get downloadSuccess => 'Abilità scaricata correttamente';

  @override
  String downloadFailed(Object error) {
    return 'Download non riuscito: $error';
  }

  @override
  String get deleteConfirm => 'Conferma eliminazione';

  @override
  String deleteConfirmMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get invalidUrl => 'Inserisci un URL valido';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Nuova cartella';

  @override
  String get newFile => 'Nuovo fascicolo';

  @override
  String get folderName => 'Nome della cartella';

  @override
  String get fileName => 'Nome del file';

  @override
  String get nameRequired => 'Il nome è obbligatorio';

  @override
  String get nameInvalid => 'Il nome non può contenere / o ..';

  @override
  String createFailed(Object error) {
    return 'Creazione non riuscita: $error';
  }

  @override
  String get fileContent => 'Contenuto del file';

  @override
  String get saveSuccess => 'Salvato con successo';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Lo zip verrà estratto nella directory corrente: $dir';
  }

  @override
  String get privacyPolicy => 'politica sulla riservatezza';

  @override
  String get privacyPolicyDesc => 'Come Memex gestisce i tuoi dati';

  @override
  String get llmAuthError =>
      'Autenticazione API non riuscita. Controlla la configurazione LLM in Impostazioni.';

  @override
  String get llmBadRequestError =>
      'La richiesta è stata respinta dal fornitore LLM. Il formato di input potrebbe non essere supportato dal modello attuale.';

  @override
  String get llmRateLimitError =>
      'Limite di velocità API superato. Per favore riprova più tardi.';

  @override
  String get llmServerError =>
      'Il servizio LLM è temporaneamente non disponibile. Per favore riprova più tardi.';

  @override
  String get llmNetworkError =>
      'Connessione di rete non riuscita. Controlla la tua connessione Internet.';

  @override
  String get llmUnknownError =>
      'Si è verificato un errore imprevisto durante l\'elaborazione del contenuto.';

  @override
  String get llmErrorDialogTitle => 'Elaborazione non riuscita';

  @override
  String get goToModelConfig => 'Vai su Impostazioni';

  @override
  String get speechModelDownloadTitle => 'Scarica il modello vocale';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'È richiesto un download del modello una tantum (~${sizeMB}MB).\n\nUna volta scaricata, la trascrizione viene eseguita interamente sul dispositivo.';
  }

  @override
  String get speechModelStartDownload => 'Avvia il download';

  @override
  String get speechModelChooseSource => 'Scegli la fonte di download:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (più veloce in CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (globale)';

  @override
  String get speechModelDownloading => 'Download del modello...';

  @override
  String get speechModelConnecting => 'Connessione...';

  @override
  String get deleteSpeechModel => 'Elimina modello vocale';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Eliminare i file del modello di riconoscimento vocale locale scaricati? Verranno scaricati di nuovo la prossima volta che verrà utilizzata la sintesi vocale locale.';

  @override
  String get speechModelDeletedSuccess => 'File del modello vocale eliminati';

  @override
  String get speechModelNotDownloaded =>
      'Nessun file del modello vocale scaricato trovato';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Impossibile eliminare i file del modello vocale: $error';
  }

  @override
  String get speechTranscribing => 'Riconoscere...';

  @override
  String get speechNoResult => 'Nessun parlato rilevato';

  @override
  String get useLocalSpeechToTextTitle =>
      'Utilizza la parlata locale per inviare messaggi di testo';

  @override
  String get useLocalSpeechToTextDesc =>
      'Se abilitato, l\'audio viene trascritto sul dispositivo prima dell\'invio, utile per i modelli che non supportano l\'input audio. Quando disabilitato, l\'audio originale viene inviato direttamente al modello.';

  @override
  String get pendingAiProcessingHint => 'Configura il modello AI da elaborare';

  @override
  String get demoWelcome =>
      'Benvenuti in Memex!\nFacciamo un breve tour di ciò che l\'intelligenza artificiale può fare per i tuoi record.';

  @override
  String get demoTapAdd => 'Tocca qui per creare il tuo primo record';

  @override
  String get demoTapSend => 'Tocca per inviare il tuo primo record';

  @override
  String get demoTapCard =>
      'Tocca per vedere come l\'IA ha organizzato il tuo record';

  @override
  String get demoDetailHint =>
      'Questo è il dettaglio del tuo record organizzato dall\'intelligenza artificiale. Scorri intorno, quindi torna indietro per continuare il tour.';

  @override
  String get demoTapInsight =>
      'Tocca per visualizzare gli approfondimenti generati dall\'intelligenza artificiale';

  @override
  String get demoTapInsightUpdate =>
      'Tocca per generare approfondimenti dai tuoi record';

  @override
  String get demoTapKnowledge =>
      'Controlla i tuoi file di conoscenza organizzati automaticamente';

  @override
  String get demoDone => 'Inizia a registrare la tua vita.';

  @override
  String get demoStartTour => 'Inizia il giro';

  @override
  String get demoGetStarted => 'Inizia';

  @override
  String get demoSkip => 'Saltare';

  @override
  String get demoPrefillText => 'Ciao Memex! Questo è il mio primo disco 🎉';

  @override
  String get visionBadge => 'Visione';

  @override
  String get notMultimodalHint =>
      'Memex si affida alle capacità del modello multimodale per l\'analisi dei media. Se i tuoi record contengono immagini, assicurati che il modello configurato supporti l\'input di immagini.';

  @override
  String get defaultModelPrefix => 'Predefinito';

  @override
  String get recommendedBadge => 'Raccomandato';

  @override
  String get readOnlyBadge => 'CHIACCHIERATA';

  @override
  String get switchCompanion => 'Cambia compagno';

  @override
  String get personaChatInputHint => 'Digita un messaggio...';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get yesterday => 'Ieri';

  @override
  String get showInsightTextTitle =>
      'Mostra il commento di approfondimento Memex';

  @override
  String get showInsightTextDesc =>
      'Se mostrare l\'approfondimento Memex come commento appuntato nella sezione dei commenti sui dettagli della carta.';

  @override
  String get enableCharacterCommentTitle => 'Commento automatico dei caratteri';

  @override
  String get enableCharacterCommentDesc =>
      'I personaggi commentano automaticamente i nuovi record.';

  @override
  String get maxCommentCharactersTitle =>
      'Numero massimo di caratteri di commento';

  @override
  String get maxCommentCharactersDesc =>
      'Quanti caratteri possono commentare ciascun record.';

  @override
  String replyTo(String name) {
    return 'Rispondi a $name';
  }

  @override
  String get cdnSignalsComments => 'Nuova risposta ricevuta';

  @override
  String get cdnSignalsInsight => 'Nuove informazioni generate';

  @override
  String get cdnSignalsBoth => 'Nuova risposta e approfondimento';

  @override
  String get untitledCard => 'Carta senza titolo';

  @override
  String get locationContextTitle => 'Contesto della posizione';

  @override
  String get locationContextDescription =>
      'Contesto attuale della città e del quartiere per la chat dell\'agente';

  @override
  String get locationContextAttachTitle =>
      'Allega la posizione corrente alla chat';

  @override
  String get locationContextAttachDesc =>
      'Utilizza il GPS del dispositivo e la geocodificazione inversa per fornire all\'agente il contesto di città, distretto e quartiere.';

  @override
  String get reverseGeocodingProvider => 'Provider di geocodifica inversa';

  @override
  String get amapProviderName => 'Una mappa';

  @override
  String get amapApiKey => 'Chiave API Amap';

  @override
  String get amapGcj02Note =>
      'Amap utilizza le coordinate GCJ-02. Il GPS del dispositivo viene convertito prima della geocodifica inversa.';

  @override
  String get contextGranularity => 'Granularità del contesto';

  @override
  String get granularityCity => 'Città';

  @override
  String get granularityDistrict => 'Quartiere';

  @override
  String get granularityNeighborhood => 'Quartiere';

  @override
  String get granularityStreet => 'Strada';

  @override
  String get granularityFullAddress => 'Candidato con indirizzo completo';

  @override
  String get locationFreshness => 'Freschezza della posizione';

  @override
  String minutesShort(int minutes) {
    return '$minutes minuti';
  }

  @override
  String get oneHour => '1 ora';

  @override
  String get testCurrentLocation => 'Testare la posizione attuale';

  @override
  String locationTestFailed(String error) {
    return 'Non riuscito: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Geocodifica inversa';

  @override
  String get locationDebugProvider => 'Fornitore';

  @override
  String get locationDebugAgentContext => 'Contesto dell\'agente';

  @override
  String get locationDebugSource => 'Fonte';

  @override
  String get locationDebugAddressSummary => 'Riepilogo degli indirizzi';

  @override
  String get locationDebugFullAddress => 'Indirizzo completo';

  @override
  String get locationDebugCoordinates => 'Coordinate';

  @override
  String get locationDebugAccuracy => 'Precisione';

  @override
  String get locationDebugReason => 'Motivo';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'non disponibile';

  @override
  String get locationDebugInjected => 'iniettato';

  @override
  String get locationDebugNotInjected => 'non iniettato';

  @override
  String get locationStatusUpdatedAt => 'Aggiornato';

  @override
  String get locationStatusSuccessTitle => 'La posizione attuale è pronta';

  @override
  String get locationStatusSuccessBody =>
      'Memex può allegare questo riepilogo della posizione quando il contesto della posizione è rilevante.';

  @override
  String get locationStatusApproximateTitle => 'Posizione solo approssimativa';

  @override
  String get locationStatusApproximateBody =>
      'La precisione sembra a livello di città o area. Puoi continuare a usarlo o abilitare Posizione precisa nelle impostazioni di sistema per un contesto più ristretto.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'La posizione del sistema è disattivata';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex utilizza solo il GPS del dispositivo e non deduce la posizione dalla rete o dall\'IP. Su Android, apri le impostazioni di Posizione; su iOS, abilita Impostazioni > Privacy e sicurezza > Servizi di localizzazione.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'È necessaria l\'autorizzazione alla posizione';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Consenti a Memex di utilizzare la posizione durante i test o quando è necessario il contesto della posizione. Non è sempre richiesto l\'accesso.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'L\'autorizzazione alla posizione è bloccata';

  @override
  String get locationStatusPermissionForeverBody =>
      'Apri le impostazioni dell\'app e consenti la posizione per Memex. Su iOS, è sufficiente utilizzare l\'app.';

  @override
  String get locationStatusDisabledTitle =>
      'Il contesto della posizione è disattivato';

  @override
  String get locationStatusDisabledBody =>
      'Attiva l\'interruttore in alto e salva quando desideri che Memex alleghi la posizione del dispositivo al contesto dell\'agente.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'Il GPS funziona, la ricerca dell\'indirizzo non è riuscita';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex ha le coordinate ma non inserirà nell\'agente il contesto solo GPS. Controlla il provider di geocodifica inversa e riprova.';

  @override
  String get locationStatusUnavailableTitle => 'Posizione non disponibile';

  @override
  String get locationStatusUnavailableBody =>
      'Controlla i servizi di localizzazione del sistema e l\'autorizzazione dell\'app, quindi prova di nuovo.';

  @override
  String get allowLocationPermissionButton =>
      'Consenti l\'autorizzazione alla posizione';

  @override
  String get openAppSettingsButton => 'Apri le impostazioni dell\'app';

  @override
  String get openLocationSettingsButton => 'Apri le impostazioni di posizione';

  @override
  String get locationSettingsOpenFailed =>
      'Impossibile aprire le impostazioni di sistema.';

  @override
  String locationActionFailed(String error) {
    return 'Azione sulla posizione non riuscita: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Cerca impostazioni...';

  @override
  String get settingsSearchEmpty =>
      'Nessuna impostazione corrispondente trovata';

  @override
  String get importCharacterCard => 'Importa scheda personaggio';

  @override
  String get firstMessageLabel => 'Primo messaggio';

  @override
  String get firstMessageHint =>
      'Saluto inviato alla prima conversazione (facoltativo)';

  @override
  String get systemPromptOverrideLabel => 'Ignora la richiesta di sistema';

  @override
  String get systemPromptOverrideHint =>
      'Sostituisci il prompt di sistema predefinito (avanzato, facoltativo)';

  @override
  String get postHistoryInstructionsLabel => 'Istruzioni post-storia';

  @override
  String get postHistoryInstructionsHint =>
      'Istruzioni inserite dopo la cronologia della chat, prima della risposta (facoltativo)';

  @override
  String get mesExampleLabel => 'Esempi di messaggi';

  @override
  String get mesExampleHint =>
      'Dialoghi di esempio che mostrano lo stile del carattere (facoltativo)';

  @override
  String get worldBookTitle => 'Libro del mondo';

  @override
  String get worldBookSubtitle =>
      'Conoscenza di base inserita quando vengono attivate le parole chiave';

  @override
  String get characterMemoryTitle => 'Memoria dei personaggi';

  @override
  String get characterMemorySubtitle =>
      'Dinamiche di relazione e ricordi di interazione tra personaggio e utente';

  @override
  String get addTooltip => 'Aggiungere';

  @override
  String get constantBadge => 'Costante';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Voce $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Parole chiave: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Memoria $index';
  }

  @override
  String get addWorldEntry => 'Aggiungi voce di libro mondiale';

  @override
  String get editWorldEntry => 'Modifica la voce del libro mondiale';

  @override
  String get commentTitleLabel => 'Commento/Titolo';

  @override
  String get entryDescriptionHint => 'Descrizione della voce (facoltativa)';

  @override
  String get triggerKeywordsLabel => 'Parole chiave attivatrici';

  @override
  String get triggerKeywordsHint =>
      'Separati da virgole, ad esempio: magia, incantesimo';

  @override
  String get contentLabel => 'Contenuto';

  @override
  String get worldEntryContentHint =>
      'Conoscenza di base inserita quando si attivano le parole chiave';

  @override
  String get enabledCheckbox => 'Abilitato';

  @override
  String get addMemory => 'Aggiungi memoria';

  @override
  String get editMemory => 'Modifica memoria';

  @override
  String get memoryLabelField => 'Etichetta';

  @override
  String get memoryLabelHint =>
      'Identificatore univoco, ad esempio: preferenza del nome';

  @override
  String get memoryContentHint => 'Contenuto della memoria';

  @override
  String get salienceLabel => 'Salienza:';

  @override
  String get labelCannotBeEmpty => 'L\'etichetta non può essere vuota';

  @override
  String importSuccess(Object name) {
    return '$name importato correttamente';
  }

  @override
  String importFailed(Object error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String get supportedFormats => 'Formati supportati';

  @override
  String get tavernImportDescription =>
      '• Carte personaggio SillyTavern V2 (.json)\n• Immagini PNG con schede incorporate (.png)\n\nCampi come persona, libro mondiale, ecc. verranno automaticamente mappati sul formato carattere Memex.';

  @override
  String get pickCharacterFile => 'Scegli File di caratteri';

  @override
  String get repickFile => 'Scegli un altro file';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'Richiesta di sistema';

  @override
  String worldEntriesCount(Object count) {
    return 'Libro del mondo: $count voci';
  }

  @override
  String fileLabel(Object filename) {
    return 'File: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Esiste già un carattere con lo stesso nome: $names. L\'importazione creerà un nuovo carattere senza sovrascrivere quelli esistenti.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Imposta come compagno principale';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Impostato automaticamente come compagno principale dopo l\'importazione';

  @override
  String get confirmImport => 'Conferma l\'importazione';

  @override
  String get chatBackground => 'Sfondo della chat';

  @override
  String get chooseChatBackgroundImage => 'Scegli l\'immagine di sfondo';

  @override
  String get earlyUpdateSettingsTitle => 'Aggiornamenti in accesso anticipato';

  @override
  String get earlyUpdateSettingsDesc =>
      'Controlla le pre-release di GitHub per l\'APK iniziale corrispondente, scaricalo e consegnalo al programma di installazione di Android.';

  @override
  String get earlyUpdateUnsupported =>
      'I primi aggiornamenti sono disponibili solo nella build Android Early.';

  @override
  String get earlyUpdateAutoCheckTitle =>
      'Controllo automatico degli aggiornamenti';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Controllare all\'avvio al massimo una volta ogni 12 ore.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Scarica solo tramite Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Salta i download degli aggiornamenti durante l\'utilizzo dei dati mobili.';

  @override
  String get earlyUpdateAutoInstallTitle =>
      'Download e installazione automatici';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Quando viene trovata una nuova build, scaricala e apri automaticamente il programma di installazione Android.';

  @override
  String get earlyUpdateCheckNow => 'Controlla ora';

  @override
  String get earlyUpdateChecking => 'Controllo delle pre-release di GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Saltato perché i download solo Wi-Fi sono abilitati.';

  @override
  String get earlyUpdateNoUpdate => 'Sei già sull\'ultima versione Early.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'La versione iniziale $version+$build è disponibile.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Scarica e installa';

  @override
  String get earlyUpdateDownloadInProgress =>
      'Download dell\'aggiornamento in corso...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Download aggiornamento: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Pacchetto di aggiornamento scaricato. Pronto per l\'installazione.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Installa il pacchetto scaricato';

  @override
  String get earlyUpdateClearDownloadedPackage =>
      'Cancella il pacchetto scaricato';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Pacchetto di aggiornamento scaricato cancellato.';

  @override
  String get earlyUpdateInstallStarted =>
      'È stato aperto il programma di installazione di Android.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Consenti a Memex di installare app sconosciute, quindi tocca Scarica e installa di nuovo.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Ultimo controllo: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Controllo aggiornamento non riuscito: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Aggiornamento anticipato disponibile';

  @override
  String get earlyUpdateReleaseNotes => 'Note sulla versione';

  @override
  String get dismissAllNotifications => 'Cancella tutto';

  @override
  String get dismissByType => 'Cancella per tipo';

  @override
  String get dismissTypeSystemAction => 'Promemoria ed eventi';

  @override
  String get dismissTypeClarification => 'Chiarimenti';

  @override
  String get dismissTypeCardUpdate => 'Aggiornamenti della carta';

  @override
  String dismissedCount(Object count) {
    return '$count cancellato';
  }

  @override
  String get dataImportTitle => 'Importa file';

  @override
  String get dataImportSettingsDescription =>
      'Porta i vecchi file in Memex, poi decidi se organizzarli.';

  @override
  String get dataImportDescription =>
      'Scegli vecchie note, record esportati, documenti o archivi ZIP. Memex salva prima una copia e lascia intatti i file originali. Dopo l\'importazione, puoi decidere se Memex deve aiutarti a organizzarli.';

  @override
  String get dataImportSelectFiles => 'Scegli i file da importare';

  @override
  String get dataImportImporting => 'Salvataggio file...';

  @override
  String get dataImportSuccess => 'File salvati in Memex';

  @override
  String get dataImportOnlyStored =>
      'File salvati. Nessuna organizzazione è iniziata.';

  @override
  String get dataImportQueued =>
      'Memex organizzerà questa importazione in background.';

  @override
  String get dataImportResultTitle => 'Importazione completata';

  @override
  String dataImportResultSummary(Object count) {
    return 'I file $count sono stati salvati. Puoi organizzarli ora o lasciarli come materiale originale.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return 'Gli elementi $count avevano lo stesso nome e sono stati rinominati per evitare di sovrascrivere nulla.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count elementi di archivio insoliti sono stati saltati; il resto è stato importato normalmente.';
  }

  @override
  String get dataImportChooseProcessing => 'Organizza questi file';

  @override
  String get dataImportProcessTitle => 'Organizzare questa importazione?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Hai importato file $count. Scegli se Memex deve organizzarli adesso o conservare solo gli originali.';
  }

  @override
  String get dataImportProcessKnowledgeBase =>
      'Organizzare in una base di conoscenza';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Ideale per documenti, note, materiale di progetto e riferimenti. Memex estrarrà le informazioni utili e le raggrupperà per un uso successivo.';

  @override
  String get dataImportProcessTimelineCards =>
      'Crea record della sequenza temporale';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Ideale per diari, registri di chat, cronologia delle attività e vecchie esportazioni. Memex trasformerà i contenuti basati sul tempo in record quando avrà senso.';

  @override
  String get dataImportImpactNone =>
      'Memex conserverà solo questi file originali. Nessuna organizzazione AI verrà avviata.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex leggerà questi file e organizzerà informazioni utili a lungo termine nella base di conoscenza. Non creerà in modo proattivo record della sequenza temporale.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex leggerà questi file e creerà registrazioni della sequenza temporale per eventi della vita o cronologia datata, quando appropriato. Non organizzerà in modo proattivo la base di conoscenza.';

  @override
  String get dataImportImpactBoth =>
      'Memex proverà a creare record di sequenza temporale e organizzare le informazioni riutilizzabili nella base di conoscenza. Questo è l\'ideale per un archivio personale completo.';

  @override
  String get dataImportFinish => 'Salvateli e basta';

  @override
  String get noImages => 'Nessuna immagine';

  @override
  String get noMessages => 'Nessun messaggio';

  @override
  String get sketchContent => 'Contenuto dello schizzo';

  @override
  String get emptyFolder => 'Cartella vuota';

  @override
  String get usernameAlreadyTaken => 'Nome utente già preso';

  @override
  String get registrationFailed => 'La registrazione non è riuscita';

  @override
  String get loginFailed => 'Accesso non riuscito';

  @override
  String get paymentCreationFailed => 'Impossibile avviare il pagamento';

  @override
  String get completePayment => 'Pagamento completo';

  @override
  String get commentReplyToYou => 'Voi';

  @override
  String get commentAuthorUser => 'Utente';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => 'Autorizzazione annullata';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Settimana $week';
  }

  @override
  String get timelineWeekLabel => 'Settimana';

  @override
  String get eventCardDefaultTitle => 'Evento';

  @override
  String get memoryNoLongTermYet => 'Ancora nessun ricordo a lungo termine.';

  @override
  String get memoryNoRecentBuffer => 'Nessun ricordo recente nel buffer.';

  @override
  String get memoryGeneralSubject => 'Generale';

  @override
  String get debugging => 'Debug';

  @override
  String get agentStates => 'Stati degli agenti';

  @override
  String get logLevel => 'Livello: ';

  @override
  String taskIdLabel(Object id) {
    return 'ID: $id';
  }

  @override
  String taskBizIdLabel(Object bizId) {
    return 'BizID: $bizId';
  }

  @override
  String taskStatusLabel(Object status) {
    return 'Stato: $status';
  }

  @override
  String taskScheduledLabel(Object date) {
    return 'Pianificato: $date';
  }

  @override
  String taskCompletedLabel(Object date) {
    return 'Completato: $date';
  }

  @override
  String get oauthCouldNotLaunchBrowser =>
      'Impossibile aprire il browser per OAuth';

  @override
  String get authorizationTimedOut => 'Autorizzazione scaduta';
}
