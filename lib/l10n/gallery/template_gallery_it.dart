import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsIt = [
  TemplateGallerySection(
    title: 'Generale',
    items: [
      TemplateGalleryItem(
        label: '1. Scheda classica (Nota di testo)',
        templateId: 'classic_card',
        title: 'Note di lettura',
        data: {
          'content':
              'Oggi ho finito il capitolo 3 di "Pensieri lenti e veloci" in un caffè. Gli esempi sull\'effetto ancoraggio erano notevoli e mi hanno ricordato come la prima informazione possa influenzare silenziosamente ogni decisione successiva.',
          'tags': ['Lettura', 'Psicologia'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Testuale',
    items: [
      TemplateGalleryItem(
        label: '2. Scheda frammento (Estratto di testo)',
        templateId: 'snippet',
        title: 'Citazione tecnologica',
        data: {
          'text':
              '**“Ogni tecnologia sufficientemente avanzata è indistinguibile dalla magia.”**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Citazione', 'Tecnologia', 'Futuro'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Scheda articolo (Articolo lungo)',
        templateId: 'article',
        title: 'Che cos\'è l\'esperienza di flusso',
        data: {
          'body':
              '## Che cos\'è il flusso?\n\nIl flusso è uno stato psicologico proposto da Mihaly Csikszentmihalyi. Quando sei completamente immerso in un compito impegnativo ma realizzabile, perdi la cognizione del tempo e la tua attenzione è totalmente concentrata: questo è il flusso.\n\n> Quando le persone fanno ciò che amano davvero, spesso dimenticano se stesse.\n\nLe ricerche mostrano che le persone in stato di flusso sono generalmente più produttive e si sentono anche più felici.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Scheda conversazione (Conversazione)',
        templateId: 'conversation',
        title: 'Conversazione con l\'IA',
        data: {
          'messages': [
            {
              'sender': 'Assistente IA',
              'text': 'Sei stato molto produttivo oggi! Che cosa hai fatto?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Ho completato la progettazione dell\'architettura e la revisione del codice. È una bella sensazione.',
              'isMe': true,
            },
            {
              'sender': 'Assistente IA',
              'text':
                  'Fantastico! Ricordati di riposare presto stasera: domani hai una riunione importante.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Scheda citazione (Citazione)',
        templateId: 'quote',
        title: 'Citazione del giorno',
        data: {
          'content':
              'Non aspettare il momento perfetto. Agisci e lascia che il momento diventi perfetto grazie alla tua azione.',
          'author': 'Napoleon Hill',
          'source': 'Pensa e arricchisci te stesso',
        },
      ),
      TemplateGalleryItem(
        label: '6. Scheda compatta (Riga compatta)',
        templateId: 'compact_card',
        title: '💧 Acqua bevuta',
        wrapped: true,
        data: {
          'details': ['500ml', 'Bicchiere 4', 'Obiettivo di oggi: 2000 ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visivo',
    items: [
      TemplateGalleryItem(
        label: '7. Scheda istantanea (Foto)',
        templateId: 'snapshot',
        title: 'Momento al tramonto',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Il Bund · Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Scheda galleria (Album)',
        templateId: 'gallery',
        title: 'Campeggio nel fine settimana',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Scheda video (Video)',
        templateId: 'video',
        title: 'Diario video',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Scheda tela (Tela)',
        templateId: 'canvas',
        title: 'Bozza della mappa mentale',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Quantificabile',
    items: [
      TemplateGalleryItem(
        label: '11. Scheda metriche (Metriche)',
        templateId: 'metric',
        title: 'Metriche di salute',
        data: {
          'items': [
            {
              'title': 'Sonno profondo',
              'value': 2.5,
              'unit': 'h',
              'label': 'La notte scorsa',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Passi',
              'value': 8342,
              'unit': 'steps',
              'label': 'Oggi',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Frequenza cardiaca',
              'value': 72,
              'unit': 'bpm',
              'label': 'A riposo',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Scheda valutazione (Valutazione)',
        templateId: 'rating',
        title: 'Valutazione del film',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Immagini mozzafiato e una riflessione filosofica sul tempo e sull\'amore che resta a lungo dopo la visione.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Scheda umore (Umore)',
        templateId: 'mood',
        title: 'Umore di oggi',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Il nuovo progetto è iniziato e il team è molto motivato.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Scheda progresso (Progresso)',
        templateId: 'progress',
        title: 'Avanzamento dell\'obiettivo annuale',
        data: {
          'label': 'Piano di lettura annuale',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Temporale',
    items: [
      TemplateGalleryItem(
        label: '15. Scheda evento (Evento)',
        templateId: 'event',
        title: 'Riunione di revisione del prodotto IA',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location':
              'Edificio A, Parco tecnologico, Nuova area di Pudong, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Scheda durata (Timer)',
        templateId: 'duration',
        title: 'Timer Pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Scheda attività (Attività)',
        templateId: 'task',
        title: 'Completare l\'analisi dei requisiti del prodotto',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Rapporto di analisi competitiva', 'completed': true},
            {
              'title': 'Sintesi delle interviste agli utenti',
              'completed': true
            },
            {
              'title': 'Prima bozza del documento dei requisiti',
              'completed': false
            },
            {'title': 'Riunione di revisione del PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Scheda routine (Monitoraggio abitudini)',
        templateId: 'routine',
        title: 'Meditazione quotidiana',
        data: {
          'habit_name': 'Meditazione quotidiana di 10 minuti',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Scheda procedura (Passaggi)',
        templateId: 'procedure',
        title: 'Ricetta dei biscotti al burro',
        data: {
          'steps': [
            'Preparare gli ingredienti: 200 g di farina per dolci, 3 uova, 100 g di burro',
            'Preriscaldare il forno a 175 °C',
            'Lavorare burro e zucchero finché il composto diventa chiaro',
            'Aggiungere le uova una alla volta e mescolare bene',
            'Setacciare la farina e incorporarla fino ad amalgamare il composto',
            'Cuocere in forno per 25 minuti',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entità',
    items: [
      TemplateGalleryItem(
        label: '20. Scheda persona (Persona)',
        templateId: 'person',
        title: 'Contatto',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Responsabile di prodotto',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Scheda luogo (Luogo)',
        templateId: 'place',
        title: 'Libreria preferita',
        data: {
          'name': 'Libreria Tsutaya · Tempio Jing’an',
          'address': '400 Taixing Rd, distretto di Jing’an, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Scheda tecnica (Specifiche del prodotto)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Series 9',
        data: {
          'subtitle': 'Smartwatch',
          'specs': {
            'Schermo': '1.9" AMOLED',
            'Batteria': 'Autonomia di 5 giorni',
            'Resistenza all\'acqua': 'IP68',
            'Peso': '32g',
            'Chip': 'Apple S9',
            'Dimensioni': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Scheda transazione (Spesa)',
        templateId: 'transaction',
        title: 'Spesa per il pranzo',
        data: {
          'merchant': 'Hutong Noodle House',
          'amount': '¥ 68.00',
          'location': 'Via Gulou, Pechino',
          'items': [
            {'name': 'Zhajiangmian della casa (grande)', 'amount': '¥ 38'},
            {'name': 'Uovo marinato', 'amount': '¥ 8'},
            {'name': 'Yogurt freddo di Pechino', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Scheda link (Link)',
        templateId: 'link',
        title: 'Documentazione di Flutter',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsIt = [
  TemplateGalleryItem(
    label: '1. Scheda timeline (Timeline di oggi)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Timeline di oggi',
      'items': [
        {
          'time': '09:00',
          'title': 'Lavoro profondo',
          'content':
              'Completato il diagramma dell\'architettura v2.0 e corretti tre bug critici.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Pranzo e pausa',
          'content':
              'Insalata leggera, seguita da una passeggiata di 20 minuti.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Da compilare...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Grafico a bolle (Bolle di parole chiave)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Parole chiave della settimana',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Design', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Analisi basata su 42 note',
    },
  ),
  TemplateGalleryItem(
    label: '3. Linea di tendenza (Grafico di tendenza)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Indice dell\'umore (ultimi 7 giorni)',
      'top_right_text': 'Media: 7,2',
      'points': [
        {'label': 'Mar', 'value': 3.5},
        {'label': 'Mer', 'value': 4.0},
        {'label': 'Gio', 'value': 5.5},
        {'label': 'Ven', 'value': 8.5, 'is_highlight': true},
        {'label': 'Sab', 'value': 7.0},
        {'label': 'Dom', 'value': 6.5},
        {'label': 'Lun', 'value': 7.5},
      ],
      'highlight_info': {
        'title': '8,5 punti',
        'subtitle': 'Momento saliente di venerdì'
      },
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Grafico a barre (Confronto a barre)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Distribuzione del tempo di concentrazione',
      'subtitle':
          'Insight dell\'agente: hai dedicato il massimo impegno alla programmazione.',
      'unit': 'h',
      'items': [
        {'label': 'Design', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Programmazione',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Lettura', 'value': 1.5, 'icon': '📚'},
        {'label': 'Riunioni', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Anello di avanzamento (Progresso dell\'obiettivo)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Obiettivo annuale di lettura',
      'subtitle': '12 libri rimanenti',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Completato', 'value': 65, 'color': '#6366F1'},
        {'label': 'Rimanente', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Grafico radar (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Modello delle capacità',
      'badge': 'Focus mensile',
      'center_value': '78',
      'center_label': 'Punteggio complessivo',
      'dimensions': [
        {'label': 'Esecuzione', 'value': 80},
        {'label': 'Pensiero', 'value': 60},
        {'label': 'Creatività', 'value': 70},
        {'label': 'Influenza', 'value': 85},
        {'label': 'Apprendimento', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Momento saliente/Citazione (Citazione)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Il modo migliore per prevedere il futuro è crearlo.',
      'quote_highlight': 'create it',
      'footer': '- Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composizione (Suddivisione)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Composizione dell\'energia di oggi',
      'badge': 'Efficiente',
      'headline_items': [
        {'label': 'Tempo totale', 'value': '8.5h'},
        {'label': 'Lavoro profondo', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Programmazione', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Riunioni', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Lettura', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Una giornata molto produttiva',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contrasto/Riformulazione (Riformulazione)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Riformulare una convinzione',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Pensiero originale',
        'content':
            'Sono troppo impegnato e non ho tempo per imparare cose nuove.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Nuova prospettiva',
        'content':
            'Essere impegnati significa avere molte opportunità di imparare con la pratica. Posso imparare facendo.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galleria/Cronaca (Galleria)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Frammenti di ispirazione',
      'headline': '3 Photos',
      'content': 'Alcune ispirazioni di design raccolte oggi.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Texture'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Colore'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Luce'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Scheda mappa (Mappa)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Tracce',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Storia di due città',
      'info_detail': 'Questa settimana in viaggio tra Pechino e Shanghai',
    },
  ),
  TemplateGalleryItem(
    label: '12. Scheda riepilogo (Riepilogo)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Settimana 4: svolta e connessione',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'Stato di livello S'},
      'insight_title': 'Insight dell\'agente',
      'insight_content':
          'Questa settimana ti sei concentrato soprattutto sullo sviluppo di #AI Agent e hai stabilito un nuovo record di commit. Ho anche notato che venerdì sera hai registrato una cena in famiglia: questo modello di “lavorare sodo, vivere pienamente” è molto salutare.',
      'metrics': [
        {'label': 'Focus', 'value': '32h'},
        {'label': 'Umore', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Note', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Momenti salienti della settimana (3 selezionati)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Lancio'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Cena in famiglia'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
