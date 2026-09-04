import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsEs = [
  TemplateGallerySection(
    title: 'General',
    items: [
      TemplateGalleryItem(
        label: '1. Tarjeta Clásica (Nota de texto)',
        templateId: 'classic_card',
        title: 'notas de lectura',
        data: {
          'content':
              'Hoy terminé el capítulo 3 de "Pensar, rápido y despacio" en un café. Los ejemplos sobre el efecto de anclaje fueron impresionantes y me recordaron cómo nuestra primera información puede sesgar silenciosamente cualquier decisión posterior.',
          'tags': ['Lectura', 'Psicología'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Textual',
    items: [
      TemplateGalleryItem(
        label: '2. Tarjeta de fragmento (fragmento de texto)',
        templateId: 'snippet',
        title: 'cita tecnica',
        data: {
          'text':
              '**“Cualquier tecnología suficientemente avanzada es indistinguible de la magia.”**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Cita', 'Tecnología', 'Futuro'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Ficha de artículo (artículo largo)',
        templateId: 'article',
        title: '¿Qué es la experiencia de flujo?',
        data: {
          'body':
              '## ¿Qué es el flujo?\n\nEl flujo es un estado psicológico propuesto por Mihaly Csikszentmihalyi. Cuando estás completamente inmerso en una tarea desafiante pero alcanzable, pierdes la noción del tiempo y tu atención está completamente enfocada: esto es fluir.\n\n> Cuando las personas hacen lo que realmente disfrutan, a menudo se olvidan de sí mismas.\n\nLas investigaciones muestran que las personas en un estado de flujo suelen ser las más productivas y también las más felices.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Tarjeta de conversación (Conversación)',
        templateId: 'conversation',
        title: 'Conversación con IA',
        data: {
          'messages': [
            {
              'sender': 'Asistente de IA',
              'text':
                  '¡Estuviste bastante productivo hoy! ¿Qué hiciste?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Terminé el diseño de arquitectura y la revisión del código. Se siente genial.',
              'isMe': true,
            },
            {
              'sender': 'Asistente de IA',
              'text':
                  '¡Impresionante! Recuerda descansar temprano esta noche, mañana tienes una reunión importante.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Tarjeta de cotización (Cotización)',
        templateId: 'quote',
        title: 'cita del dia',
        data: {
          'content':
              'No esperes el momento perfecto. Actúa y deja que el momento se vuelva perfecto a través de tu acción.',
          'author': 'Napoleon Hill',
          'source': 'Piense y hágase rico',
        },
      ),
      TemplateGalleryItem(
        label: '6. Tarjeta compacta (fila compacta)',
        templateId: 'compact_card',
        title: '💧 Ingesta de agua',
        wrapped: true,
        data: {
          'details': ['500ml', 'copa 4', 'El objetivo de hoy 2000ml.'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visual',
    items: [
      TemplateGalleryItem(
        label: '7. Tarjeta de instantáneas (foto)',
        templateId: 'snapshot',
        title: 'momento del anochecer',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Bund · Shanghái',
        },
      ),
      TemplateGalleryItem(
        label: '8. Tarjeta de galería (álbum)',
        templateId: 'gallery',
        title: 'Campamento de fin de semana',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Tarjeta de video (vídeo)',
        templateId: 'video',
        title: 'Registro de vídeo',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Tarjeta de lienzo (lienzo)',
        templateId: 'canvas',
        title: 'Borrador de mapa mental',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Cuantificable',
    items: [
      TemplateGalleryItem(
        label: '11. Tarjeta de métricas (Métricas)',
        templateId: 'metric',
        title: 'Métricas de salud',
        data: {
          'items': [
            {
              'title': 'sueño profundo',
              'value': 2.5,
              'unit': 'h',
              'label': 'Anoche',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Pasos',
              'value': 8342,
              'unit': 'steps',
              'label': 'Hoy',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'frecuencia cardiaca',
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
        label: '12. Rating Card (Rating)',
        templateId: 'rating',
        title: 'Movie rating',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Imágenes impresionantes y una visión filosófica del tiempo y el amor que perdura mucho después de verlo.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Tarjeta de humor (estado de ánimo)',
        templateId: 'mood',
        title: 'El estado de ánimo de hoy',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Comenzó el nuevo proyecto y el equipo está muy motivado.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Tarjeta de progreso (Progreso)',
        templateId: 'progress',
        title: 'Progreso de la meta anual',
        data: {
          'label': 'Plan de lectura anual',
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
        label: '15. Tarjeta de evento (Evento)',
        templateId: 'event',
        title: 'Reunión de revisión de productos de IA',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Edificio A, Tech Park, Nueva Área de Pudong, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Tarjeta de duración (temporizador)',
        templateId: 'duration',
        title: 'Temporizador pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Tarjeta de tarea (tarea)',
        templateId: 'task',
        title: 'Análisis completo de los requisitos del producto.',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Informe de análisis competitivo', 'completed': true},
            {'title': 'Síntesis de la entrevista del usuario', 'completed': true},
            {'title': 'Primer borrador del documento de requisitos.', 'completed': false},
            {'title': 'Reunión de revisión del PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Tarjeta de rutina (rastreador de hábitos)',
        templateId: 'routine',
        title: 'Meditación diaria',
        data: {
          'habit_name': 'Meditación diaria de 10 minutos.',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Tarjeta de Procedimiento (Pasos)',
        templateId: 'procedure',
        title: 'receta de galleta de mantequilla',
        data: {
          'steps': [
            'Ingredientes para preparar: 200 g de harina para repostería, 3 huevos, 100 g de mantequilla',
            'Precalentar el horno a 175°C',
            'Batir la mantequilla y el azúcar hasta que la mezcla se ponga pálida.',
            'Agrega los huevos uno por uno y mezcla bien.',
            'Tamizar la harina y mezclar hasta que esté combinada.',
            'Hornear en el horno durante 25 minutos.',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entidades',
    items: [
      TemplateGalleryItem(
        label: '20. Tarjeta de Persona (Persona)',
        templateId: 'person',
        title: 'Contacto',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Gerente de Producto',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Tarjeta de lugar (lugar)',
        templateId: 'place',
        title: 'Librería favorita',
        data: {
          'name': 'Librería Tsutaya · Templo Jing\'an',
          'address': '400 Taixing Rd, distrito de Jing\'an, Shanghái',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Hoja de especificaciones (especificaciones del producto)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Serie 9',
        data: {
          'subtitle': 'reloj inteligente',
          'specs': {
            'Mostrar': '1.9" AMOLED',
            'Batería': 'Duración de la batería de 5 días',
            'Resistencia al agua': 'IP68',
            'Peso': '32g',
            'Chip': 'Apple S9',
            'Tamaño': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Tarjeta de transacción (gastos)',
        templateId: 'transaction',
        title: 'Gasto en el almuerzo',
        data: {
          'merchant': 'Casa de fideos hutong',
          'amount': '¥ 68.00',
          'location': 'Calle Gulou, Pekín',
          'items': [
            {'name': 'Firma Zhajiangmian (grande)', 'amount': '¥ 38'},
            {'name': 'huevo marinado', 'amount': '¥ 8'},
            {'name': 'Yogurt Beijing frío', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Tarjeta de enlace (Enlace)',
        templateId: 'link',
        title: 'Documentación de aleteo',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsEs = [
  TemplateGalleryItem(
    label: '1. Tarjeta de cronograma (cronograma de hoy)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'La línea de tiempo de hoy',
      'items': [
        {
          'time': '09:00',
          'title': 'Trabajo profundo',
          'content':
              'Se completó el diagrama de arquitectura v2.0 y se corrigieron tres errores críticos.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Almuerzo y descanso',
          'content': 'Ensalada ligera, seguida de una caminata de 20 minutos.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Para llenar...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Gráfico de burbujas (burbujas de palabras clave)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Palabras clave de la semana',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Diseño', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Análisis basado en 42 notas.',
    },
  ),
  TemplateGalleryItem(
    label: '3. Línea de tendencia (gráfico de tendencias)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Índice de humor (últimos 7 días)',
      'top_right_text': 'Promedio: 7,2',
      'points': [
        {'label': 'Mar', 'value': 3.5},
        {'label': 'Casarse', 'value': 4.0},
        {'label': 'Jue', 'value': 5.5},
        {'label': 'Vie', 'value': 8.5, 'is_highlight': true},
        {'label': 'Se sentó', 'value': 7.0},
        {'label': 'Sol', 'value': 6.5},
        {'label': 'Lun', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 puntos', 'subtitle': 'Lo más destacado del viernes'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Gráfico de barras (comparación de barras)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Distribución del tiempo de concentración',
      'subtitle': 'Información del agente: usted dedicó el mayor esfuerzo a la codificación.',
      'unit': 'h',
      'items': [
        {'label': 'Diseño', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Codificación',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Lectura', 'value': 1.5, 'icon': '📚'},
        {'label': 'Reuniones', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Anillo de progreso (progreso del objetivo)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Meta de lectura anual',
      'subtitle': '12 libros para ir',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Terminado', 'value': 65, 'color': '#6366F1'},
        {'label': 'Restante', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Gráfico de radar (radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Modelo de capacidad',
      'badge': 'Enfoque mensual',
      'center_value': '78',
      'center_label': 'Puntuación general',
      'dimensions': [
        {'label': 'Ejecución', 'value': 80},
        {'label': 'Pensamiento', 'value': 60},
        {'label': 'Creatividad', 'value': 70},
        {'label': 'Influencia', 'value': 85},
        {'label': 'Aprendiendo', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Resaltar/Citar (Citar)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'La mejor manera de predecir el futuro es crearlo.',
      'quote_highlight': 'create it',
      'footer': '-Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composición (Desglose)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Composición energética hoy',
      'badge': 'Eficiente',
      'headline_items': [
        {'label': 'tiempo total', 'value': '8.5h'},
        {'label': 'Trabajo profundo', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Codificación', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Reuniones', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Lectura', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Un dia muy productivo',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contraste/Reencuadre (Reencuadre)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Reformular una creencia',
      'emotion': 'neutral',
      'context_section': {
        'title': 'pensamiento original',
        'content': 'Estoy demasiado ocupado y no tengo tiempo para aprender cosas nuevas.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Nueva perspectiva',
        'content':
            'Estar ocupado significa que hay muchas oportunidades para aprender mediante la práctica. Puedo aprender haciendo.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galería/Crónica (Galería)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Fragmentos de inspiración',
      'headline': '3 Photos',
      'content': 'Algunas inspiraciones de diseño capturadas hoy.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Textura'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Color'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Luz'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Tarjeta de mapa (mapa)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Huellas',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Una historia de dos ciudades.',
      'info_detail': 'Viajes diarios entre Beijing y Shanghai esta semana',
    },
  ),
  TemplateGalleryItem(
    label: '12. Tarjeta de resumen (Resumen)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Semana 4: Avance y conexión',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'estado de nivel S'},
      'insight_title': 'Información del agente',
      'insight_content':
          'Esta semana se centró principalmente en el desarrollo del #AI Agent y alcanzó un nuevo récord en confirmaciones de código. También noté que registraste una cena familiar el viernes por la noche; este patrón de “trabajar duro, vivir plenamente” es muy saludable.',
      'metrics': [
        {'label': 'Enfocar', 'value': '32h'},
        {'label': 'Ánimo', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Notas', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Lo más destacado de la semana (3 seleccionados)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Lanzamiento'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'cena familiar'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
