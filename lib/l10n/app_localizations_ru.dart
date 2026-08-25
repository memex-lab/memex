// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get timesLabel => 'Раз';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Сделать $modelId моделью по умолчанию';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get unknownModel => 'Неизвестная модель';

  @override
  String get notSet => 'Не задано';

  @override
  String get confirmClear => 'Подтвердить очистку';

  @override
  String get confirmClearTokenMessage =>
      'Очистить текущего пользователя? Нужно будет снова ввести ID пользователя.';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get tokenCleared => 'Пользователь очищен';

  @override
  String clearTokenFailed(Object error) {
    return 'Не удалось очистить пользователя: $error';
  }

  @override
  String get selectDateRangeOptional =>
      'Выберите диапазон дат (необязательно):';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get select => 'Выбрать';

  @override
  String get processLimitOptional => 'Лимит обработки (необязательно)';

  @override
  String get leaveEmptyForAll => 'Оставьте пустым, чтобы обработать все';

  @override
  String get startProcessing => 'Начать обработку';

  @override
  String get userIdNotFound => 'ID пользователя не найден';

  @override
  String createTaskFailed(Object error) {
    return 'Не удалось создать задачу: $error';
  }

  @override
  String get reprocessCards => 'Повторно обработать карточки';

  @override
  String get reprocessCardsTaskCreated =>
      'Запрос на повторную обработку поставлен в очередь Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Область';

  @override
  String get reprocessCardsCardOnly => 'Только карточки';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Попросить Super Agent проверить и заново создать выбранные карточки ленты.';

  @override
  String get reprocessCardsRerunDownstream =>
      'Карточки и связанные продолжения';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Попросить Super Agent при необходимости также учесть связанные обновления PKM и инсайтов.';

  @override
  String get reanalyzeMediaAssets => 'Повторно прочитать медиа-вложения';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Попросить Super Agent снова проверить прикрепленные медиа при пересоздании карточек.';

  @override
  String get regenerateComments => 'Сгенерировать комментарии заново';

  @override
  String get regenerateCommentsTaskCreated =>
      'Задача повторной генерации комментариев создана и выполняется в фоне';

  @override
  String get rebuildSearchIndex => 'Перестроить поисковый индекс';

  @override
  String get rebuildSearchIndexSuccess => 'Поисковый индекс успешно перестроен';

  @override
  String get rebuildSearchIndexFailed =>
      'Не удалось перестроить поисковый индекс';

  @override
  String get clearData => 'Очистить данные';

  @override
  String get confirmClearDataMessage => 'Очистить данные?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Все локальные данные workspace текущего пользователя будут удалены, включая карточки, медиа, файлы знаний, инсайты, память, историю чатов и состояние системы.\\n\\nЭто действие нельзя отменить!';

  @override
  String get clearFailedAgentContexts => 'Очистить сбойный контекст разговора';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Очистить сохраненный контекст разговора для агентов Insight и Schedule? Это полезно после смены моделей, когда предыдущие сообщения агента больше несовместимы. Факты, карточки, знания, воспоминания и настройки модели не будут удалены.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'Очищено сохраненных контекстов разговора: $count';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Не удалось очистить контекст разговора: $error';
  }

  @override
  String get cloneToTestUser => 'Клонировать в тестового пользователя';

  @override
  String get confirmCloneToTestUserMessage =>
      'Скопировать текущий workspace в нового локального тестового пользователя и переключиться на него. Runtime-состояние агентов не копируется. Данные текущего пользователя не будут изменены.';

  @override
  String get testUserIdLabel => 'ID тестового пользователя';

  @override
  String get testUserIdHelper =>
      'Используйте буквы, цифры, дефис или нижнее подчеркивание.';

  @override
  String get testUserIdInvalid =>
      'Используйте только буквы, цифры, дефис или нижнее подчеркивание.';

  @override
  String get overwriteExistingTestUser =>
      'Заменить существующего тестового пользователя с тем же ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Переключено на тестового пользователя $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Не удалось клонировать тестового пользователя: $error';
  }

  @override
  String get dataClearedSuccess => 'Данные успешно очищены';

  @override
  String clearDataFailed(Object error) {
    return 'Не удалось очистить данные: $error';
  }

  @override
  String get personalCenter => 'Личный центр';

  @override
  String get viewLogs => 'Просмотр логов';

  @override
  String get systemAuthorization => 'Системная авторизация';

  @override
  String get aiCharacterConfig => 'Настройка AI-персонажа';

  @override
  String get modelConfig => 'Настройка модели';

  @override
  String get agentConfig => 'Настройка агента';

  @override
  String get experimentalLab => 'Лаборатории';

  @override
  String get experimentalLabDescription =>
      'Экспериментальные функции, которые позже могут измениться или переместиться.';

  @override
  String get modelUsageStats => 'Статистика использования моделей';

  @override
  String get asyncTaskList => 'Список асинхронных задач';

  @override
  String get clearLocalToken => 'Очистить пользователя';

  @override
  String get insightCardTemplates => 'Шаблоны карточек инсайтов';

  @override
  String get timelineCardTemplates => 'Шаблоны карточек ленты';

  @override
  String get logViewer => 'Просмотр логов';

  @override
  String get autoRefresh => 'Автообновление';

  @override
  String get lineCount => 'Строк: ';

  @override
  String get all => 'Все';

  @override
  String get schedule => 'Расписание';

  @override
  String get appLockConfig => 'Настройка блокировки приложения';

  @override
  String loadStatsFailed(Object error) {
    return 'Не удалось загрузить статистику: $error';
  }

  @override
  String get overview => 'Обзор';

  @override
  String get daily => 'По дням';

  @override
  String get modelStatsByAgent => 'По агентам';

  @override
  String get detail => 'Детали';

  @override
  String get date => 'Дата';

  @override
  String get agent => 'Агент';

  @override
  String get noData => 'Нет данных';

  @override
  String get totalCalls => 'Всего вызовов';

  @override
  String get calls => 'Вызовы';

  @override
  String callsCount(Object count) {
    return '$count вызовов';
  }

  @override
  String get selectDateRange => 'Выберите диапазон дат';

  @override
  String get totalTokens => 'Всего токенов';

  @override
  String get cacheRate => 'Доля кэша';

  @override
  String get promptTokens => 'Токены промпта';

  @override
  String get completionTokens => 'Токены ответа';

  @override
  String get cachedTokens => 'Кэшированные токены';

  @override
  String get thoughtTokens => 'Токены рассуждений';

  @override
  String get prompt => 'Промпт';

  @override
  String get completion => 'Ответ';

  @override
  String get cached => 'Кэшировано';

  @override
  String get thought => 'Рассуждение';

  @override
  String get model => 'Модель';

  @override
  String get scene => 'Сценарий';

  @override
  String get sceneId => 'ID сценария';

  @override
  String get tokenUsage => 'Использование токенов';

  @override
  String get handler => 'Обработчик';

  @override
  String get modelBreakdown => 'Разбивка по моделям';

  @override
  String get callDetails => 'Детали вызова';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Детали записи: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Не удалось сохранить конфигурацию LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Предпросмотр HTML недоступен в веб-версии. Посмотрите на мобильном устройстве.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Не удалось сохранить данные пользователя: $error';
  }

  @override
  String get totalEstimatedCost => 'Общая примерная стоимость';

  @override
  String get close => 'Закрыть';

  @override
  String get totalTokenConsumption => 'Общее потребление токенов';

  @override
  String get dataLoadFailedRetry =>
      'Не удалось загрузить данные, повторите позже.';

  @override
  String get timelineLoadFailedRetry =>
      'Не удалось загрузить ленту, повторите позже.';

  @override
  String get newPerspective => 'Новый взгляд';

  @override
  String get startPoint => 'Начало';

  @override
  String get endPoint => 'Конец';

  @override
  String get originalInput => 'Исходный ввод';

  @override
  String get referenceContent => 'Справочный контент';

  @override
  String referenceWithTitle(Object title) {
    return 'Справка: $title';
  }

  @override
  String get actionCenterTitle => 'Ожидающие действия';

  @override
  String get noPendingActions => 'Нет ожидающих действий';

  @override
  String get clarificationNeeded => 'Memex хочет уточнить';

  @override
  String get clarificationTextHint => 'Введите короткий ответ';

  @override
  String get clarificationTextRequired => 'Сначала добавьте короткий ответ';

  @override
  String get clarificationAnswered => 'Отвечено';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Ответ: $answer';
  }

  @override
  String get answerSaved => 'Ответ сохранен';

  @override
  String get clarificationOtherAnswer => 'Ручной ввод';

  @override
  String get clarificationNotSure => 'Не уверен / предпочитаю не отвечать';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get footprintMap => 'Карта следов';

  @override
  String get waypointPlaces => 'Промежуточные места';

  @override
  String get unknownPlace => 'Неизвестное место';

  @override
  String get releaseToSend => 'Отпустите, чтобы отправить';

  @override
  String get selectFromAlbum => 'Выбрать из альбома';

  @override
  String get clipboardPreviewTitle => 'Новый буфер обмена';

  @override
  String get clipboardPreviewImageTitle => 'Изображение из буфера';

  @override
  String get clipboardPreviewImageDescription =>
      'Изображение готово к добавлению';

  @override
  String get clipboardPreviewUnprocessed => 'Еще не вставлено';

  @override
  String get clipboardPreviewPasteToInput => 'Вставить в поле ввода';

  @override
  String get clipboardPreviewAddImageToInput => 'Добавить изображение';

  @override
  String get clipboardPreviewImageFailed =>
      'Не удалось прочитать изображение из буфера';

  @override
  String get tellAiWhatHappened => 'Расскажите AI, что произошло...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Запись: $duration';
  }

  @override
  String get playing => 'Воспроизведение...';

  @override
  String get sendLabel => 'Отправить';

  @override
  String attachedImagesMessage(Object count) {
    return 'Отправлено изображений: $count';
  }

  @override
  String get noTaskData => 'Нет данных задачи';

  @override
  String createdAtDate(Object date) {
    return 'Создано: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Обновлено: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Длительность: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Повтор: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Не удалось загрузить детали, повторите позже.';

  @override
  String get loadFailed => 'Загрузка не удалась';

  @override
  String get reload => 'Перезагрузить';

  @override
  String get aiInsightDetail => 'Детали инсайта';

  @override
  String relatedRecordsCount(Object count) {
    return 'Связанные записи ($count)';
  }

  @override
  String get noRelatedRecords => 'Связанных записей нет';

  @override
  String get useFingerprintToUnlock => 'Разблокировать отпечатком пальца';

  @override
  String get locked => 'Заблокировано';

  @override
  String get wrongPassword => 'Неверный пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get memexLocked => 'Memex заблокирован';

  @override
  String get calendarShortSun => 'Вс';

  @override
  String get calendarShortMon => 'Пн';

  @override
  String get calendarShortTue => 'Вт';

  @override
  String get calendarShortWed => 'Ср';

  @override
  String get calendarShortThu => 'Чт';

  @override
  String get calendarShortFri => 'Пт';

  @override
  String get calendarShortSat => 'Сб';

  @override
  String noRecordsOnDate(Object date) {
    return 'Нет записей за $date';
  }

  @override
  String get footprintPath => 'Маршрут следов';

  @override
  String get lifeCompositionTable => 'Состав жизни';

  @override
  String get emotionReframe => 'Переосмысление эмоций';

  @override
  String get chronicleOfThings => 'Хроника вещей';

  @override
  String get goalProgress => 'Прогресс целей';

  @override
  String get trendChart => 'График тренда';

  @override
  String get comparisonChart => 'Сравнительный график';

  @override
  String get todayTimeFlow => 'Поток времени сегодня';

  @override
  String get aiInputHint => 'Будь то воспоминания или настоящее, я здесь...';

  @override
  String get refreshSuperAgentStateTooltip => 'Очистить контекст Memex Agent';

  @override
  String get refreshSuperAgentStateTitle =>
      'Очистить исторический контекст Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'Видимая история чата останется, но исторический runtime-контекст Memex Agent будет очищен, и будущие ответы начнутся с чистого контекста. Постоянная память, файлы базы знаний, карточки и другие сохраненные данные не затрагиваются. Используйте это, если Memex Agent продолжает вести себя ненормально. Продолжить?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Дождитесь завершения текущего сообщения Memex Agent перед очисткой контекста.';

  @override
  String get refreshSuperAgentStateSuccess => 'Контекст Memex Agent очищен';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Не удалось очистить контекст Memex Agent: $error';
  }

  @override
  String get nothingHere => 'Здесь пока ничего нет';

  @override
  String get nothingHereHint =>
      'Нажмите кнопку ниже, чтобы создать первую карточку';

  @override
  String get agentProcessing => 'AI обрабатывает...';

  @override
  String get keepAppOpen => 'Не закрывайте приложение';

  @override
  String get activityDetail => 'Детали активности';

  @override
  String get noAgentActivityYet => 'Активности агента пока нет';

  @override
  String get processingEllipsis => 'Обработка...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent приостановлен';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent требует внимания';

  @override
  String get agentBackgroundStageIdle => 'Ожидание';

  @override
  String get agentBackgroundStageProcessing => 'Обработка';

  @override
  String get agentBackgroundStageQueued => 'В очереди';

  @override
  String get agentBackgroundStageRetrying => 'Ожидание повтора';

  @override
  String get agentBackgroundStagePaused => 'Приостановлено';

  @override
  String get agentBackgroundStageCompleted => 'Завершено';

  @override
  String get agentBackgroundStageNeedsAttention => 'Требует внимания';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Анализ медиа';

  @override
  String get agentBackgroundStageGeneratingCard => 'Создание карточки';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Обновление знаний';

  @override
  String get agentBackgroundStagePreparingComment => 'Подготовка комментария';

  @override
  String get agentBackgroundStageRoutingFollowUps =>
      'Маршрутизация продолжений';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'Выполняется $running, ожидает $pending, повтор $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Обрабатывается задач в очереди: $count.';
  }

  @override
  String get agentBackgroundNoTasks => 'Нет фоновых задач.';

  @override
  String get agentBackgroundStarting => 'Обработка запускается.';

  @override
  String get agentBackgroundCompletedDetail => 'Все фоновые задачи завершены.';

  @override
  String get agentBackgroundFailedDetail => 'Обработка остановилась с ошибкой.';

  @override
  String get agentBackgroundPausedDetail =>
      'Обработка приостановлена и продолжится позже.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Ожидание следующего шага обработки.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Текущий шаг будет автоматически повторен.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Чтение вложений и локального контекста.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Преобразование записи в карточку ленты.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Обновление локальных знаний и памяти.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Подготовка ответа-последствия от ассистента.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Проверка последующих действий для этой карточки.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Приостановлено - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Требует внимания - $summary';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get languageSettings => 'Язык';

  @override
  String get languageSettingsDesc => 'Изменить язык интерфейса приложения';

  @override
  String get noPendingActionsToast => 'Нет ожидающих действий';

  @override
  String get knowledgeNewDiscovery => 'Новое открытие в знаниях';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Найдено новых инсайтов: $count';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Обновлено существующих инсайтов: $count';
  }

  @override
  String get sectionNewInsights => 'Новые инсайты';

  @override
  String get sectionUpdatedInsights => 'Обновленные инсайты';

  @override
  String get unnamedInsight => 'Инсайт без названия';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get copy => 'Копировать';

  @override
  String get selectedLocation => 'Выбранное место';

  @override
  String get confirmLocationName => 'Подтвердите название места';

  @override
  String get confirmLocationNameHint =>
      'Название можно изменить (координаты останутся прежними)';

  @override
  String get nameLabel => 'Название';

  @override
  String get inputPlaceNameHint => 'Введите название места...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Координаты: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Подтвердить место';

  @override
  String get welcomeToMemex => 'Добро пожаловать в Memex';

  @override
  String get createUserIdToStart => 'Создайте профиль';

  @override
  String get userIdLabel => 'Ваше имя / никнейм';

  @override
  String get userIdHint => 'Введите имя или никнейм';

  @override
  String get pleaseEnterUserId => 'Введите имя';

  @override
  String get userIdMaxLength => 'Имя не должно превышать 50 символов';

  @override
  String get startUsing => 'Продолжить';

  @override
  String get userIdTip => 'Это будет использоваться для персонализации опыта.';

  @override
  String get setupModelConfigTitle => 'Настройте AI-модель';

  @override
  String get setupModelConfigSubtitle =>
      'Memex нужна frontier AI-модель, чтобы организовывать записи, анализировать изображения и генерировать инсайты. Выберите один способ подключения.';

  @override
  String get setupModelConfigComplete => 'Готово и перейти';

  @override
  String get aiService => 'Сервис моделей Memex';

  @override
  String get aiModelHubTitle => 'AI-модели и сервисы';

  @override
  String get aiModelHubSubtitle =>
      'Выберите официальный сервис Memex или подключите своего провайдера. Расширенная маршрутизация моделей останется доступной при необходимости.';

  @override
  String get aiSetupCurrentStatusTitle => 'Текущая настройка';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'AI-сервис не настроен';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Выберите один способ подключения, чтобы включить AI-организацию записей, медиа и инсайтов.';

  @override
  String get aiSetupStatusMemexTitle => 'Используется официальный сервис MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex будет использовать официальное подключение и API-учетные данные, управляемые вашим аккаунтом MemeX.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Используются настройки своего провайдера';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex будет использовать настроенные учетные данные провайдера и выбранные роли моделей.';

  @override
  String get aiSetupChooseConnectionTitle => 'Выберите способ подключения';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Начните с варианта, который соответствует тому, как Memex должен получать доступ к AI-моделям.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Войдите в MemeX и используйте официальный сервис без выбора провайдеров, ключей или моделей уровня агента.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Добавьте учетные данные своего провайдера, выберите модель для Super Agent и при необходимости переопределите модели по агентам.';

  @override
  String get aiSetupCustomPageTitle => 'Свой AI-сервис';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Сначала настройте учетные данные провайдера, затем выберите модель, которую должен использовать Memex.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Провайдеры и API-ключи';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Добавьте или измените OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama или другого совместимого провайдера.';

  @override
  String get modelRolesTitle => 'Выберите основную модель';

  @override
  String get modelRolesDescription =>
      'Super Agent использует одну модель для текстового и графического ввода. Расширенные переопределения агентов доступны ниже.';

  @override
  String get textModelRoleTitle => 'Основная модель';

  @override
  String get textModelRoleDescription =>
      'Используется Super Agent для текста, изображений, карточек, знаний, инсайтов, чата, комментариев и памяти.';

  @override
  String get modelConnectionsTitle => 'Провайдеры моделей и API-ключи';

  @override
  String get modelConnectionsDescription =>
      'Подключите официальный сервис Memex или добавьте учетные данные своего провайдера.';

  @override
  String get relatedAiCapabilitiesTitle =>
      'Расширенные и связанные возможности';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Настройте назначения агентов, провайдера геолокации и поведение распознавания речи.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Возможности сервиса';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Выберите провайдеров, которых Memex использует для смежных AI-возможностей, например речи и обратного геокодирования.';

  @override
  String get aiSetupAdvancedCustomizationTitle =>
      'Расширенная маршрутизация моделей';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Для опытных пользователей, которым нужно, чтобы разные агенты использовали разных провайдеров или конфигурации моделей.';

  @override
  String get locationProviderSettings => 'Провайдер геолокации';

  @override
  String get speechProviderSettings => 'Распознавание речи';

  @override
  String get advancedAgentModelAssignments => 'Назначения моделей агентам';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Переопределить отдельных агентов';

  @override
  String get noConfiguredModelOptions =>
      'Добавьте провайдера или API-ключ перед выбором ролей моделей.';

  @override
  String get modelSlotUpdated => 'Роль модели обновлена';

  @override
  String get aiServiceMemexRouteTitle => 'Подключиться через Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex использует многоагентную систему, чтобы организовывать жизненные записи, заметки знаний и социальный контекст, находить более глубокие инсайты и обеспечивать AI-компаньона с постоянной памятью. Ваши данные хранятся как обычный текст Markdown, сохраняя свободу и переносимость данных.';

  @override
  String get aiServiceCustomApiRouteTitle => 'У меня есть API-ключ';

  @override
  String get aiServiceCustomModelDescription =>
      'Выберите это сначала, если у вас уже есть API-ключ OpenAI, Anthropic, DeepSeek, Gemini или другого провайдера.';

  @override
  String get enableAiService => 'Подключить через Memex';

  @override
  String get aiServiceReadyToast => 'AI-организация включена';

  @override
  String get aiServiceSettingsDescription =>
      'Если у вас нет API-ключа, используйте аккаунт Memex для подключения к основным сервисам моделей.';

  @override
  String get advancedModelConfiguration => 'Настроить API-ключ';

  @override
  String get skipForNow => 'Пропустить сейчас';

  @override
  String get clearAuth => 'Очистить авторизацию';

  @override
  String get authorizing => 'Авторизация...';

  @override
  String authFailed(Object error) {
    return 'Авторизация не удалась: $error';
  }

  @override
  String get authorized => 'Авторизовано';

  @override
  String get config => 'Конфигурация';

  @override
  String get calendar => 'Календарь';

  @override
  String get reminders => 'Напоминания';

  @override
  String get writeToSystemFailed => 'Не удалось записать в систему';

  @override
  String permissionRequired(Object name) {
    return 'Требуется разрешение: $name';
  }

  @override
  String permissionRationale(Object name) {
    return 'Разрешите приложению доступ к $name в Настройках, чтобы мы могли создать это для вас.';
  }

  @override
  String get goToSettings => 'Перейти в настройки';

  @override
  String get unknownAction => 'Неизвестное действие';

  @override
  String get discoveredCalendarEvent => 'Найдено событие календаря';

  @override
  String get discoveredReminder => 'Найдено напоминание';

  @override
  String get addToCalendar => 'Добавить в календарь';

  @override
  String get addToReminders => 'Добавить в напоминания';

  @override
  String get systemActionPendingExplanation =>
      'Ещё не добавлено. Нажмите ниже, чтобы запросить разрешение и добавить на устройство.';

  @override
  String addedToSuccess(Object target) {
    return 'Успешно добавлено в $target';
  }

  @override
  String get ignore => 'Игнорировать';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String get confirmDeleteSessionMessage =>
      'Удалить этот разговор? Это действие нельзя отменить.';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteSuccess => 'Успешно удалено';

  @override
  String deleteFailed(Object error) {
    return 'Удаление не удалось: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count дн. назад';
  }

  @override
  String get chatHistory => 'История чатов';

  @override
  String get enterFullScreenTooltip => 'Открыть на весь экран';

  @override
  String get exitFullScreenTooltip => 'Выйти из полноэкранного режима';

  @override
  String get noConversations => 'Нет разговоров';

  @override
  String loadSessionListFailed(Object error) {
    return 'Не удалось загрузить список сессий: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Вчера $time';
  }

  @override
  String get newChat => 'Новый чат';

  @override
  String messageCount(Object count) {
    return 'Сообщений: $count';
  }

  @override
  String get organize => 'Организовать';

  @override
  String get pkmCategoryProject => 'Проект';

  @override
  String get pkmCategoryProjectSubtitle => 'Краткосрочное · Цели · Дедлайны';

  @override
  String get pkmCategoryArea => 'Область';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Долгосрочное · Ответственность · Стандарты';

  @override
  String get pkmCategoryResource => 'Ресурс';

  @override
  String get pkmCategoryResourceSubtitle => 'Интересы · Вдохновение · Запас';

  @override
  String get pkmCategoryArchive => 'Архив';

  @override
  String get pkmCategoryArchiveSubtitle => 'Готово · Неактивно · Справка';

  @override
  String get recentChanges => 'Недавние изменения';

  @override
  String get noRecentChangesInThreeDays => 'За последние 3 дня изменений нет';

  @override
  String get unpinned => 'Не закреплено';

  @override
  String get pinnedStyle => 'Стиль закреплен';

  @override
  String operationFailed(Object error) {
    return 'Операция не удалась: $error';
  }

  @override
  String get refreshingInsightData =>
      'Обновление данных инсайтов, это может занять немного времени...';

  @override
  String refreshFailed(Object error) {
    return 'Обновление не удалось: $error';
  }

  @override
  String get sortUpdated => 'Порядок сортировки обновлен';

  @override
  String sortSaveFailed(Object error) {
    return 'Не удалось сохранить сортировку: $error';
  }

  @override
  String get insightCardDeleted => 'Карточка инсайта удалена';

  @override
  String deleteFailedShort(Object error) {
    return 'Удаление не удалось: $error';
  }

  @override
  String get knowledgeInsight => 'Инсайт знаний';

  @override
  String get completeSort => 'Завершить сортировку';

  @override
  String get noKnowledgeInsight => 'Нет инсайтов знаний';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return 'Фоновые задачи все еще обрабатываются: $count.';
  }

  @override
  String get insightUnavailableMessage =>
      'Этот инсайт еще генерируется или был обновлен. Обновите инсайты и повторите позже.';

  @override
  String get artifactOpen => 'Открыть';

  @override
  String get updating => 'Обновление...';

  @override
  String get update => 'Обновить';

  @override
  String get enabled => 'Включено';

  @override
  String get disabled => 'Отключено';

  @override
  String get appLockOn => 'Блокировка приложения включена';

  @override
  String get appLockOff => 'Блокировка приложения отключена';

  @override
  String get enableAppLockFirst => 'Сначала включите блокировку приложения';

  @override
  String get enterFourDigitPassword => 'Введите 4-значный пароль';

  @override
  String get passwordSetAndLockOn =>
      'Пароль задан, блокировка приложения включена';

  @override
  String get appLockSettings => 'Настройки блокировки приложения';

  @override
  String get enableAppLock => 'Включить блокировку приложения';

  @override
  String get enableAppLockSubtitle => 'Пароль требуется при запуске приложения';

  @override
  String get enableBiometrics => 'Включить биометрию';

  @override
  String get biometricsSubtitle =>
      'Использовать Face ID или Touch ID для разблокировки';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get setFourDigitPassword => 'Задать 4-значный пароль';

  @override
  String get reenterPasswordToConfirm =>
      'Введите пароль еще раз для подтверждения';

  @override
  String get passwordMismatch => 'Пароли не совпадают. Повторите попытку.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Удалить персонажа \"$name\"? Это действие нельзя отменить.';
  }

  @override
  String get configureAiCharacter => 'Настроить AI-персонажа';

  @override
  String get addCharacter => 'Добавить персонажа';

  @override
  String get addCharacterSubtitle =>
      'Выберите AI-персонажей для вашей команды инсайтов. Они будут анализировать данные вашей жизни с разных углов.';

  @override
  String get noCharacters => 'Нет персонажей';

  @override
  String loadCharacterFailed(Object error) {
    return 'Не удалось загрузить персонажей: $error';
  }

  @override
  String get noTags => 'Нет тегов';

  @override
  String get createSuccess => 'Успешно создано';

  @override
  String get updateSuccess => 'Успешно обновлено';

  @override
  String saveFailed(Object error) {
    return 'Сохранение не удалось: $error';
  }

  @override
  String get newCharacter => 'Новый персонаж';

  @override
  String get editCharacter => 'Редактировать персонажа';

  @override
  String get save => 'Сохранить';

  @override
  String get characterName => 'Имя персонажа';

  @override
  String get characterNameHint => 'Дайте персонажу имя';

  @override
  String get pleaseEnterCharacterName => 'Введите имя персонажа';

  @override
  String get tagsLabel => 'Теги';

  @override
  String get tagsHint =>
      'например wisdom, recognition, macro\\nРазделяйте несколько тегов запятыми';

  @override
  String get characterPersonaLabel => 'Персона персонажа';

  @override
  String get characterPersonaHint =>
      'Включите персону, руководство по стилю, пример диалога, фильтры знаний и т. д.\\nИспользуйте ## для заголовков разделов.';

  @override
  String get pleaseEnterCharacterPersona => 'Введите персону персонажа';

  @override
  String permissionRequestError(Object error) {
    return 'Ошибка запроса разрешения: $error';
  }

  @override
  String get permissionRequiredTitle => 'Требуется разрешение';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Вы навсегда запретили это разрешение или оно требуется системой. Включите его в системных настройках.';

  @override
  String get getting => 'Получение...';

  @override
  String get unauthorized => 'Не авторизовано';

  @override
  String get authorizedGoToSettings =>
      'Авторизовано. Перейдите в системные настройки, чтобы изменить.';

  @override
  String get location => 'Геолокация';

  @override
  String get locationPermissionReason =>
      'Для записи мест и функций, связанных с локацией';

  @override
  String get photos => 'Фото';

  @override
  String get photosPermissionReason =>
      'Для выбора фото, сохранения сгенерированных изображений и т. д.';

  @override
  String get camera => 'Камера';

  @override
  String get cameraPermissionReason => 'Для съемки фото и видео';

  @override
  String get microphone => 'Микрофон';

  @override
  String get microphonePermissionReason =>
      'Для распознавания речи, записи и т. д.';

  @override
  String get calendarPermissionReason =>
      'Для записи расписания и чтения событий календаря';

  @override
  String get remindersPermissionReason =>
      'Для записи и чтения ваших напоминаний';

  @override
  String get fitnessAndMotion => 'Фитнес и движение';

  @override
  String get fitnessPermissionReason => 'Для записи данных здоровья и движения';

  @override
  String get notification => 'Уведомления';

  @override
  String get notificationPermissionReason =>
      'Для отправки расписаний и важных напоминаний';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Оставить Memex Agent работать в фоне';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent работает локально на вашем устройстве. Уведомления позволяют Memex показывать прогресс и продолжать обработку после выхода из приложения или выключения экрана. Если уведомления отключены, держите Memex открытым на переднем плане до завершения задачи.';

  @override
  String get loadDetailFailedRetryShort =>
      'Не удалось загрузить детали, повторите позже.';

  @override
  String get total => 'Всего';

  @override
  String get estimatedCost => 'Примерная стоимость';

  @override
  String get byAgent => 'По агентам';

  @override
  String get timeUpdated => 'Время обновлено';

  @override
  String updateFailed(Object error) {
    return 'Обновление не удалось: $error';
  }

  @override
  String get locationUpdated => 'Локация обновлена';

  @override
  String get confirmDeleteCardMessage =>
      'Удалить эту карточку? Это действие нельзя отменить.';

  @override
  String get cardDetailNotFound => 'Детали карточки не найдены';

  @override
  String get saySomething => 'Напишите что-нибудь...';

  @override
  String get relatedMemories => 'Связанные воспоминания';

  @override
  String get viewMore => 'Показать еще';

  @override
  String get relatedRecords => 'Связанные записи';

  @override
  String get reply => 'Ответить';

  @override
  String get replySent => 'Ответ отправлен';

  @override
  String get insightTemplateGalleryTitle => 'Шаблоны карточек инсайтов';

  @override
  String get timelineTemplateGalleryTitle => 'Шаблоны карточек ленты';

  @override
  String get categoryTextual => 'Текстовые';

  @override
  String get timelineFilterAll => 'ВСЕ';

  @override
  String get insights => 'Инсайты';

  @override
  String get memoryTitle => 'Память';

  @override
  String get longTermProfile => 'Долгосрочный профиль';

  @override
  String get recentBuffer => 'Недавний буфер';

  @override
  String errorLoadingMemory(Object error) {
    return 'Ошибка загрузки памяти: $error';
  }

  @override
  String get agentConfiguration => 'Конфигурация агента';

  @override
  String get resetToDefaults => 'Сбросить к умолчаниям';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Сбросить все конфигурации агентов';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Вы уверены, что хотите сбросить все конфигурации агентов к значениям по умолчанию? Это действие нельзя отменить.';

  @override
  String get resetButton => 'Сбросить';

  @override
  String loadDataFailed(Object error) {
    return 'Не удалось загрузить данные: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Не удалось сохранить конфигурацию: $error';
  }

  @override
  String get selectLlmClient => 'Выберите LLM Client:';

  @override
  String get agentConfigurationsReset => 'Конфигурации агентов сброшены';

  @override
  String resetFailed(Object error) {
    return 'Сброс не удался: $error';
  }

  @override
  String get modelConfiguration => 'Конфигурация модели';

  @override
  String get resetAllConfigurationsTitle => 'Сбросить все конфигурации';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Вы уверены, что хотите сбросить все конфигурации моделей к значениям по умолчанию? Это действие нельзя отменить.';

  @override
  String get modelConfigurationsReset => 'Конфигурации моделей сброшены';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Нельзя удалить конфигурацию по умолчанию';

  @override
  String get cannotDeleteConfigurationTitle => 'Нельзя удалить конфигурацию';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Эта конфигурация сейчас используется следующими агентами:\\n\\n$agentList\\n\\nПеред удалением переназначьте этих агентов.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Удалить конфигурацию';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Вы уверены, что хотите удалить \"$key\"?';
  }

  @override
  String get defaultLabel => 'По умолчанию';

  @override
  String get setAsDefault => 'Сделать по умолчанию';

  @override
  String get invalidJsonInExtraField => 'Недопустимый JSON в поле Extra';

  @override
  String get keyAlreadyExists => 'Ключ уже существует';

  @override
  String get resetConfigurationTitle => 'Сбросить конфигурацию';

  @override
  String get resetConfigurationMessage =>
      'Сбросить эту конфигурацию к начальным значениям по умолчанию? Текущие изменения будут потеряны.';

  @override
  String get configurationResetPressSave =>
      'Конфигурация сброшена. Нажмите Сохранить, чтобы применить.';

  @override
  String get addConfiguration => 'Добавить конфигурацию';

  @override
  String get editConfiguration => 'Редактировать конфигурацию';

  @override
  String get duplicateConfiguration => 'Дублировать конфигурацию';

  @override
  String get duplicate => 'Дублировать';

  @override
  String get keyIdLabel => 'ID конфигурации';

  @override
  String get keyIdHelper =>
      'Назовите эту настройку, например deepseek или work-gpt.';

  @override
  String get required => 'Обязательно';

  @override
  String get clientLabel => 'Провайдер модели';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Популярные';

  @override
  String get providerOpenAiApiKey => 'API-ключ';

  @override
  String get providerOpenAiResponses => 'API-ключ (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API-ключ';

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
  String get providerOllama => 'Ollama (локально)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Прокси-сервис Memex';

  @override
  String get memexSignIn => 'Войти';

  @override
  String get memexCreateAccount => 'Создать аккаунт';

  @override
  String get memexUsername => 'Имя пользователя';

  @override
  String get memexPassword => 'Пароль';

  @override
  String get memexCreateAccountLink => 'Создать аккаунт';

  @override
  String get memexSignInLink => 'Уже есть аккаунт? Войти';

  @override
  String get memexTopUp =>
      'Пополните баланс, чтобы начать использовать Memex AI';

  @override
  String get memexTopUpSuccess => 'Пополнение успешно!';

  @override
  String get memexFillAllFields => 'Заполните все поля';

  @override
  String get memexUsernameTooShort =>
      'Имя пользователя должно быть не короче 6 символов';

  @override
  String get memexAuthFailed => 'Аутентификация не удалась';

  @override
  String get memexPaymentFailed => 'Не удалось создать платеж';

  @override
  String get memexLogout => 'Выйти';

  @override
  String get memexTopUpButton => 'Пополнить';

  @override
  String get memexTopUpChooseAmount => 'Выберите сумму';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Около $range записей';
  }

  @override
  String get memexTopUpPlanStarter => 'Стартовый';

  @override
  String get memexTopUpPlanEveryday => 'На каждый день';

  @override
  String get memexTopUpPlanHighVolume => 'Большой объем';

  @override
  String get memexTopUpPlanCustom => 'Свои кредиты';

  @override
  String get memexTopUpPlanStarterSubtitle =>
      'Подходит, чтобы попробовать Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Подходит для регулярной организации';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Подходит для больших пакетов';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Введите USD 1-10 000';

  @override
  String get memexTopUpCustomEstimate => 'Оценка основана на введенной сумме';

  @override
  String get memexCustomAmount => 'Своя сумма';

  @override
  String get memexViewHistory => 'История использования';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Баланс: $amount';
  }

  @override
  String get memexConfirmPassword => 'Подтвердите пароль';

  @override
  String get memexPasswordMismatch => 'Пароли не совпадают';

  @override
  String memexPayAmount(Object amount) {
    return 'Пополнить на $amount';
  }

  @override
  String get modelIdLabel => 'Модель';

  @override
  String get modelIdHelper => 'например gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Получение моделей...';

  @override
  String get fetchModelsButton => 'Получить модели';

  @override
  String get enterApiKeyFirst =>
      'Сначала введите API Key, чтобы получить модели';

  @override
  String get apiKeyLabel => 'API-ключ';

  @override
  String get baseUrlLabel => 'Конечная точка API';

  @override
  String get advancedSettings => 'Расширенные настройки';

  @override
  String get testConnectionSuccess => 'Подключение успешно';

  @override
  String get testConnectionFailed => 'Подключение не удалось';

  @override
  String get testTypeText => 'Текст';

  @override
  String get testTypeVision => 'Зрение';

  @override
  String get testButton => 'Тест';

  @override
  String get testing => 'Тестирование...';

  @override
  String get proxyUrlOptional => 'Proxy URL (необязательно)';

  @override
  String get proxyUrlHelper => 'например http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Температура';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Макс. токенов';

  @override
  String get extraParamsJson => 'Доп. параметры (JSON)';

  @override
  String get invalidJson => 'Недопустимый JSON';

  @override
  String get warning => 'Неполная настройка';

  @override
  String get invalidConfigurationWarning =>
      'Конфигурация еще не завершена (например, отсутствует API Key или Model ID). Вы все равно можете сохранить ее и настроить позже. Продолжить?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" нужна действительная конфигурация модели (ключ: \"$configKey\") для работы. Проверьте настройки модели.';
  }

  @override
  String get discardChangesTitle => 'Покинуть эту страницу?';

  @override
  String get discardChangesMessage =>
      'Если вы внесли изменения, сохраните их перед выходом.';

  @override
  String get discardButton => 'Отбросить';

  @override
  String get chooseLanguage => 'Выбрать язык';

  @override
  String get chooseAvatar => 'Выбрать аватар';

  @override
  String get configureNow => 'Настроить сейчас';

  @override
  String get modelNotConfiguredBanner =>
      'AI-модель еще не настроена. Настройте ее, чтобы открыть все функции.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Настройте AI-модель перед публикацией';

  @override
  String get processingStatus => 'Обработка';

  @override
  String get failedStatus => 'Сбой';

  @override
  String get failureReason => 'Причина сбоя';

  @override
  String get unknownError => 'Произошла неизвестная ошибка';

  @override
  String get enableFitness => 'Включить фитнес';

  @override
  String get fitnessBannerMessage =>
      'Разрешите доступ к фитнесу, чтобы отслеживать здоровье и активность.';

  @override
  String get fitnessDismissTitle => 'Пропустить доступ к фитнесу?';

  @override
  String get fitnessDismissMessage =>
      'Без разрешения фитнеса приложение не сможет автоматически собирать данные здоровья для инсайтов и автозаписи.';

  @override
  String get skipAnyway => 'Все равно пропустить';

  @override
  String get proModelHint => 'Эта модель требует подписку ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Поиск в базе знаний...';

  @override
  String get searchKnowledgeHint =>
      'Введите ключевое слово для поиска по именам файлов или содержимому';

  @override
  String noSearchResults(Object query) {
    return 'Нет результатов для \"$query\"';
  }

  @override
  String get onlyMarkdownPreview =>
      'Поддерживается только предпросмотр Markdown';

  @override
  String get backupAndRestore => 'Резервное копирование и восстановление';

  @override
  String get createBackup => 'Создать резервную копию';

  @override
  String get restoreBackup => 'Восстановить резервную копию';

  @override
  String get backupDescription =>
      'Упакуйте все ваши данные (карточки, базу знаний, инсайты, настройки) в файл .memex. Сохраните его в iCloud Drive, Google Drive или любое место через share sheet.';

  @override
  String get restoreDescription =>
      'Выберите файл резервной копии .memex для восстановления всех данных. Это перезапишет текущие данные.';

  @override
  String get selectBackupFile => 'Выбрать файл резервной копии';

  @override
  String get estimatedSize => 'Примерный размер';

  @override
  String get backupComplete => 'Резервная копия создана';

  @override
  String backupFailed(Object error) {
    return 'Резервное копирование не удалось: $error';
  }

  @override
  String get confirmRestore => 'Подтвердить восстановление';

  @override
  String get confirmRestoreMessage =>
      'Восстановление перезапишет все текущие данные, включая карточки, базу знаний, инсайты и настройки. Это нельзя отменить. Продолжить?';

  @override
  String get restoreComplete => 'Восстановление завершено';

  @override
  String get restoreRestartHint =>
      'Данные восстановлены. Перезапустите приложение, чтобы все изменения вступили в силу.';

  @override
  String restoreFailed(Object error) {
    return 'Восстановление не удалось: $error';
  }

  @override
  String get invalidBackupFile =>
      'Недопустимый файл резервной копии. Выберите файл .memex.';

  @override
  String get automaticBackup => 'Автоматическое резервное копирование';

  @override
  String get autoBackupDescription =>
      'Когда включено, Memex создает не более одного локального снимка в день после запуска или возвращения на передний план.';

  @override
  String get backupSensitiveSettingsHint =>
      'Резервные копии включают настройки и ключи провайдеров моделей. Храните файлы резервных копий в надежном месте.';

  @override
  String get backupLocation => 'Место';

  @override
  String get backupLocationDetails => 'Сведения о месте';

  @override
  String get backupLocationSummary => 'Показано в приложении';

  @override
  String get backupLocationFullPath => 'Полный путь';

  @override
  String get backupLocationUri => 'URI доступа к папке';

  @override
  String get copyBackupLocationPath => 'Копировать путь';

  @override
  String get backupLocationCopied => 'Место резервной копии скопировано';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Выбранная папка: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'Статус';

  @override
  String get noAutoBackupYet => 'Автоматических резервных копий пока нет';

  @override
  String lastBackupAt(Object time) {
    return 'Последняя копия: $time';
  }

  @override
  String get autoBackupRetention => 'Хранение';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days дн.';
  }

  @override
  String get autoBackupRetentionForever => 'Хранить всегда';

  @override
  String get autoBackupMaxSize => 'Лимит хранилища';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Автоматическая очистка удерживает автоматические снимки в пределах $size. Снимки безопасности и ручные экспорты хранятся отдельно.';
  }

  @override
  String get createSnapshotNow => 'Создать копию сейчас';

  @override
  String get backupLocationMenu => 'Изменить место';

  @override
  String get defaultBackupLocation => 'Папка резервных копий по умолчанию';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Использовать внешнюю папку файлов Memex, специфичную для приложения. Разрешение на хранилище не нужно.';

  @override
  String get chooseBackupLocation => 'Выбрать папку резервных копий';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Выберите папку системным выборщиком Android и предоставьте Memex постоянный доступ.';

  @override
  String get storedBackups => 'Сохраненные резервные копии';

  @override
  String get noStoredBackups =>
      'Автоматические копии появятся здесь после первого снимка.';

  @override
  String get backupTypeAutoSnapshot => 'Автоматический снимок';

  @override
  String get backupTypeSafetySnapshot => 'Снимок безопасности';

  @override
  String get backupTypeManualBackup => 'Ручная резервная копия';

  @override
  String get refresh => 'Обновить';

  @override
  String get restoreThisBackup => 'Восстановить эту копию';

  @override
  String get deleteThisBackup => 'Удалить эту копию';

  @override
  String get confirmDeleteBackup => 'Удалить резервную копию?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Удалить $fileName? Это удалит сохраненный файл резервной копии, и действие нельзя отменить.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Резервная копия удалена: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Не удалось удалить резервную копию: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Создание снимка безопасности...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Снимок создан: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Не удалось обновить место резервной копии: $error';
  }

  @override
  String get backupImportCreatedAt => 'Создано';

  @override
  String get backupImportSourceVersion => 'Версия источника';

  @override
  String get backupImportFlavor => 'Сборка';

  @override
  String get backupLegacyFormat => 'Старая резервная копия (без manifest)';

  @override
  String get restoreInProgress => 'Восстановление резервной копии...';

  @override
  String get dataStorage => 'Хранилище данных';

  @override
  String get dataStorageDescriptionAndroid =>
      'Выберите свою папку для хранения workspace. Данные сохраняются при переустановке приложения.';

  @override
  String get dataStorageDescriptionIOS =>
      'Включите iCloud, чтобы синхронизировать workspace между устройствами и сохранить данные при переустановке приложения.';

  @override
  String get storageLocationApp => 'Хранилище приложения';

  @override
  String get storageLocationAppDesc =>
      'Данные хранятся внутри приложения и будут удалены при его удалении.';

  @override
  String get storageLocationCustom => 'Хранилище устройства (своя папка)';

  @override
  String get storageLocationCustomDesc =>
      'Храните данные в выбранной вами папке. Данные сохранятся после переустановки, если папка останется.';

  @override
  String get storageLocationICloud => 'Хранить в iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Синхронизируйте workspace между устройствами Apple. Данные сохранятся после переустановки.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Сейчас: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Войдите в iCloud и включите iCloud Drive, чтобы использовать хранилище iCloud.';

  @override
  String get loadingFromICloud => 'Восстановление данных из iCloud…';

  @override
  String get switchingToICloud => 'Переключение на хранилище iCloud…';

  @override
  String get switchingStorage => 'Переключение хранилища…';

  @override
  String get customFolderAccessDenied =>
      'Не удается читать или писать в эту папку. Предоставьте разрешение на хранилище или выберите другое место.';

  @override
  String get configured => 'Настроено';

  @override
  String get apiKeyNotSet => 'API Key не задан — нажмите, чтобы настроить';

  @override
  String get bottomNavTimeline => 'Лента';

  @override
  String get bottomNavLibrary => 'Библиотека';

  @override
  String get aiGeneratedLabel => 'Сгенерировано AI';

  @override
  String sourceTraceWithCount(Object count) {
    return 'СЛЕД ИСТОЧНИКОВ ($count)';
  }

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountDesc =>
      'Навсегда удалить все локальные данные и сбросить приложение.';

  @override
  String get deleteAccountConfirmTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountConfirmMessage =>
      'Это навсегда удалит все ваши данные, включая карточки ленты, базу знаний, записи и настройки. Это действие нельзя отменить.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Введите \"$name\" для подтверждения';
  }

  @override
  String get deleteAccountTypeHint =>
      'Введите имя пользователя для подтверждения';

  @override
  String get llmConsentTitle => 'Согласие на передачу данных';

  @override
  String llmConsentMessage(Object provider) {
    return 'Чтобы включить AI-функции, Memex должен отправлять ваши данные в $provider для обработки. Это включает:\\n\\n• Введенный вами текст (заметки, расшифровки голоса)\\n• Метаданные фото и извлеченный текст (OCR)\\n• Сводки здоровья и фитнеса\\n• Содержимое карточек ленты\\n\\nВаши данные отправляются напрямую с вашего устройства в $provider. Memex не хранит и не передает ваши данные через какой-либо другой сервер.\\n\\nОзнакомьтесь с политикой конфиденциальности $provider, чтобы узнать, как они обрабатывают ваши данные.\\n\\nВы согласны отправлять ваши данные в $provider для AI-обработки?';
  }

  @override
  String get llmConsentAgree => 'Согласен';

  @override
  String get llmConsentDecline => 'Отклонить';

  @override
  String get customAgents => 'Пользовательские агенты';

  @override
  String get noCustomAgents => 'Пользовательские агенты не настроены.';

  @override
  String get deleteAgent => 'Удалить агента';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Удалить пользовательского агента \"$name\"?';
  }

  @override
  String get deleted => 'Удалено';

  @override
  String get saved => 'Сохранено';

  @override
  String get newAgent => 'Новый агент';

  @override
  String get editAgent => 'Редактировать агента';

  @override
  String get agentName => 'Имя агента';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Обязательно';

  @override
  String get agentNameInvalid => 'Только буквы, цифры и дефисы';

  @override
  String get agentNameExists => 'Имя уже существует';

  @override
  String get hostAgentType => 'Тип host-агента';

  @override
  String get skillDirectory => 'Каталог skill';

  @override
  String get skillDirInvalid =>
      'Должен быть относительным путем (без начального / или ..)';

  @override
  String get workingDirectory => 'Рабочий каталог (необязательно)';

  @override
  String get workingDirectoryHint =>
      'Оставьте пустым для workspace по умолчанию';

  @override
  String get llmConfig => 'Конфигурация LLM';

  @override
  String get eventType => 'Тип события';

  @override
  String get executionMode => 'Режим выполнения';

  @override
  String get executionModeAsync => 'Async';

  @override
  String get executionModeSync => 'Sync';

  @override
  String get dependsOn => 'Зависит от';

  @override
  String get dependsOnHint => 'Выберите зависимости';

  @override
  String get priority => 'Приоритет';

  @override
  String get maxRetries => 'Макс. повторов';

  @override
  String get systemPromptLabel => 'System Prompt (необязательно)';

  @override
  String get systemPromptHint =>
      'Дополнительные инструкции, добавляемые к промпту host-агента';

  @override
  String get eventSerializer => 'Сериализатор событий';

  @override
  String get eventSerializerDefault => 'По умолчанию (XML)';

  @override
  String get enabledLabel => 'Включено';

  @override
  String get skillsManagement => 'Управление skills';

  @override
  String get skillsManagementEmpty => 'Skills пока нет';

  @override
  String get downloadSkill => 'Скачать skill';

  @override
  String get downloadFile => 'Скачать файл';

  @override
  String get downloading => 'Загрузка...';

  @override
  String get downloadSuccess => 'Skill успешно скачан';

  @override
  String downloadFailed(Object error) {
    return 'Загрузка не удалась: $error';
  }

  @override
  String get deleteConfirm => 'Подтвердить удаление';

  @override
  String deleteConfirmMessage(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get invalidUrl => 'Введите действительный URL';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Новая папка';

  @override
  String get newFile => 'Новый файл';

  @override
  String get folderName => 'Имя папки';

  @override
  String get fileName => 'Имя файла';

  @override
  String get nameRequired => 'Имя обязательно';

  @override
  String get nameInvalid => 'Имя не может содержать / или ..';

  @override
  String createFailed(Object error) {
    return 'Создание не удалось: $error';
  }

  @override
  String get fileContent => 'Содержимое файла';

  @override
  String get saveSuccess => 'Успешно сохранено';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Zip будет распакован в текущий каталог: $dir';
  }

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicyDesc => 'Как Memex обрабатывает ваши данные';

  @override
  String get llmAuthError =>
      'Аутентификация API не удалась. Проверьте конфигурацию LLM в настройках.';

  @override
  String get llmBadRequestError =>
      'Запрос был отклонен провайдером LLM. Текущий модель может не поддерживать формат ввода.';

  @override
  String get llmRateLimitError => 'Превышен лимит API. Повторите позже.';

  @override
  String get llmServerError =>
      'Сервис LLM временно недоступен. Повторите позже.';

  @override
  String get llmNetworkError =>
      'Сетевое подключение не удалось. Проверьте интернет-соединение.';

  @override
  String get llmUnknownError =>
      'При обработке вашего контента произошла непредвиденная ошибка.';

  @override
  String get llmErrorDialogTitle => 'Обработка не удалась';

  @override
  String get goToModelConfig => 'Перейти в настройки';

  @override
  String get speechModelDownloadTitle => 'Скачать модель речи';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Требуется разовая загрузка модели (~$sizeMB МБ).\\n\\nПосле загрузки транскрибация полностью выполняется на устройстве.';
  }

  @override
  String get speechModelStartDownload => 'Начать загрузку';

  @override
  String get speechModelChooseSource => 'Выберите источник загрузки:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (быстрее в CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (Global)';

  @override
  String get speechModelDownloading => 'Загрузка модели...';

  @override
  String get speechModelConnecting => 'Подключение...';

  @override
  String get deleteSpeechModel => 'Удалить модель речи';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Удалить загруженные файлы локальной модели распознавания речи? Они будут скачаны снова при следующем использовании локального speech-to-text.';

  @override
  String get speechModelDeletedSuccess => 'Файлы модели речи удалены';

  @override
  String get speechModelNotDownloaded =>
      'Загруженные файлы модели речи не найдены';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Не удалось удалить файлы модели речи: $error';
  }

  @override
  String get speechTranscribing => 'Распознавание...';

  @override
  String get speechNoResult => 'Речь не обнаружена';

  @override
  String get useLocalSpeechToTextTitle =>
      'Использовать локальный speech-to-text';

  @override
  String get useLocalSpeechToTextDesc =>
      'Когда включено, аудио транскрибируется на устройстве перед отправкой — полезно для моделей, которые не поддерживают аудиоввод. Когда отключено, исходное аудио отправляется напрямую в модель.';

  @override
  String get pendingAiProcessingHint => 'Настройте AI-модель для обработки';

  @override
  String get demoWelcome =>
      'Добро пожаловать в Memex!\\nДавайте быстро посмотрим, что AI может делать с вашими записями.';

  @override
  String get demoTapAdd => 'Нажмите здесь, чтобы создать первую запись';

  @override
  String get demoTapSend => 'Нажмите, чтобы отправить первую запись';

  @override
  String get demoTapCard =>
      'Нажмите, чтобы увидеть, как AI организовал вашу запись';

  @override
  String get demoDetailHint =>
      'Это детали записи, организованные AI. Просмотрите их, затем вернитесь, чтобы продолжить тур.';

  @override
  String get demoTapInsight => 'Нажмите, чтобы увидеть AI-инсайты';

  @override
  String get demoTapInsightUpdate =>
      'Нажмите, чтобы сгенерировать инсайты из записей';

  @override
  String get demoTapKnowledge =>
      'Посмотрите автоматически организованные файлы знаний';

  @override
  String get demoDone => 'Начните записывать свою жизнь.';

  @override
  String get demoStartTour => 'Начать тур';

  @override
  String get demoGetStarted => 'Начать';

  @override
  String get demoSkip => 'Пропустить';

  @override
  String get demoPrefillText => 'Привет, Memex! Это моя первая запись 🎉';

  @override
  String get visionBadge => 'Зрение';

  @override
  String get notMultimodalHint =>
      'Memex полагается на мультимодальные возможности модели для анализа медиа. Если ваши записи содержат изображения, убедитесь, что настроенная модель поддерживает ввод изображений.';

  @override
  String get defaultModelPrefix => 'По умолчанию';

  @override
  String get recommendedBadge => 'Рекомендуется';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Сменить компаньона';

  @override
  String get personaChatInputHint => 'Введите сообщение...';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчера';

  @override
  String get showInsightTextTitle => 'Показывать комментарий инсайта Memex';

  @override
  String get showInsightTextDesc =>
      'Показывать ли инсайт Memex как закрепленный комментарий в разделе комментариев деталей карточки.';

  @override
  String get enableCharacterCommentTitle => 'Автокомментарии персонажей';

  @override
  String get enableCharacterCommentDesc =>
      'Персонажи автоматически комментируют новые записи.';

  @override
  String get maxCommentCharactersTitle => 'Макс. персонажей для комментариев';

  @override
  String get maxCommentCharactersDesc =>
      'Сколько персонажей могут комментировать каждую запись.';

  @override
  String replyTo(String name) {
    return 'Ответить $name';
  }

  @override
  String get cdnSignalsComments => 'Получен новый ответ';

  @override
  String get cdnSignalsInsight => 'Сгенерирован новый инсайт';

  @override
  String get cdnSignalsBoth => 'Новый ответ и инсайт';

  @override
  String get untitledCard => 'Карточка без названия';

  @override
  String get locationContextTitle => 'Контекст локации';

  @override
  String get locationContextDescription =>
      'Текущий город и район для чата с агентом';

  @override
  String get locationContextAttachTitle => 'Прикреплять текущую локацию к чату';

  @override
  String get locationContextAttachDesc =>
      'Использует GPS устройства и обратное геокодирование, чтобы предоставить агенту контекст города, района и окрестностей.';

  @override
  String get reverseGeocodingProvider => 'Провайдер обратного геокодирования';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap использует координаты GCJ-02. GPS устройства преобразуется перед обратным геокодированием.';

  @override
  String get contextGranularity => 'Детализация контекста';

  @override
  String get granularityCity => 'Город';

  @override
  String get granularityDistrict => 'Район';

  @override
  String get granularityNeighborhood => 'Окрестности';

  @override
  String get granularityStreet => 'Улица';

  @override
  String get granularityFullAddress => 'Кандидат полного адреса';

  @override
  String get locationFreshness => 'Актуальность локации';

  @override
  String minutesShort(int minutes) {
    return '$minutes мин.';
  }

  @override
  String get oneHour => '1 час';

  @override
  String get testCurrentLocation => 'Проверить текущую локацию';

  @override
  String locationTestFailed(String error) {
    return 'Сбой: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Обратное геокодирование';

  @override
  String get locationDebugProvider => 'Провайдер';

  @override
  String get locationDebugAgentContext => 'Контекст агента';

  @override
  String get locationDebugSource => 'Источник';

  @override
  String get locationDebugAddressSummary => 'Сводка адреса';

  @override
  String get locationDebugFullAddress => 'Полный адрес';

  @override
  String get locationDebugCoordinates => 'Координаты';

  @override
  String get locationDebugAccuracy => 'Точность';

  @override
  String get locationDebugReason => 'Причина';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'недоступно';

  @override
  String get locationDebugInjected => 'внедрено';

  @override
  String get locationDebugNotInjected => 'не внедрено';

  @override
  String get locationStatusUpdatedAt => 'Обновлено';

  @override
  String get locationStatusSuccessTitle => 'Текущая локация готова';

  @override
  String get locationStatusSuccessBody =>
      'Memex может прикрепить эту сводку локации, когда контекст локации уместен.';

  @override
  String get locationStatusApproximateTitle => 'Только приблизительная локация';

  @override
  String get locationStatusApproximateBody =>
      'Точность похожа на уровень города или района. Можно продолжать использовать ее или включить Точную геопозицию в системных настройках для более плотного контекста.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'Системная геолокация выключена';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex использует только GPS устройства и не выводит локацию из сети или IP. На Android откройте настройки Location; на iOS включите Settings > Privacy & Security > Location Services.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Нужно разрешение на локацию';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Разрешите Memex использовать локацию при тестировании или когда нужен контекст локации. Постоянный доступ не запрашивается.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'Разрешение на локацию заблокировано';

  @override
  String get locationStatusPermissionForeverBody =>
      'Откройте настройки приложения и разрешите локацию для Memex. На iOS достаточно While Using the App.';

  @override
  String get locationStatusDisabledTitle => 'Контекст локации выключен';

  @override
  String get locationStatusDisabledBody =>
      'Включите переключатель выше и сохраните, когда хотите, чтобы Memex прикреплял локацию устройства к контексту агента.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS работает, поиск адреса не удался';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'У Memex есть координаты, но GPS-only контекст не будет внедрен в агента. Проверьте провайдера обратного геокодирования и повторите.';

  @override
  String get locationStatusUnavailableTitle => 'Локация недоступна';

  @override
  String get locationStatusUnavailableBody =>
      'Проверьте системные службы геолокации и разрешение приложения, затем повторите тест.';

  @override
  String get allowLocationPermissionButton => 'Разрешить доступ к локации';

  @override
  String get openAppSettingsButton => 'Открыть настройки приложения';

  @override
  String get openLocationSettingsButton => 'Открыть настройки локации';

  @override
  String get locationSettingsOpenFailed =>
      'Не удалось открыть системные настройки.';

  @override
  String locationActionFailed(String error) {
    return 'Действие с локацией не удалось: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Поиск настроек...';

  @override
  String get settingsSearchEmpty => 'Подходящие настройки не найдены';

  @override
  String get importCharacterCard => 'Импортировать карточку персонажа';

  @override
  String get firstMessageLabel => 'Первое сообщение';

  @override
  String get firstMessageHint =>
      'Приветствие в первом разговоре (необязательно)';

  @override
  String get systemPromptOverrideLabel => 'Переопределение System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'Переопределить system prompt по умолчанию (расширенно, необязательно)';

  @override
  String get postHistoryInstructionsLabel => 'Инструкции после истории';

  @override
  String get postHistoryInstructionsHint =>
      'Инструкции, внедряемые после истории чата и перед ответом (необязательно)';

  @override
  String get mesExampleLabel => 'Примеры сообщений';

  @override
  String get mesExampleHint =>
      'Примеры диалогов, показывающие стиль персонажа (необязательно)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Фоновые знания, внедряемые при срабатывании ключевых слов';

  @override
  String get characterMemoryTitle => 'Память персонажа';

  @override
  String get characterMemorySubtitle =>
      'Динамика отношений и воспоминания взаимодействий между персонажем и пользователем';

  @override
  String get addTooltip => 'Добавить';

  @override
  String get constantBadge => 'Постоянно';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Запись $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Ключевые слова: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Память $index';
  }

  @override
  String get addWorldEntry => 'Добавить запись World Book';

  @override
  String get editWorldEntry => 'Редактировать запись World Book';

  @override
  String get commentTitleLabel => 'Комментарий / Заголовок';

  @override
  String get entryDescriptionHint => 'Описание записи (необязательно)';

  @override
  String get triggerKeywordsLabel => 'Ключевые слова-триггеры';

  @override
  String get triggerKeywordsHint => 'Через запятую, например: magic, spell';

  @override
  String get contentLabel => 'Содержимое';

  @override
  String get worldEntryContentHint =>
      'Фоновые знания, внедряемые при срабатывании ключевых слов';

  @override
  String get enabledCheckbox => 'Включено';

  @override
  String get addMemory => 'Добавить память';

  @override
  String get editMemory => 'Редактировать память';

  @override
  String get memoryLabelField => 'Метка';

  @override
  String get memoryLabelHint =>
      'Уникальный идентификатор, например: предпочтение имени';

  @override
  String get memoryContentHint => 'Содержимое памяти';

  @override
  String get salienceLabel => 'Значимость: ';

  @override
  String get labelCannotBeEmpty => 'Метка не может быть пустой';

  @override
  String importSuccess(Object name) {
    return '$name успешно импортирован';
  }

  @override
  String importFailed(Object error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get supportedFormats => 'Поддерживаемые форматы';

  @override
  String get tavernImportDescription =>
      '• Карточки персонажей SillyTavern V2 (.json)\\n• PNG-изображения со встроенными карточками (.png)\\n\\nПоля вроде persona, world book и т. д. будут автоматически сопоставлены с форматом персонажей Memex.';

  @override
  String get pickCharacterFile => 'Выбрать файл персонажа';

  @override
  String get repickFile => 'Выбрать другой файл';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: записей $count';
  }

  @override
  String fileLabel(Object filename) {
    return 'Файл: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Персонаж с тем же именем уже существует: $names. Импорт создаст нового персонажа, не перезаписывая существующих.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Сделать основным компаньоном';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Автоматически сделать основным компаньоном после импорта';

  @override
  String get confirmImport => 'Подтвердить импорт';

  @override
  String get chatBackground => 'Фон чата';

  @override
  String get chooseChatBackgroundImage => 'Выбрать фоновое изображение';

  @override
  String get earlyUpdateSettingsTitle => 'Обновления раннего доступа';

  @override
  String get earlyUpdateSettingsDesc =>
      'Проверять pre-release GitHub для подходящего Early APK, скачивать его и передавать установщику Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Ранние обновления доступны только в Android Early build.';

  @override
  String get earlyUpdateAutoCheckTitle => 'Автоматически проверять обновления';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Проверять при запуске не чаще одного раза в 12 часов.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Скачивать только по Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Пропускать загрузки обновлений при использовании мобильных данных.';

  @override
  String get earlyUpdateAutoInstallTitle =>
      'Автоматически скачать и установить';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Когда найдена новая сборка, скачать ее и автоматически открыть установщик Android.';

  @override
  String get earlyUpdateCheckNow => 'Проверить сейчас';

  @override
  String get earlyUpdateChecking => 'Проверка pre-release GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Пропущено, потому что включены загрузки только по Wi-Fi.';

  @override
  String get earlyUpdateNoUpdate => 'У вас уже последняя Early build.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Доступна Early build $version+$build.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Скачать и установить';

  @override
  String get earlyUpdateDownloadInProgress => 'Загрузка обновления...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Загрузка обновления: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Пакет обновления скачан. Готов к установке.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Установить скачанный пакет';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Очистить скачанный пакет';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Скачанный пакет обновления очищен.';

  @override
  String get earlyUpdateInstallStarted => 'Установщик Android открыт.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Разрешите Memex устанавливать неизвестные приложения, затем снова нажмите скачать и установить.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Последняя проверка: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Проверка обновления не удалась: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Доступно Early-обновление';

  @override
  String get earlyUpdateReleaseNotes => 'Примечания к выпуску';

  @override
  String get dismissAllNotifications => 'Очистить все';

  @override
  String get dismissByType => 'Очистить по типу';

  @override
  String get dismissTypeSystemAction => 'Напоминания и события';

  @override
  String get dismissTypeClarification => 'Уточнения';

  @override
  String get dismissTypeCardUpdate => 'Обновления карточек';

  @override
  String dismissedCount(Object count) {
    return 'Очищено: $count';
  }

  @override
  String get dataImportTitle => 'Импорт файлов';

  @override
  String get dataImportSettingsDescription =>
      'Перенесите старые файлы в Memex, а затем решите, нужно ли их упорядочить.';

  @override
  String get dataImportDescription =>
      'Выберите старые заметки, экспортированные записи, документы или ZIP-архивы. Memex сначала сохранит копию и не изменит исходные файлы. После импорта вы сможете решить, должен ли Memex помочь с организацией.';

  @override
  String get dataImportSelectFiles => 'Выбрать файлы для импорта';

  @override
  String get dataImportImporting => 'Сохранение файлов...';

  @override
  String get dataImportSuccess => 'Файлы сохранены в Memex';

  @override
  String get dataImportOnlyStored =>
      'Файлы сохранены. Организация не запущена.';

  @override
  String get dataImportQueued => 'Memex упорядочит этот импорт в фоне.';

  @override
  String get dataImportResultTitle => 'Импорт завершён';

  @override
  String dataImportResultSummary(Object count) {
    return 'Сохранено файлов: $count. Вы можете упорядочить их сейчас или оставить как исходные материалы.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return 'Элементы с одинаковыми именами переименованы, чтобы ничего не перезаписать. Количество: $count.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'Необычные элементы архива пропущены, остальное импортировано обычным образом. Количество: $count.';
  }

  @override
  String get dataImportChooseProcessing => 'Упорядочить эти файлы';

  @override
  String get dataImportProcessTitle => 'Упорядочить этот импорт?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Вы импортировали файлов: $count. Выберите, должен ли Memex упорядочить их сейчас или просто сохранить оригиналы.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'Упорядочить в базе знаний';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Подходит для документов, заметок, проектных материалов и справок. Memex извлечёт полезную информацию и сгруппирует её для дальнейшего использования.';

  @override
  String get dataImportProcessTimelineCards => 'Создать записи таймлайна';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Подходит для дневников, переписок, истории активности и старых экспортов. Memex превратит содержимое с временным смыслом в записи, когда это уместно.';

  @override
  String get dataImportImpactNone =>
      'Memex только сохранит эти исходные файлы. Организация с помощью ИИ не начнётся.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex прочитает эти файлы и упорядочит долгосрочно полезную информацию в базе знаний. Записи таймлайна не будут создаваться автоматически.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex прочитает эти файлы и создаст записи таймлайна для жизненных событий или датированной истории, когда это уместно. База знаний не будет упорядочиваться автоматически.';

  @override
  String get dataImportImpactBoth =>
      'Memex попробует создать записи таймлайна и упорядочить переиспользуемую информацию в базе знаний. Это лучше всего подходит для полного личного архива.';

  @override
  String get dataImportFinish => 'Только сохранить';

  @override
  String get noImages => 'Нет изображений';

  @override
  String get noMessages => 'Нет сообщений';

  @override
  String get sketchContent => 'Эскиз';

  @override
  String get emptyFolder => 'Пустая папка';

  @override
  String get usernameAlreadyTaken => 'Имя пользователя уже занято';

  @override
  String get registrationFailed => 'Не удалось зарегистрироваться';

  @override
  String get loginFailed => 'Не удалось войти';

  @override
  String get paymentCreationFailed => 'Не удалось начать оплату';

  @override
  String get completePayment => 'Завершить оплату';
}
