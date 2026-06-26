// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get timesLabel => 'Vezes';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Definir $modelId como modelo padrão';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get unknownModel => 'Modelo desconhecido';

  @override
  String get notSet => 'Não definido';

  @override
  String get confirmClear => 'Confirmar limpeza';

  @override
  String get confirmClearTokenMessage =>
      'Limpar o usuário atual? Você precisará inserir o ID de usuário novamente.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get tokenCleared => 'Usuário limpo';

  @override
  String clearTokenFailed(Object error) {
    return 'Falha ao limpar usuário: $error';
  }

  @override
  String get selectDateRangeOptional =>
      'Selecionar intervalo de datas (opcional):';

  @override
  String get startDate => 'Data inicial';

  @override
  String get endDate => 'Data final';

  @override
  String get select => 'Selecionar';

  @override
  String get processLimitOptional => 'Limite de processamento (opcional)';

  @override
  String get leaveEmptyForAll => 'Deixe vazio para processar tudo';

  @override
  String get startProcessing => 'Iniciar processamento';

  @override
  String get userIdNotFound => 'ID de usuário não encontrado';

  @override
  String createTaskFailed(Object error) {
    return 'Falha ao criar tarefa: $error';
  }

  @override
  String get reprocessCards => 'Reprocessar cartões';

  @override
  String get reprocessCardsTaskCreated =>
      'Pedido de reprocessamento enfileirado no Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Escopo';

  @override
  String get reprocessCardsCardOnly => 'Somente cartões';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Peça ao Super Agent para revisar e regenerar os cartões de timeline selecionados.';

  @override
  String get reprocessCardsRerunDownstream =>
      'Cartões e acompanhamentos relacionados';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Peça ao Super Agent para também considerar atualizações relacionadas de PKM, agenda e insights quando necessário.';

  @override
  String get reanalyzeMediaAssets => 'Reler anexos de mídia';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Peça ao Super Agent para inspecionar novamente as mídias anexadas ao regenerar cartões.';

  @override
  String get regenerateComments => 'Regenerar comentários';

  @override
  String get regenerateCommentsTaskCreated =>
      'Tarefa de regeneração de comentários criada, rodando em segundo plano';

  @override
  String get rebuildSearchIndex => 'Reconstruir índice de busca';

  @override
  String get rebuildSearchIndexSuccess =>
      'Índice de busca reconstruído com sucesso';

  @override
  String get rebuildSearchIndexFailed => 'Falha ao reconstruir índice de busca';

  @override
  String get clearData => 'Limpar dados';

  @override
  String get confirmClearDataMessage => 'Limpar dados?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Todos os dados locais do workspace do usuário atual serão excluídos, incluindo cartões, mídia, arquivos de conhecimento, insights, memória, histórico de chat e estado do sistema.\n\nEsta ação não pode ser desfeita!';

  @override
  String get clearFailedAgentContexts =>
      'Limpar contexto de conversa com falha';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Limpar o contexto de conversa salvo dos agentes Insight e Schedule? Isso é útil depois de trocar modelos quando mensagens antigas dos agentes deixam de ser compatíveis. Fatos, cartões, conhecimento, memórias e configurações de modelo não serão excluídos.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count contexto(s) de conversa salvo(s) foram limpos';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Falha ao limpar contexto de conversa: $error';
  }

  @override
  String get cloneToTestUser => 'Clonar para usuário de teste';

  @override
  String get confirmCloneToTestUserMessage =>
      'Copiar o workspace atual para um novo usuário local de teste e alternar para ele. O estado de runtime dos agentes não será copiado. Seus dados atuais não serão modificados.';

  @override
  String get testUserIdLabel => 'ID do usuário de teste';

  @override
  String get testUserIdHelper => 'Use letras, números, hífen ou sublinhado.';

  @override
  String get testUserIdInvalid =>
      'Use apenas letras, números, hífen ou sublinhado.';

  @override
  String get overwriteExistingTestUser =>
      'Substituir usuário de teste existente com o mesmo ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Alternado para o usuário de teste $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Falha ao clonar usuário de teste: $error';
  }

  @override
  String get dataClearedSuccess => 'Dados limpos com sucesso';

  @override
  String clearDataFailed(Object error) {
    return 'Falha ao limpar dados: $error';
  }

  @override
  String get personalCenter => 'Central pessoal';

  @override
  String get viewLogs => 'Ver logs';

  @override
  String get systemAuthorization => 'Autorização do sistema';

  @override
  String get aiCharacterConfig => 'Configuração de personagem AI';

  @override
  String get modelConfig => 'Configuração de modelo';

  @override
  String get agentConfig => 'Configuração de agente';

  @override
  String get experimentalLab => 'Laboratório';

  @override
  String get experimentalLabDescription =>
      'Recursos experimentais que podem mudar ou ser movidos depois.';

  @override
  String get modelUsageStats => 'Estatísticas de uso de modelo';

  @override
  String get asyncTaskList => 'Lista de tarefas assíncronas';

  @override
  String get clearLocalToken => 'Limpar usuário';

  @override
  String get insightCardTemplates => 'Modelos de cartões de insight';

  @override
  String get timelineCardTemplates => 'Modelos de cartões de timeline';

  @override
  String get logViewer => 'Visualizador de logs';

  @override
  String get autoRefresh => 'Atualização automática';

  @override
  String get lineCount => 'Contagem de linhas: ';

  @override
  String get all => 'Todos';

  @override
  String get schedule => 'Agenda';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get appLockConfig => 'Configuração de bloqueio do app';

  @override
  String get activityStats => 'Estatísticas de atividade';

  @override
  String activityStatsSummary(Object inputs, Object cards, Object todos) {
    return 'Neste período você registrou $inputs vez(es), gerou $cards cartão(ões) e concluiu $todos tarefa(s).';
  }

  @override
  String get last7Days => '7 dias';

  @override
  String get last30Days => '30 dias';

  @override
  String get last90Days => '90 dias';

  @override
  String get records => 'Registros';

  @override
  String get words => 'Palavras';

  @override
  String get cards => 'Cartões';

  @override
  String get knowledgeUnits => 'Unidades de conhecimento';

  @override
  String get completedTodos => 'Tarefas concluídas';

  @override
  String get activeDays => 'Dias ativos';

  @override
  String get streakDays => 'Sequência';

  @override
  String get dailyRhythm => 'Ritmo diário';

  @override
  String get recordToOutput => 'Registro para saída';

  @override
  String get sourceBreakdown => 'Distribuição de fontes';

  @override
  String get topThemes => 'Principais temas';

  @override
  String get textInput => 'Texto';

  @override
  String get imageInput => 'Imagens';

  @override
  String get audioInput => 'Áudio';

  @override
  String get noStatsYet => 'Ainda não há estatísticas de atividade';

  @override
  String get tapDayForDetails => 'Toque em um dia para ver detalhes';

  @override
  String get dayDetails => 'Detalhes do dia';

  @override
  String loadStatsFailed(Object error) {
    return 'Falha ao carregar estatísticas: $error';
  }

  @override
  String get overview => 'Visão geral';

  @override
  String get daily => 'Diário';

  @override
  String get modelStatsByAgent => 'Por agente';

  @override
  String get detail => 'Detalhe';

  @override
  String get date => 'Data';

  @override
  String get agent => 'Agente';

  @override
  String get noData => 'Sem dados';

  @override
  String get totalCalls => 'Chamadas totais';

  @override
  String get calls => 'Chamadas';

  @override
  String callsCount(Object count) {
    return '$count chamadas';
  }

  @override
  String get selectDateRange => 'Selecionar intervalo de datas';

  @override
  String get totalTokens => 'Total de tokens';

  @override
  String get cacheRate => 'Taxa de cache';

  @override
  String get promptTokens => 'Tokens de prompt';

  @override
  String get completionTokens => 'Tokens de completion';

  @override
  String get cachedTokens => 'Tokens em cache';

  @override
  String get thoughtTokens => 'Tokens de pensamento';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Completion';

  @override
  String get cached => 'Cached';

  @override
  String get thought => 'Thought';

  @override
  String get model => 'Modelo';

  @override
  String get scene => 'Cena';

  @override
  String get sceneId => 'ID da cena';

  @override
  String get tokenUsage => 'Uso de tokens';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'Distribuição por modelo';

  @override
  String get callDetails => 'Detalhes da chamada';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Detalhes do registro: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Falha ao salvar configuração LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'A prévia HTML não está disponível na web. Veja no celular.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Falha ao salvar informações do usuário: $error';
  }

  @override
  String get totalEstimatedCost => 'Custo estimado total';

  @override
  String get close => 'Fechar';

  @override
  String get totalTokenConsumption => 'Consumo total de tokens';

  @override
  String get dataLoadFailedRetry =>
      'Falha ao carregar dados, tente novamente mais tarde.';

  @override
  String get timelineLoadFailedRetry =>
      'Falha ao carregar timeline, tente novamente mais tarde.';

  @override
  String get newPerspective => 'Nova perspectiva';

  @override
  String get startPoint => 'Início';

  @override
  String get endPoint => 'Fim';

  @override
  String get originalInput => 'Entrada original';

  @override
  String get referenceContent => 'Conteúdo de referência';

  @override
  String referenceWithTitle(Object title) {
    return 'Referência: $title';
  }

  @override
  String get actionCenterTitle => 'Ações pendentes';

  @override
  String get noPendingActions => 'Nenhuma ação pendente';

  @override
  String get clarificationNeeded => 'Memex quer confirmar';

  @override
  String get clarificationTextHint => 'Digite uma resposta curta';

  @override
  String get clarificationTextRequired =>
      'Adicione uma resposta curta primeiro';

  @override
  String get clarificationAnswered => 'Respondido';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Resposta: $answer';
  }

  @override
  String get answerSaved => 'Resposta salva';

  @override
  String get clarificationOtherAnswer => 'Entrada manual';

  @override
  String get clarificationNotSure => 'Não tenho certeza / prefiro não dizer';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get footprintMap => 'Mapa de pegadas';

  @override
  String get waypointPlaces => 'Locais de passagem';

  @override
  String get unknownPlace => 'Local desconhecido';

  @override
  String get releaseToSend => 'Solte para enviar';

  @override
  String get selectFromAlbum => 'Selecionar do álbum';

  @override
  String get clipboardPreviewTitle => 'Nova área de transferência';

  @override
  String get clipboardPreviewImageTitle => 'Imagem da área de transferência';

  @override
  String get clipboardPreviewImageDescription => 'Imagem pronta para adicionar';

  @override
  String get clipboardPreviewUnprocessed => 'Ainda não colado';

  @override
  String get clipboardPreviewPasteToInput => 'Colar na entrada';

  @override
  String get clipboardPreviewAddImageToInput => 'Adicionar imagem';

  @override
  String get clipboardPreviewImageFailed =>
      'Não foi possível ler a imagem da área de transferência';

  @override
  String get tellAiWhatHappened => 'Conte ao AI o que aconteceu...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Gravando: $duration';
  }

  @override
  String get playing => 'Reproduzindo...';

  @override
  String get sendLabel => 'Enviar';

  @override
  String attachedImagesMessage(Object count) {
    return '$count imagem(ns) enviada(s)';
  }

  @override
  String get noTaskData => 'Sem dados da tarefa';

  @override
  String createdAtDate(Object date) {
    return 'Criado: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Atualizado: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Duração: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Tentativa: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Falha ao carregar detalhes, tente novamente mais tarde.';

  @override
  String get loadFailed => 'Falha ao carregar';

  @override
  String get reload => 'Recarregar';

  @override
  String get aiInsightDetail => 'Detalhe do insight';

  @override
  String relatedRecordsCount(Object count) {
    return 'Registros relacionados ($count)';
  }

  @override
  String get noRelatedRecords => 'Sem registros relacionados';

  @override
  String get useFingerprintToUnlock =>
      'Use a impressão digital para desbloquear';

  @override
  String get locked => 'Bloqueado';

  @override
  String get wrongPassword => 'Senha incorreta';

  @override
  String get enterPassword => 'Digite a senha';

  @override
  String get memexLocked => 'Memex está bloqueado';

  @override
  String get calendarShortSun => 'Dom';

  @override
  String get calendarShortMon => 'Seg';

  @override
  String get calendarShortTue => 'Ter';

  @override
  String get calendarShortWed => 'Qua';

  @override
  String get calendarShortThu => 'Qui';

  @override
  String get calendarShortFri => 'Sex';

  @override
  String get calendarShortSat => 'Sáb';

  @override
  String noRecordsOnDate(Object date) {
    return 'Sem registros em $date';
  }

  @override
  String get footprintPath => 'Caminho de pegadas';

  @override
  String get lifeCompositionTable => 'Composição da vida';

  @override
  String get emotionReframe => 'Reenquadramento emocional';

  @override
  String get chronicleOfThings => 'Crônica das coisas';

  @override
  String get goalProgress => 'Progresso da meta';

  @override
  String get trendChart => 'Gráfico de tendência';

  @override
  String get comparisonChart => 'Gráfico de comparação';

  @override
  String get todayTimeFlow => 'Fluxo de tempo de hoje';

  @override
  String get aiInputHint => 'Seja memória ou presente, estou aqui...';

  @override
  String get refreshSuperAgentStateTooltip => 'Limpar contexto do Memex Agent';

  @override
  String get refreshSuperAgentStateTitle =>
      'Limpar contexto histórico do Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'O histórico visível do chat permanecerá, mas o contexto histórico de runtime do Memex Agent será limpo e as respostas futuras começarão com um contexto novo. Memória persistente, arquivos da base de conhecimento, cartões e outros dados salvos não serão afetados. Use isto quando o Memex Agent continuar se comportando de forma anormal. Continuar?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Aguarde a mensagem atual do Memex Agent terminar antes de limpar o contexto.';

  @override
  String get refreshSuperAgentStateSuccess => 'Contexto do Memex Agent limpo';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Falha ao limpar contexto do Memex Agent: $error';
  }

  @override
  String get nothingHere => 'Ainda não há nada aqui';

  @override
  String get nothingHereHint =>
      'Toque no botão abaixo para criar seu primeiro cartão';

  @override
  String get agentProcessing => 'AI está processando...';

  @override
  String get keepAppOpen => 'Não feche o app';

  @override
  String get activityDetail => 'Detalhe da atividade';

  @override
  String get noAgentActivityYet => 'Ainda não há atividade de agente';

  @override
  String get processingEllipsis => 'Processando...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent pausado';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent precisa de atenção';

  @override
  String get agentBackgroundStageIdle => 'Ocioso';

  @override
  String get agentBackgroundStageProcessing => 'Processando';

  @override
  String get agentBackgroundStageQueued => 'Na fila';

  @override
  String get agentBackgroundStageRetrying => 'Aguardando nova tentativa';

  @override
  String get agentBackgroundStagePaused => 'Pausado';

  @override
  String get agentBackgroundStageCompleted => 'Concluído';

  @override
  String get agentBackgroundStageNeedsAttention => 'Precisa de atenção';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Analisando mídia';

  @override
  String get agentBackgroundStageGeneratingCard => 'Gerando cartão';

  @override
  String get agentBackgroundStageUpdatingKnowledge =>
      'Atualizando conhecimento';

  @override
  String get agentBackgroundStagePreparingComment => 'Preparando comentário';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Roteando acompanhamentos';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'Executando $running, pendentes $pending, nova tentativa $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Processando $count tarefa(s) na fila.';
  }

  @override
  String get agentBackgroundNoTasks => 'Nenhuma tarefa em segundo plano.';

  @override
  String get agentBackgroundStarting => 'O processamento está começando.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Todas as tarefas em segundo plano terminaram.';

  @override
  String get agentBackgroundFailedDetail => 'O processamento parou com erro.';

  @override
  String get agentBackgroundPausedDetail =>
      'O processamento está pausado e continuará depois.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Aguardando a próxima etapa de processamento.';

  @override
  String get agentBackgroundRetryingDetail =>
      'A etapa atual será tentada novamente automaticamente.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Lendo anexos e contexto local.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Transformando o registro em um cartão de timeline.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Atualizando conhecimento e memória locais.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Preparando um acompanhamento do assistente.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Verificando ações de acompanhamento para este cartão.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Pausado - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Precisa de atenção - $summary';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get languageSettingsDesc => 'Alterar o idioma de exibição do app';

  @override
  String get noPendingActionsToast => 'Nenhuma ação pendente';

  @override
  String get knowledgeNewDiscovery => 'Nova descoberta de conhecimento';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count novo(s) insight(s) descoberto(s)';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count insight(s) existente(s) atualizado(s)';
  }

  @override
  String get sectionNewInsights => 'Novos insights';

  @override
  String get sectionUpdatedInsights => 'Insights atualizados';

  @override
  String get unnamedInsight => 'Insight sem nome';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get copy => 'Copiar';

  @override
  String get selectedLocation => 'Local selecionado';

  @override
  String get confirmLocationName => 'Confirmar nome do local';

  @override
  String get confirmLocationNameHint =>
      'Você pode editar o nome (as coordenadas ficam iguais)';

  @override
  String get nameLabel => 'Nome';

  @override
  String get inputPlaceNameHint => 'Digite o nome do local...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Coordenadas: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Confirmar local';

  @override
  String get welcomeToMemex => 'Boas-vindas ao Memex';

  @override
  String get createUserIdToStart => 'Crie seu perfil';

  @override
  String get userIdLabel => 'Seu nome / apelido';

  @override
  String get userIdHint => 'Digite seu nome ou apelido';

  @override
  String get pleaseEnterUserId => 'Digite seu nome';

  @override
  String get userIdMaxLength => 'O nome não deve exceder 50 caracteres';

  @override
  String get startUsing => 'Continuar';

  @override
  String get userIdTip => 'Isso será usado para personalizar sua experiência.';

  @override
  String get setupModelConfigTitle => 'Configurar um modelo AI';

  @override
  String get setupModelConfigSubtitle =>
      'Memex precisa de um modelo AI de fronteira para organizar registros, analisar imagens e gerar insights. Escolha um método de conexão.';

  @override
  String get setupModelConfigComplete => 'Concluir e seguir';

  @override
  String get aiService => 'Serviço de modelos Memex';

  @override
  String get aiModelHubTitle => 'Modelos e serviços AI';

  @override
  String get aiModelHubSubtitle =>
      'Escolha o serviço oficial do Memex ou traga seu próprio provedor. O roteamento avançado de modelos fica disponível quando você precisar.';

  @override
  String get aiSetupCurrentStatusTitle => 'Configuração atual';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'Serviço AI não configurado';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Escolha um método de conexão para ativar a organização AI de registros, mídia e insights.';

  @override
  String get aiSetupStatusMemexTitle => 'Usando o serviço oficial MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex usará a conexão oficial e credenciais de API gerenciadas pela sua conta MemeX.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Usando configurações de provedor personalizado';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex usará suas credenciais de provedor configuradas e seleções de papéis de modelo.';

  @override
  String get aiSetupChooseConnectionTitle => 'Escolha um método de conexão';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Comece pelo caminho que combina com a forma como você quer que Memex acesse modelos AI.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Entre no MemeX e use o serviço oficial sem escolher provedores, chaves ou modelos por agente.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Adicione suas credenciais de provedor, escolha o modelo que o Super Agent deve usar e opcionalmente substitua modelos por agente.';

  @override
  String get aiSetupCustomPageTitle => 'Serviço AI personalizado';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Configure credenciais do provedor primeiro, depois escolha o modelo que Memex deve usar.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Provedor e chaves API';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Adicione ou edite OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama ou outro provedor compatível.';

  @override
  String get modelRolesTitle => 'Escolha o modelo principal';

  @override
  String get modelRolesDescription =>
      'Super Agent usa um modelo para entradas de texto e imagem. Overrides avançados por agente ficam disponíveis abaixo.';

  @override
  String get textModelRoleTitle => 'Modelo principal';

  @override
  String get textModelRoleDescription =>
      'Usado pelo Super Agent para texto, imagens, cartões, conhecimento, insights, chat, comentários, agenda e memória.';

  @override
  String get modelConnectionsTitle => 'Provedores de modelo e chaves API';

  @override
  String get modelConnectionsDescription =>
      'Conecte o serviço oficial do Memex ou adicione suas próprias credenciais de provedor.';

  @override
  String get relatedAiCapabilitiesTitle =>
      'Capacidades avançadas e relacionadas';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Ajuste atribuições de agentes, provedor de localização e comportamento de speech transcription.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Capacidades do serviço';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Escolha os provedores que Memex usa para capacidades AI adjacentes, como speech e reverse geocoding.';

  @override
  String get aiSetupAdvancedCustomizationTitle =>
      'Roteamento avançado de modelos';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Para usuários avançados que querem que agentes individuais usem provedores ou configurações de modelo diferentes.';

  @override
  String get locationProviderSettings => 'Provedor de localização';

  @override
  String get speechProviderSettings => 'Transcrição de fala';

  @override
  String get advancedAgentModelAssignments =>
      'Atribuições de modelo por agente';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Substituir agentes individuais';

  @override
  String get noConfiguredModelOptions =>
      'Adicione um provedor ou chave API antes de escolher papéis de modelo.';

  @override
  String get modelSlotUpdated => 'Papel do modelo atualizado';

  @override
  String get aiServiceMemexRouteTitle => 'Conectar pelo Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex usa um sistema multiagente para organizar registros de vida, notas de conhecimento e contexto social, descobrir insights mais profundos e oferecer companhia AI com memória persistente. Seus dados são armazenados como Markdown em texto puro, preservando liberdade e portabilidade dos dados.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Tenho uma chave API';

  @override
  String get aiServiceCustomModelDescription =>
      'Escolha isto primeiro se você já tem uma chave API da OpenAI, Anthropic, DeepSeek, Gemini ou outro provedor.';

  @override
  String get enableAiService => 'Conectar com Memex';

  @override
  String get aiServiceReadyToast => 'Organização AI ativada';

  @override
  String get aiServiceSettingsDescription =>
      'Se você não tem uma chave API, use uma conta Memex para conectar a serviços de modelos populares.';

  @override
  String get advancedModelConfiguration => 'Configurar chave API';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String get clearAuth => 'Limpar autorização';

  @override
  String get authorizing => 'Autorizando...';

  @override
  String authFailed(Object error) {
    return 'Falha na autorização: $error';
  }

  @override
  String get authorized => 'Autorizado';

  @override
  String get config => 'Configuração';

  @override
  String get calendar => 'Calendário';

  @override
  String get reminders => 'Lembretes';

  @override
  String get writeToSystemFailed => 'Falha ao escrever no sistema';

  @override
  String permissionRequired(Object name) {
    return 'Permissão de $name necessária';
  }

  @override
  String permissionRationale(Object name) {
    return 'Permita que o app acesse $name em Configurações para que possamos criar isso para você.';
  }

  @override
  String get goToSettings => 'Ir para Configurações';

  @override
  String get unknownAction => 'Ação desconhecida';

  @override
  String get discoveredCalendarEvent => 'Evento de calendário encontrado';

  @override
  String get discoveredReminder => 'Lembrete encontrado';

  @override
  String get addToCalendar => 'Adicionar ao calendário';

  @override
  String get addToReminders => 'Adicionar aos lembretes';

  @override
  String addedToSuccess(Object target) {
    return 'Adicionado a $target com sucesso';
  }

  @override
  String get ignore => 'Ignorar';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get confirmDeleteSessionMessage =>
      'Excluir esta conversa? Isso não pode ser desfeito.';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteSuccess => 'Excluído com sucesso';

  @override
  String deleteFailed(Object error) {
    return 'Falha ao excluir: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count dias atrás';
  }

  @override
  String get chatHistory => 'Histórico de chat';

  @override
  String get enterFullScreenTooltip => 'Entrar em tela cheia';

  @override
  String get exitFullScreenTooltip => 'Sair da tela cheia';

  @override
  String get noConversations => 'Sem conversas';

  @override
  String loadSessionListFailed(Object error) {
    return 'Falha ao carregar lista de sessões: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Ontem $time';
  }

  @override
  String get newChat => 'Novo chat';

  @override
  String messageCount(Object count) {
    return '$count mensagens';
  }

  @override
  String get organize => 'Organizar';

  @override
  String get pkmCategoryProject => 'Project (projeto)';

  @override
  String get pkmCategoryProjectSubtitle => 'Curto prazo · Metas · Prazos';

  @override
  String get pkmCategoryArea => 'Area (área)';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Longo prazo · Responsabilidade · Padrões';

  @override
  String get pkmCategoryResource => 'Resource (recurso)';

  @override
  String get pkmCategoryResourceSubtitle => 'Interesses · Inspiração · Reserva';

  @override
  String get pkmCategoryArchive => 'Archive (arquivo)';

  @override
  String get pkmCategoryArchiveSubtitle => 'Concluído · Dormente · Referência';

  @override
  String get recentChanges => 'Mudanças recentes';

  @override
  String get noRecentChangesInThreeDays => 'Sem mudanças nos últimos 3 dias';

  @override
  String get unpinned => 'Desafixado';

  @override
  String get pinnedStyle => 'Estilo fixado';

  @override
  String operationFailed(Object error) {
    return 'Operação falhou: $error';
  }

  @override
  String get refreshingInsightData =>
      'Atualizando dados de insight, isso pode levar um momento...';

  @override
  String refreshFailed(Object error) {
    return 'Falha ao atualizar: $error';
  }

  @override
  String get sortUpdated => 'Ordem de classificação atualizada';

  @override
  String sortSaveFailed(Object error) {
    return 'Falha ao salvar classificação: $error';
  }

  @override
  String get insightCardDeleted => 'Cartão de insight excluído';

  @override
  String deleteFailedShort(Object error) {
    return 'Falha ao excluir: $error';
  }

  @override
  String get knowledgeInsight => 'Insight de conhecimento';

  @override
  String get completeSort => 'Concluir classificação';

  @override
  String get noKnowledgeInsight => 'Sem insight de conhecimento';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count tarefas em segundo plano ainda estão processando.';
  }

  @override
  String get insightUnavailableMessage =>
      'Este insight ainda está sendo gerado ou foi atualizado. Atualize os insights e tente novamente depois.';

  @override
  String get noScheduleAggregation => 'Sem agregação de agenda';

  @override
  String get scheduleAggregationEmptyHint =>
      'Toque em Update para organizar agendas e tarefas a partir de cartões temporais reais.';

  @override
  String get scheduleAggregationLoadFailed =>
      'Falha ao carregar dados de agenda';

  @override
  String get scheduleAggregationRefreshFailed =>
      'Falha ao atualizar dados de agenda';

  @override
  String get scheduleTaskUpdateFailed => 'Falha ao atualizar tarefa';

  @override
  String get scheduleFeatured => 'Destaque';

  @override
  String get scheduleThisWeek => 'Esta semana';

  @override
  String get scheduleDone => 'Concluído';

  @override
  String get scheduleTbd => 'A definir';

  @override
  String get scheduleWeekOverview => 'Esta semana';

  @override
  String get scheduleImportant => 'Importante';

  @override
  String get scheduleBriefingTitle => 'Resumo da agenda';

  @override
  String get scheduleBriefingOpen => 'Abrir';

  @override
  String get scheduleBriefingNoData => 'Ainda não há resumo da agenda';

  @override
  String scheduleBriefingUpdated(Object time) {
    return 'Atualizado $time';
  }

  @override
  String scheduleBriefingDoneCount(Object count) {
    return '$count concluídos';
  }

  @override
  String get updating => 'Atualizando...';

  @override
  String get update => 'Atualizar';

  @override
  String get enabled => 'Ativado';

  @override
  String get disabled => 'Desativado';

  @override
  String get appLockOn => 'Bloqueio do app ativado';

  @override
  String get appLockOff => 'Bloqueio do app desativado';

  @override
  String get enableAppLockFirst => 'Ative o bloqueio do app primeiro';

  @override
  String get enterFourDigitPassword => 'Digite uma senha de 4 dígitos';

  @override
  String get passwordSetAndLockOn => 'Senha definida e bloqueio do app ativado';

  @override
  String get appLockSettings => 'Configurações de bloqueio do app';

  @override
  String get enableAppLock => 'Ativar bloqueio do app';

  @override
  String get enableAppLockSubtitle => 'Senha necessária ao iniciar o app';

  @override
  String get enableBiometrics => 'Ativar biometria';

  @override
  String get biometricsSubtitle => 'Use Face ID ou Touch ID para desbloquear';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get setFourDigitPassword => 'Definir senha de 4 dígitos';

  @override
  String get reenterPasswordToConfirm =>
      'Digite a senha novamente para confirmar';

  @override
  String get passwordMismatch => 'As senhas não coincidem. Tente novamente.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Excluir personagem \"$name\"? Isso não pode ser desfeito.';
  }

  @override
  String get configureAiCharacter => 'Configurar personagem AI';

  @override
  String get addCharacter => 'Adicionar personagem';

  @override
  String get addCharacterSubtitle =>
      'Escolha personagens AI para entrar no seu time de insights. Eles analisarão seus dados de vida por diferentes ângulos.';

  @override
  String get noCharacters => 'Sem personagens';

  @override
  String loadCharacterFailed(Object error) {
    return 'Falha ao carregar personagens: $error';
  }

  @override
  String get noTags => 'Sem tags';

  @override
  String get createSuccess => 'Criado com sucesso';

  @override
  String get updateSuccess => 'Atualizado com sucesso';

  @override
  String saveFailed(Object error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String get newCharacter => 'Novo personagem';

  @override
  String get editCharacter => 'Editar personagem';

  @override
  String get save => 'Salvar';

  @override
  String get characterName => 'Nome do personagem';

  @override
  String get characterNameHint => 'Dê um nome ao seu personagem';

  @override
  String get pleaseEnterCharacterName => 'Insira o nome do personagem';

  @override
  String get tagsLabel => 'Tags / etiquetas';

  @override
  String get tagsHint =>
      'ex.: wisdom, recognition, macro\nSepare várias tags com vírgulas';

  @override
  String get characterPersonaLabel => 'Persona do personagem';

  @override
  String get characterPersonaHint =>
      'Inclua persona, guia de estilo, diálogo exemplo, filtros de conhecimento etc.\nUse ## para títulos de seção.';

  @override
  String get pleaseEnterCharacterPersona => 'Insira a persona do personagem';

  @override
  String permissionRequestError(Object error) {
    return 'Erro ao solicitar permissão: $error';
  }

  @override
  String get permissionRequiredTitle => 'Permissão necessária';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Você negou esta permissão permanentemente ou o sistema a exige. Ative-a nas configurações do sistema.';

  @override
  String get getting => 'Obtendo...';

  @override
  String get unauthorized => 'Não autorizado';

  @override
  String get authorizedGoToSettings =>
      'Autorizado. Vá às configurações do sistema para alterar.';

  @override
  String get location => 'Localização';

  @override
  String get locationPermissionReason =>
      'Para registrar lugares e recursos relacionados à localização';

  @override
  String get photos => 'Fotos';

  @override
  String get photosPermissionReason =>
      'Para selecionar fotos, salvar imagens geradas etc.';

  @override
  String get camera => 'Câmera';

  @override
  String get cameraPermissionReason => 'Para tirar fotos e vídeos';

  @override
  String get microphone => 'Microfone';

  @override
  String get microphonePermissionReason =>
      'Para reconhecimento de voz, gravação etc.';

  @override
  String get calendarPermissionReason =>
      'Para registrar agenda e ler eventos do calendário';

  @override
  String get remindersPermissionReason => 'Para registrar e ler seus lembretes';

  @override
  String get fitnessAndMotion => 'Fitness e movimento';

  @override
  String get fitnessPermissionReason =>
      'Para registrar dados de saúde e movimento';

  @override
  String get notification => 'Notificação';

  @override
  String get notificationPermissionReason =>
      'Para enviar agenda e lembretes importantes';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Manter o Memex Agent em segundo plano';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'O Memex Agent roda localmente no seu dispositivo. Com notificações, o Memex pode mostrar o progresso e continuar processando depois que você sai do app ou desliga a tela. Se as notificações estiverem desativadas, mantenha o Memex aberto em primeiro plano até a tarefa terminar.';

  @override
  String get loadDetailFailedRetryShort =>
      'Falha ao carregar detalhes, tente novamente mais tarde.';

  @override
  String get total => 'Total geral';

  @override
  String get estimatedCost => 'Custo estimado';

  @override
  String get byAgent => 'Por agente';

  @override
  String get timeUpdated => 'Hora atualizada';

  @override
  String updateFailed(Object error) {
    return 'Falha ao atualizar: $error';
  }

  @override
  String get locationUpdated => 'Localização atualizada';

  @override
  String get confirmDeleteCardMessage =>
      'Excluir este cartão? Isso não pode ser desfeito.';

  @override
  String get cardDetailNotFound => 'Detalhe do cartão não encontrado';

  @override
  String get saySomething => 'Diga algo...';

  @override
  String get relatedMemories => 'Memórias relacionadas';

  @override
  String get viewMore => 'Ver mais';

  @override
  String get relatedRecords => 'Registros relacionados';

  @override
  String get reply => 'Responder';

  @override
  String get replySent => 'Resposta enviada';

  @override
  String get insightTemplateGalleryTitle => 'Modelos de cartões de insight';

  @override
  String get timelineTemplateGalleryTitle => 'Modelos de cartões de timeline';

  @override
  String get categoryTextual => 'Categoria textual';

  @override
  String get timelineFilterAll => 'TODOS';

  @override
  String get insights => 'Insights gerados';

  @override
  String get memoryTitle => 'Memória';

  @override
  String get longTermProfile => 'Perfil de longo prazo';

  @override
  String get recentBuffer => 'Buffer recente';

  @override
  String errorLoadingMemory(Object error) {
    return 'Erro ao carregar memória: $error';
  }

  @override
  String get agentConfiguration => 'Configuração de agente';

  @override
  String get resetToDefaults => 'Restaurar padrões';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Restaurar todas as configurações de agentes';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Tem certeza de que deseja restaurar todas as configurações de agentes para os valores padrão? Esta ação não pode ser desfeita.';

  @override
  String get resetButton => 'Restaurar';

  @override
  String loadDataFailed(Object error) {
    return 'Falha ao carregar dados: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Falha ao salvar configuração: $error';
  }

  @override
  String get selectLlmClient => 'Selecione o LLM Client:';

  @override
  String get agentConfigurationsReset => 'Configurações de agentes restauradas';

  @override
  String resetFailed(Object error) {
    return 'Falha ao restaurar: $error';
  }

  @override
  String get modelConfiguration => 'Configuração de modelo';

  @override
  String get resetAllConfigurationsTitle => 'Restaurar todas as configurações';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Tem certeza de que deseja restaurar todas as configurações de modelo para os valores padrão? Esta ação não pode ser desfeita.';

  @override
  String get modelConfigurationsReset => 'Configurações de modelo restauradas';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Não é possível excluir a configuração padrão';

  @override
  String get cannotDeleteConfigurationTitle =>
      'Não é possível excluir configuração';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Esta configuração está sendo usada pelos seguintes agentes:\n\n$agentList\n\nReatribua esses agentes antes de excluir.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Excluir configuração';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Tem certeza de que deseja excluir \"$key\"?';
  }

  @override
  String get defaultLabel => 'Padrão';

  @override
  String get setAsDefault => 'Definir como padrão';

  @override
  String get invalidJsonInExtraField => 'JSON inválido no campo Extra';

  @override
  String get keyAlreadyExists => 'A chave já existe';

  @override
  String get resetConfigurationTitle => 'Restaurar configuração';

  @override
  String get resetConfigurationMessage =>
      'Restaurar esta configuração para os valores padrão iniciais? As mudanças atuais serão perdidas.';

  @override
  String get configurationResetPressSave =>
      'Configuração restaurada. Pressione Salvar para aplicar.';

  @override
  String get addConfiguration => 'Adicionar configuração';

  @override
  String get editConfiguration => 'Editar configuração';

  @override
  String get duplicateConfiguration => 'Duplicar configuração';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get keyIdLabel => 'ID da configuração';

  @override
  String get keyIdHelper =>
      'Nomeie esta configuração, como deepseek ou work-gpt.';

  @override
  String get required => 'Obrigatório';

  @override
  String get clientLabel => 'Provedor de modelo';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Populares';

  @override
  String get providerOpenAiApiKey => 'API Key';

  @override
  String get providerOpenAiResponses => 'API Key (modo Responses)';

  @override
  String get providerChatGptOauth => 'Conta ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API Key';

  @override
  String get providerBedrockSecret => 'Bedrock Secret key';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini via Google OAuth';

  @override
  String get providerKimi => 'Kimi da Moonshot';

  @override
  String get providerQwen => 'Provedor Aliyun';

  @override
  String get providerSeed => 'Provedor Volcengine';

  @override
  String get providerZhipu => 'Provedor Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama local';

  @override
  String get providerMimo => 'Provedor Xiaomi MIMO';

  @override
  String get providerMemex => 'Serviço proxy Memex';

  @override
  String get memexSignIn => 'Entrar';

  @override
  String get memexCreateAccount => 'Criar conta';

  @override
  String get memexUsername => 'Nome de usuário';

  @override
  String get memexPassword => 'Senha';

  @override
  String get memexCreateAccountLink => 'Criar conta';

  @override
  String get memexSignInLink => 'Entrar em vez disso';

  @override
  String get memexTopUp => 'Adicione créditos para começar a usar Memex AI';

  @override
  String get memexTopUpSuccess => 'Crédito adicionado com sucesso!';

  @override
  String get memexFillAllFields => 'Preencha todos os campos';

  @override
  String get memexUsernameTooShort =>
      'O nome de usuário deve ter pelo menos 6 caracteres';

  @override
  String get memexAuthFailed => 'Falha de autenticação';

  @override
  String get memexPaymentFailed => 'Falha ao criar pagamento';

  @override
  String get memexLogout => 'Sair';

  @override
  String get memexTopUpButton => 'Adicionar créditos';

  @override
  String get memexTopUpChooseAmount => 'Escolha um valor';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Cerca de $range registros';
  }

  @override
  String get memexTopUpPlanStarter => 'Plano Starter';

  @override
  String get memexTopUpPlanEveryday => 'Plano Everyday';

  @override
  String get memexTopUpPlanHighVolume => 'Plano High volume';

  @override
  String get memexTopUpPlanCustom => 'Créditos personalizados';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Bom para testar Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'Bom para organização regular';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Bom para lotes maiores';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Digite USD 1-10.000';

  @override
  String get memexTopUpCustomEstimate => 'Estimativa baseada no valor inserido';

  @override
  String get memexCustomAmount => 'Valor personalizado';

  @override
  String get memexViewHistory => 'Ver histórico de uso';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Saldo: $amount';
  }

  @override
  String get memexConfirmPassword => 'Confirmar senha';

  @override
  String get memexPasswordMismatch => 'As senhas não coincidem';

  @override
  String memexPayAmount(Object amount) {
    return 'Adicionar $amount';
  }

  @override
  String get modelIdLabel => 'Modelo';

  @override
  String get modelIdHelper => 'ex.: gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Buscando modelos...';

  @override
  String get fetchModelsButton => 'Buscar modelos';

  @override
  String get enterApiKeyFirst =>
      'Digite a API Key primeiro para buscar modelos';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Endpoint API';

  @override
  String get advancedSettings => 'Configurações avançadas';

  @override
  String get testConnectionSuccess => 'Conexão bem-sucedida';

  @override
  String get testConnectionFailed => 'Conexão falhou';

  @override
  String get testTypeText => 'Texto';

  @override
  String get testTypeVision => 'Visão';

  @override
  String get testButton => 'Testar';

  @override
  String get testing => 'Testando...';

  @override
  String get proxyUrlOptional => 'Proxy URL (opcional)';

  @override
  String get proxyUrlHelper => 'ex.: http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Valor de Temperature';

  @override
  String get topPLabel => 'Valor de Top P';

  @override
  String get maxTokensLabel => 'Máx. tokens';

  @override
  String get extraParamsJson => 'Parâmetros extras (JSON)';

  @override
  String get invalidJson => 'JSON inválido';

  @override
  String get warning => 'Configuração incompleta';

  @override
  String get invalidConfigurationWarning =>
      'A configuração ainda não está completa (por exemplo, falta API Key ou Model ID). Você ainda pode salvar e configurar depois. Continuar?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" precisa de uma configuração de modelo válida (key: \"$configKey\") para operar. Verifique as configurações de modelo.';
  }

  @override
  String get discardChangesTitle => 'Sair desta página?';

  @override
  String get discardChangesMessage =>
      'Se você fez alterações, salve antes de sair.';

  @override
  String get discardButton => 'Descartar';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get chooseAvatar => 'Escolher avatar';

  @override
  String get configureNow => 'Configurar agora';

  @override
  String get modelNotConfiguredBanner =>
      'Modelo AI ainda não configurado. Configure para liberar todos os recursos.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Configure um modelo AI antes de publicar';

  @override
  String get processingStatus => 'Processando';

  @override
  String get failedStatus => 'Falhou';

  @override
  String get failureReason => 'Motivo da falha';

  @override
  String get unknownError => 'Ocorreu um erro desconhecido';

  @override
  String get enableFitness => 'Ativar Fitness';

  @override
  String get fitnessBannerMessage =>
      'Permita acesso ao fitness para acompanhar dados de saúde e atividade.';

  @override
  String get fitnessDismissTitle => 'Pular acesso ao Fitness?';

  @override
  String get fitnessDismissMessage =>
      'Sem permissão de fitness, o app não poderá coletar automaticamente seus dados de saúde para insights e auto-registro.';

  @override
  String get skipAnyway => 'Pular mesmo assim';

  @override
  String get proModelHint =>
      'Este modelo exige uma assinatura ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Buscar na base de conhecimento...';

  @override
  String get searchKnowledgeHint =>
      'Digite uma palavra-chave para buscar nomes de arquivos ou conteúdo';

  @override
  String noSearchResults(Object query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'Somente prévia Markdown é suportada';

  @override
  String get backupAndRestore => 'Backup e restauração';

  @override
  String get createBackup => 'Criar backup';

  @override
  String get restoreBackup => 'Restaurar backup';

  @override
  String get backupDescription =>
      'Empacote todos os seus dados (cartões, base de conhecimento, insights, configurações) em um arquivo .memex. Salve no iCloud Drive, Google Drive ou qualquer local pelo share sheet.';

  @override
  String get restoreDescription =>
      'Selecione um arquivo de backup .memex para restaurar todos os dados. Isso substituirá os dados atuais.';

  @override
  String get selectBackupFile => 'Selecionar arquivo de backup';

  @override
  String get estimatedSize => 'Tamanho estimado';

  @override
  String get backupComplete => 'Backup criado';

  @override
  String backupFailed(Object error) {
    return 'Backup falhou: $error';
  }

  @override
  String get confirmRestore => 'Confirmar restauração';

  @override
  String get confirmRestoreMessage =>
      'A restauração substituirá todos os dados atuais, incluindo cartões, base de conhecimento, insights e configurações. Isso não pode ser desfeito. Continuar?';

  @override
  String get restoreComplete => 'Restauração concluída';

  @override
  String get restoreRestartHint =>
      'Os dados foram restaurados. Reinicie o app para que todas as mudanças tenham efeito.';

  @override
  String restoreFailed(Object error) {
    return 'Restauração falhou: $error';
  }

  @override
  String get invalidBackupFile =>
      'Arquivo de backup inválido. Selecione um arquivo .memex.';

  @override
  String get automaticBackup => 'Backup automático';

  @override
  String get autoBackupDescription =>
      'Quando ativado, Memex cria no máximo um snapshot local por dia depois da inicialização ou ao voltar ao foreground.';

  @override
  String get backupSensitiveSettingsHint =>
      'Backups incluem configurações e chaves de provedores de modelo. Guarde os arquivos de backup em um lugar confiável.';

  @override
  String get backupLocation => 'Local';

  @override
  String get backupLocationDetails => 'Detalhes do local';

  @override
  String get backupLocationSummary => 'Mostrado no app';

  @override
  String get backupLocationFullPath => 'Caminho completo';

  @override
  String get backupLocationUri => 'URI de acesso à pasta';

  @override
  String get copyBackupLocationPath => 'Copiar caminho';

  @override
  String get backupLocationCopied => 'Local do backup copiado';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Pasta selecionada: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups folder';

  @override
  String get autoBackupStatus => 'Status do backup';

  @override
  String get noAutoBackupYet => 'Ainda não há backup automático';

  @override
  String lastBackupAt(Object time) {
    return 'Último backup: $time';
  }

  @override
  String get autoBackupRetention => 'Retenção';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days dias';
  }

  @override
  String get autoBackupRetentionForever => 'Manter para sempre';

  @override
  String get autoBackupMaxSize => 'Limite de armazenamento';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'A limpeza automática mantém snapshots automáticos abaixo de $size. Snapshots de segurança e exports manuais são mantidos separadamente.';
  }

  @override
  String get createSnapshotNow => 'Fazer backup agora';

  @override
  String get backupLocationMenu => 'Alterar local';

  @override
  String get defaultBackupLocation => 'Pasta padrão de backup';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Use a pasta de arquivos externos específica do Memex. Não é necessária permissão de armazenamento.';

  @override
  String get chooseBackupLocation => 'Escolher pasta de backup';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Escolha uma pasta pelo seletor do Android e conceda acesso persistente ao Memex.';

  @override
  String get storedBackups => 'Backups armazenados';

  @override
  String get noStoredBackups =>
      'Backups automáticos aparecerão aqui depois do primeiro snapshot.';

  @override
  String get backupTypeAutoSnapshot => 'Snapshot automático';

  @override
  String get backupTypeSafetySnapshot => 'Snapshot de segurança';

  @override
  String get backupTypeManualBackup => 'Backup manual';

  @override
  String get refresh => 'Atualizar';

  @override
  String get restoreThisBackup => 'Restaurar este backup';

  @override
  String get deleteThisBackup => 'Excluir este backup';

  @override
  String get confirmDeleteBackup => 'Excluir backup?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Excluir $fileName? Isso remove o arquivo de backup armazenado e não pode ser desfeito.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Backup excluído: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Não foi possível excluir backup: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Criando snapshot de segurança...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Snapshot criado: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Não foi possível atualizar local do backup: $error';
  }

  @override
  String get backupImportCreatedAt => 'Criado';

  @override
  String get backupImportSourceVersion => 'Versão de origem';

  @override
  String get backupImportFlavor => 'Build';

  @override
  String get backupLegacyFormat => 'Backup legado (sem manifest)';

  @override
  String get restoreInProgress => 'Restaurando backup...';

  @override
  String get dataStorage => 'Armazenamento de dados';

  @override
  String get dataStorageDescriptionAndroid =>
      'Escolha uma pasta personalizada para armazenar seu workspace. Os dados permanecem quando você reinstala o app.';

  @override
  String get dataStorageDescriptionIOS =>
      'Ative o iCloud para sincronizar seu workspace entre dispositivos e manter os dados após reinstalar o app.';

  @override
  String get storageLocationApp => 'Armazenamento do app';

  @override
  String get storageLocationAppDesc =>
      'Os dados são armazenados dentro do app e serão removidos ao desinstalar.';

  @override
  String get storageLocationCustom =>
      'Armazenamento do dispositivo (pasta personalizada)';

  @override
  String get storageLocationCustomDesc =>
      'Armazene dados em uma pasta escolhida por você. Os dados persistem após reinstalação se a pasta permanecer.';

  @override
  String get storageLocationICloud => 'Armazenar no iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Sincronize seu workspace entre dispositivos Apple. Os dados permanecem após reinstalar.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Atual: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Entre no iCloud e ative o iCloud Drive para usar armazenamento iCloud.';

  @override
  String get loadingFromICloud => 'Restaurando dados do iCloud…';

  @override
  String get switchingToICloud => 'Alternando para armazenamento iCloud…';

  @override
  String get switchingStorage => 'Alternando armazenamento…';

  @override
  String get customFolderAccessDenied =>
      'Não é possível ler ou escrever nesta pasta. Conceda permissão de armazenamento ou escolha outro local.';

  @override
  String get configured => 'Configurado';

  @override
  String get apiKeyNotSet => 'API Key não definida — toque para configurar';

  @override
  String get bottomNavTimeline => 'Aba Timeline';

  @override
  String get bottomNavLibrary => 'Biblioteca';

  @override
  String get aiGeneratedLabel => 'Gerado por AI';

  @override
  String sourceTraceWithCount(Object count) {
    return 'RASTRO DE FONTE ($count)';
  }

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountDesc =>
      'Excluir permanentemente todos os dados locais e redefinir o app.';

  @override
  String get deleteAccountConfirmTitle => 'Excluir conta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Isso excluirá permanentemente todos os seus dados, incluindo cartões de timeline, base de conhecimento, gravações e configurações. Esta ação não pode ser desfeita.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Digite \"$name\" para confirmar';
  }

  @override
  String get deleteAccountTypeHint =>
      'Digite seu nome de usuário para confirmar';

  @override
  String get llmConsentTitle => 'Consentimento de compartilhamento de dados';

  @override
  String llmConsentMessage(Object provider) {
    return 'Para ativar recursos AI, Memex precisa enviar seus dados para $provider para processamento. Isso inclui:\n\n• Texto que você digita (notas, transcrições de voz)\n• Metadados de fotos e texto extraído (OCR)\n• Resumos de saúde e fitness\n• Conteúdo de cartões de timeline\n\nSeus dados são enviados diretamente do seu dispositivo para $provider. Memex não armazena nem retransmite seus dados por qualquer outro servidor.\n\nRevise a política de privacidade de $provider para saber como eles lidam com seus dados.\n\nVocê concorda em enviar seus dados para $provider para processamento AI?';
  }

  @override
  String get llmConsentAgree => 'Concordo';

  @override
  String get llmConsentDecline => 'Recusar';

  @override
  String get customAgents => 'Agentes personalizados';

  @override
  String get noCustomAgents => 'Nenhum agente personalizado configurado.';

  @override
  String get deleteAgent => 'Excluir agente';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Excluir agente personalizado \"$name\"?';
  }

  @override
  String get deleted => 'Excluído';

  @override
  String get saved => 'Salvo';

  @override
  String get newAgent => 'Novo agente';

  @override
  String get editAgent => 'Editar agente';

  @override
  String get agentName => 'Nome do agente';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Obrigatório';

  @override
  String get agentNameInvalid => 'Somente letras, dígitos e hifens';

  @override
  String get agentNameExists => 'Nome já existe';

  @override
  String get hostAgentType => 'Tipo de agente host';

  @override
  String get skillDirectory => 'Diretório de skill';

  @override
  String get skillDirInvalid =>
      'Deve ser um caminho relativo (sem / inicial ou ..)';

  @override
  String get workingDirectory => 'Diretório de trabalho (opcional)';

  @override
  String get workingDirectoryHint => 'Deixe vazio para o padrão do workspace';

  @override
  String get llmConfig => 'Configuração LLM';

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get executionMode => 'Modo de execução';

  @override
  String get executionModeAsync => 'Assíncrono';

  @override
  String get executionModeSync => 'Síncrono';

  @override
  String get dependsOn => 'Depende de';

  @override
  String get dependsOnHint => 'Selecione dependências';

  @override
  String get priority => 'Prioridade';

  @override
  String get maxRetries => 'Máx. tentativas';

  @override
  String get systemPromptLabel => 'System Prompt (opcional)';

  @override
  String get systemPromptHint =>
      'Instruções adicionais anexadas ao prompt do agente host';

  @override
  String get eventSerializer => 'Serializador de evento';

  @override
  String get eventSerializerDefault => 'Padrão (XML)';

  @override
  String get enabledLabel => 'Ativado';

  @override
  String get skillsManagement => 'Gerenciamento de skills';

  @override
  String get skillsManagementEmpty => 'Ainda não há skills';

  @override
  String get downloadSkill => 'Baixar skill';

  @override
  String get downloading => 'Baixando...';

  @override
  String get downloadSuccess => 'Skill baixada com sucesso';

  @override
  String downloadFailed(Object error) {
    return 'Download falhou: $error';
  }

  @override
  String get deleteConfirm => 'Confirmar exclusão';

  @override
  String deleteConfirmMessage(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"?';
  }

  @override
  String get invalidUrl => 'Digite uma URL válida';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Nova pasta';

  @override
  String get newFile => 'Novo arquivo';

  @override
  String get folderName => 'Nome da pasta';

  @override
  String get fileName => 'Nome do arquivo';

  @override
  String get nameRequired => 'Nome é obrigatório';

  @override
  String get nameInvalid => 'Nome não pode conter / ou ..';

  @override
  String createFailed(Object error) {
    return 'Criação falhou: $error';
  }

  @override
  String get fileContent => 'Conteúdo do arquivo';

  @override
  String get saveSuccess => 'Salvo com sucesso';

  @override
  String downloadToCurrentDir(String dir) {
    return 'O zip será extraído para o diretório atual: $dir';
  }

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get privacyPolicyDesc => 'Como Memex lida com seus dados';

  @override
  String get llmAuthError =>
      'Falha na autenticação API. Verifique sua configuração LLM em Configurações.';

  @override
  String get llmBadRequestError =>
      'A solicitação foi rejeitada pelo provedor LLM. O formato da entrada pode não ser suportado pelo modelo atual.';

  @override
  String get llmRateLimitError =>
      'Limite de taxa da API excedido. Tente novamente mais tarde.';

  @override
  String get llmServerError =>
      'Serviço LLM temporariamente indisponível. Tente novamente mais tarde.';

  @override
  String get llmNetworkError =>
      'Falha na conexão de rede. Verifique sua conexão com a internet.';

  @override
  String get llmUnknownError =>
      'Ocorreu um erro inesperado ao processar seu conteúdo.';

  @override
  String get llmErrorDialogTitle => 'Processamento falhou';

  @override
  String get goToModelConfig => 'Ir para Configurações';

  @override
  String get speechModelDownloadTitle => 'Baixar modelo de fala';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'É necessário baixar o modelo uma vez (~${sizeMB}MB).\n\nDepois de baixado, a transcrição roda inteiramente no dispositivo.';
  }

  @override
  String get speechModelStartDownload => 'Iniciar download';

  @override
  String get speechModelChooseSource => 'Escolha a fonte de download:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (mais rápido na CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (fonte global)';

  @override
  String get speechModelDownloading => 'Baixando modelo...';

  @override
  String get speechModelConnecting => 'Conectando...';

  @override
  String get deleteSpeechModel => 'Excluir modelo de fala';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Excluir os arquivos do modelo local de reconhecimento de fala baixado? Eles serão baixados novamente na próxima vez que local speech-to-text for usado.';

  @override
  String get speechModelDeletedSuccess =>
      'Arquivos do modelo de fala excluídos';

  @override
  String get speechModelNotDownloaded =>
      'Nenhum arquivo de modelo de fala baixado encontrado';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Falha ao excluir arquivos do modelo de fala: $error';
  }

  @override
  String get speechTranscribing => 'Reconhecendo...';

  @override
  String get speechNoResult => 'Nenhuma fala detectada';

  @override
  String get useLocalSpeechToTextTitle => 'Usar speech to text local';

  @override
  String get useLocalSpeechToTextDesc =>
      'Quando ativado, o áudio é transcrito no dispositivo antes do envio — útil para modelos que não suportam entrada de áudio. Quando desativado, o áudio original é enviado diretamente ao modelo.';

  @override
  String get pendingAiProcessingHint => 'Configure o modelo AI para processar';

  @override
  String get demoWelcome =>
      'Boas-vindas ao Memex!\nVamos fazer uma tour rápida do que AI pode fazer pelos seus registros.';

  @override
  String get demoTapAdd => 'Toque aqui para criar seu primeiro registro';

  @override
  String get demoTapSend => 'Toque para enviar seu primeiro registro';

  @override
  String get demoTapCard => 'Toque para ver como AI organizou seu registro';

  @override
  String get demoDetailHint =>
      'Este é o detalhe do seu registro organizado pela AI. Explore e depois volte para continuar a tour.';

  @override
  String get demoTapInsight => 'Toque para ver insights gerados por AI';

  @override
  String get demoTapInsightUpdate =>
      'Toque para gerar insights a partir dos seus registros';

  @override
  String get demoTapKnowledge =>
      'Veja seus arquivos de conhecimento organizados automaticamente';

  @override
  String get demoDone => 'Comece a registrar sua vida.';

  @override
  String get demoStartTour => 'Iniciar tour';

  @override
  String get demoGetStarted => 'Começar';

  @override
  String get demoSkip => 'Pular';

  @override
  String get demoPrefillText => 'Olá Memex! Este é meu primeiro registro 🎉';

  @override
  String get visionBadge => 'Visão';

  @override
  String get notMultimodalHint =>
      'Memex depende de capacidades multimodais de modelo para análise de mídia. Se seus registros contêm imagens, confirme que o modelo configurado suporta entrada de imagem.';

  @override
  String get defaultModelPrefix => 'Padrão';

  @override
  String get recommendedBadge => 'Recomendado';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Trocar companheiro';

  @override
  String get personaChatInputHint => 'Digite uma mensagem...';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get yesterday => 'Ontem';

  @override
  String get showInsightTextTitle => 'Mostrar comentário de insight do Memex';

  @override
  String get showInsightTextDesc =>
      'Se deve mostrar o insight do Memex como comentário fixado na seção de comentários do detalhe do cartão.';

  @override
  String get enableCharacterCommentTitle =>
      'Comentário automático de personagem';

  @override
  String get enableCharacterCommentDesc =>
      'Personagens comentam automaticamente em novos registros.';

  @override
  String get maxCommentCharactersTitle => 'Máximo de personagens comentando';

  @override
  String get maxCommentCharactersDesc =>
      'Quantos personagens podem comentar em cada registro.';

  @override
  String replyTo(String name) {
    return 'Responder a $name';
  }

  @override
  String get cdnSignalsComments => 'Nova resposta recebida';

  @override
  String get cdnSignalsInsight => 'Novo insight gerado';

  @override
  String get cdnSignalsBoth => 'Nova resposta e insight';

  @override
  String get untitledCard => 'Cartão sem título';

  @override
  String get locationContextTitle => 'Contexto de localização';

  @override
  String get locationContextDescription =>
      'Contexto da cidade e bairro atuais para chat com agente';

  @override
  String get locationContextAttachTitle => 'Anexar localização atual ao chat';

  @override
  String get locationContextAttachDesc =>
      'Usa GPS do dispositivo e reverse geocoding para fornecer cidade, distrito e bairro ao agente.';

  @override
  String get reverseGeocodingProvider => 'Provedor de reverse geocoding';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Valor Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap usa coordenadas GCJ-02. O GPS do dispositivo é convertido antes do reverse geocoding.';

  @override
  String get contextGranularity => 'Granularidade do contexto';

  @override
  String get granularityCity => 'Cidade';

  @override
  String get granularityDistrict => 'Distrito';

  @override
  String get granularityNeighborhood => 'Bairro';

  @override
  String get granularityStreet => 'Rua';

  @override
  String get granularityFullAddress => 'Candidato de endereço completo';

  @override
  String get locationFreshness => 'Atualidade da localização';

  @override
  String minutesShort(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get oneHour => '1 hora';

  @override
  String get testCurrentLocation => 'Testar localização atual';

  @override
  String locationTestFailed(String error) {
    return 'Falhou: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Etapa reverse geocode';

  @override
  String get locationDebugProvider => 'Provedor';

  @override
  String get locationDebugAgentContext => 'Contexto do agente';

  @override
  String get locationDebugSource => 'Fonte';

  @override
  String get locationDebugAddressSummary => 'Resumo do endereço';

  @override
  String get locationDebugFullAddress => 'Endereço completo';

  @override
  String get locationDebugCoordinates => 'Coordenadas';

  @override
  String get locationDebugAccuracy => 'Precisão';

  @override
  String get locationDebugReason => 'Motivo';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'indisponível';

  @override
  String get locationDebugInjected => 'injetado';

  @override
  String get locationDebugNotInjected => 'não injetado';

  @override
  String get locationStatusUpdatedAt => 'Atualizado';

  @override
  String get locationStatusSuccessTitle => 'Localização atual pronta';

  @override
  String get locationStatusSuccessBody =>
      'Memex pode anexar este resumo de localização quando o contexto for relevante.';

  @override
  String get locationStatusApproximateTitle => 'Apenas localização aproximada';

  @override
  String get locationStatusApproximateBody =>
      'A precisão parece estar em nível de cidade ou área. Você pode continuar usando, ou ativar Precise Location nas configurações do sistema para um contexto mais estreito.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'Localização do sistema desligada';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex usa apenas o GPS do dispositivo e não inferirá localização por rede ou IP. No Android, abra Location settings; no iOS, ative Settings > Privacy & Security > Location Services.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Permissão de localização necessária';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Permita que Memex use localização durante testes ou quando o contexto de localização for necessário. Always access não é solicitado.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'Permissão de localização bloqueada';

  @override
  String get locationStatusPermissionForeverBody =>
      'Abra as configurações do app e permita localização para Memex. No iOS, While Using the App é suficiente.';

  @override
  String get locationStatusDisabledTitle => 'Contexto de localização desligado';

  @override
  String get locationStatusDisabledBody =>
      'Ative o switch acima e salve quando quiser que Memex anexe a localização do dispositivo ao contexto do agente.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS funciona, mas a busca de endereço falhou';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex tem coordenadas, mas não injetará contexto apenas de GPS no agente. Verifique o provedor de reverse geocoding e tente novamente.';

  @override
  String get locationStatusUnavailableTitle => 'Localização indisponível';

  @override
  String get locationStatusUnavailableBody =>
      'Verifique serviços de localização do sistema e permissão do app, depois teste novamente.';

  @override
  String get allowLocationPermissionButton => 'Permitir localização';

  @override
  String get openAppSettingsButton => 'Abrir configurações do app';

  @override
  String get openLocationSettingsButton => 'Abrir configurações de localização';

  @override
  String get locationSettingsOpenFailed =>
      'Não foi possível abrir configurações do sistema.';

  @override
  String locationActionFailed(String error) {
    return 'Ação de localização falhou: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Buscar configurações...';

  @override
  String get settingsSearchEmpty =>
      'Nenhuma configuração correspondente encontrada';

  @override
  String get importCharacterCard => 'Importar Character Card';

  @override
  String get firstMessageLabel => 'Primeira mensagem';

  @override
  String get firstMessageHint =>
      'Saudação enviada na primeira conversa (opcional)';

  @override
  String get systemPromptOverrideLabel => 'Override de System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'Substituir system prompt padrão (avançado, opcional)';

  @override
  String get postHistoryInstructionsLabel => 'Instruções pós-histórico';

  @override
  String get postHistoryInstructionsHint =>
      'Instruções injetadas depois do histórico de chat e antes da resposta (opcional)';

  @override
  String get mesExampleLabel => 'Exemplos de mensagens';

  @override
  String get mesExampleHint =>
      'Diálogos exemplo mostrando estilo do personagem (opcional)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Conhecimento de fundo injetado quando palavras-chave são acionadas';

  @override
  String get characterMemoryTitle => 'Memória do personagem';

  @override
  String get characterMemorySubtitle =>
      'Dinâmicas de relacionamento e memórias de interação entre personagem e usuário';

  @override
  String get addTooltip => 'Adicionar';

  @override
  String get constantBadge => 'Constante';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Entrada $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Palavras-chave: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Memória $index';
  }

  @override
  String get addWorldEntry => 'Adicionar entrada do World Book';

  @override
  String get editWorldEntry => 'Editar entrada do World Book';

  @override
  String get commentTitleLabel => 'Comentário / título';

  @override
  String get entryDescriptionHint => 'Descrição da entrada (opcional)';

  @override
  String get triggerKeywordsLabel => 'Palavras-chave de acionamento';

  @override
  String get triggerKeywordsHint => 'Separadas por vírgula, ex.: magic, spell';

  @override
  String get contentLabel => 'Conteúdo';

  @override
  String get worldEntryContentHint =>
      'Conhecimento de fundo injetado quando palavras-chave acionam';

  @override
  String get enabledCheckbox => 'Ativado';

  @override
  String get addMemory => 'Adicionar memória';

  @override
  String get editMemory => 'Editar memória';

  @override
  String get memoryLabelField => 'Rótulo';

  @override
  String get memoryLabelHint => 'Identificador único, ex.: preferência de nome';

  @override
  String get memoryContentHint => 'Conteúdo da memória';

  @override
  String get salienceLabel => 'Saliência: ';

  @override
  String get labelCannotBeEmpty => 'O rótulo não pode ficar vazio';

  @override
  String importSuccess(Object name) {
    return '$name importado com sucesso';
  }

  @override
  String importFailed(Object error) {
    return 'Importação falhou: $error';
  }

  @override
  String get supportedFormats => 'Formatos suportados';

  @override
  String get tavernImportDescription =>
      '• Cartões de personagem SillyTavern V2 (.json)\n• Imagens PNG com cartões embutidos (.png)\n\nCampos como persona, world book etc. serão mapeados automaticamente para o formato de personagem do Memex.';

  @override
  String get pickCharacterFile => 'Escolher arquivo de personagem';

  @override
  String get repickFile => 'Escolher outro arquivo';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count entradas';
  }

  @override
  String fileLabel(Object filename) {
    return 'Arquivo: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Já existe personagem com o mesmo nome: $names. A importação criará um novo personagem sem sobrescrever os existentes.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Definir como companheiro principal';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Definir automaticamente como seu companheiro principal após importar';

  @override
  String get confirmImport => 'Confirmar importação';

  @override
  String get chatBackground => 'Fundo do chat';

  @override
  String get chooseChatBackgroundImage => 'Escolher imagem de fundo';

  @override
  String get earlyUpdateSettingsTitle => 'Atualizações Early access';

  @override
  String get earlyUpdateSettingsDesc =>
      'Verifique os pre-releases do GitHub para o Early APK correspondente, baixe-o e entregue ao instalador do Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Atualizações Early só estão disponíveis no Android Early build.';

  @override
  String get earlyUpdateAutoCheckTitle =>
      'Verificar atualizações automaticamente';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Verificar na inicialização no máximo uma vez a cada 12 horas.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Baixar somente no Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Pular downloads de atualização usando dados móveis.';

  @override
  String get earlyUpdateAutoInstallTitle => 'Baixar e instalar automaticamente';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Quando uma nova build for encontrada, baixe-a e abra automaticamente o instalador do Android.';

  @override
  String get earlyUpdateCheckNow => 'Verificar agora';

  @override
  String get earlyUpdateChecking => 'Verificando GitHub pre-releases...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Ignorado porque downloads somente por Wi-Fi estão ativados.';

  @override
  String get earlyUpdateNoUpdate => 'Você já está na última Early build.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early build $version+$build está disponível.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Baixar e instalar';

  @override
  String get earlyUpdateDownloadInProgress => 'Baixando atualização...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Baixando atualização: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Pacote de atualização baixado. Pronto para instalar.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'Instalar pacote baixado';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Limpar pacote baixado';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Pacote de atualização baixado limpo.';

  @override
  String get earlyUpdateInstallStarted => 'Instalador Android aberto.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Permita que Memex instale apps desconhecidos, depois toque em baixar e instalar novamente.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Última verificação: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Falha ao verificar atualização: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Atualização Early disponível';

  @override
  String get earlyUpdateReleaseNotes => 'Notas da versão';

  @override
  String get dismissAllNotifications => 'Limpar tudo';

  @override
  String get dismissByType => 'Limpar por tipo';

  @override
  String get dismissTypeSystemAction => 'Lembretes e eventos';

  @override
  String get dismissTypeClarification => 'Esclarecimentos';

  @override
  String get dismissTypeCardUpdate => 'Atualizações de cartões';

  @override
  String dismissedCount(Object count) {
    return '$count limpos';
  }

  @override
  String get dataImportTitle => 'Importar arquivos';

  @override
  String get dataImportSettingsDescription =>
      'Traga arquivos antigos para o Memex e depois decida se quer organizá-los.';

  @override
  String get dataImportDescription =>
      'Escolha anotações antigas, registros exportados, documentos ou arquivos ZIP. O Memex salva uma cópia primeiro e não altera os arquivos originais. Depois você decide se quer ajuda do Memex para organizar tudo.';

  @override
  String get dataImportSelectFiles => 'Escolher arquivos para importar';

  @override
  String get dataImportImporting => 'Salvando arquivos...';

  @override
  String get dataImportSuccess => 'Arquivos salvos no Memex';

  @override
  String get dataImportOnlyStored =>
      'Arquivos salvos. Nenhuma organização iniciada.';

  @override
  String get dataImportQueued =>
      'O Memex organizará esta importação em segundo plano.';

  @override
  String get dataImportResultTitle => 'Importação concluída';

  @override
  String dataImportResultSummary(Object count) {
    return '$count arquivos foram salvos. Você pode organizá-los agora ou mantê-los como material original.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count itens tinham o mesmo nome e foram renomeados para evitar sobrescrever qualquer coisa.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count itens incomuns do arquivo compactado foram ignorados; o restante foi importado normalmente.';
  }

  @override
  String get dataImportChooseProcessing => 'Organizar estes arquivos';

  @override
  String get dataImportProcessTitle => 'Organizar esta importação?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Você importou $count arquivos. Escolha se o Memex deve organizá-los agora ou apenas manter os originais.';
  }

  @override
  String get dataImportProcessKnowledgeBase =>
      'Organizar na base de conhecimento';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Ideal para documentos, notas, material de projetos e referências. O Memex extrairá informações úteis e as agrupará para uso futuro.';

  @override
  String get dataImportProcessTimelineCards =>
      'Criar registros da linha do tempo';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Ideal para diários, conversas, histórico de atividades e exportações antigas. O Memex transformará conteúdo com data em registros quando fizer sentido.';

  @override
  String get dataImportImpactNone =>
      'O Memex manterá apenas estes arquivos originais. Nenhuma organização por IA será iniciada.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'O Memex lerá estes arquivos e organizará informações úteis de longo prazo na base de conhecimento. Ele não criará registros da linha do tempo de forma proativa.';

  @override
  String get dataImportImpactTimelineCards =>
      'O Memex lerá estes arquivos e criará registros da linha do tempo para eventos ou históricos com data quando apropriado. Ele não organizará a base de conhecimento de forma proativa.';

  @override
  String get dataImportImpactBoth =>
      'O Memex tentará criar registros da linha do tempo e organizar informações reutilizáveis na base de conhecimento. É a melhor opção para um arquivo pessoal completo.';

  @override
  String get dataImportFinish => 'Apenas salvar';
}
