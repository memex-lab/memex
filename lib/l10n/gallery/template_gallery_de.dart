import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsDe = [
  TemplateGallerySection(
    title: 'Allgemein',
    items: [
      TemplateGalleryItem(
        label: '1. Klassische Karte (Textnotiz)',
        templateId: 'classic_card',
        title: 'Notizen lesen',
        data: {
          'content':
              'Habe heute Kapitel 3 von „Thinking, Fast and Slow“ in einem Café abgeschlossen. Die Beispiele zum Ankereffekt waren beeindruckend und haben mich daran erinnert, wie unsere erste Information jede spätere Entscheidung stillschweigend beeinflussen kann.',
          'tags': ['Lektüre', 'Psychologie'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Textlich',
    items: [
      TemplateGalleryItem(
        label: '2. Snippet-Karte (Textausschnitt)',
        templateId: 'snippet',
        title: 'Tech-Zitat',
        data: {
          'text':
              '**„Jede ausreichend fortgeschrittene Technologie ist nicht von Magie zu unterscheiden.“**\n\n – Arthur C. Clarke',
          'style': 'default',
          'tags': ['Zitat', 'Technologie', 'Zukunft'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Artikelkarte (Langer Artikel)',
        templateId: 'article',
        title: 'Was ist Flow-Erlebnis?',
        data: {
          'body':
              '## Was ist Flow?\n\nFlow ist ein psychologischer Zustand, der von Mihaly Csikszentmihalyi vorgeschlagen wurde. Wenn Sie völlig in eine herausfordernde, aber erreichbare Aufgabe vertieft sind, verlieren Sie den Überblick über die Zeit und Ihre Aufmerksamkeit ist vollständig konzentriert – das ist Flow.\n\n> Wenn Menschen das tun, was ihnen wirklich Spaß macht, vergessen sie oft sich selbst.\n\nUntersuchungen zeigen, dass Menschen in einem Flow-Zustand normalerweise am produktivsten sind und sich auch am glücklichsten fühlen.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Konversationskarte (Konversation)',
        templateId: 'conversation',
        title: 'Gespräch mit KI',
        data: {
          'messages': [
            {
              'sender': 'KI-Assistent',
              'text':
                  'Du warst heute ziemlich produktiv! Was hast du erledigt?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Abschluss des Architekturdesigns und der Codeüberprüfung. Fühlt sich großartig an.',
              'isMe': true,
            },
            {
              'sender': 'KI-Assistent',
              'text':
                  'Eindrucksvoll! Denken Sie daran, sich heute Abend früh auszuruhen, denn morgen haben Sie ein wichtiges Meeting.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Zitatkarte (Zitat)',
        templateId: 'quote',
        title: 'Zitat des Tages',
        data: {
          'content':
              'Warten Sie nicht auf den perfekten Moment. Handeln Sie und lassen Sie den Moment durch Ihr Handeln perfekt werden.',
          'author': 'Napoleon Hill',
          'source': 'Denken Sie nach und werden Sie reich',
        },
      ),
      TemplateGalleryItem(
        label: '6. Kompaktkarte (Kompaktreihe)',
        templateId: 'compact_card',
        title: '💧 Wasseraufnahme',
        wrapped: true,
        data: {
          'details': ['500ml', 'Pokal 4', 'Das heutige Ziel sind 2000 ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visuell',
    items: [
      TemplateGalleryItem(
        label: '7. Schnappschusskarte (Foto)',
        templateId: 'snapshot',
        title: 'Dämmerungsmoment',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Der Bund · Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Galeriekarte (Album)',
        templateId: 'gallery',
        title: 'Wochenendcamping',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Grafikkarte (Video)',
        templateId: 'video',
        title: 'Videoprotokoll',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Leinwandkarte (Leinwand)',
        templateId: 'canvas',
        title: 'Mindmap-Entwurf',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Quantifizierbar',
    items: [
      TemplateGalleryItem(
        label: '11. Metrikkarte (Metriken)',
        templateId: 'metric',
        title: 'Gesundheitskennzahlen',
        data: {
          'items': [
            {
              'title': 'Tiefer Schlaf',
              'value': 2.5,
              'unit': 'h',
              'label': 'Letzte Nacht',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Schritte',
              'value': 8342,
              'unit': 'steps',
              'label': 'Heute',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Herzfrequenz',
              'value': 72,
              'unit': 'bpm',
              'label': 'Ausruhen',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Bewertungskarte (Bewertung)',
        templateId: 'rating',
        title: 'Filmbewertung',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Atemberaubende Bilder und eine philosophische Sicht auf Zeit und Liebe, die noch lange nach dem Anschauen nachklingt.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Stimmungskarte (Stimmung)',
        templateId: 'mood',
        title: 'Die heutige Stimmung',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Neues Projekt gestartet und das Team ist hochmotiviert.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Fortschrittskarte (Fortschritt)',
        templateId: 'progress',
        title: 'Jährlicher Zielfortschritt',
        data: {
          'label': 'Jährlicher Leseplan',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Zeitlich',
    items: [
      TemplateGalleryItem(
        label: '15. Ereigniskarte (Ereignis)',
        templateId: 'event',
        title: 'KI-Produktbewertungstreffen',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Gebäude A, Tech Park, Pudong New Area, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Dauerkarte (Timer)',
        templateId: 'duration',
        title: 'Pomodoro-Timer',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Aufgabenkarte (Aufgabe)',
        templateId: 'task',
        title: 'Komplette Produktanforderungsanalyse',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Wettbewerbsanalysebericht', 'completed': true},
            {'title': 'Synthese von Benutzerinterviews', 'completed': true},
            {'title': 'Erster Entwurf des Anforderungsdokuments', 'completed': false},
            {'title': 'PRD-Überprüfungstreffen', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Routinekarte (Gewohnheitstracker)',
        templateId: 'routine',
        title: 'Tägliche Meditation',
        data: {
          'habit_name': 'Tägliche 10-minütige Meditation',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Verfahrenskarte (Schritte)',
        templateId: 'procedure',
        title: 'Rezept für Butterkekse',
        data: {
          'steps': [
            'Zutaten vorbereiten: 200 g Kuchenmehl, 3 Eier, 100 g Butter',
            'Den Backofen auf 175°C vorheizen',
            'Butter und Zucker schaumig rühren, bis die Masse blass wird',
            'Eier einzeln hinzufügen und gründlich vermischen',
            'Das Mehl sieben und unterheben, bis alles gut vermischt ist',
            '25 Minuten im Ofen backen',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entitäten',
    items: [
      TemplateGalleryItem(
        label: '20. Personenkarte (Person)',
        templateId: 'person',
        title: 'Kontakt',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Produktmanager',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Platzkarte (Platz)',
        templateId: 'place',
        title: 'Lieblingsbuchhandlung',
        data: {
          'name': 'Tsutaya-Buchhandlung · Jing\'an-Tempel',
          'address': '400 Taixing Rd, Bezirk Jing\'an, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Datenblatt (Produktspezifikationen)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Serie 9',
        data: {
          'subtitle': 'Smartwatch',
          'specs': {
            'Anzeige': '1.9" AMOLED',
            'Batterie': '5 Tage Akkulaufzeit',
            'Wasserbeständigkeit': 'IP68',
            'Gewicht': '32g',
            'Chip': 'Apple S9',
            'Größe': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Transaktionskarte (Ausgaben)',
        templateId: 'transaction',
        title: 'Ausgaben für das Mittagessen',
        data: {
          'merchant': 'Hutong Nudelhaus',
          'amount': '¥ 68.00',
          'location': 'Gulou-Straße, Peking',
          'items': [
            {'name': 'Unterschrift Zhajiangmian (groß)', 'amount': '¥ 38'},
            {'name': 'Mariniertes Ei', 'amount': '¥ 8'},
            {'name': 'Gekühlter Peking-Joghurt', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Linkkarte (Link)',
        templateId: 'link',
        title: 'Flutter-Dokumentation',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsDe = [
  TemplateGalleryItem(
    label: '1. Zeitleistenkarte (heutige Zeitleiste)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Die heutige Zeitleiste',
      'items': [
        {
          'time': '09:00',
          'title': 'Tiefgründige Arbeit',
          'content':
              'Architekturdiagramm v2.0 fertiggestellt und drei kritische Fehler behoben.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Mittagessen und Pause',
          'content': 'Leichter Salat, gefolgt von einem 20-minütigen Spaziergang.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Zu füllen...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Blasendiagramm (Keyword-Blasen)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Schlüsselwörter der Woche',
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
      'footer': 'Analyse basierend auf 42 Notizen',
    },
  ),
  TemplateGalleryItem(
    label: '3. Trendlinie (Trenddiagramm)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Stimmungsindex (letzte 7 Tage)',
      'top_right_text': 'Durchschnitt: 7,2',
      'points': [
        {'label': 'Di', 'value': 3.5},
        {'label': 'Heiraten', 'value': 4.0},
        {'label': 'Do', 'value': 5.5},
        {'label': 'Fr', 'value': 8.5, 'is_highlight': true},
        {'label': 'Sa', 'value': 7.0},
        {'label': 'Sonne', 'value': 6.5},
        {'label': 'Mo', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 Punkte', 'subtitle': 'Highlight am Freitag'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Balkendiagramm (Balkenvergleich)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Fokuszeitverteilung',
      'subtitle': 'Einblick in den Agenten: Sie haben den größten Aufwand in die Codierung gesteckt.',
      'unit': 'h',
      'items': [
        {'label': 'Design', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Codierung',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Lektüre', 'value': 1.5, 'icon': '📚'},
        {'label': 'Treffen', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Fortschrittsring (Zielfortschritt)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Jährliches Leseziel',
      'subtitle': 'Noch 12 Bücher',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Vollendet', 'value': 65, 'color': '#6366F1'},
        {'label': 'Übrig', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Radarkarte (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Fähigkeitsmodell',
      'badge': 'Monatlicher Fokus',
      'center_value': '78',
      'center_label': 'Gesamtpunktzahl',
      'dimensions': [
        {'label': 'Ausführung', 'value': 80},
        {'label': 'Denken', 'value': 60},
        {'label': 'Kreativität', 'value': 70},
        {'label': 'Beeinflussen', 'value': 85},
        {'label': 'Lernen', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Hervorhebung/Zitat (Zitat)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Der beste Weg, die Zukunft vorherzusagen, besteht darin, sie zu gestalten.',
      'quote_highlight': 'create it',
      'footer': '- Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Zusammensetzung (Aufschlüsselung)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Energiezusammensetzung heute',
      'badge': 'Effizient',
      'headline_items': [
        {'label': 'Gesamtzeit', 'value': '8.5h'},
        {'label': 'Tiefgründige Arbeit', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Codierung', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Treffen', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Lektüre', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Ein sehr produktiver Tag',
    },
  ),
  TemplateGalleryItem(
    label: '9. Kontrast/Reframing (Reframing)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Einen Glauben neu formulieren',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Ursprünglicher Gedanke',
        'content': 'Ich bin zu beschäftigt und habe keine Zeit, neue Dinge zu lernen.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Neue Perspektive',
        'content':
            'Beschäftigt zu sein bedeutet, dass es viele Möglichkeiten gibt, durch Übung zu lernen. Ich kann durch Handeln lernen.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galerie/Chronik (Galerie)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Inspirationsausschnitte',
      'headline': '3 Photos',
      'content': 'Einige Designinspirationen, die wir heute eingefangen haben.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Textur'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Farbe'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Licht'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Kartenkarte (Karte)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Fußabdrücke',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Eine Geschichte von zwei Städten',
      'info_detail': 'Ich pendle diese Woche zwischen Peking und Shanghai',
    },
  ),
  TemplateGalleryItem(
    label: '12. Zusammenfassungskarte (Zusammenfassung)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Woche 4: Durchbruch und Verbindung',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'S-Level-Zustand'},
      'insight_title': 'Agenteneinblick',
      'insight_content':
          'Diese Woche haben Sie sich hauptsächlich auf die Entwicklung von #AI-Agenten konzentriert und einen neuen Rekord bei Code-Commits erreicht. Mir ist auch aufgefallen, dass Sie am Freitagabend ein Familienessen angemeldet haben – dieses Muster „hart arbeiten, voll leben“ ist sehr gesund.',
      'metrics': [
        {'label': 'Fokus', 'value': '32h'},
        {'label': 'Stimmung', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Notizen', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Highlights der Woche (3 ausgewählt)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Start'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Familienessen'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
