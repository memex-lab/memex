import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsPt = [
  TemplateGallerySection(
    title: 'Em geral',
    items: [
      TemplateGalleryItem(
        label: '1. Cartão Clássico (nota de texto)',
        templateId: 'classic_card',
        title: 'Notas de leitura',
        data: {
          'content':
              'Terminei o capítulo 3 de "Pensando rápido e devagar" em um café hoje. Os exemplos sobre o efeito de ancoragem foram impressionantes e me lembraram como nossa primeira informação pode influenciar silenciosamente todas as decisões posteriores.',
          'tags': ['Leitura', 'Psicologia'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Textual',
    items: [
      TemplateGalleryItem(
        label: '2. Cartão de snippet (snippet de texto)',
        templateId: 'snippet',
        title: 'Cotação técnica',
        data: {
          'text':
              '**“Qualquer tecnologia suficientemente avançada é indistinguível da magia.”**\\n\\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Citar', 'Tecnologia', 'Futuro'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Cartão de artigo (artigo longo)',
        templateId: 'article',
        title: 'O que é experiência de fluxo',
        data: {
          'body':
              '## O que é fluxo?\\n\\nFluxo é um estado psicológico proposto por Mihaly Csikszentmihalyi. Quando você está totalmente imerso em uma tarefa desafiadora, mas alcançável, você perde a noção do tempo e sua atenção fica completamente focada. Isso é fluxo.\\n\\n> Quando as pessoas fazem o que realmente gostam, muitas vezes elas se esquecem de si mesmas.\\n\\nPesquisas mostram que pessoas em estado de fluxo geralmente são mais produtivas e também se sentem mais felizes.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Cartão de Conversa (Conversa)',
        templateId: 'conversation',
        title: 'Conversa com IA',
        data: {
          'messages': [
            {
              'sender': 'Assistente de IA',
              'text':
                  'Você foi muito produtivo hoje! O que você fez?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Concluí o design da arquitetura e a revisão do código. É ótimo.',
              'isMe': true,
            },
            {
              'sender': 'Assistente de IA',
              'text':
                  'Incrível! Lembre-se de descansar cedo esta noite, você tem uma reunião importante amanhã.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Cartão de cotação (cotação)',
        templateId: 'quote',
        title: 'Citação do dia',
        data: {
          'content':
              'Não espere pelo momento perfeito. Aja e deixe o momento se tornar perfeito através da sua ação.',
          'author': 'Napoleon Hill',
          'source': 'Pense e fique rico',
        },
      ),
      TemplateGalleryItem(
        label: '6. Cartão Compacto (linha Compacta)',
        templateId: 'compact_card',
        title: '💧 Ingestão de água',
        wrapped: true,
        data: {
          'details': ['500ml', 'Copa 4', 'Meta de hoje 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visual',
    items: [
      TemplateGalleryItem(
        label: '7. Cartão de instantâneo (foto)',
        templateId: 'snapshot',
        title: 'Momento do crepúsculo',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Bund · Xangai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Cartão da Galeria (Álbum)',
        templateId: 'gallery',
        title: 'Acampamento de fim de semana',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Placa de vídeo (vídeo)',
        templateId: 'video',
        title: 'Registro de vídeo',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Cartão de tela (tela)',
        templateId: 'canvas',
        title: 'Rascunho do mapa mental',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Quantificável',
    items: [
      TemplateGalleryItem(
        label: '11. Cartão Métrico (Métricas)',
        templateId: 'metric',
        title: 'Métricas de saúde',
        data: {
          'items': [
            {
              'title': 'Sono profundo',
              'value': 2.5,
              'unit': 'h',
              'label': 'Noite passada',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Passos',
              'value': 8342,
              'unit': 'steps',
              'label': 'Hoje',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Frequência cardíaca',
              'value': 72,
              'unit': 'bpm',
              'label': 'Resting',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Cartão de classificação (classificação)',
        templateId: 'rating',
        title: 'Classificação do filme',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Visuais de tirar o fôlego e uma visão filosófica do tempo e do amor que perdura por muito tempo depois de assistido.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Cartão de humor (humor)',
        templateId: 'mood',
        title: 'Humor de hoje',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Novo projeto arrancou e a equipa está altamente motivada.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Cartão de Progresso (Progresso)',
        templateId: 'progress',
        title: 'Progresso da meta anual',
        data: {
          'label': 'Plano anual de leitura',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Temporal',
    items: [
      TemplateGalleryItem(
        label: '15. Cartão de Evento (Evento)',
        templateId: 'event',
        title: 'Reunião de revisão de produtos de IA',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Edifício A, Parque Tecnológico, Nova Área de Pudong, Xangai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Cartão de duração (temporizador)',
        templateId: 'duration',
        title: 'Temporizador Pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Cartão de Tarefas (Tarefa)',
        templateId: 'task',
        title: 'Análise completa dos requisitos do produto',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Relatório de análise competitiva', 'completed': true},
            {'title': 'Síntese da entrevista do usuário', 'completed': true},
            {'title': 'Primeiro rascunho do documento de requisitos', 'completed': false},
            {'title': 'Reunião de revisão do PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Cartão de rotina (rastreador de hábitos)',
        templateId: 'routine',
        title: 'Meditação diária',
        data: {
          'habit_name': 'Meditação diária de 10 minutos',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Cartão de procedimento (etapas)',
        templateId: 'procedure',
        title: 'Receita de biscoito amanteigado',
        data: {
          'steps': [
            'Prepare os ingredientes: 200g de farinha para bolo, 3 ovos, 100g de manteiga',
            'Pré-aqueça o forno a 175°C',
            'Bata a manteiga e o açúcar até a mistura ficar clara',
            'Adicione os ovos um por um e misture bem',
            'Peneire a farinha e misture até incorporar',
            'Asse no forno por 25 minutos',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entidades',
    items: [
      TemplateGalleryItem(
        label: '20. Cartão Pessoal (Pessoa)',
        templateId: 'person',
        title: 'Contato',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Gerente de Produto',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Cartão de lugar (lugar)',
        templateId: 'place',
        title: 'Livraria favorita',
        data: {
          'name': 'Livraria Tsutaya · Templo Jing\'an',
          'address': '400 Taixing Rd, distrito de Jing\'an, Xangai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Folha de especificações (especificações do produto)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Série 9',
        data: {
          'subtitle': 'Relógio inteligente',
          'specs': {
            'Mostrar': '1.9" AMOLED',
            'Bateria': 'Duração da bateria de 5 dias',
            'Resistência à água': 'IP68',
            'Peso': '32g',
            'Chip': 'Apple S9',
            'Tamanho': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Cartão de transação (gastos)',
        templateId: 'transaction',
        title: 'Gastos com almoço',
        data: {
          'merchant': 'Casa de macarrão Hutong',
          'amount': '¥ 68.00',
          'location': 'Rua Gulou, Pequim',
          'items': [
            {'name': 'Assinatura Zhajiangmian (grande)', 'amount': '¥ 38'},
            {'name': 'Ovo marinado', 'amount': '¥ 8'},
            {'name': 'Iogurte gelado de Pequim', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Cartão de link (link)',
        templateId: 'link',
        title: 'Documentação flutuante',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsPt = [
  TemplateGalleryItem(
    label: '1. Cartão da linha do tempo (linha do tempo de hoje)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Linha do tempo de hoje',
      'items': [
        {
          'time': '09:00',
          'title': 'Trabalho profundo',
          'content':
              'Concluímos o diagrama de arquitetura v2.0 e corrigimos três bugs críticos.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Almoço e intervalo',
          'content': 'Salada light, seguida de caminhada de 20 minutos.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Para ser preenchido...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Gráfico de bolhas (bolhas de palavras-chave)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Palavras-chave da semana',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Projeto', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Análise baseada em 42 notas',
    },
  ),
  TemplateGalleryItem(
    label: '3. Linha de tendência (gráfico de tendências)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Índice de humor (últimos 7 dias)',
      'top_right_text': 'Média: 7,2',
      'points': [
        {'label': 'ter', 'value': 3.5},
        {'label': 'qua', 'value': 4.0},
        {'label': 'qui', 'value': 5.5},
        {'label': 'sex', 'value': 8.5, 'is_highlight': true},
        {'label': 'Sentado', 'value': 7.0},
        {'label': 'Sol', 'value': 6.5},
        {'label': 'seg', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 pontos', 'subtitle': 'Destaque de sexta-feira'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Gráfico de barras (comparação de barras)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Distribuição do tempo de foco',
      'subtitle': 'Insight do agente: você gastou mais esforço na codificação.',
      'unit': 'h',
      'items': [
        {'label': 'Projeto', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Codificação',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Leitura', 'value': 1.5, 'icon': '📚'},
        {'label': 'Reuniões', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Anel de progresso (progresso da meta)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Meta anual de leitura',
      'subtitle': 'Faltam 12 livros',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Concluído', 'value': 65, 'color': '#6366F1'},
        {'label': 'Restante', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Gráfico de radar (radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Modelo de capacidade',
      'badge': 'Foco mensal',
      'center_value': '78',
      'center_label': 'Pontuação geral',
      'dimensions': [
        {'label': 'Execução', 'value': 80},
        {'label': 'Pensamento', 'value': 60},
        {'label': 'Criatividade', 'value': 70},
        {'label': 'Influência', 'value': 85},
        {'label': 'Aprendizado', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Destaque/Citação (Citação)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'A melhor maneira de prever o futuro é criá-lo.',
      'quote_highlight': 'create it',
      'footer': '-Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composição (Detalhamento)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Composição energética hoje',
      'badge': 'Eficiente',
      'headline_items': [
        {'label': 'Tempo total', 'value': '8.5h'},
        {'label': 'Trabalho profundo', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Codificação', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Reuniões', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Leitura', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Um dia muito produtivo',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contraste/Reenquadramento (Reenquadramento)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Reformulando uma crença',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Pensamento original',
        'content': 'Estou muito ocupado e não tenho tempo para aprender coisas novas.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Nova perspectiva',
        'content':
            'Estar ocupado significa que há muitas oportunidades de aprender através da prática. Posso aprender fazendo.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galeria/Crônica (Galeria)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Trechos de inspiração',
      'headline': '3 Photos',
      'content': 'Algumas inspirações de design capturadas hoje.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Textura'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Cor'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Luz'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Cartão de Mapa (Mapa)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Pegadas',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Uma história de duas cidades',
      'info_detail': 'Viajando entre Pequim e Xangai esta semana',
    },
  ),
  TemplateGalleryItem(
    label: '12. Cartão de Resumo (Resumo)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Semana 4: Avanço e conexão',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'Estado de nível S'},
      'insight_title': 'Visão do agente',
      'insight_content':
          'Esta semana você se concentrou principalmente no desenvolvimento do #AI Agent e bateu um novo recorde de commits de código. Também notei que você marcou um jantar em família na sexta à noite – esse padrão de “trabalhar duro, viver plenamente” é muito saudável.',
      'metrics': [
        {'label': 'Foco', 'value': '32h'},
        {'label': 'Humor', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Notas', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Destaques da semana (3 selecionados)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Lançar'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Jantar em família'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
