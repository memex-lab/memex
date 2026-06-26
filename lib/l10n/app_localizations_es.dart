// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get timesLabel => 'Veces';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Establecer $modelId como modelo predeterminado';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get unknownModel => 'Modelo desconocido';

  @override
  String get notSet => 'Sin configurar';

  @override
  String get confirmClear => 'Confirmar limpieza';

  @override
  String get confirmClearTokenMessage =>
      '¿Borrar el usuario actual? Tendrás que ingresar el ID de usuario otra vez.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get tokenCleared => 'Usuario borrado';

  @override
  String clearTokenFailed(Object error) {
    return 'No se pudo borrar el usuario: $error';
  }

  @override
  String get selectDateRangeOptional =>
      'Seleccionar rango de fechas (opcional):';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get select => 'Seleccionar';

  @override
  String get processLimitOptional => 'Límite de procesamiento (opcional)';

  @override
  String get leaveEmptyForAll => 'Déjalo vacío para procesar todo';

  @override
  String get startProcessing => 'Iniciar procesamiento';

  @override
  String get userIdNotFound => 'No se encontró el ID de usuario';

  @override
  String createTaskFailed(Object error) {
    return 'No se pudo crear la tarea: $error';
  }

  @override
  String get reprocessCards => 'Reprocesar tarjetas';

  @override
  String get reprocessCardsTaskCreated =>
      'Solicitud de reprocesamiento encolada en Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Alcance';

  @override
  String get reprocessCardsCardOnly => 'Solo tarjetas';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Pedir a Super Agent que revise y regenere las tarjetas de línea de tiempo seleccionadas.';

  @override
  String get reprocessCardsRerunDownstream =>
      'Tarjetas y seguimientos relacionados';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Pedir a Super Agent que también considere actualizaciones relacionadas de PKM, agenda e insights cuando haga falta.';

  @override
  String get reanalyzeMediaAssets => 'Volver a leer adjuntos multimedia';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Pedir a Super Agent que inspeccione de nuevo los medios adjuntos al regenerar tarjetas.';

  @override
  String get regenerateComments => 'Regenerar comentarios';

  @override
  String get regenerateCommentsTaskCreated =>
      'Tarea de regeneración de comentarios creada; se ejecuta en segundo plano';

  @override
  String get rebuildSearchIndex => 'Reconstruir índice de búsqueda';

  @override
  String get rebuildSearchIndexSuccess =>
      'Índice de búsqueda reconstruido correctamente';

  @override
  String get rebuildSearchIndexFailed =>
      'No se pudo reconstruir el índice de búsqueda';

  @override
  String get clearData => 'Borrar datos';

  @override
  String get confirmClearDataMessage => '¿Borrar datos?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Se eliminarán todos los datos locales del espacio de trabajo del usuario actual, incluidas tarjetas, medios, archivos de conocimiento, insights, memoria, historial de chat y estado del sistema.\n\n¡Esta acción no se puede deshacer!';

  @override
  String get clearFailedAgentContexts =>
      'Borrar contexto de conversación fallido';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      '¿Borrar el contexto de conversación guardado de los agentes de Insights y Agenda? Esto es útil después de cambiar de modelo, cuando los mensajes anteriores del agente ya no son compatibles. No se eliminarán hechos, tarjetas, conocimiento, memorias ni configuración de modelos.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'Se borraron $count contexto(s) de conversación guardados';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'No se pudo borrar el contexto de conversación: $error';
  }

  @override
  String get cloneToTestUser => 'Clonar a usuario de prueba';

  @override
  String get confirmCloneToTestUserMessage =>
      'Copiar el espacio de trabajo actual a un nuevo usuario local de prueba y cambiar a él. El estado de ejecución de los agentes no se copia. Los datos del usuario actual no se modificarán.';

  @override
  String get testUserIdLabel => 'ID de usuario de prueba';

  @override
  String get testUserIdHelper => 'Usa letras, números, guion o guion bajo.';

  @override
  String get testUserIdInvalid =>
      'Usa solo letras, números, guion o guion bajo.';

  @override
  String get overwriteExistingTestUser =>
      'Reemplazar usuario de prueba existente con el mismo ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Cambiado al usuario de prueba $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'No se pudo clonar el usuario de prueba: $error';
  }

  @override
  String get dataClearedSuccess => 'Datos borrados correctamente';

  @override
  String clearDataFailed(Object error) {
    return 'No se pudieron borrar los datos: $error';
  }

  @override
  String get personalCenter => 'Centro personal';

  @override
  String get viewLogs => 'Ver registros';

  @override
  String get systemAuthorization => 'Autorización del sistema';

  @override
  String get aiCharacterConfig => 'Configuración de personajes de IA';

  @override
  String get modelConfig => 'Configuración de modelos';

  @override
  String get agentConfig => 'Configuración de Agent';

  @override
  String get experimentalLab => 'Laboratorio';

  @override
  String get experimentalLabDescription =>
      'Funciones experimentales que podrían cambiar o moverse más adelante.';

  @override
  String get modelUsageStats => 'Estadísticas de uso de modelos';

  @override
  String get asyncTaskList => 'Lista de tareas asíncronas';

  @override
  String get clearLocalToken => 'Borrar usuario';

  @override
  String get insightCardTemplates => 'Plantillas de tarjetas de insight';

  @override
  String get timelineCardTemplates =>
      'Plantillas de tarjetas de línea de tiempo';

  @override
  String get logViewer => 'Visor de registros';

  @override
  String get autoRefresh => 'Actualización automática';

  @override
  String get lineCount => 'Número de líneas: ';

  @override
  String get all => 'Todo';

  @override
  String get schedule => 'Agenda';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get appLockConfig => 'Configuración de bloqueo de app';

  @override
  String get activityStats => 'Estadísticas de actividad';

  @override
  String activityStatsSummary(Object inputs, Object cards, Object todos) {
    return 'En este periodo registraste $inputs vez/veces, generaste $cards tarjeta(s) y completaste $todos tarea(s).';
  }

  @override
  String get last7Days => '7 días';

  @override
  String get last30Days => '30 días';

  @override
  String get last90Days => '90 días';

  @override
  String get records => 'Registros';

  @override
  String get words => 'Palabras';

  @override
  String get cards => 'Tarjetas';

  @override
  String get knowledgeUnits => 'Unidades de conocimiento';

  @override
  String get completedTodos => 'Tareas completadas';

  @override
  String get activeDays => 'Días activos';

  @override
  String get streakDays => 'Racha';

  @override
  String get dailyRhythm => 'Ritmo diario';

  @override
  String get recordToOutput => 'De registro a salida';

  @override
  String get sourceBreakdown => 'Desglose por fuente';

  @override
  String get topThemes => 'Temas principales';

  @override
  String get textInput => 'Texto';

  @override
  String get imageInput => 'Imágenes';

  @override
  String get audioInput => 'Audio adjunto';

  @override
  String get noStatsYet => 'Aún no hay estadísticas de actividad';

  @override
  String get tapDayForDetails => 'Toca un día para ver detalles';

  @override
  String get dayDetails => 'Detalles del día';

  @override
  String loadStatsFailed(Object error) {
    return 'No se pudieron cargar las estadísticas: $error';
  }

  @override
  String get overview => 'Resumen';

  @override
  String get daily => 'Diario';

  @override
  String get modelStatsByAgent => 'Por Agent';

  @override
  String get detail => 'Detalle';

  @override
  String get date => 'Fecha';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'Sin datos';

  @override
  String get totalCalls => 'Llamadas totales';

  @override
  String get calls => 'Llamadas';

  @override
  String callsCount(Object count) {
    return '$count llamadas';
  }

  @override
  String get selectDateRange => 'Seleccionar rango de fechas';

  @override
  String get totalTokens => 'Tokens totales';

  @override
  String get cacheRate => 'Tasa de caché';

  @override
  String get promptTokens => 'Tokens de prompt';

  @override
  String get completionTokens => 'Tokens de respuesta';

  @override
  String get cachedTokens => 'Tokens en caché';

  @override
  String get thoughtTokens => 'Tokens de razonamiento';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Respuesta';

  @override
  String get cached => 'En caché';

  @override
  String get thought => 'Razonamiento';

  @override
  String get model => 'Modelo';

  @override
  String get scene => 'Escena';

  @override
  String get sceneId => 'ID de escena';

  @override
  String get tokenUsage => 'Uso de tokens';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'Desglose por modelo';

  @override
  String get callDetails => 'Detalles de llamada';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Detalles del registro: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'No se pudo guardar la configuración de LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'La vista previa HTML no está disponible en web. Véela en móvil.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'No se pudo guardar la información del usuario: $error';
  }

  @override
  String get totalEstimatedCost => 'Costo total estimado';

  @override
  String get close => 'Cerrar';

  @override
  String get totalTokenConsumption => 'Consumo total de tokens';

  @override
  String get dataLoadFailedRetry =>
      'No se pudieron cargar los datos; inténtalo de nuevo más tarde.';

  @override
  String get timelineLoadFailedRetry =>
      'No se pudo cargar la línea de tiempo; inténtalo de nuevo más tarde.';

  @override
  String get newPerspective => 'Nueva perspectiva';

  @override
  String get startPoint => 'Inicio';

  @override
  String get endPoint => 'Fin';

  @override
  String get originalInput => 'Entrada original';

  @override
  String get referenceContent => 'Contenido de referencia';

  @override
  String referenceWithTitle(Object title) {
    return 'Referencia: $title';
  }

  @override
  String get actionCenterTitle => 'Acciones pendientes';

  @override
  String get noPendingActions => 'No hay acciones pendientes';

  @override
  String get clarificationNeeded => 'Memex quiere confirmar';

  @override
  String get clarificationTextHint => 'Escribe una respuesta breve';

  @override
  String get clarificationTextRequired => 'Añade primero una respuesta breve';

  @override
  String get clarificationAnswered => 'Respondido';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Respuesta: $answer';
  }

  @override
  String get answerSaved => 'Respuesta guardada';

  @override
  String get clarificationOtherAnswer => 'Entrada manual';

  @override
  String get clarificationNotSure => 'No estoy seguro / prefiero no decirlo';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get footprintMap => 'Mapa de huellas';

  @override
  String get waypointPlaces => 'Lugares de paso';

  @override
  String get unknownPlace => 'Lugar desconocido';

  @override
  String get releaseToSend => 'Suelta para enviar';

  @override
  String get selectFromAlbum => 'Seleccionar del álbum';

  @override
  String get clipboardPreviewTitle => 'Nuevo portapapeles';

  @override
  String get clipboardPreviewImageTitle => 'Imagen del portapapeles';

  @override
  String get clipboardPreviewImageDescription => 'Imagen lista para añadir';

  @override
  String get clipboardPreviewUnprocessed => 'Aún no pegado';

  @override
  String get clipboardPreviewPasteToInput => 'Pegar en la entrada';

  @override
  String get clipboardPreviewAddImageToInput => 'Añadir imagen';

  @override
  String get clipboardPreviewImageFailed =>
      'No se pudo leer la imagen del portapapeles';

  @override
  String get tellAiWhatHappened => 'Cuéntale a la IA qué pasó...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Grabando: $duration';
  }

  @override
  String get playing => 'Reproduciendo...';

  @override
  String get sendLabel => 'Enviar';

  @override
  String attachedImagesMessage(Object count) {
    return 'Se enviaron $count imagen(es)';
  }

  @override
  String get noTaskData => 'No hay datos de tarea';

  @override
  String createdAtDate(Object date) {
    return 'Creado: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Actualizado: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Duración: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Reintento: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'No se pudo cargar el detalle; inténtalo de nuevo más tarde.';

  @override
  String get loadFailed => 'Carga fallida';

  @override
  String get reload => 'Recargar';

  @override
  String get aiInsightDetail => 'Detalle del insight';

  @override
  String relatedRecordsCount(Object count) {
    return 'Registros relacionados ($count)';
  }

  @override
  String get noRelatedRecords => 'No hay registros relacionados';

  @override
  String get useFingerprintToUnlock => 'Usar huella para desbloquear';

  @override
  String get locked => 'Bloqueado';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get enterPassword => 'Ingresar contraseña';

  @override
  String get memexLocked => 'Memex está bloqueado';

  @override
  String get calendarShortSun => 'Dom';

  @override
  String get calendarShortMon => 'Lun';

  @override
  String get calendarShortTue => 'Mar';

  @override
  String get calendarShortWed => 'Mié';

  @override
  String get calendarShortThu => 'Jue';

  @override
  String get calendarShortFri => 'Vie';

  @override
  String get calendarShortSat => 'Sáb';

  @override
  String noRecordsOnDate(Object date) {
    return 'No hay registros el $date';
  }

  @override
  String get footprintPath => 'Ruta de huellas';

  @override
  String get lifeCompositionTable => 'Composición de vida';

  @override
  String get emotionReframe => 'Reencuadre emocional';

  @override
  String get chronicleOfThings => 'Crónica de las cosas';

  @override
  String get goalProgress => 'Progreso de objetivos';

  @override
  String get trendChart => 'Gráfico de tendencia';

  @override
  String get comparisonChart => 'Gráfico comparativo';

  @override
  String get todayTimeFlow => 'Flujo de tiempo de hoy';

  @override
  String get aiInputHint => 'Ya sean recuerdos o el presente, estoy aquí...';

  @override
  String get refreshSuperAgentStateTooltip => 'Borrar contexto de Memex Agent';

  @override
  String get refreshSuperAgentStateTitle =>
      '¿Borrar el contexto histórico de Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'El historial visible del chat se conservará, pero el contexto histórico de ejecución de Memex Agent se borrará y las respuestas futuras empezarán desde un contexto nuevo. La memoria persistente, los archivos de la base de conocimiento, las tarjetas y otros datos guardados no se verán afectados. Úsalo cuando Memex Agent siga comportándose de forma anómala. ¿Continuar?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Espera a que termine el mensaje actual de Memex Agent antes de borrar el contexto.';

  @override
  String get refreshSuperAgentStateSuccess => 'Contexto de Memex Agent borrado';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'No se pudo borrar el contexto de Memex Agent: $error';
  }

  @override
  String get nothingHere => 'Todavía no hay nada aquí';

  @override
  String get nothingHereHint =>
      'Toca el botón de abajo para crear tu primera tarjeta';

  @override
  String get agentProcessing => 'La IA está procesando...';

  @override
  String get keepAppOpen => 'No cierres la app';

  @override
  String get activityDetail => 'Detalle de actividad';

  @override
  String get noAgentActivityYet => 'Aún no hay actividad de Agent';

  @override
  String get processingEllipsis => 'Procesando...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent está en pausa';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent necesita atención';

  @override
  String get agentBackgroundStageIdle => 'Inactivo';

  @override
  String get agentBackgroundStageProcessing => 'Procesando';

  @override
  String get agentBackgroundStageQueued => 'En cola';

  @override
  String get agentBackgroundStageRetrying => 'Esperando reintento';

  @override
  String get agentBackgroundStagePaused => 'En pausa';

  @override
  String get agentBackgroundStageCompleted => 'Completado';

  @override
  String get agentBackgroundStageNeedsAttention => 'Necesita atención';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Analizando medios';

  @override
  String get agentBackgroundStageGeneratingCard => 'Generando tarjeta';

  @override
  String get agentBackgroundStageUpdatingKnowledge =>
      'Actualizando conocimiento';

  @override
  String get agentBackgroundStagePreparingComment => 'Preparando comentario';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Enrutando seguimientos';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'En ejecución $running, pendientes $pending, reintentos $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Procesando $count tarea(s) en cola.';
  }

  @override
  String get agentBackgroundNoTasks => 'No hay tareas en segundo plano.';

  @override
  String get agentBackgroundStarting => 'El procesamiento está empezando.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Todas las tareas en segundo plano terminaron.';

  @override
  String get agentBackgroundFailedDetail =>
      'El procesamiento se detuvo con un error.';

  @override
  String get agentBackgroundPausedDetail =>
      'El procesamiento está en pausa y continuará más tarde.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Esperando el siguiente paso de procesamiento.';

  @override
  String get agentBackgroundRetryingDetail =>
      'El paso actual se reintentará automáticamente.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Leyendo adjuntos y contexto local.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Convirtiendo el registro en una tarjeta de línea de tiempo.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Actualizando conocimiento y memoria locales.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Preparando un seguimiento del asistente.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Revisando acciones de seguimiento para esta tarjeta.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'En pausa - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Necesita atención - $summary';
  }

  @override
  String get settings => 'Configuración';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get languageSettingsDesc => 'Cambiar el idioma de la app';

  @override
  String get noPendingActionsToast => 'No hay acciones pendientes';

  @override
  String get knowledgeNewDiscovery => 'Nuevo descubrimiento de conocimiento';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Se descubrieron $count nuevo(s) insight(s)';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Se actualizaron $count insight(s) existente(s)';
  }

  @override
  String get sectionNewInsights => 'Nuevos insights';

  @override
  String get sectionUpdatedInsights => 'Insights actualizados';

  @override
  String get unnamedInsight => 'Insight sin nombre';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get selectedLocation => 'Ubicación seleccionada';

  @override
  String get confirmLocationName => 'Confirmar nombre de ubicación';

  @override
  String get confirmLocationNameHint =>
      'Puedes editar el nombre (las coordenadas no cambian)';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get inputPlaceNameHint => 'Ingresa el nombre del lugar...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Coordenadas: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Confirmar ubicación';

  @override
  String get welcomeToMemex => 'Bienvenido a Memex';

  @override
  String get createUserIdToStart => 'Crea tu perfil';

  @override
  String get userIdLabel => 'Tu nombre / apodo';

  @override
  String get userIdHint => 'Ingresa tu nombre o apodo';

  @override
  String get pleaseEnterUserId => 'Ingresa tu nombre';

  @override
  String get userIdMaxLength => 'El nombre no debe superar 50 caracteres';

  @override
  String get startUsing => 'Continuar';

  @override
  String get userIdTip => 'Se usará para personalizar tu experiencia.';

  @override
  String get setupModelConfigTitle => 'Configurar un modelo de IA';

  @override
  String get setupModelConfigSubtitle =>
      'Memex necesita un modelo de IA de frontera para organizar registros, analizar imágenes y generar insights. Elige un método de conexión.';

  @override
  String get setupModelConfigComplete => 'Completar e ir';

  @override
  String get aiService => 'Servicio de modelos de Memex';

  @override
  String get aiModelHubTitle => 'Modelos y servicios de IA';

  @override
  String get aiModelHubSubtitle =>
      'Elige el servicio oficial de Memex o conecta tu propio proveedor. El enrutamiento avanzado de modelos seguirá disponible cuando lo necesites.';

  @override
  String get aiSetupCurrentStatusTitle => 'Configuración actual';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'El servicio de IA no está configurado';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Elige un método de conexión para activar la organización por IA de registros, medios e insights.';

  @override
  String get aiSetupStatusMemexTitle => 'Usando el servicio oficial de MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex usará la conexión oficial y las credenciales de API administradas por tu cuenta de MemeX.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Usando configuración de proveedor personalizado';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex usará tus credenciales de proveedor configuradas y las selecciones de roles de modelo.';

  @override
  String get aiSetupChooseConnectionTitle => 'Elige un método de conexión';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Empieza por la ruta que coincide con la forma en que quieres que Memex acceda a los modelos de IA.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Inicia sesión en MemeX y usa el servicio oficial sin elegir proveedores, claves ni modelos por Agent.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Añade tus propias credenciales de proveedor, elige el modelo que debe usar Super Agent y, opcionalmente, sobrescribe modelos por Agent.';

  @override
  String get aiSetupCustomPageTitle => 'Servicio de IA personalizado';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Configura primero las credenciales del proveedor y luego elige el modelo que Memex debe usar.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Proveedor y claves de API';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Añade o edita OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama u otro proveedor compatible.';

  @override
  String get modelRolesTitle => 'Elegir modelo principal';

  @override
  String get modelRolesDescription =>
      'Super Agent usa un modelo para entradas de texto e imagen. Las sobrescrituras avanzadas por Agent siguen disponibles abajo.';

  @override
  String get textModelRoleTitle => 'Modelo principal';

  @override
  String get textModelRoleDescription =>
      'Usado por Super Agent para texto, imágenes, tarjetas, conocimiento, insights, chat, comentarios, agenda y memoria.';

  @override
  String get modelConnectionsTitle => 'Proveedores de modelos y claves de API';

  @override
  String get modelConnectionsDescription =>
      'Conecta el servicio oficial de Memex o añade tus propias credenciales de proveedor.';

  @override
  String get relatedAiCapabilitiesTitle =>
      'Capacidades avanzadas y relacionadas';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Ajusta asignaciones de agentes, proveedor de ubicación y comportamiento de transcripción de voz.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Capacidades del servicio';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Elige los proveedores que Memex usa para capacidades cercanas impulsadas por IA, como voz y geocodificación inversa.';

  @override
  String get aiSetupAdvancedCustomizationTitle =>
      'Enrutamiento avanzado de modelos';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Para usuarios avanzados que quieren que agentes individuales usen proveedores o configuraciones de modelo diferentes.';

  @override
  String get locationProviderSettings => 'Proveedor de ubicación';

  @override
  String get speechProviderSettings => 'Transcripción de voz';

  @override
  String get advancedAgentModelAssignments =>
      'Asignaciones de modelos por Agent';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Sobrescribir agentes individuales';

  @override
  String get noConfiguredModelOptions =>
      'Añade un proveedor o una clave de API antes de elegir roles de modelo.';

  @override
  String get modelSlotUpdated => 'Rol de modelo actualizado';

  @override
  String get aiServiceMemexRouteTitle => 'Conectar a través de Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex usa un sistema multiagente para organizar registros de vida, notas de conocimiento y contexto social, descubrir insights más profundos y ofrecer compañía de IA con memoria persistente. Tus datos se almacenan como Markdown de texto plano, preservando libertad y portabilidad de datos.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Tengo una clave de API';

  @override
  String get aiServiceCustomModelDescription =>
      'Elige esto primero si ya tienes una clave de API de OpenAI, Anthropic, DeepSeek, Gemini u otro proveedor.';

  @override
  String get enableAiService => 'Conectar con Memex';

  @override
  String get aiServiceReadyToast => 'La organización por IA está activada';

  @override
  String get aiServiceSettingsDescription =>
      'Si no tienes una clave de API, usa una cuenta de Memex para conectarte a servicios de modelos principales.';

  @override
  String get advancedModelConfiguration => 'Configurar clave de API';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get clearAuth => 'Borrar autenticación';

  @override
  String get authorizing => 'Autorizando...';

  @override
  String authFailed(Object error) {
    return 'Autenticación fallida: $error';
  }

  @override
  String get authorized => 'Autorizado';

  @override
  String get config => 'Configuración';

  @override
  String get calendar => 'Calendario';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get writeToSystemFailed => 'No se pudo escribir en el sistema';

  @override
  String permissionRequired(Object name) {
    return 'Se requiere permiso de $name';
  }

  @override
  String permissionRationale(Object name) {
    return 'Permite que la app acceda a $name en Configuración para que podamos crearlo por ti.';
  }

  @override
  String get goToSettings => 'Ir a Configuración';

  @override
  String get unknownAction => 'Acción desconocida';

  @override
  String get discoveredCalendarEvent => 'Evento de calendario encontrado';

  @override
  String get discoveredReminder => 'Recordatorio encontrado';

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String get addToReminders => 'Añadir a recordatorios';

  @override
  String addedToSuccess(Object target) {
    return 'Añadido correctamente a $target';
  }

  @override
  String get ignore => 'Ignorar';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteSessionMessage =>
      '¿Eliminar esta conversación? Esto no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteSuccess => 'Eliminado correctamente';

  @override
  String deleteFailed(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String daysAgo(Object count) {
    return 'Hace $count días';
  }

  @override
  String get chatHistory => 'Historial de chat';

  @override
  String get enterFullScreenTooltip => 'Entrar en pantalla completa';

  @override
  String get exitFullScreenTooltip => 'Salir de pantalla completa';

  @override
  String get noConversations => 'No hay conversaciones';

  @override
  String loadSessionListFailed(Object error) {
    return 'No se pudo cargar la lista de conversaciones: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Ayer $time';
  }

  @override
  String get newChat => 'Nuevo chat';

  @override
  String messageCount(Object count) {
    return '$count mensajes';
  }

  @override
  String get organize => 'Organizar';

  @override
  String get pkmCategoryProject => 'Proyecto';

  @override
  String get pkmCategoryProjectSubtitle =>
      'Corto plazo · Objetivos · Fechas límite';

  @override
  String get pkmCategoryArea => 'Área';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Largo plazo · Responsabilidad · Estándares';

  @override
  String get pkmCategoryResource => 'Recurso';

  @override
  String get pkmCategoryResourceSubtitle => 'Intereses · Inspiración · Reserva';

  @override
  String get pkmCategoryArchive => 'Archivo';

  @override
  String get pkmCategoryArchiveSubtitle => 'Hecho · Inactivo · Referencia';

  @override
  String get recentChanges => 'Cambios recientes';

  @override
  String get noRecentChangesInThreeDays =>
      'No hay cambios en los últimos 3 días';

  @override
  String get unpinned => 'Sin fijar';

  @override
  String get pinnedStyle => 'Estilo fijado';

  @override
  String operationFailed(Object error) {
    return 'Operación fallida: $error';
  }

  @override
  String get refreshingInsightData =>
      'Actualizando datos de insight; esto puede tardar un momento...';

  @override
  String refreshFailed(Object error) {
    return 'Actualización fallida: $error';
  }

  @override
  String get sortUpdated => 'Orden actualizado';

  @override
  String sortSaveFailed(Object error) {
    return 'No se pudo guardar el orden: $error';
  }

  @override
  String get insightCardDeleted => 'Tarjeta de insight eliminada';

  @override
  String deleteFailedShort(Object error) {
    return 'Eliminación fallida: $error';
  }

  @override
  String get knowledgeInsight => 'Insight de conocimiento';

  @override
  String get completeSort => 'Completar ordenación';

  @override
  String get noKnowledgeInsight => 'No hay insight de conocimiento';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return 'Aún se están procesando $count tareas en segundo plano.';
  }

  @override
  String get insightUnavailableMessage =>
      'Este insight aún se está generando o se actualizó. Actualiza los insights e inténtalo más tarde.';

  @override
  String get noScheduleAggregation => 'No hay agregación de agenda';

  @override
  String get scheduleAggregationEmptyHint =>
      'Toca Actualizar para organizar agendas y tareas desde tarjetas temporales reales.';

  @override
  String get scheduleAggregationLoadFailed =>
      'No se pudieron cargar los datos de agenda';

  @override
  String get scheduleAggregationRefreshFailed =>
      'No se pudieron actualizar los datos de agenda';

  @override
  String get scheduleTaskUpdateFailed => 'No se pudo actualizar la tarea';

  @override
  String get scheduleFeatured => 'Destacado';

  @override
  String get scheduleThisWeek => 'Esta semana';

  @override
  String get scheduleDone => 'Hecho';

  @override
  String get scheduleTbd => 'Por definir';

  @override
  String get scheduleWeekOverview => 'Esta semana';

  @override
  String get scheduleImportant => 'Importante';

  @override
  String get scheduleBriefingTitle => 'Resumen de agenda';

  @override
  String get scheduleBriefingOpen => 'Abrir';

  @override
  String get scheduleBriefingNoData => 'Aún no hay resumen de agenda';

  @override
  String scheduleBriefingUpdated(Object time) {
    return 'Actualizado $time';
  }

  @override
  String scheduleBriefingDoneCount(Object count) {
    return '$count completadas';
  }

  @override
  String get updating => 'Actualizando...';

  @override
  String get update => 'Actualizar';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String get appLockOn => 'Bloqueo de app activado';

  @override
  String get appLockOff => 'Bloqueo de app desactivado';

  @override
  String get enableAppLockFirst => 'Activa primero el bloqueo de app';

  @override
  String get enterFourDigitPassword => 'Ingresa una contraseña de 4 dígitos';

  @override
  String get passwordSetAndLockOn =>
      'Contraseña establecida y bloqueo de app activado';

  @override
  String get appLockSettings => 'Configuración de bloqueo de app';

  @override
  String get enableAppLock => 'Activar bloqueo de app';

  @override
  String get enableAppLockSubtitle => 'Requiere contraseña al abrir la app';

  @override
  String get enableBiometrics => 'Activar biometría';

  @override
  String get biometricsSubtitle => 'Usa Face ID o Touch ID para desbloquear';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get setFourDigitPassword => 'Establecer contraseña de 4 dígitos';

  @override
  String get reenterPasswordToConfirm =>
      'Vuelve a ingresar la contraseña para confirmar';

  @override
  String get passwordMismatch =>
      'Las contraseñas no coinciden. Inténtalo de nuevo.';

  @override
  String confirmDeleteCharacter(Object name) {
    return '¿Eliminar el personaje \"$name\"? Esto no se puede deshacer.';
  }

  @override
  String get configureAiCharacter => 'Configurar personaje de IA';

  @override
  String get addCharacter => 'Añadir personaje';

  @override
  String get addCharacterSubtitle =>
      'Elige personajes de IA para unirse a tu equipo de insights. Analizarán tus datos de vida desde distintos ángulos.';

  @override
  String get noCharacters => 'No hay personajes';

  @override
  String loadCharacterFailed(Object error) {
    return 'No se pudieron cargar los personajes: $error';
  }

  @override
  String get noTags => 'Sin etiquetas';

  @override
  String get createSuccess => 'Creado correctamente';

  @override
  String get updateSuccess => 'Actualizado correctamente';

  @override
  String saveFailed(Object error) {
    return 'Guardado fallido: $error';
  }

  @override
  String get newCharacter => 'Nuevo personaje';

  @override
  String get editCharacter => 'Editar personaje';

  @override
  String get save => 'Guardar';

  @override
  String get characterName => 'Nombre del personaje';

  @override
  String get characterNameHint => 'Dale un nombre a tu personaje';

  @override
  String get pleaseEnterCharacterName => 'Ingresa el nombre del personaje';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get tagsHint =>
      'p. ej. sabiduría, reconocimiento, visión global\nSepara varias etiquetas con comas';

  @override
  String get characterPersonaLabel => 'Persona del personaje';

  @override
  String get characterPersonaHint =>
      'Incluye persona, guía de estilo, diálogo de ejemplo, filtros de conocimiento, etc.\nUsa ## para encabezados de sección.';

  @override
  String get pleaseEnterCharacterPersona => 'Ingresa la persona del personaje';

  @override
  String permissionRequestError(Object error) {
    return 'Error al solicitar permiso: $error';
  }

  @override
  String get permissionRequiredTitle => 'Permiso requerido';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Has denegado permanentemente este permiso o el sistema lo requiere. Actívalo en la configuración del sistema.';

  @override
  String get getting => 'Obteniendo...';

  @override
  String get unauthorized => 'No autorizado';

  @override
  String get authorizedGoToSettings =>
      'Autorizado. Ve a la configuración del sistema para cambiarlo.';

  @override
  String get location => 'Ubicación';

  @override
  String get locationPermissionReason =>
      'Para registrar lugares y funciones relacionadas con ubicación';

  @override
  String get photos => 'Fotos';

  @override
  String get photosPermissionReason =>
      'Para seleccionar fotos, guardar imágenes generadas, etc.';

  @override
  String get camera => 'Cámara';

  @override
  String get cameraPermissionReason => 'Para tomar fotos y videos';

  @override
  String get microphone => 'Micrófono';

  @override
  String get microphonePermissionReason =>
      'Para reconocimiento de voz, grabación, etc.';

  @override
  String get calendarPermissionReason =>
      'Para registrar agenda y leer eventos del calendario';

  @override
  String get remindersPermissionReason =>
      'Para registrar y leer tus recordatorios';

  @override
  String get fitnessAndMotion => 'Actividad física y movimiento';

  @override
  String get fitnessPermissionReason =>
      'Para registrar datos de salud y movimiento';

  @override
  String get notification => 'Notificación';

  @override
  String get notificationPermissionReason =>
      'Para enviar agenda y recordatorios importantes';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Mantener Memex Agent en segundo plano';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent se ejecuta localmente en tu dispositivo. Con las notificaciones, Memex puede mostrar el progreso y seguir procesando después de salir de la app o apagar la pantalla. Si las notificaciones están desactivadas, mantén Memex abierto en primer plano hasta que la tarea termine.';

  @override
  String get loadDetailFailedRetryShort =>
      'No se pudo cargar el detalle; inténtalo de nuevo más tarde.';

  @override
  String get total => 'Total general';

  @override
  String get estimatedCost => 'Costo estimado';

  @override
  String get byAgent => 'Por Agent';

  @override
  String get timeUpdated => 'Hora actualizada';

  @override
  String updateFailed(Object error) {
    return 'Actualización fallida: $error';
  }

  @override
  String get locationUpdated => 'Ubicación actualizada';

  @override
  String get confirmDeleteCardMessage =>
      '¿Eliminar esta tarjeta? Esto no se puede deshacer.';

  @override
  String get cardDetailNotFound => 'Detalle de tarjeta no encontrado';

  @override
  String get saySomething => 'Di algo...';

  @override
  String get relatedMemories => 'Memorias relacionadas';

  @override
  String get viewMore => 'Ver más';

  @override
  String get relatedRecords => 'Registros relacionados';

  @override
  String get reply => 'Responder';

  @override
  String get replySent => 'Respuesta enviada';

  @override
  String get insightTemplateGalleryTitle => 'Plantillas de tarjetas de insight';

  @override
  String get timelineTemplateGalleryTitle =>
      'Plantillas de tarjetas de línea de tiempo';

  @override
  String get categoryTextual => 'Texto';

  @override
  String get timelineFilterAll => 'TODO';

  @override
  String get insights => 'Insights generados';

  @override
  String get memoryTitle => 'Memoria';

  @override
  String get longTermProfile => 'Perfil a largo plazo';

  @override
  String get recentBuffer => 'Búfer reciente';

  @override
  String errorLoadingMemory(Object error) {
    return 'Error al cargar memoria: $error';
  }

  @override
  String get agentConfiguration => 'Configuración de Agent';

  @override
  String get resetToDefaults => 'Restablecer valores predeterminados';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Restablecer todas las configuraciones de Agent';

  @override
  String get resetAllAgentConfigurationsMessage =>
      '¿Seguro que quieres restablecer todas las configuraciones de Agent a sus valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get resetButton => 'Restablecer';

  @override
  String loadDataFailed(Object error) {
    return 'No se pudieron cargar los datos: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'No se pudo guardar la configuración: $error';
  }

  @override
  String get selectLlmClient => 'Seleccionar cliente LLM:';

  @override
  String get agentConfigurationsReset =>
      'Configuraciones de Agent restablecidas';

  @override
  String resetFailed(Object error) {
    return 'No se pudo restablecer: $error';
  }

  @override
  String get modelConfiguration => 'Configuración de modelos';

  @override
  String get resetAllConfigurationsTitle =>
      'Restablecer todas las configuraciones';

  @override
  String get resetAllModelConfigurationsMessage =>
      '¿Seguro que quieres restablecer todas las configuraciones de modelo a sus valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get modelConfigurationsReset =>
      'Configuraciones de modelo restablecidas';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'No se puede eliminar la configuración predeterminada';

  @override
  String get cannotDeleteConfigurationTitle =>
      'No se puede eliminar la configuración';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Esta configuración está siendo usada por los siguientes agentes:\n\n$agentList\n\nReasigna estos agentes antes de eliminarla.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Eliminar configuración';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '¿Seguro que quieres eliminar \"$key\"?';
  }

  @override
  String get defaultLabel => 'Predeterminado';

  @override
  String get setAsDefault => 'Establecer como predeterminado';

  @override
  String get invalidJsonInExtraField => 'JSON inválido en el campo Extra';

  @override
  String get keyAlreadyExists => 'La clave ya existe';

  @override
  String get resetConfigurationTitle => 'Restablecer configuración';

  @override
  String get resetConfigurationMessage =>
      '¿Restablecer esta configuración a sus valores iniciales predeterminados? Los cambios actuales se perderán.';

  @override
  String get configurationResetPressSave =>
      'Configuración restablecida. Pulsa Guardar para aplicar.';

  @override
  String get addConfiguration => 'Añadir configuración';

  @override
  String get editConfiguration => 'Editar configuración';

  @override
  String get duplicateConfiguration => 'Duplicar configuración';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get keyIdLabel => 'ID de configuración';

  @override
  String get keyIdHelper =>
      'Nombra esta configuración, por ejemplo deepseek o work-gpt.';

  @override
  String get required => 'Obligatorio';

  @override
  String get clientLabel => 'Proveedor de modelo';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Populares';

  @override
  String get providerOpenAiApiKey => 'Clave de API';

  @override
  String get providerOpenAiResponses => 'Clave de API (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'Clave de API';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini (Google OAuth)';

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
  String get providerOllama => 'Ollama (local)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Servicio proxy de Memex';

  @override
  String get memexSignIn => 'Iniciar sesión';

  @override
  String get memexCreateAccount => 'Crear cuenta';

  @override
  String get memexUsername => 'Nombre de usuario';

  @override
  String get memexPassword => 'Contraseña';

  @override
  String get memexCreateAccountLink => 'Crear cuenta';

  @override
  String get memexSignInLink => 'Iniciar sesión en su lugar';

  @override
  String get memexTopUp => 'Recarga para empezar a usar Memex AI';

  @override
  String get memexTopUpSuccess => '¡Recarga exitosa!';

  @override
  String get memexFillAllFields => 'Completa todos los campos';

  @override
  String get memexUsernameTooShort =>
      'El nombre de usuario debe tener al menos 6 caracteres';

  @override
  String get memexAuthFailed => 'Autenticación fallida';

  @override
  String get memexPaymentFailed => 'No se pudo crear el pago';

  @override
  String get memexLogout => 'Cerrar sesión';

  @override
  String get memexTopUpButton => 'Recargar';

  @override
  String get memexTopUpChooseAmount => 'Elige un monto';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Aproximadamente $range registros';
  }

  @override
  String get memexTopUpPlanStarter => 'Inicial';

  @override
  String get memexTopUpPlanEveryday => 'Diario';

  @override
  String get memexTopUpPlanHighVolume => 'Alto volumen';

  @override
  String get memexTopUpPlanCustom => 'Créditos personalizados';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Bueno para probar Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Bueno para organización regular';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Bueno para lotes más grandes';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Ingresa USD 1-10,000';

  @override
  String get memexTopUpCustomEstimate =>
      'La estimación se basa en el monto ingresado';

  @override
  String get memexCustomAmount => 'Monto personalizado';

  @override
  String get memexViewHistory => 'Historial de uso';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Saldo: $amount';
  }

  @override
  String get memexConfirmPassword => 'Confirmar contraseña';

  @override
  String get memexPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String memexPayAmount(Object amount) {
    return 'Recargar $amount';
  }

  @override
  String get modelIdLabel => 'Modelo';

  @override
  String get modelIdHelper => 'p. ej. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Obteniendo modelos...';

  @override
  String get fetchModelsButton => 'Obtener modelos';

  @override
  String get enterApiKeyFirst =>
      'Ingresa primero la clave de API para obtener modelos';

  @override
  String get apiKeyLabel => 'Clave de API';

  @override
  String get baseUrlLabel => 'Endpoint de API';

  @override
  String get advancedSettings => 'Configuración avanzada';

  @override
  String get testConnectionSuccess => 'Conexión exitosa';

  @override
  String get testConnectionFailed => 'Conexión fallida';

  @override
  String get testTypeText => 'Texto';

  @override
  String get testTypeVision => 'Visión';

  @override
  String get testButton => 'Probar';

  @override
  String get testing => 'Probando...';

  @override
  String get proxyUrlOptional => 'URL de proxy (opcional)';

  @override
  String get proxyUrlHelper => 'p. ej. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => 'Parámetros extra (JSON)';

  @override
  String get invalidJson => 'JSON inválido';

  @override
  String get warning => 'Configuración incompleta';

  @override
  String get invalidConfigurationWarning =>
      'La configuración aún no está completa (por ejemplo, falta la clave de API o el ID de modelo). Aun así puedes guardarla y configurarla más tarde. ¿Continuar?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" necesita una configuración de modelo válida (clave: \"$configKey\") para funcionar. Revisa la configuración del modelo.';
  }

  @override
  String get discardChangesTitle => '¿Salir de esta página?';

  @override
  String get discardChangesMessage =>
      'Si hiciste cambios, guárdalos antes de salir.';

  @override
  String get discardButton => 'Descartar';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get chooseAvatar => 'Elegir avatar';

  @override
  String get configureNow => 'Configurar ahora';

  @override
  String get modelNotConfiguredBanner =>
      'El modelo de IA aún no está configurado. Configúralo para desbloquear todas las funciones.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Configura un modelo de IA antes de publicar';

  @override
  String get processingStatus => 'Procesando';

  @override
  String get failedStatus => 'Fallido';

  @override
  String get failureReason => 'Motivo del fallo';

  @override
  String get unknownError => 'Ocurrió un error desconocido';

  @override
  String get enableFitness => 'Activar Fitness';

  @override
  String get fitnessBannerMessage =>
      'Permite acceso a fitness para registrar tus datos de salud y actividad.';

  @override
  String get fitnessDismissTitle => '¿Omitir acceso a Fitness?';

  @override
  String get fitnessDismissMessage =>
      'Sin permiso de fitness, la app no podrá recopilar automáticamente tus datos de salud para insights y autorregistro.';

  @override
  String get skipAnyway => 'Omitir de todos modos';

  @override
  String get proModelHint =>
      'Este modelo requiere una suscripción ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Buscar en la base de conocimiento...';

  @override
  String get searchKnowledgeHint =>
      'Ingresa una palabra clave para buscar nombres de archivos o contenido';

  @override
  String noSearchResults(Object query) {
    return 'No se encontraron resultados para \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'Solo se admite vista previa de Markdown';

  @override
  String get backupAndRestore => 'Copia de seguridad y restauración';

  @override
  String get createBackup => 'Crear copia de seguridad';

  @override
  String get restoreBackup => 'Restaurar copia de seguridad';

  @override
  String get backupDescription =>
      'Empaqueta todos tus datos (tarjetas, base de conocimiento, insights, configuración) en un archivo .memex. Guárdalo en iCloud Drive, Google Drive o cualquier ubicación mediante la hoja de compartir.';

  @override
  String get restoreDescription =>
      'Selecciona un archivo de copia .memex para restaurar todos los datos. Esto sobrescribirá los datos actuales.';

  @override
  String get selectBackupFile => 'Seleccionar archivo de copia';

  @override
  String get estimatedSize => 'Tamaño estimado';

  @override
  String get backupComplete => 'Copia de seguridad creada';

  @override
  String backupFailed(Object error) {
    return 'Copia de seguridad fallida: $error';
  }

  @override
  String get confirmRestore => 'Confirmar restauración';

  @override
  String get confirmRestoreMessage =>
      'La restauración sobrescribirá todos los datos actuales, incluidas tarjetas, base de conocimiento, insights y configuración. Esto no se puede deshacer. ¿Continuar?';

  @override
  String get restoreComplete => 'Restauración completa';

  @override
  String get restoreRestartHint =>
      'Los datos se restauraron. Reinicia la app para que todos los cambios surtan efecto.';

  @override
  String restoreFailed(Object error) {
    return 'Restauración fallida: $error';
  }

  @override
  String get invalidBackupFile =>
      'Archivo de copia de seguridad inválido. Selecciona un archivo .memex.';

  @override
  String get automaticBackup => 'Copia de seguridad automática';

  @override
  String get autoBackupDescription =>
      'Cuando está activado, Memex crea como máximo una instantánea local al día después de iniciar o al volver al primer plano.';

  @override
  String get backupSensitiveSettingsHint =>
      'Las copias de seguridad incluyen configuración y claves de proveedores de modelos. Guárdalas en un lugar de confianza.';

  @override
  String get backupLocation => 'Ubicación';

  @override
  String get backupLocationDetails => 'Detalles de ubicación';

  @override
  String get backupLocationSummary => 'Mostrado en la app';

  @override
  String get backupLocationFullPath => 'Ruta completa';

  @override
  String get backupLocationUri => 'URI de acceso a carpeta';

  @override
  String get copyBackupLocationPath => 'Copiar ruta';

  @override
  String get backupLocationCopied => 'Ubicación de copia copiada';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Carpeta seleccionada: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Archivos > En mi iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'Estado';

  @override
  String get noAutoBackupYet => 'Aún no hay copia automática';

  @override
  String lastBackupAt(Object time) {
    return 'Última copia: $time';
  }

  @override
  String get autoBackupRetention => 'Retención';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days días';
  }

  @override
  String get autoBackupRetentionForever => 'Conservar para siempre';

  @override
  String get autoBackupMaxSize => 'Límite de almacenamiento';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'La limpieza automática mantiene las instantáneas automáticas por debajo de $size. Las instantáneas de seguridad y exportaciones manuales se conservan por separado.';
  }

  @override
  String get createSnapshotNow => 'Hacer copia ahora';

  @override
  String get backupLocationMenu => 'Cambiar ubicación';

  @override
  String get defaultBackupLocation => 'Carpeta de copia predeterminada';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Usa la carpeta externa específica de la app Memex. No requiere permiso de almacenamiento.';

  @override
  String get chooseBackupLocation => 'Elegir carpeta de copia';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Elige una carpeta con el selector del sistema de Android y concede acceso persistente a Memex.';

  @override
  String get storedBackups => 'Copias guardadas';

  @override
  String get noStoredBackups =>
      'Las copias automáticas aparecerán aquí después de la primera instantánea.';

  @override
  String get backupTypeAutoSnapshot => 'Instantánea automática';

  @override
  String get backupTypeSafetySnapshot => 'Instantánea de seguridad';

  @override
  String get backupTypeManualBackup => 'Copia manual';

  @override
  String get refresh => 'Actualizar';

  @override
  String get restoreThisBackup => 'Restaurar esta copia';

  @override
  String get deleteThisBackup => 'Eliminar esta copia';

  @override
  String get confirmDeleteBackup => '¿Eliminar copia?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '¿Eliminar $fileName? Esto elimina el archivo de copia guardado y no se puede deshacer.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Copia eliminada: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'No se pudo eliminar la copia: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Creando instantánea de seguridad...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Instantánea creada: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'No se pudo actualizar la ubicación de copia: $error';
  }

  @override
  String get backupImportCreatedAt => 'Creado';

  @override
  String get backupImportSourceVersion => 'Versión de origen';

  @override
  String get backupImportFlavor => 'Build';

  @override
  String get backupLegacyFormat => 'Copia heredada (sin manifest)';

  @override
  String get restoreInProgress => 'Restaurando copia...';

  @override
  String get dataStorage => 'Almacenamiento de datos';

  @override
  String get dataStorageDescriptionAndroid =>
      'Elige una carpeta personalizada para guardar tu espacio de trabajo. Los datos se conservan al reinstalar la app.';

  @override
  String get dataStorageDescriptionIOS =>
      'Activa iCloud para sincronizar tu espacio de trabajo entre dispositivos y conservar datos al reinstalar la app.';

  @override
  String get storageLocationApp => 'Almacenamiento de la app';

  @override
  String get storageLocationAppDesc =>
      'Los datos se almacenan dentro de la app y se eliminarán al desinstalarla.';

  @override
  String get storageLocationCustom =>
      'Almacenamiento del dispositivo (carpeta personalizada)';

  @override
  String get storageLocationCustomDesc =>
      'Guarda datos en una carpeta que elijas. Los datos persisten al reinstalar si la carpeta permanece.';

  @override
  String get storageLocationICloud => 'Guardar en iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Sincroniza tu espacio de trabajo entre dispositivos Apple. Los datos permanecen después de reinstalar.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Actual: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Inicia sesión en iCloud y activa iCloud Drive para usar almacenamiento de iCloud.';

  @override
  String get loadingFromICloud => 'Restaurando datos desde iCloud…';

  @override
  String get switchingToICloud => 'Cambiando a almacenamiento de iCloud…';

  @override
  String get switchingStorage => 'Cambiando almacenamiento…';

  @override
  String get customFolderAccessDenied =>
      'No se puede leer ni escribir en esta carpeta. Concede permiso de almacenamiento o elige otra ubicación.';

  @override
  String get configured => 'Configurado';

  @override
  String get apiKeyNotSet =>
      'Clave de API no configurada — toca para configurar';

  @override
  String get bottomNavTimeline => 'Línea de tiempo';

  @override
  String get bottomNavLibrary => 'Biblioteca';

  @override
  String get aiGeneratedLabel => 'Generado por IA';

  @override
  String sourceTraceWithCount(Object count) {
    return 'TRAZA DE FUENTE ($count)';
  }

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountDesc =>
      'Eliminar permanentemente todos los datos locales y restablecer la app.';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Esto eliminará permanentemente todos tus datos, incluidas tarjetas de línea de tiempo, base de conocimiento, grabaciones y configuración. Esta acción no se puede deshacer.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Escribe \"$name\" para confirmar';
  }

  @override
  String get deleteAccountTypeHint =>
      'Ingresa tu nombre de usuario para confirmar';

  @override
  String get llmConsentTitle => 'Consentimiento para compartir datos';

  @override
  String llmConsentMessage(Object provider) {
    return 'Para activar funciones de IA, Memex necesita enviar tus datos a $provider para procesarlos. Esto incluye:\n\n• Texto que ingreses (notas, transcripciones de voz)\n• Metadatos de fotos y texto extraído (OCR)\n• Resúmenes de salud y actividad física\n• Contenido de tarjetas de línea de tiempo\n\nTus datos se envían directamente desde tu dispositivo a $provider. Memex no almacena ni retransmite tus datos a través de ningún otro servidor.\n\nRevisa la política de privacidad de $provider para saber cómo manejan tus datos.\n\n¿Aceptas enviar tus datos a $provider para procesamiento de IA?';
  }

  @override
  String get llmConsentAgree => 'Acepto';

  @override
  String get llmConsentDecline => 'Rechazar';

  @override
  String get customAgents => 'Agentes personalizados';

  @override
  String get noCustomAgents => 'No hay agentes personalizados configurados.';

  @override
  String get deleteAgent => 'Eliminar Agent';

  @override
  String deleteAgentConfirm(Object name) {
    return '¿Eliminar el Agent personalizado \"$name\"?';
  }

  @override
  String get deleted => 'Eliminado';

  @override
  String get saved => 'Guardado';

  @override
  String get newAgent => 'Nuevo Agent';

  @override
  String get editAgent => 'Editar Agent';

  @override
  String get agentName => 'Nombre del Agent';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Obligatorio';

  @override
  String get agentNameInvalid => 'Solo letras, números y guiones';

  @override
  String get agentNameExists => 'El nombre ya existe';

  @override
  String get hostAgentType => 'Tipo de Agent host';

  @override
  String get skillDirectory => 'Directorio de Skill';

  @override
  String get skillDirInvalid =>
      'Debe ser una ruta relativa (sin / inicial ni ..)';

  @override
  String get workingDirectory => 'Directorio de trabajo (opcional)';

  @override
  String get workingDirectoryHint =>
      'Déjalo vacío para usar el valor predeterminado del espacio de trabajo';

  @override
  String get llmConfig => 'Configuración LLM';

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get executionMode => 'Modo de ejecución';

  @override
  String get executionModeAsync => 'Asíncrono';

  @override
  String get executionModeSync => 'Síncrono';

  @override
  String get dependsOn => 'Depende de';

  @override
  String get dependsOnHint => 'Seleccionar dependencias';

  @override
  String get priority => 'Prioridad';

  @override
  String get maxRetries => 'Reintentos máximos';

  @override
  String get systemPromptLabel => 'Prompt del sistema (opcional)';

  @override
  String get systemPromptHint =>
      'Instrucciones adicionales añadidas al prompt del Agent host';

  @override
  String get eventSerializer => 'Serializador de eventos';

  @override
  String get eventSerializerDefault => 'Predeterminado (XML)';

  @override
  String get enabledLabel => 'Activado';

  @override
  String get skillsManagement => 'Gestión de Skills';

  @override
  String get skillsManagementEmpty => 'Aún no hay Skills';

  @override
  String get downloadSkill => 'Descargar Skill';

  @override
  String get downloadFile => 'Descargar archivo';

  @override
  String get downloading => 'Descargando...';

  @override
  String get downloadSuccess => 'Skill descargada correctamente';

  @override
  String downloadFailed(Object error) {
    return 'Descarga fallida: $error';
  }

  @override
  String get deleteConfirm => 'Confirmar eliminación';

  @override
  String deleteConfirmMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String get invalidUrl => 'Ingresa una URL válida';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String get newFile => 'Nuevo archivo';

  @override
  String get folderName => 'Nombre de carpeta';

  @override
  String get fileName => 'Nombre de archivo';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get nameInvalid => 'El nombre no puede contener / ni ..';

  @override
  String createFailed(Object error) {
    return 'Creación fallida: $error';
  }

  @override
  String get fileContent => 'Contenido del archivo';

  @override
  String get saveSuccess => 'Guardado correctamente';

  @override
  String downloadToCurrentDir(String dir) {
    return 'El zip se extraerá en el directorio actual: $dir';
  }

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyDesc => 'Cómo maneja Memex tus datos';

  @override
  String get llmAuthError =>
      'La autenticación de API falló. Revisa tu configuración de LLM en Configuración.';

  @override
  String get llmBadRequestError =>
      'El proveedor LLM rechazó la solicitud. Es posible que el formato de entrada no sea compatible con el modelo actual.';

  @override
  String get llmRateLimitError =>
      'Se superó el límite de uso de API. Inténtalo de nuevo más tarde.';

  @override
  String get llmServerError =>
      'El servicio LLM no está disponible temporalmente. Inténtalo de nuevo más tarde.';

  @override
  String get llmNetworkError =>
      'La conexión de red falló. Revisa tu conexión a internet.';

  @override
  String get llmUnknownError =>
      'Ocurrió un error inesperado al procesar tu contenido.';

  @override
  String get llmErrorDialogTitle => 'Procesamiento fallido';

  @override
  String get goToModelConfig => 'Ir a Configuración';

  @override
  String get speechModelDownloadTitle => 'Descargar modelo de voz';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Se requiere una descarga única del modelo (~${sizeMB}MB).\n\nUna vez descargado, la transcripción se ejecuta completamente en el dispositivo.';
  }

  @override
  String get speechModelStartDownload => 'Iniciar descarga';

  @override
  String get speechModelChooseSource => 'Elige fuente de descarga:';

  @override
  String get speechModelChinaMirror =>
      '🇨🇳 Espejo de China (más rápido en CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (global)';

  @override
  String get speechModelDownloading => 'Descargando modelo...';

  @override
  String get speechModelConnecting => 'Conectando...';

  @override
  String get deleteSpeechModel => 'Eliminar modelo de voz';

  @override
  String get confirmDeleteSpeechModelMessage =>
      '¿Eliminar los archivos descargados del modelo local de reconocimiento de voz? Se descargarán de nuevo la próxima vez que se use voz a texto local.';

  @override
  String get speechModelDeletedSuccess =>
      'Archivos del modelo de voz eliminados';

  @override
  String get speechModelNotDownloaded =>
      'No se encontraron archivos descargados del modelo de voz';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'No se pudieron eliminar los archivos del modelo de voz: $error';
  }

  @override
  String get speechTranscribing => 'Reconociendo...';

  @override
  String get speechNoResult => 'No se detectó voz';

  @override
  String get useLocalSpeechToTextTitle => 'Usar voz a texto local';

  @override
  String get useLocalSpeechToTextDesc =>
      'Cuando está activado, el audio se transcribe en el dispositivo antes de enviarse; es útil para modelos que no admiten entrada de audio. Cuando está desactivado, el audio original se envía directamente al modelo.';

  @override
  String get pendingAiProcessingHint => 'Configurar modelo de IA para procesar';

  @override
  String get demoWelcome =>
      '¡Bienvenido a Memex!\nVeamos rápidamente qué puede hacer la IA con tus registros.';

  @override
  String get demoTapAdd => 'Toca aquí para crear tu primer registro';

  @override
  String get demoTapSend => 'Toca para enviar tu primer registro';

  @override
  String get demoTapCard => 'Toca para ver cómo la IA organizó tu registro';

  @override
  String get demoDetailHint =>
      'Este es el detalle de tu registro organizado por la IA. Explóralo y luego vuelve para continuar el recorrido.';

  @override
  String get demoTapInsight => 'Toca para ver insights generados por IA';

  @override
  String get demoTapInsightUpdate =>
      'Toca para generar insights a partir de tus registros';

  @override
  String get demoTapKnowledge =>
      'Revisa tus archivos de conocimiento organizados automáticamente';

  @override
  String get demoDone => 'Empieza a registrar tu vida.';

  @override
  String get demoStartTour => 'Iniciar recorrido';

  @override
  String get demoGetStarted => 'Empezar';

  @override
  String get demoSkip => 'Omitir';

  @override
  String get demoPrefillText => '¡Hola Memex! Este es mi primer registro 🎉';

  @override
  String get visionBadge => 'Visión';

  @override
  String get notMultimodalHint =>
      'Memex depende de capacidades de modelos multimodales para el análisis de medios. Si tus registros contienen imágenes, asegúrate de que el modelo configurado admita entrada de imagen.';

  @override
  String get defaultModelPrefix => 'Predeterminado';

  @override
  String get recommendedBadge => 'Recomendado';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Cambiar compañero';

  @override
  String get personaChatInputHint => 'Escribe un mensaje...';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get yesterday => 'Ayer';

  @override
  String get showInsightTextTitle => 'Mostrar comentario de insight de Memex';

  @override
  String get showInsightTextDesc =>
      'Si se muestra el insight de Memex como comentario fijado en la sección de comentarios del detalle de la tarjeta.';

  @override
  String get enableCharacterCommentTitle =>
      'Comentario automático de personaje';

  @override
  String get enableCharacterCommentDesc =>
      'Los personajes comentan automáticamente en registros nuevos.';

  @override
  String get maxCommentCharactersTitle => 'Máximo de personajes comentando';

  @override
  String get maxCommentCharactersDesc =>
      'Cuántos personajes pueden comentar en cada registro.';

  @override
  String replyTo(String name) {
    return 'Responder a $name';
  }

  @override
  String get cdnSignalsComments => 'Nueva respuesta recibida';

  @override
  String get cdnSignalsInsight => 'Nuevo insight generado';

  @override
  String get cdnSignalsBoth => 'Nueva respuesta e insight';

  @override
  String get untitledCard => 'Tarjeta sin título';

  @override
  String get locationContextTitle => 'Contexto de ubicación';

  @override
  String get locationContextDescription =>
      'Contexto de ciudad y barrio actuales para chat con Agent';

  @override
  String get locationContextAttachTitle => 'Adjuntar ubicación actual al chat';

  @override
  String get locationContextAttachDesc =>
      'Usa el GPS del dispositivo y geocodificación inversa para proporcionar ciudad, distrito y barrio al Agent.';

  @override
  String get reverseGeocodingProvider => 'Proveedor de geocodificación inversa';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Clave de API de Amap';

  @override
  String get amapGcj02Note =>
      'Amap usa coordenadas GCJ-02. El GPS del dispositivo se convierte antes de la geocodificación inversa.';

  @override
  String get contextGranularity => 'Granularidad de contexto';

  @override
  String get granularityCity => 'Ciudad';

  @override
  String get granularityDistrict => 'Distrito';

  @override
  String get granularityNeighborhood => 'Barrio';

  @override
  String get granularityStreet => 'Calle';

  @override
  String get granularityFullAddress => 'Candidato de dirección completa';

  @override
  String get locationFreshness => 'Actualidad de ubicación';

  @override
  String minutesShort(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get oneHour => '1 hora';

  @override
  String get testCurrentLocation => 'Probar ubicación actual';

  @override
  String locationTestFailed(String error) {
    return 'Falló: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Geocodificación inversa';

  @override
  String get locationDebugProvider => 'Proveedor';

  @override
  String get locationDebugAgentContext => 'Contexto de Agent';

  @override
  String get locationDebugSource => 'Fuente';

  @override
  String get locationDebugAddressSummary => 'Resumen de dirección';

  @override
  String get locationDebugFullAddress => 'Dirección completa';

  @override
  String get locationDebugCoordinates => 'Coordenadas';

  @override
  String get locationDebugAccuracy => 'Precisión';

  @override
  String get locationDebugReason => 'Motivo';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'no disponible';

  @override
  String get locationDebugInjected => 'inyectado';

  @override
  String get locationDebugNotInjected => 'no inyectado';

  @override
  String get locationStatusUpdatedAt => 'Actualizado';

  @override
  String get locationStatusSuccessTitle => 'La ubicación actual está lista';

  @override
  String get locationStatusSuccessBody =>
      'Memex puede adjuntar este resumen de ubicación cuando el contexto de ubicación sea relevante.';

  @override
  String get locationStatusApproximateTitle => 'Solo ubicación aproximada';

  @override
  String get locationStatusApproximateBody =>
      'La precisión parece de nivel ciudad o zona. Puedes seguir usándola o activar Ubicación precisa en la configuración del sistema para un contexto más ajustado.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'La ubicación del sistema está desactivada';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex solo usa el GPS del dispositivo y no inferirá ubicación por red o IP. En Android, abre Ajustes de ubicación; en iOS, activa Ajustes > Privacidad y seguridad > Servicios de ubicación.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Se necesita permiso de ubicación';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Permite que Memex use ubicación al probar o cuando el contexto de ubicación sea necesario. No se solicita acceso permanente.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'El permiso de ubicación está bloqueado';

  @override
  String get locationStatusPermissionForeverBody =>
      'Abre la configuración de la app y permite ubicación para Memex. En iOS, basta con Mientras se usa la app.';

  @override
  String get locationStatusDisabledTitle =>
      'El contexto de ubicación está desactivado';

  @override
  String get locationStatusDisabledBody =>
      'Activa el interruptor de arriba y guarda cuando quieras que Memex adjunte ubicación del dispositivo al contexto de Agent.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'El GPS funciona, pero falló la búsqueda de dirección';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex tiene coordenadas, pero no inyectará contexto solo de GPS al Agent. Revisa el proveedor de geocodificación inversa e inténtalo de nuevo.';

  @override
  String get locationStatusUnavailableTitle => 'Ubicación no disponible';

  @override
  String get locationStatusUnavailableBody =>
      'Revisa los servicios de ubicación del sistema y el permiso de la app, luego prueba de nuevo.';

  @override
  String get allowLocationPermissionButton => 'Permitir permiso de ubicación';

  @override
  String get openAppSettingsButton => 'Abrir configuración de la app';

  @override
  String get openLocationSettingsButton => 'Abrir ajustes de ubicación';

  @override
  String get locationSettingsOpenFailed =>
      'No se pudo abrir la configuración del sistema.';

  @override
  String locationActionFailed(String error) {
    return 'Acción de ubicación fallida: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Buscar configuración...';

  @override
  String get settingsSearchEmpty => 'No se encontraron ajustes coincidentes';

  @override
  String get importCharacterCard => 'Importar tarjeta de personaje';

  @override
  String get firstMessageLabel => 'Primer mensaje';

  @override
  String get firstMessageHint =>
      'Saludo enviado en la primera conversación (opcional)';

  @override
  String get systemPromptOverrideLabel =>
      'Sobrescritura del prompt del sistema';

  @override
  String get systemPromptOverrideHint =>
      'Sobrescribe el prompt del sistema predeterminado (avanzado, opcional)';

  @override
  String get postHistoryInstructionsLabel =>
      'Instrucciones posteriores al historial';

  @override
  String get postHistoryInstructionsHint =>
      'Instrucciones inyectadas después del historial de chat y antes de la respuesta (opcional)';

  @override
  String get mesExampleLabel => 'Ejemplos de mensajes';

  @override
  String get mesExampleHint =>
      'Diálogos de ejemplo que muestran el estilo del personaje (opcional)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Conocimiento de fondo inyectado cuando se activan palabras clave';

  @override
  String get characterMemoryTitle => 'Memoria del personaje';

  @override
  String get characterMemorySubtitle =>
      'Dinámicas de relación y memorias de interacción entre personaje y usuario';

  @override
  String get addTooltip => 'Añadir';

  @override
  String get constantBadge => 'Constante';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Entrada $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Palabras clave: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Memoria $index';
  }

  @override
  String get addWorldEntry => 'Añadir entrada de World Book';

  @override
  String get editWorldEntry => 'Editar entrada de World Book';

  @override
  String get commentTitleLabel => 'Comentario / Título';

  @override
  String get entryDescriptionHint => 'Descripción de entrada (opcional)';

  @override
  String get triggerKeywordsLabel => 'Palabras clave activadoras';

  @override
  String get triggerKeywordsHint =>
      'Separadas por comas, p. ej.: magia, hechizo';

  @override
  String get contentLabel => 'Contenido';

  @override
  String get worldEntryContentHint =>
      'Conocimiento de fondo inyectado cuando se activan palabras clave';

  @override
  String get enabledCheckbox => 'Activado';

  @override
  String get addMemory => 'Añadir memoria';

  @override
  String get editMemory => 'Editar memoria';

  @override
  String get memoryLabelField => 'Etiqueta';

  @override
  String get memoryLabelHint =>
      'Identificador único, p. ej.: preferencia de nombre';

  @override
  String get memoryContentHint => 'Contenido de memoria';

  @override
  String get salienceLabel => 'Relevancia: ';

  @override
  String get labelCannotBeEmpty => 'La etiqueta no puede estar vacía';

  @override
  String importSuccess(Object name) {
    return '$name importado correctamente';
  }

  @override
  String importFailed(Object error) {
    return 'Importación fallida: $error';
  }

  @override
  String get supportedFormats => 'Formatos admitidos';

  @override
  String get tavernImportDescription =>
      '• Tarjetas de personaje SillyTavern V2 (.json)\n• Imágenes PNG con tarjetas incrustadas (.png)\n\nCampos como persona, World Book, etc. se mapearán automáticamente al formato de personaje de Memex.';

  @override
  String get pickCharacterFile => 'Elegir archivo de personaje';

  @override
  String get repickFile => 'Elegir otro archivo';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'Prompt del sistema';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count entradas';
  }

  @override
  String fileLabel(Object filename) {
    return 'Archivo: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Ya existe un personaje con el mismo nombre: $names. Importar creará un nuevo personaje sin sobrescribir los existentes.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Establecer como compañero principal';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Establecer automáticamente como tu compañero principal después de importar';

  @override
  String get confirmImport => 'Confirmar importación';

  @override
  String get chatBackground => 'Fondo de chat';

  @override
  String get chooseChatBackgroundImage => 'Elegir imagen de fondo';

  @override
  String get earlyUpdateSettingsTitle => 'Actualizaciones de acceso Early';

  @override
  String get earlyUpdateSettingsDesc =>
      'Busca en los pre-lanzamientos de GitHub el APK Early correspondiente, descárgalo y entrégalo al instalador de Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Las actualizaciones Early solo están disponibles en la build Android Early.';

  @override
  String get earlyUpdateAutoCheckTitle =>
      'Comprobar actualizaciones automáticamente';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Comprobar al iniciar como máximo una vez cada 12 horas.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Descargar solo con Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Omitir descargas de actualización al usar datos móviles.';

  @override
  String get earlyUpdateAutoInstallTitle =>
      'Descargar e instalar automáticamente';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Cuando se encuentre una nueva build, descargarla y abrir automáticamente el instalador de Android.';

  @override
  String get earlyUpdateCheckNow => 'Comprobar ahora';

  @override
  String get earlyUpdateChecking => 'Comprobando pre-lanzamientos de GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Omitido porque las descargas solo con Wi-Fi están activadas.';

  @override
  String get earlyUpdateNoUpdate => 'Ya tienes la build Early más reciente.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'La build Early $version+$build está disponible.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Descargar e instalar';

  @override
  String get earlyUpdateDownloadInProgress => 'Descargando actualización...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Descargando actualización: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Paquete de actualización descargado. Listo para instalar.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Instalar paquete descargado';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Borrar paquete descargado';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Paquete de actualización descargado borrado.';

  @override
  String get earlyUpdateInstallStarted => 'Instalador de Android abierto.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Permite que Memex instale apps desconocidas y luego toca descargar e instalar otra vez.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Última comprobación: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Error al comprobar actualización: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Actualización Early disponible';

  @override
  String get earlyUpdateReleaseNotes => 'Notas de la versión';

  @override
  String get dismissAllNotifications => 'Borrar todo';

  @override
  String get dismissByType => 'Borrar por tipo';

  @override
  String get dismissTypeSystemAction => 'Recordatorios y eventos';

  @override
  String get dismissTypeClarification => 'Aclaraciones';

  @override
  String get dismissTypeCardUpdate => 'Actualizaciones de tarjetas';

  @override
  String dismissedCount(Object count) {
    return '$count borrado(s)';
  }

  @override
  String get dataImportTitle => 'Importar archivos';

  @override
  String get dataImportSettingsDescription =>
      'Trae archivos antiguos a Memex y decide después si quieres organizarlos.';

  @override
  String get dataImportDescription =>
      'Elige notas antiguas, registros exportados, documentos o archivos ZIP. Memex guarda primero una copia y no modifica los originales. Después podrás decidir si quieres que Memex te ayude a organizarlos.';

  @override
  String get dataImportSelectFiles => 'Elegir archivos para importar';

  @override
  String get dataImportImporting => 'Guardando archivos...';

  @override
  String get dataImportSuccess => 'Archivos guardados en Memex';

  @override
  String get dataImportOnlyStored =>
      'Archivos guardados. No se inició organización.';

  @override
  String get dataImportQueued =>
      'Memex organizará esta importación en segundo plano.';

  @override
  String get dataImportResultTitle => 'Importación completada';

  @override
  String dataImportResultSummary(Object count) {
    return 'Se guardaron $count archivos. Puedes organizarlos ahora o conservarlos como material original.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count elementos tenían el mismo nombre y se renombraron para no sobrescribir nada.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'Se omitieron $count elementos inusuales del archivo comprimido; el resto se importó normalmente.';
  }

  @override
  String get dataImportChooseProcessing => 'Organizar estos archivos';

  @override
  String get dataImportProcessTitle => '¿Organizar esta importación?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Importaste $count archivos. Elige si Memex debe organizarlos ahora o solo conservar los originales.';
  }

  @override
  String get dataImportProcessKnowledgeBase =>
      'Organizar en la base de conocimiento';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Ideal para documentos, notas, material de proyectos y referencias. Memex extraerá información útil y la agrupará para usarla después.';

  @override
  String get dataImportProcessTimelineCards =>
      'Crear registros de línea de tiempo';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Ideal para diarios, chats, historial de actividad y exportaciones antiguas. Memex convertirá el contenido con fechas en registros cuando tenga sentido.';

  @override
  String get dataImportImpactNone =>
      'Memex solo conservará estos archivos originales. No se iniciará organización con IA.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex leerá estos archivos y organizará la información útil a largo plazo en la base de conocimiento. No creará registros de línea de tiempo de forma proactiva.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex leerá estos archivos y creará registros de línea de tiempo para eventos o historial con fecha cuando corresponda. No organizará proactivamente la base de conocimiento.';

  @override
  String get dataImportImpactBoth =>
      'Memex intentará crear registros de línea de tiempo y organizar información reutilizable en la base de conocimiento. Es lo más adecuado para un archivo personal completo.';

  @override
  String get dataImportFinish => 'Solo guardar';
}
