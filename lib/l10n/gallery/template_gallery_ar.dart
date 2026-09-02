import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsAr = [
  TemplateGallerySection(
    title: 'عام',
    items: [
      TemplateGalleryItem(
        label: '1. البطاقة الكلاسيكية (ملاحظة نصية)',
        templateId: 'classic_card',
        title: 'قراءة الملاحظات',
        data: {
          'content':
              'أنهيت الفصل الثالث من كتاب "التفكير السريع والبطيء" في أحد المقاهي اليوم. كانت الأمثلة حول تأثير التثبيت مثيرة للإعجاب وذكّرتني كيف يمكن لمعلومتنا الأولى أن تؤدي بهدوء إلى تحيز كل قرار لاحق.',
          'tags': ['قراءة', 'علم النفس'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'نصية',
    items: [
      TemplateGalleryItem(
        label: '2. بطاقة المقتطف (مقتطف نصي)',
        templateId: 'snippet',
        title: 'اقتباس تقني',
        data: {
          'text':
              '**"أي تكنولوجيا متقدمة بما فيه الكفاية لا يمكن تمييزها عن السحر."**\\n\\n— آرثر سي. كلارك',
          'style': 'default',
          'tags': ['يقتبس', 'تكنولوجيا', 'مستقبل'],
        },
      ),
      TemplateGalleryItem(
        label: '3. بطاقة المقالة (مقالة طويلة)',
        templateId: 'article',
        title: 'ما هي تجربة التدفق',
        data: {
          'body':
              '## ما هو التدفق؟\\n\\nالتدفق هو حالة نفسية اقترحها ميهالي سيكسزنتميهالي. عندما تنغمس تمامًا في مهمة صعبة وقابلة للتحقيق، فإنك تفقد إحساسك بالوقت ويتركز انتباهك تمامًا — وهذا هو التدفق.\\n\\n> عندما يفعل الأشخاص ما يستمتعون به حقًا، فإنهم غالبًا ما ينسون أنفسهم.\\n\\nتظهر الأبحاث أن الأشخاص في حالة التدفق هم عادةً الأكثر إنتاجية ويشعرون أيضًا بالسعادة.',
        },
      ),
      TemplateGalleryItem(
        label: '4. بطاقة المحادثة (المحادثة)',
        templateId: 'conversation',
        title: 'محادثة مع منظمة العفو الدولية',
        data: {
          'messages': [
            {
              'sender': 'مساعد الذكاء الاصطناعي',
              'text':
                  'لقد كنت منتجًا جدًا اليوم! ماذا فعلت؟',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'تم الانتهاء من التصميم المعماري ومراجعة الكود. شعور رائع.',
              'isMe': true,
            },
            {
              'sender': 'مساعد الذكاء الاصطناعي',
              'text':
                  'مذهل! تذكر أن تستريح مبكرًا الليلة، فلديك اجتماع مهم غدًا.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. بطاقة الاقتباس (اقتباس)',
        templateId: 'quote',
        title: 'اقتباس من اليوم',
        data: {
          'content':
              'لا تنتظر اللحظة المثالية. تصرف، ودع اللحظة تصبح مثالية من خلال أفعالك.',
          'author': 'Napoleon Hill',
          'source': 'فكر وكن غنيا',
        },
      ),
      TemplateGalleryItem(
        label: '6. البطاقة المدمجة (الصف المضغوط)',
        templateId: 'compact_card',
        title: '💧تناول الماء',
        wrapped: true,
        data: {
          'details': ['500ml', 'كوب 4', 'هدف اليوم 2000 مل'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'مرئي',
    items: [
      TemplateGalleryItem(
        label: '7. بطاقة اللقطات (الصورة)',
        templateId: 'snapshot',
        title: 'لحظة الغسق',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'البوند · شنغهاي',
        },
      ),
      TemplateGalleryItem(
        label: '8. بطاقة المعرض (الألبوم)',
        templateId: 'gallery',
        title: 'التخييم في عطلة نهاية الأسبوع',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. بطاقة الفيديو (الفيديو)',
        templateId: 'video',
        title: 'سجل الفيديو',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. بطاقة قماش (قماش)',
        templateId: 'canvas',
        title: 'مسودة الخريطة الذهنية',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'قابلة للقياس',
    items: [
      TemplateGalleryItem(
        label: '11. البطاقة المترية (المقاييس)',
        templateId: 'metric',
        title: 'المقاييس الصحية',
        data: {
          'items': [
            {
              'title': 'نوم عميق',
              'value': 2.5,
              'unit': 'h',
              'label': 'ليلة أمس',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'خطوات',
              'value': 8342,
              'unit': 'steps',
              'label': 'اليوم',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'معدل ضربات القلب',
              'value': 72,
              'unit': 'bpm',
              'label': 'يستريح',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. بطاقة التصنيف (التقييم)',
        templateId: 'rating',
        title: 'تصنيف الفيلم',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'صور مذهلة وفلسفية تأخذ الوقت والحب الذي يستمر لفترة طويلة بعد المشاهدة.',
        },
      ),
      TemplateGalleryItem(
        label: '13. بطاقة المزاج (المزاج)',
        templateId: 'mood',
        title: 'مزاج اليوم',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'بدأ مشروع جديد والفريق متحمس للغاية.',
        },
      ),
      TemplateGalleryItem(
        label: '14. بطاقة التقدم (التقدم)',
        templateId: 'progress',
        title: 'تقدم الهدف السنوي',
        data: {
          'label': 'خطة القراءة السنوية',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'زمني',
    items: [
      TemplateGalleryItem(
        label: '15. بطاقة الحدث (الحدث)',
        templateId: 'event',
        title: 'اجتماع مراجعة منتجات الذكاء الاصطناعي',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'المبنى أ، تيك بارك، منطقة بودونغ الجديدة، شنغهاي',
        },
      ),
      TemplateGalleryItem(
        label: '16. بطاقة المدة (المؤقت)',
        templateId: 'duration',
        title: 'توقيت بومودورو',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. بطاقة المهمة (المهمة)',
        templateId: 'task',
        title: 'تحليل كامل لمتطلبات المنتج',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'تقرير التحليل التنافسي', 'completed': true},
            {'title': 'توليف مقابلة المستخدم', 'completed': true},
            {'title': 'المسودة الأولى للمتطلبات doc', 'completed': false},
            {'title': 'اجتماع مراجعة PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. البطاقة الروتينية (متعقب العادة)',
        templateId: 'routine',
        title: 'التأمل اليومي',
        data: {
          'habit_name': 'التأمل اليومي لمدة 10 دقائق',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. بطاقة الإجراءات (الخطوات)',
        templateId: 'procedure',
        title: 'وصفة كعكة الزبدة',
        data: {
          'steps': [
            'تحضير المكونات: 200 جرام دقيق الكيك، 3 بيضات، 100 جرام زبدة',
            'سخني الفرن إلى 175 درجة مئوية',
            'نخفق الزبدة والسكر حتى يصبح الخليط شاحبًا',
            'أضف البيض واحدة تلو الأخرى واخلطها جيدًا',
            'ينخل الدقيق ويقلب حتى يمتزج للتو',
            'اخبزيها في الفرن لمدة 25 دقيقة',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'الكيانات',
    items: [
      TemplateGalleryItem(
        label: '20. بطاقة الشخص (الشخص)',
        templateId: 'person',
        title: 'اتصال',
        data: {
          'name': 'Alex Zhang',
          'relation': 'مدير المنتج',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. مكان البطاقة (المكان)',
        templateId: 'place',
        title: 'محل بيع الكتب المفضل',
        data: {
          'name': 'مكتبة تسوتايا · معبد جينغان',
          'address': '400 طريق تايكسينغ، منطقة جينغان، شنغهاي',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. ورقة المواصفات (مواصفات المنتج)',
        templateId: 'spec_sheet',
        title: 'ساعة ابل سيريس 9',
        data: {
          'subtitle': 'ساعة ذكية',
          'specs': {
            'عرض': '1.9" AMOLED',
            'بطارية': 'عمر البطارية 5 أيام',
            'مقاومة الماء': 'IP68',
            'وزن': '32g',
            'رقاقة': 'Apple S9',
            'مقاس': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. بطاقة المعاملات (الإنفاق)',
        templateId: 'transaction',
        title: 'الإنفاق على الغداء',
        data: {
          'merchant': 'هوتونج نودل هاوس',
          'amount': '¥ 68.00',
          'location': 'شارع جولو، بكين',
          'items': [
            {'name': 'التوقيع تشاجيانغميان (كبير)', 'amount': '¥ 38'},
            {'name': 'بيضة متبلة', 'amount': '¥ 8'},
            {'name': 'زبادي بكين المبرد', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. بطاقة الرابط (رابط)',
        templateId: 'link',
        title: 'توثيق الرفرفة',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsAr = [
  TemplateGalleryItem(
    label: '1. بطاقة الجدول الزمني (الجدول الزمني اليوم)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'الجدول الزمني اليوم',
      'items': [
        {
          'time': '09:00',
          'title': 'عمل عميق',
          'content':
              'تم الانتهاء من الرسم التخطيطي للهندسة المعمارية الإصدار 2.0 وإصلاح ثلاثة أخطاء حرجة.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'الغداء والاستراحة',
          'content': 'سلطة خفيفة، يليها المشي لمدة 20 دقيقة.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'ليتم ملؤها...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. المخطط الفقاعي (فقاعات الكلمات الرئيسية)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'الكلمات الرئيسية للأسبوع',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'تصميم', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'التحليل على أساس 42 ملاحظة',
    },
  ),
  TemplateGalleryItem(
    label: '3. خط الاتجاه (مخطط الاتجاه)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'مؤشر الحالة المزاجية (آخر 7 أيام)',
      'top_right_text': 'المتوسط: 7.2',
      'points': [
        {'label': 'الثلاثاء', 'value': 3.5},
        {'label': 'تزوج', 'value': 4.0},
        {'label': 'الخميس', 'value': 5.5},
        {'label': 'الجمعة', 'value': 8.5, 'is_highlight': true},
        {'label': 'قعد', 'value': 7.0},
        {'label': 'شمس', 'value': 6.5},
        {'label': 'الاثنين', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5 نقطة', 'subtitle': 'تسليط الضوء على الجمعة'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. مخطط شريطي (مقارنة شريطية)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'توزيع وقت التركيز',
      'subtitle': 'رؤية الوكيل: لقد بذلت أقصى جهد في البرمجة.',
      'unit': 'h',
      'items': [
        {'label': 'تصميم', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'الترميز',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'قراءة', 'value': 1.5, 'icon': '📚'},
        {'label': 'الاجتماعات', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. حلقة التقدم (تقدم الهدف)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'هدف القراءة السنوي',
      'subtitle': '12 كتابا للذهاب',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'مكتمل', 'value': 65, 'color': '#6366F1'},
        {'label': 'متبقي', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. مخطط الرادار (الرادار)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'نموذج القدرة',
      'badge': 'التركيز الشهري',
      'center_value': '78',
      'center_label': 'النتيجة الإجمالية',
      'dimensions': [
        {'label': 'تنفيذ', 'value': 80},
        {'label': 'التفكير', 'value': 60},
        {'label': 'إِبداع', 'value': 70},
        {'label': 'تأثير', 'value': 85},
        {'label': 'تعلُّم', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. تسليط الضوء/اقتباس (اقتباس)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'أفضل طريقة للتنبؤ بالمستقبل هي صناعته.',
      'quote_highlight': 'create it',
      'footer': '- بيتر دراكر',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. التركيب (الانهيار)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'تكوين الطاقة اليوم',
      'badge': 'فعال',
      'headline_items': [
        {'label': 'الوقت الإجمالي', 'value': '8.5h'},
        {'label': 'عمل عميق', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'الترميز', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'الاجتماعات', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'قراءة', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'يوم مثمر للغاية',
    },
  ),
  TemplateGalleryItem(
    label: '9. التباين/إعادة الصياغة (إعادة الصياغة)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'إعادة صياغة المعتقد',
      'emotion': 'neutral',
      'context_section': {
        'title': 'الفكر الأصلي',
        'content': 'أنا مشغول جدًا وليس لدي الوقت لتعلم أشياء جديدة.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'منظور جديد',
        'content':
            'كونك مشغولاً يعني أن هناك العديد من الفرص للتعلم من خلال الممارسة. أستطيع أن أتعلم من خلال العمل.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. المعرض/الوقائع (المعرض)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'قصاصات الإلهام',
      'headline': '3 Photos',
      'content': 'تم التقاط بعض إلهامات التصميم اليوم.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'نَسِيج'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'لون'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'ضوء'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. بطاقة الخريطة (الخريطة)',
    templateId: 'map_card_v1',
    data: {
      'title': 'آثار أقدام',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'قصة مدينتين',
      'info_detail': 'التنقل بين بكين وشانغهاي هذا الأسبوع',
    },
  ),
  TemplateGalleryItem(
    label: '12. البطاقة التلخيصية (الملخص)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'الأسبوع الرابع: الاختراق والاتصال',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'حالة المستوى S'},
      'insight_title': 'بصيرة الوكيل',
      'insight_content':
          'ركزت هذا الأسبوع بشكل أساسي على تطوير #AI Agent وحققت رقمًا قياسيًا جديدًا في عمليات تنفيذ التعليمات البرمجية. لاحظت أيضًا أنك قمت بتسجيل عشاء عائلي ليلة الجمعة - وهذا النمط "اعمل بجد، عش بشكل كامل" صحي جدًا.',
      'metrics': [
        {'label': 'ركز', 'value': '32h'},
        {'label': 'مزاج', 'value': '8.2', 'color': '#10B981'},
        {'label': 'ملحوظات', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'أبرز أحداث الأسبوع (3 مختارة)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'يطلق'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'عشاء عائلي'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
