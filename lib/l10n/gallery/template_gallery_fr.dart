import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsFr = [
  TemplateGallerySection(
    title: 'Général',
    items: [
      TemplateGalleryItem(
        label: '1. Carte classique (Note textuelle)',
        templateId: 'classic_card',
        title: 'Notes de lecture',
        data: {
          'content':
              'J\'ai terminé le chapitre 3 de "Penser, vite et lentement" dans un café aujourd\'hui. Les exemples sur l\'effet d\'ancrage étaient impressionnants et m\'ont rappelé à quel point notre première information peut discrètement influencer chaque décision ultérieure.',
          'tags': ['En lisant', 'Psychologie'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Textuel',
    items: [
      TemplateGalleryItem(
        label: '2. Carte d\'extrait (extrait de texte)',
        templateId: 'snippet',
        title: 'Devis technique',
        data: {
          'text':
              '** « Toute technologie suffisamment avancée ne peut être distinguée de la magie. » **\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Citation', 'Technologie', 'Avenir'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Fiche article (article long)',
        templateId: 'article',
        title: 'Qu\'est-ce que l\'expérience de flux',
        data: {
          'body':
              '## Qu\'est-ce que le flow ?\n\nLe flow est un état psychologique proposé par Mihaly Csikszentmihalyi. Lorsque vous êtes entièrement immergé dans une tâche difficile mais réalisable, vous perdez la notion du temps et votre attention est complètement concentrée : c\'est le flux.\n\n> Lorsque les gens font ce qu\'ils aiment vraiment, ils s\'oublient souvent.\n\nLa recherche montre que les personnes dans un état de flux sont généralement les plus productives et se sentent également les plus heureuses.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Carte de conversation (Conversation)',
        templateId: 'conversation',
        title: 'Conversation avec l\'IA',
        data: {
          'messages': [
            {
              'sender': 'Assistant IA',
              'text':
                  'Vous avez été plutôt productif aujourd\'hui ! Qu\'as-tu fait ?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Fin de la conception de l\'architecture et de la révision du code. Ça fait du bien.',
              'isMe': true,
            },
            {
              'sender': 'Assistant IA',
              'text':
                  'Génial! N\'oubliez pas de vous reposer tôt ce soir, vous avez un rendez-vous important demain.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Carte de devis (Citation)',
        templateId: 'quote',
        title: 'Citation du jour',
        data: {
          'content':
              'N\'attendez pas le moment parfait. Agissez et laissez le moment devenir parfait grâce à votre action.',
          'author': 'Napoleon Hill',
          'source': 'Réfléchissez et devenez riche',
        },
      ),
      TemplateGalleryItem(
        label: '6. Carte compacte (rangée compacte)',
        templateId: 'compact_card',
        title: '💧 Prise d\'eau',
        wrapped: true,
        data: {
          'details': ['500ml', 'Coupe 4', 'Objectif du jour 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visuel',
    items: [
      TemplateGalleryItem(
        label: '7. Carte instantanée (Photo)',
        templateId: 'snapshot',
        title: 'Moment de crépuscule',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Le Bund · Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Carte galerie (Album)',
        templateId: 'gallery',
        title: 'Camper le week-end',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Carte vidéo (Vidéo)',
        templateId: 'video',
        title: 'Journal vidéo',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Carte en toile (Toile)',
        templateId: 'canvas',
        title: 'Brouillon de carte mentale',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Quantifiable',
    items: [
      TemplateGalleryItem(
        label: '11. Carte métrique (métriques)',
        templateId: 'metric',
        title: 'Paramètres de santé',
        data: {
          'items': [
            {
              'title': 'Sommeil profond',
              'value': 2.5,
              'unit': 'h',
              'label': 'La nuit dernière',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Mesures',
              'value': 8342,
              'unit': 'steps',
              'label': 'Aujourd\'hui',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Fréquence cardiaque',
              'value': 72,
              'unit': 'bpm',
              'label': 'Repos',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Carte de notation (Note)',
        templateId: 'rating',
        title: 'Classement du film',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Des visuels à couper le souffle et une vision philosophique du temps et de l’amour qui persistent longtemps après le visionnage.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Carte d\'humeur (humeur)',
        templateId: 'mood',
        title: 'L\'humeur du jour',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Un nouveau projet a démarré et l\'équipe est très motivée.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Carte de progression (Progrès)',
        templateId: 'progress',
        title: 'Progression de l\'objectif annuel',
        data: {
          'label': 'Plan de lecture annuel',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Temporel',
    items: [
      TemplateGalleryItem(
        label: '15. Carte d\'événement (événement)',
        templateId: 'event',
        title: 'Réunion d\'examen des produits d\'IA',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Bâtiment A, parc technologique, nouvelle zone de Pudong, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Carte de durée (minuterie)',
        templateId: 'duration',
        title: 'Minuterie Pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Carte de tâche (tâche)',
        templateId: 'task',
        title: 'Analyse complète des exigences du produit',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Rapport d\'analyse concurrentielle', 'completed': true},
            {'title': 'Synthèse des entretiens utilisateurs', 'completed': true},
            {'title': 'Première ébauche du document d\'exigences', 'completed': false},
            {'title': 'Réunion de revue du PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Carte de routine (suivi des habitudes)',
        templateId: 'routine',
        title: 'Méditation quotidienne',
        data: {
          'habit_name': 'Méditation quotidienne de 10 minutes',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Fiche de procédure (étapes)',
        templateId: 'procedure',
        title: 'Recette de biscuits au beurre',
        data: {
          'steps': [
            'Préparer les ingrédients : 200 g de farine à gâteau, 3 œufs, 100 g de beurre',
            'Préchauffer le four à 175°C',
            'Crémer le beurre et le sucre jusqu\'à ce que le mélange devienne pâle',
            'Ajouter les œufs un à un et bien mélanger',
            'Tamiser la farine et plier jusqu\'à ce qu\'elle soit juste combinée',
            'Cuire au four pendant 25 minutes',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entités',
    items: [
      TemplateGalleryItem(
        label: '20. Carte personnelle (Personne)',
        templateId: 'person',
        title: 'Contact',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Chef de produit',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Carte de lieu (Lieu)',
        templateId: 'place',
        title: 'Librairie préférée',
        data: {
          'name': 'Librairie Tsutaya · Temple Jing\'an',
          'address': '400 Taixing Rd, district de Jing\'an, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Fiche technique (spécifications du produit)',
        templateId: 'spec_sheet',
        title: 'Apple Watch série 9',
        data: {
          'subtitle': 'Montre intelligente',
          'specs': {
            'Afficher': '1.9" AMOLED',
            'Batterie': 'Autonomie de 5 jours',
            'Résistance à l\'eau': 'IP68',
            'Poids': '32g',
            'Ébrécher': 'Apple S9',
            'Taille': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Carte de transaction (dépenses)',
        templateId: 'transaction',
        title: 'Dépenses pour le déjeuner',
        data: {
          'merchant': 'Maison de nouilles Hutong',
          'amount': '¥ 68.00',
          'location': 'Rue Gulou, Pékin',
          'items': [
            {'name': 'Signature Zhajiangmian (grande)', 'amount': '¥ 38'},
            {'name': 'Oeuf mariné', 'amount': '¥ 8'},
            {'name': 'Yaourt glacé de Pékin', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Carte de lien (Lien)',
        templateId: 'link',
        title: 'Documentation Flutter',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsFr = [
  TemplateGalleryItem(
    label: '1. Carte chronologique (chronologie d\'aujourd\'hui)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Chronologie d\'aujourd\'hui',
      'items': [
        {
          'time': '09:00',
          'title': 'Travail en profondeur',
          'content':
              'Diagramme d\'architecture v2.0 terminé et correction de trois bugs critiques.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Déjeuner et pause',
          'content': 'Salade légère, suivie d\'une marche de 20 minutes.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'A combler...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Graphique à bulles (bulles de mots clés)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Mots clés de la semaine',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Conception', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Analyse basée sur 42 notes',
    },
  ),
  TemplateGalleryItem(
    label: '3. Ligne de tendance (graphique de tendance)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Indice d\'humeur (7 derniers jours)',
      'top_right_text': 'Moyenne : 7,2',
      'points': [
        {'label': 'Mar', 'value': 3.5},
        {'label': 'Épouser', 'value': 4.0},
        {'label': 'Jeu', 'value': 5.5},
        {'label': 'Ven', 'value': 8.5, 'is_highlight': true},
        {'label': 'Assis', 'value': 7.0},
        {'label': 'Soleil', 'value': 6.5},
        {'label': 'Lun', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 points', 'subtitle': 'Temps fort du vendredi'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Graphique à barres (comparaison à barres)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Répartition du temps de mise au point',
      'subtitle': 'Aperçu de l\'agent : vous avez consacré le plus d\'efforts au codage.',
      'unit': 'h',
      'items': [
        {'label': 'Conception', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Codage',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'En lisant', 'value': 1.5, 'icon': '📚'},
        {'label': 'Réunions', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Anneau de progression (progression de l\'objectif)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Objectif de lecture annuel',
      'subtitle': '12 livres à emporter',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Complété', 'value': 65, 'color': '#6366F1'},
        {'label': 'Restant', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Carte radar (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Modèle de capacité',
      'badge': 'Focus mensuel',
      'center_value': '78',
      'center_label': 'Note globale',
      'dimensions': [
        {'label': 'Exécution', 'value': 80},
        {'label': 'Pensée', 'value': 60},
        {'label': 'Créativité', 'value': 70},
        {'label': 'Influence', 'value': 85},
        {'label': 'Apprentissage', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Surligner/Citer (Citation)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'La meilleure façon de prédire l’avenir est de le créer.',
      'quote_highlight': 'create it',
      'footer': '-Pierre Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composition (répartition)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Composition énergétique aujourd\'hui',
      'badge': 'Efficace',
      'headline_items': [
        {'label': 'Durée totale', 'value': '8.5h'},
        {'label': 'Travail en profondeur', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Codage', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Réunions', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'En lisant', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Une journée très productive',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contraste/Recadrage (Recadrage)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Recadrer une croyance',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Pensée originale',
        'content': 'Je suis trop occupé et je n’ai pas le temps d’apprendre de nouvelles choses.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Nouvelle perspective',
        'content':
            'Être occupé signifie qu\'il existe de nombreuses opportunités d\'apprendre par la pratique. Je peux apprendre en faisant.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galerie/Chronique (Galerie)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Extraits d\'inspiration',
      'headline': '3 Photos',
      'content': 'Quelques inspirations de design capturées aujourd\'hui.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Texture'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Couleur'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Lumière'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Carte cartographique (Carte)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Empreintes',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Une histoire de deux villes',
      'info_detail': 'Déplacement entre Pékin et Shanghai cette semaine',
    },
  ),
  TemplateGalleryItem(
    label: '12. Carte récapitulative (Résumé)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Semaine 4 : Percée et connexion',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'État de niveau S'},
      'insight_title': 'Aperçu des agents',
      'insight_content':
          'Cette semaine, vous vous êtes principalement concentré sur le développement de l\'#AI Agent et avez atteint un nouveau record de validations de code. J\'ai également remarqué que vous aviez prévu un dîner en famille vendredi soir – ce modèle « travailler dur, vivre pleinement » est très sain.',
      'metrics': [
        {'label': 'Se concentrer', 'value': '32h'},
        {'label': 'Humeur', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Remarques', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Temps forts de la semaine (3 sélectionnés)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Lancement'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Dîner en famille'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
