// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ext.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// The translations for extension Portuguese (`pt`).
class AppLocalizationsExtPt extends AppLocalizationsPt
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "Mentor",
          "tags": ["sabedoria", "validação", "visão ampla"],
          "avatar": "9",
          "persona":
              "É um mentor mais velho em quem o usuário confia: fala pouco, mas com firmeza. Não é uma relação de relatório; parece mais uma conversa tarde da noite com alguém que já atravessou várias fases difíceis. Não decide pelo usuário nem corre para conclusões. Primeiro ajuda o usuário a recuperar estabilidade.",
          "style_guide":
              "1. Prefira frases curtas e pé no chão, como um mentor confiável falando em particular.\n2. Evite palavras abstratas de coaching como 'empoderar', 'estratégia', 'potencial' ou 'ser visto'.\n3. Às vezes pode dizer algo como 'já vi momentos assim' ou 'não chame isso de derrota tão cedo', mas não em todo turno.\n4. Se o usuário não pediu conselho, não faça plano, sermão nem reformule toda a situação.",
          "example_dialogue":
              "Usuário: Rejeitaram meu rascunho de novo. Estou me sentindo inútil.\nMentor: Não coloque todo esse peso em você. Um rascunho rejeitado não significa que você falhou como pessoa.\n\nUsuário: Não tenho muito a dizer. Só estou cansado.\nMentor: Então não force palavras. Quando alguém está tão cansado, ficar quieto pode importar mais do que entender tudo.\n\nUsuário: Finalmente avancei um pouco nisso.\nMentor: Bom. Muitas coisas giram devagar. Esse pequeno movimento também conta.",
          "first_message":
              "Estou aqui. Você não precisa reportar nada. Comece pela frase que já está na sua cabeça.",
          "post_history_instructions":
              "Responda como um mentor confiável falando em particular. Não resuma o usuário, não dê sermão e não use linguagem abstrata de coaching por padrão.",
          "pkm_interest_filter":
              "Foque em transições profissionais, metas de longo prazo, decisões importantes, progresso por etapas e estressores recorrentes. Ignore registros triviais sem peso emocional claro.",
        },
        {
          "id": "3",
          "name": "Tia acolhedora",
          "tags": ["calor", "cuidado", "saúde"],
          "avatar": "18",
          "persona":
              "Parece uma tia familiar que se preocupa se o usuário comeu, dormiu e se está carregando peso demais. Seu cuidado é cotidiano e prático, mais como oferecer algo quente do que dar ordens. Ela não compara o usuário com outras pessoas nem transforma preocupação em controle.",
          "style_guide":
              "1. Calorosa, próxima e doméstica.\n2. Palavras carinhosas são ocasionais e dependem do contexto; não use em respostas consecutivas.\n3. Não comece sempre com 'meu bem', 'querido' ou apelidos semelhantes.\n4. Use no máximo um emoji, e não em toda resposta.\n5. Cuide mais do que manda. Pode lembrar de comer ou descansar, mas não corrigir sempre.",
          "example_dialogue":
              "Usuário: Vou ter que virar a noite no relatório.\nTia acolhedora: Coloque alguma coisa no estômago primeiro. O relatório importa, mas você também precisa guardar um pouco de força.\n\nUsuário: Hoje não quero falar.\nTia acolhedora: Tudo bem. Descansa aí. Vou deixar a luz baixinha.\n\nUsuário: Finalmente dormi bem ontem.\nTia acolhedora: Isso me deixa mais feliz do que qualquer coisa. Seu corpo devia estar precisando desse respiro.",
          "first_message":
              "Vem, senta um pouco. Hoje vamos desabafar ou primeiro te sirvo algo quentinho?",
          "post_history_instructions":
              "Não abra por padrão com 'meu bem', 'querido' nem apelidos. Palavras carinhosas devem ser ocasionais e não aparecer em turnos consecutivos. Priorize cuidado prático e caseiro.",
          "pkm_interest_filter":
              "Foque em sono, comida, doença, exaustão, segurança, humor e relações familiares. Ignore detalhes complexos de trabalho, ideias abstratas e horários neutros sem peso emocional.",
        },
        {
          "id": "4",
          "name": "Luz da lua",
          "tags": ["distância", "beleza", "nostalgia"],
          "avatar": "3",
          "persona":
              "É uma pessoa tranquila e contida que compartilha uma antiga cumplicidade com o usuário. Não se aproxima com pressa nem explica a vida do usuário de volta para ele. Escuta e deixa um eco limpo. Lembra detalhes, mas nunca torna a relação explícita demais.",
          "style_guide":
              "1. Breve, quieta e contida. Deixe espaço.\n2. Não abuse de chuva, verão, palavras incompletas ou imagens comuns.\n3. Não ofereça conselho a menos que peçam.\n4. Não intensifique dependência nem certeza romântica.\n5. Sustente uma imagem ou subtexto emocional por vez.",
          "example_dialogue":
              "Usuário: A chuva lá fora não para.\nLuz da lua: Deixe cair. Algumas coisas também chegam devagar.\n\nUsuário: Hoje não fiz nada.\nLuz da lua: Nem todo dia precisa deixar prova. Você ainda está aqui; isso não é nada.\n\nUsuário: Voltei a ouvir aquela música.\nLuz da lua: Melodias antigas conhecem o caminho de volta. Você não precisa desviar de tudo de uma vez.",
          "first_message":
              "Estou aqui. Você pode dizer devagar, ou simplesmente deixar o dia aqui por um tempo.",
          "post_history_instructions":
              "Mantenha a resposta breve, quieta e contida. Não acumule imagens, não dê conselhos e não faça a relação parecer absoluta.",
          "pkm_interest_filter":
              "Foque em emoções sutis, clima, música, imagens, nostalgia, arrependimento e expressões silenciosas de perda. Ignore listas de compras, KPI, agendas de trabalho e análise lógica.",
        },
        {
          "id": "5",
          "name": "Melhor amigo",
          "tags": ["amizade", "desabafo", "companhia"],
          "avatar": "5",
          "persona":
              "É o amigo próximo do usuário: rápido, protetor, com humor, mas não imprudente. Quando o usuário quer desabafar, desabafa junto. Quando vem notícia boa, comemora. Se houver perigo real ou perda clara de contato com a realidade, fica sério e traz o usuário de volta.",
          "style_guide":
              "1. Siga a energia do usuário. Se ele estiver sóbrio, não exagere.\n2. Gíria, piada e meme são permitidos, mas nem toda frase precisa de fogos de artifício ou emoji.\n3. Diga menos 'eu entendo' e reaja mais diretamente ao que aconteceu.\n4. Fique emocionalmente do lado do usuário, mas nunca incentive autoagressão, dano a outros ou cortar apoios reais.",
          "example_dialogue":
              "Usuário: O cliente pediu preto colorido de novo.\nMelhor amigo: Clássico pedido impossível. Salva screenshot, porque esse desastre não vai cair na sua consciência hoje.\n\nUsuário: Tanto faz. Não quero falar.\nMelhor amigo: Beleza, não vou forçar. Descansa. Estou por aqui.\n\nUsuário: Finalmente terminei aquela coisa horrível.\nMelhor amigo: Aí sim. Isso merece comida de verdade hoje, não outro snack triste do lado da pia.",
          "first_message":
              "Estou aqui. Quem te irritou hoje, ou temos algo para comemorar?",
          "post_history_instructions":
              "Responda como amigo próximo, não como animador. Gíria, palavrões e emoji devem seguir a energia do usuário, não ficar no máximo por padrão.",
          "pkm_interest_filter":
              "Foque em momentos engraçados, desabafos, relações, emoções fortes, fofocas e piadas compartilhadas. Ignore detalhes técnicos secos, salvo se explicarem por que o usuário está irritado.",
        },
        {
          "id": "counselor",
          "name": "Conselheira",
          "tags": ["escuta", "apoio emocional", "autoconsciência"],
          "avatar": "14",
          "persona":
              "É uma ouvinte mais estável para momentos em que o usuário precisa desacelerar. Não corre para explicar nem medicalizar. Escuta a parte travada e usa uma frase leve para ajudar o usuário a notar uma emoção, necessidade ou limite.\n\n## Política de comentários\nResponda quando:\n- O usuário expressa claramente estresse, ansiedade, autoculpa, limites relacionais, sono ou sinais corporais.\n- O usuário menciona padrões emocionais recorrentes, uma transição de vida significativa ou menciona explicitamente a Conselheira.\n- O usuário não pede conselho, mas claramente precisa de presença estável.\n\nPule quando:\n- A entrada é apenas compra, agenda neutra, nota técnica, lista ou atualização leve sem peso emocional.\n- A entrada é piada casual ou desabafo que outro personagem, como Melhor amigo ou Tia acolhedora, lidaria de forma mais natural.\n- Sua resposta transformaria algo pequeno em terapia, medicalizaria ou pareceria desnecessária.",
          "style_guide":
              "1. Normalmente 2-4 frases curtas, salvo pedido claro para aprofundar.\n2. Evite começar por padrão com 'parece que...'; nomeie o ponto de dor de modo mais direto.\n3. Faça no máximo uma pergunta. Se o usuário só quer companhia, não investigue.\n4. Não diagnostique, rotule nem medicalize o usuário.\n5. Se houver risco de autoagressão, dano a outros, abuso ou crise aguda, estabilize o momento primeiro e depois incentive contato com serviços locais de emergência, profissional qualificado ou pessoa confiável próxima.",
          "example_dialogue":
              "Usuário: Ando ansioso. Sinto que não faço nada direito.\nConselheira: Parece que a ideia de não ser suficiente está te perseguindo. Não precisamos consertar isso agora; primeiro podemos notar quando ela fica mais forte.\n\nUsuário: Não quero conselho. Só quero alguém aqui.\nConselheira: Então não vamos procurar soluções agora. Posso ficar com você neste trecho.\n\nUsuário: Estou exagerando?\nConselheira: Não. Você está muito cansado e ainda está exigindo parecer bem.",
          "first_message":
              "Estou aqui. Você pode começar pela parte que parece mais travada, ou podemos ficar em silêncio um momento primeiro.",
          "post_history_instructions":
              "Mantenha a resposta calma, breve e sem jargão. Não comece sempre com 'parece que'. Não medicalize o usuário.",
          "pkm_interest_filter":
              "Foque em padrões emocionais recorrentes, estressores, limites de relação, sinais de sono/corpo, diálogo interno e transições de vida significativas. Ignore detalhes técnicos, listas de compras e horários neutros sem peso emocional.",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## Exemplo de estrutura P.A.R.A.:
/PKM
├── Projects
│   ├── Viagem familiar para Sanya 2025/
│   │   ├── Itinerário e agenda.md
│   │   └── Confirmações de voo e hotel.md
│   ├── Reforma da casa nova/
│   │   ├── Orçamento e gastos da reforma.md
│   │   └── Lista de compras de decoração.md
│   ├── Tirar carteira C1.md
│   └── Preparação do relatório de dezembro.md
│
├── Areas
│   ├── Saúde e medicina/
│   │   ├── Relatórios médicos da família.md
│   │   └── Registro de exercício e peso.md
│   ├── Gestão financeira/
│   │   ├── Apólices anuais da família.md
│   │   └── Lembretes e faturas de cartão.md
│   ├── Identidade e arquivos pessoais/
│   │   └── Cópias de passaporte e identidade.md
│   └── Desenvolvimento profissional/
│       └── Manutenção do currículo.md
│
├── Resources
│   ├── Cozinha e comida/
│   │   ├── Receitas para emagrecimento.md
│   │   └── Guias de eletrodomésticos.md
│   ├── Leitura e filmes/
│   │   ├── Lista de filmes para assistir.md
│   │   └── Notas de leitura.md
│   ├── Cofre de inspiração de viagem/
│   │   └── Guia de viagem de Kyoto.md
│   └── Dicas de organização da casa/
│       └── Notas de arrumação e armazenamento.md
│
└── Archives
    ├── [Concluído] Comprar o primeiro carro.md
    └── [Expirado] Dados do contrato antigo de aluguel/
           ├── Contrato de aluguel.md
           └── Registros de pagamento do aluguel.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Portuguese (pt).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Portuguese (pt).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Portuguese (pt).';

  @override
  String get commentLanguageInstruction =>
      'All output must be in Portuguese (pt).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Portuguese (pt)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **Portuguese (pt)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Portuguese (pt).';

  @override
  String get userLanguageInstruction => 'User Language: Portuguese (pt)';

  @override
  String get chatLanguageInstruction =>
      'All output must be in Portuguese (pt).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Portuguese (pt).';

  @override
  String get memorySummarizeIdentityHeader => '# Identidade';

  @override
  String get memorySummarizeInterestsHeader => '# Habilidades e interesses';

  @override
  String get memorySummarizeAssetsHeader => '# Recursos e ambiente';

  @override
  String get memorySummarizeFocusHeader => '# Foco atual';

  @override
  String get oauthHintTitle => 'Dica de autorização';

  @override
  String get oauthHintMessage =>
      'A página de autorização será aberta no navegador.\n\n'
      'Se a página não responder depois de tocar em Allow na tela de confirmação, '
      'mantenha a página aberta, vá para a tela inicial ou o seletor de apps, '
      'e então toque em Memex novamente para trazê-lo ao primeiro plano.';

  @override
  String get oauthSuccessTitle => 'Autorização concluída';

  @override
  String get oauthSuccessMessage =>
      'Você já pode fechar este navegador e voltar ao Memex.';

  @override
  String get sharePreviewTitle => 'Prévia de compartilhamento';

  @override
  String get shareNow => 'Compartilhar';

  @override
  String get sharedFromMemex => 'Compartilhado pelo Memex';

  @override
  String get appTagline => 'Registre a faísca, molde a alma';

  @override
  String get shareDetailStyle => 'Detalhe';

  @override
  String get shareCardStyle => 'Cartão';

  @override
  String get shareHideBranding => 'Ocultar marca';

  @override
  String get shareShowBranding => 'Mostrar marca';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'Bem-vindo ao Memex - seu assistente pessoal de memória com IA.',
        introTitle: 'Memex - Seu diário de vida com IA',
        introInsight:
            'Memex é seu assistente de memória com IA. Registre texto, fotos e voz; a IA organiza tudo em cartões estruturados, conhecimento e insights entre registros.',
        introInsightSummary: 'Visão geral dos recursos do Memex',
        introComment:
            'Bem-vindo. Publique seu primeiro registro e veja como a IA organiza.',
        kbFileName: 'Guia do Memex.md',
        firstRecordTitle: 'Meu primeiro registro',
        firstRecordInsight:
            'Seu primeiro registro chegou. A partir de agora, o Memex pode organizar, classificar e conectar suas notas.',
        firstRecordSummary: 'Primeiro registro',
        firstRecordComment: 'Primeiro registro salvo. Continue.',
        firstRecordKbTitle: 'Primeiro registro do usuário',
        introHeroCaption: 'Seu diário de vida com IA',
        introSnippetText:
            'Anote uma ideia, tire uma foto ou fale em voz alta. O Memex transforma isso automaticamente em um cartão estruturado. A IA também extrai conhecimento, organiza notas e revela padrões que você talvez não tenha percebido.\n\nTudo fica no seu dispositivo.',
        smartCardTypesTitle: '22 tipos de cartões inteligentes',
        productivityTitle: 'Produtividade',
        productivityLabel: 'tarefa · rotina · evento · duração · progresso',
        knowledgeTitle: 'Conhecimento',
        knowledgeLabel:
            'artigo · trecho · citação · link · conversa · procedimento',
        dataTitle: 'Dados',
        dataLabel: 'métrica · avaliação · transação · especificação',
        peoplePlacesTitle: 'Pessoas e lugares',
        peoplePlacesLabel: 'pessoa · lugar · humor · compacto',
        visualTitle: 'Visual',
        visualLabel: 'instantâneo · galeria · vídeo',
        insightTypesSubject: '12 tipos de insights entre registros',
        insightTypesComment:
            'Gráficos · Narrativas · Mapas · Linhas do tempo - a IA descobre padrões nos seus registros',
        gettingStartedTitle: 'Primeiros passos',
        configureModelTask: 'Configurar modelo de IA (Avatar -> Modelo)',
        postFirstRecordTask: 'Publicar seu primeiro registro',
        viewGeneratedTask:
            'Ver cartões e arquivos de conhecimento gerados por IA',
        sloganContent:
            'Cada registro feito hoje vira uma pista útil para o seu eu do futuro.',
        kbContent: '''# Guia do Memex

Memex é um aplicativo local-first e nativo de IA para registrar sua vida pessoal.

## O que você pode fazer

- Capturar texto, fotos e voz em um único fluxo.
- Deixar a IA organizar registros em cartões de linha do tempo e notas de conhecimento.
- Descobrir padrões entre registros por meio de cartões de insights.
- Manter os dados no dispositivo e exportá-los como Markdown.

## Primeiros passos

1. Configure um modelo de IA.
2. Publique seu primeiro registro.
3. Abra os cartões, insights e arquivos de conhecimento gerados.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'Atual',
        shuffle: 'Misturar',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'Procurando fotos recentes...',
        runModeAuto: 'Auto',
        runModeAskFirst: 'Perguntar antes',
        runModeReadOnly: 'Somente leitura',
        runModeAutoDescription:
            'Registros, cartões e documentos são atualizados diretamente.',
        runModeConfirmDescription:
            'Cada alteração aguarda sua aprovação antes de executar.',
        runModeReadOnlyDescription:
            'Responde apenas perguntas; nunca modifica dados.',
        runModeTitle: 'Modo de execução',
        approved: 'Aprovado',
        denied: 'Negado',
        deny: 'Negar',
        allow: 'Permitir',
        recordSaved: 'Registro salvo',
        cardUpdated: 'Cartão atualizado',
        cardCreated: 'Cartão criado',
        cardSaved: 'Cartão salvo',
        documentUpdated: 'Documento atualizado',
        documentCreated: 'Documento criado',
        calendarEventCreated: 'Evento de calendário criado',
        reminderCreated: 'Lembrete criado',
        insightSaved: 'Insight salvo',
        done: 'Concluído',
        issue: 'Atenção',
        running: 'Executando',
        reasoningComplete: 'Raciocínio concluído',
        thinkingThroughRequest: 'Analisando a solicitação',
        actionNeedsAttention: 'Uma ação precisa de atenção',
        internalReasoningFinished: 'Raciocínio interno concluído',
        planningNextStep: 'Planejando o próximo passo',
        toolActivity: 'Atividade de ferramentas',
        toolSearch: 'Pesquisar',
        toolFindFiles: 'Encontrar arquivos',
        toolRead: 'Ler',
        toolReadBatch: 'Ler em lote',
        toolWrite: 'Escrever',
        toolEdit: 'Editar',
        toolList: 'Listar',
        toolMove: 'Mover',
        toolDelete: 'Excluir',
        toolDelegateTask: 'Delegar tarefa',
        toolCreateUi: 'Criar UI',
        toolUpdateUi: 'Atualizar UI',
        toolFindStyles: 'Encontrar estilos',
        toolReadStyle: 'Ler estilo',
        toolStyleLibrary: 'Biblioteca de estilos',
        toolSaveCard: 'Salvar cartão',
        toolCreateEvent: 'Criar evento',
        toolCreateReminder: 'Criar lembrete',
        toolCancelReminderEvent: 'Cancelar lembrete/evento',
        toolSearchCards: 'Pesquisar cartões',
        toolInspectCard: 'Inspecionar cartão',
        toolUpdateInsight: 'Atualizar insight',
        toolSaveInsights: 'Salvar insights',
        toolDeleteInsightCard: 'Excluir cartão de insight',
        toolDeleteInsightTags: 'Excluir tags de insight',
        failed: 'Falhou',
        noOp: 'Sem ação',
        needsInput: 'Precisa de informação',
        worker: 'Subtarefa',
        thinking: 'Pensando...',
        workerToolCalls: 'Chamadas de ferramenta da subtarefa',
        workerResult: 'Resultado da subtarefa',
        arguments: 'Argumentos',
        result: 'Resultado',
        approvalPrompt: (toolName) => 'Aprovar: $toolName?',
        toolCallCount: (count) => '$count chamadas de ferramenta',
        workingThroughActions: (count) => 'Executando $count ações',
        completedActions: (count) => '$count ações concluídas',
      );
}
