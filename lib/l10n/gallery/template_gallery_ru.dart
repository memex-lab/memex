import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsRu = [
  TemplateGallerySection(
    title: 'Общий',
    items: [
      TemplateGalleryItem(
        label: '1. Классическая карта (Текстовое примечание)',
        templateId: 'classic_card',
        title: 'Чтение заметок',
        data: {
          'content':
              'Finished chapter 3 of "Thinking, Fast and Slow" at a café today. The examples about the anchoring effect were impressive and reminded me how our first piece of information can quietly bias every later decision.',
          'tags': ['Reading', 'Психология'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Текстовый',
    items: [
      TemplateGalleryItem(
        label: '2. Карточка сниппета (текстовый фрагмент)',
        templateId: 'snippet',
        title: 'Техническая цитата',
        data: {
          'text':
              '**«Любая достаточно продвинутая технология неотличима от магии».**\\n\\n— Артур Кларк.',
          'style': 'default',
          'tags': ['Цитировать', 'Технология', 'Будущее'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Карточка статьи (длинная статья)',
        templateId: 'article',
        title: 'Что такое опыт потока',
        data: {
          'body':
              '## Что такое поток?\\n\\nПоток — это психологическое состояние, предложенное Михаем Чиксентмихайи. Когда вы полностью погружаетесь в сложную, но достижимую задачу, вы теряете счет времени и ваше внимание полностью сосредоточено — это поток.\\n\\n> Когда люди делают то, что им действительно нравится, они часто забывают себя.\\n\\nИсследования показывают, что люди в состоянии потока обычно наиболее продуктивны и при этом чувствуют себя наиболее счастливыми.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Разговорная карточка (Разговор)',
        templateId: 'conversation',
        title: 'Разговор с ИИ',
        data: {
          'messages': [
            {
              'sender': 'ИИ-помощник',
              'text':
                  'Вы сегодня были очень продуктивны! Что ты сделал?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Завершил проектирование архитектуры и проверку кода. Чувствует себя прекрасно.',
              'isMe': true,
            },
            {
              'sender': 'ИИ-помощник',
              'text':
                  'Потрясающий! Не забудь сегодня отдохнуть пораньше, завтра у тебя важная встреча.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Котировочная карта (Цитата)',
        templateId: 'quote',
        title: 'Цитата дня',
        data: {
          'content':
              'Не ждите идеального момента. Действуйте, и пусть момент станет совершенным благодаря вашим действиям.',
          'author': 'Napoleon Hill',
          'source': 'Думай и богатей',
        },
      ),
      TemplateGalleryItem(
        label: '6. Компактная карта (компактный ряд)',
        templateId: 'compact_card',
        title: '💧Забор воды',
        wrapped: true,
        data: {
          'details': ['500ml', 'Кубок 4', 'Сегодняшняя цель 2000мл'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Визуальный',
    items: [
      TemplateGalleryItem(
        label: '7. Карточка моментального снимка (фото)',
        templateId: 'snapshot',
        title: 'Момент сумерек',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Бунд · Шанхай',
        },
      ),
      TemplateGalleryItem(
        label: '8. Карта галереи (альбом)',
        templateId: 'gallery',
        title: 'Кемпинг выходного дня',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Видеокарта (Видео)',
        templateId: 'video',
        title: 'Видео журнал',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Холст-карта (холст)',
        templateId: 'canvas',
        title: 'Проект карты разума',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Измеримый',
    items: [
      TemplateGalleryItem(
        label: '11. Метрическая карта (Метрики)',
        templateId: 'metric',
        title: 'Health metrics',
        data: {
          'items': [
            {
              'title': 'Глубокий сон',
              'value': 2.5,
              'unit': 'h',
              'label': 'Вчера вечером',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Steps',
              'value': 8342,
              'unit': 'steps',
              'label': 'Сегодня',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Частота сердечных сокращений',
              'value': 72,
              'unit': 'bpm',
              'label': 'Отдых',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Рейтинговая карточка (Рейтинг)',
        templateId: 'rating',
        title: 'Рейтинг фильма',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Захватывающие визуальные эффекты, философский взгляд на время и любовь, которая сохраняется еще долго после просмотра.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Карта настроения (Настроение)',
        templateId: 'mood',
        title: 'Сегодняшнее настроение',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Новый проект стартовал, и команда очень мотивирована.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Карта прогресса (Прогресс)',
        templateId: 'progress',
        title: 'Годовой прогресс цели',
        data: {
          'label': 'Годовой план чтения',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Временной',
    items: [
      TemplateGalleryItem(
        label: '15. Карта Событий (Событие)',
        templateId: 'event',
        title: 'Совещание по обзору продуктов искусственного интеллекта',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Здание А, технопарк, новый район Пудун, Шанхай',
        },
      ),
      TemplateGalleryItem(
        label: '16. Карта продолжительности (таймер)',
        templateId: 'duration',
        title: 'Таймер Помидора',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Карта задач (Задание)',
        templateId: 'task',
        title: 'Полный анализ требований к продукту',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Отчет о конкурентном анализе', 'completed': true},
            {'title': 'Синтез интервью с пользователем', 'completed': true},
            {'title': 'Первый вариант документа с требованиями', 'completed': false},
            {'title': 'Обзорное совещание PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Карта рутины (трекер привычек)',
        templateId: 'routine',
        title: 'Ежедневная медитация',
        data: {
          'habit_name': 'Ежедневная 10-минутная медитация',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Карта процедур (шаги)',
        templateId: 'procedure',
        title: 'Рецепт печенья с маслом',
        data: {
          'steps': [
            'Подготовьте ингредиенты: 200 г муки для кексов, 3 яйца, 100 г сливочного масла.',
            'Разогрейте духовку до 175°C.',
            'Взбивайте масло и сахар, пока смесь не станет бледной.',
            'Добавляем яйца по одному и тщательно перемешиваем',
            'Просейте муку и перемешайте до однородного состояния.',
            'Запекать в духовке 25 минут',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Сущности',
    items: [
      TemplateGalleryItem(
        label: '20. Карточка персоны (Персона)',
        templateId: 'person',
        title: 'Контакт',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Менеджер по продукту',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Карта места (Место)',
        templateId: 'place',
        title: 'Любимый книжный магазин',
        data: {
          'name': 'Книжный магазин Цутая · Храм Цзинъань',
          'address': '400 Taixing Rd, район Цзинъань, Шанхай',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Спецификация (технические характеристики продукта)',
        templateId: 'spec_sheet',
        title: 'Apple, часы серии 9',
        data: {
          'subtitle': 'Умные часы',
          'specs': {
            'Отображать': '1.9" AMOLED',
            'Батарея': '5 дней автономной работы',
            'Водонепроницаемость': 'IP68',
            'Масса': '32g',
            'Чип': 'Apple S9',
            'Размер': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Карта транзакций (расходы)',
        templateId: 'transaction',
        title: 'Расходы на обед',
        data: {
          'merchant': 'Дом лапши Хутун',
          'amount': '¥ 68.00',
          'location': 'Улица Гулоу, Пекин',
          'items': [
            {'name': 'Подпись Чжацзянмянь (большая)', 'amount': '¥ 38'},
            {'name': 'Маринованное яйцо', 'amount': '¥ 8'},
            {'name': 'Пекинский йогурт охлажденный.', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Ссылка на карту (Ссылка)',
        templateId: 'link',
        title: 'Флаттер документация',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsRu = [
  TemplateGalleryItem(
    label: '1. Карта временной шкалы (сегодняшняя временная шкала)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Сегодняшняя временная шкала',
      'items': [
        {
          'time': '09:00',
          'title': 'Глубокая работа',
          'content':
              'Доработана схема архитектуры v2.0 и исправлены три критические ошибки.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Обед и перерыв',
          'content': 'Легкий салат, а затем 20-минутная прогулка.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Чтобы быть наполненным...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Пузырьковая диаграмма (пузырьки ключевых слов)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Ключевые слова недели',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Дизайн', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Анализ на основе 42 заметок',
    },
  ),
  TemplateGalleryItem(
    label: '3. Линия тренда (график тренда)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Индекс настроения (последние 7 дней)',
      'top_right_text': 'Средний: 7,2',
      'points': [
        {'label': 'Вт', 'value': 3.5},
        {'label': 'Обвенчались', 'value': 4.0},
        {'label': 'Чт', 'value': 5.5},
        {'label': 'Пт', 'value': 8.5, 'is_highlight': true},
        {'label': 'Суббота', 'value': 7.0},
        {'label': 'Солнце', 'value': 6.5},
        {'label': 'Пн.', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 баллов', 'subtitle': 'Пятничное событие'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Гистограмма (сравнение гистограмм)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Распределение времени фокусировки',
      'subtitle': 'Комментарий агента: больше всего усилий вы потратили на кодирование.',
      'unit': 'h',
      'items': [
        {'label': 'Дизайн', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Кодирование',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Reading', 'value': 1.5, 'icon': '📚'},
        {'label': 'Встречи', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Кольцо прогресса (прогресс цели)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Цель ежегодного чтения',
      'subtitle': '12 книг впереди',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Завершенный', 'value': 65, 'color': '#6366F1'},
        {'label': 'Оставшийся', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Радарная диаграмма (Радар)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Модель возможностей',
      'badge': 'Ежемесячный фокус',
      'center_value': '78',
      'center_label': 'Общий балл',
      'dimensions': [
        {'label': 'Исполнение', 'value': 80},
        {'label': 'мышление', 'value': 60},
        {'label': 'Креативность', 'value': 70},
        {'label': 'Влияние', 'value': 85},
        {'label': 'Обучение', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Выделение/Цитата (Цитата)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Лучший способ предсказать будущее — создать его.',
      'quote_highlight': 'create it',
      'footer': '- Питер Друкер',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Состав (разбивка)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Энергетический состав сегодня',
      'badge': 'Эффективный',
      'headline_items': [
        {'label': 'Общее время', 'value': '8.5h'},
        {'label': 'Глубокая работа', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Кодирование', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Встречи', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Reading', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Очень продуктивный день',
    },
  ),
  TemplateGalleryItem(
    label: '9. Контраст/Рефрейминг (Рефрейминг)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Переосмысление убеждения',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Оригинальная мысль',
        'content': 'Я слишком занят и у меня нет времени узнавать что-то новое.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Новая перспектива',
        'content':
            'Занятость означает, что есть много возможностей учиться на практике. Я могу учиться, делая.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Галерея/Хроника (Галерея)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Фрагменты для вдохновения',
      'headline': '3 Photos',
      'content': 'Некоторые дизайнерские идеи, запечатленные сегодня.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Текстура'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Цвет'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Свет'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Карта-карта (Карта)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Следы',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'История двух городов',
      'info_detail': 'Путешествие между Пекином и Шанхаем на этой неделе',
    },
  ),
  TemplateGalleryItem(
    label: '12. Сводная карточка (сводка)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Неделя 4: Прорыв и связь',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'Состояние S-уровня'},
      'insight_title': 'Информация об агенте',
      'insight_content':
          'На этой неделе вы сосредоточились в основном на разработке #AI Agent и установили новый рекорд по количеству коммитов кода. Я также заметил, что вы записали семейный ужин в пятницу вечером — принцип «работай усердно, живи полноценно» очень полезен для здоровья.',
      'metrics': [
        {'label': 'Фокус', 'value': '32h'},
        {'label': 'Настроение', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Примечания', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Главные события недели (выбрано 3)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Запуск'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Семейный ужин'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
