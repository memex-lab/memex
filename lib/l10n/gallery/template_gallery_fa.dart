import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsFa = [
  TemplateGallerySection(
    title: 'ژنرال',
    items: [
      TemplateGalleryItem(
        label: '1. کارت کلاسیک (یادداشت متنی)',
        templateId: 'classic_card',
        title: 'خواندن یادداشت ها',
        data: {
          'content':
              'فصل 3 "تفکر، سریع و آهسته" امروز در یک کافه به پایان رسید. مثال‌هایی درباره اثر لنگر انداختن تأثیرگذار بودند و به من یادآوری کردند که چگونه اولین قطعه اطلاعات ما می‌تواند هر تصمیم بعدی را بی‌صدا سوگیری کند.',
          'tags': ['خواندن', 'روانشناسی'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'متنی',
    items: [
      TemplateGalleryItem(
        label: '2. کارت قطعه (قطعه متن)',
        templateId: 'snippet',
        title: 'نقل قول فنی',
        data: {
          'text':
              '**"هر فناوری به اندازه کافی پیشرفته از جادو قابل تشخیص نیست."**\\n\\n— آرتور سی کلارک',
          'style': 'default',
          'tags': ['نقل قول', 'تکنولوژی', 'آینده'],
        },
      ),
      TemplateGalleryItem(
        label: '3. کارت مقاله (مقاله طولانی)',
        templateId: 'article',
        title: 'تجربه جریان چیست',
        data: {
          'body':
              '## جریان چیست؟\\n\\nFlow یک حالت روانی است که توسط Mihaly Csikszentmihalyi پیشنهاد شده است. وقتی کاملاً در یک کار چالش‌برانگیز و در عین حال قابل دستیابی غرق می‌شوید، زمان را از دست می‌دهید و توجه‌تان کاملاً متمرکز می‌شود - این جریان است.\\n\\n> وقتی مردم کاری را انجام می‌دهند که واقعاً از آن لذت می‌برند، اغلب خودشان را فراموش می‌کنند.\\n\\nتحقیق نشان می‌دهد که افرادی که در وضعیت جریان هستند معمولاً بهره‌ورترین هستند و همچنین احساس خوشبختی می‌کنند.',
        },
      ),
      TemplateGalleryItem(
        label: '4. کارت مکالمه (مکالمه)',
        templateId: 'conversation',
        title: 'مکالمه با هوش مصنوعی',
        data: {
          'messages': [
            {
              'sender': 'دستیار هوش مصنوعی',
              'text':
                  'شما امروز بسیار سازنده بودید! چه کاری انجام دادی؟',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'طراحی معماری و بررسی کد به پایان رسید. احساس عالی می کند.',
              'isMe': true,
            },
            {
              'sender': 'دستیار هوش مصنوعی',
              'text':
                  'عالی! یادتان باشد امشب زود استراحت کنید، فردا جلسه مهمی دارید.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. کارت نقل قول (نقل قول)',
        templateId: 'quote',
        title: 'نقل قول روز',
        data: {
          'content':
              'منتظر لحظه عالی نباشید. عمل کنید و اجازه دهید لحظه با عمل شما کامل شود.',
          'author': 'Napoleon Hill',
          'source': 'بیندیش و ثروتمند شو',
        },
      ),
      TemplateGalleryItem(
        label: '6. کارت فشرده (ردیف فشرده)',
        templateId: 'compact_card',
        title: '💧 مصرف آب',
        wrapped: true,
        data: {
          'details': ['500ml', 'جام 4', 'هدف امروز 2000 میلی لیتر'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'بصری',
    items: [
      TemplateGalleryItem(
        label: '7. کارت عکس فوری (عکس)',
        templateId: 'snapshot',
        title: 'لحظه غروب',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'باند · شانگهای',
        },
      ),
      TemplateGalleryItem(
        label: '8. کارت گالری (آلبوم)',
        templateId: 'gallery',
        title: 'کمپینگ آخر هفته',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. کارت گرافیک (ویدئو)',
        templateId: 'video',
        title: 'گزارش تصویری',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. کارت بوم (بوم)',
        templateId: 'canvas',
        title: 'پیش نویس نقشه ذهنی',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'قابل اندازه گیری',
    items: [
      TemplateGalleryItem(
        label: '11. کارت متریک (متریک)',
        templateId: 'metric',
        title: 'معیارهای سلامت',
        data: {
          'items': [
            {
              'title': 'خواب عمیق',
              'value': 2.5,
              'unit': 'h',
              'label': 'دیشب',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'مراحل',
              'value': 8342,
              'unit': 'steps',
              'label': 'امروز',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'ضربان قلب',
              'value': 72,
              'unit': 'bpm',
              'label': 'در حال استراحت',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. کارت امتیاز (رتبه بندی)',
        templateId: 'rating',
        title: 'امتیاز فیلم',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'تصاویری نفس گیر و برداشتی فلسفی از زمان و عشقی که مدت ها پس از تماشا باقی می ماند.',
        },
      ),
      TemplateGalleryItem(
        label: '13. کارت خلق و خو (Mood)',
        templateId: 'mood',
        title: 'حال و هوای امروز',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'پروژه جدید شروع شد و تیم انگیزه بالایی دارد.',
        },
      ),
      TemplateGalleryItem(
        label: '14. کارت پیشرفت (پیشرفت)',
        templateId: 'progress',
        title: 'پیشرفت هدف سالانه',
        data: {
          'label': 'برنامه مطالعه سالانه',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'زمانی',
    items: [
      TemplateGalleryItem(
        label: '15. کارت رویداد (رویداد)',
        templateId: 'event',
        title: 'جلسه بررسی محصول هوش مصنوعی',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'ساختمان A، پارک فناوری، منطقه جدید پودونگ، شانگهای',
        },
      ),
      TemplateGalleryItem(
        label: '16. کارت مدت زمان (تایمر)',
        templateId: 'duration',
        title: 'تایمر پومودورو',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. کارت وظیفه (وظیفه)',
        templateId: 'task',
        title: 'تجزیه و تحلیل کامل نیازهای محصول',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'گزارش تحلیل رقابتی', 'completed': true},
            {'title': 'ترکیب مصاحبه کاربر', 'completed': true},
            {'title': 'اولین پیش نویس الزامات سند', 'completed': false},
            {'title': 'جلسه بررسی PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. کارت روتین (ردیاب عادت)',
        templateId: 'routine',
        title: 'مدیتیشن روزانه',
        data: {
          'habit_name': 'مدیتیشن روزانه 10 دقیقه ای',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. کارت رویه (مراحل)',
        templateId: 'procedure',
        title: 'دستور پخت کوکی کره',
        data: {
          'steps': [
            'مواد لازم: 200 گرم آرد کیک، 3 تخم مرغ، 100 گرم کره',
            'فر را با دمای 175 درجه سانتی گراد گرم کنید',
            'کره و شکر را هم بزنید تا رنگ آن کمرنگ شود',
            'تخم مرغ ها را یکی یکی اضافه کنید و کاملا مخلوط کنید',
            'آرد را الک کرده و هم میزنیم تا یکدست شود',
            'به مدت 25 دقیقه در فر بپزید',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'نهادها',
    items: [
      TemplateGalleryItem(
        label: '20. کارت شخصی (شخصی)',
        templateId: 'person',
        title: 'تماس بگیرید',
        data: {
          'name': 'Alex Zhang',
          'relation': 'مدیر محصول',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. کارت مکان (مکان)',
        templateId: 'place',
        title: 'کتابفروشی مورد علاقه',
        data: {
          'name': 'کتابفروشی تسوتایا · معبد جینگان',
          'address': '400 Taixing Rd, Jing’an District, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. برگه مشخصات (مشخصات محصول)',
        templateId: 'spec_sheet',
        title: 'اپل واچ سری 9',
        data: {
          'subtitle': 'ساعت هوشمند',
          'specs': {
            'نمایش': '1.9" AMOLED',
            'باتری': 'عمر باتری 5 روزه',
            'مقاومت در برابر آب': 'IP68',
            'وزن': '32g',
            'تراشه': 'Apple S9',
            'اندازه': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. کارت تراکنش (خرج)',
        templateId: 'transaction',
        title: 'خرج ناهار',
        data: {
          'merchant': 'خانه نودل هوتونگ',
          'amount': '¥ 68.00',
          'location': 'خیابان گولو، پکن',
          'items': [
            {'name': 'امضای Zhajiangmian (بزرگ)', 'amount': '¥ 38'},
            {'name': 'تخم مرغ ترشی شده', 'amount': '¥ 8'},
            {'name': 'ماست پکن سرد شده', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. کارت پیوند (پیوند)',
        templateId: 'link',
        title: 'مستندات فلاتر',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsFa = [
  TemplateGalleryItem(
    label: '1. کارت جدول زمانی (خط زمانی امروز)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'جدول زمانی امروز',
      'items': [
        {
          'time': '09:00',
          'title': 'کار عمیق',
          'content':
              'نمودار معماری نسخه 2.0 به پایان رسید و سه باگ مهم برطرف شد.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'ناهار و استراحت',
          'content': 'سالاد سبک و سپس 20 دقیقه پیاده روی.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'برای پر شدن...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. نمودار حباب (حباب کلمات کلیدی)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'کلمات کلیدی هفته',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'طراحی', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'تجزیه و تحلیل بر اساس 42 یادداشت',
    },
  ),
  TemplateGalleryItem(
    label: '3. خط روند (نمودار روند)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'شاخص خلق و خو (7 روز گذشته)',
      'top_right_text': 'میانگین: 7.2',
      'points': [
        {'label': 'سه شنبه', 'value': 3.5},
        {'label': 'چهارشنبه', 'value': 4.0},
        {'label': 'پنج شنبه', 'value': 5.5},
        {'label': 'جمعه', 'value': 8.5, 'is_highlight': true},
        {'label': 'نشست', 'value': 7.0},
        {'label': 'خورشید', 'value': 6.5},
        {'label': 'دوشنبه', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5 امتیاز', 'subtitle': 'برجسته روز جمعه'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. نمودار میله ای (مقایسه میله ای)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'توزیع زمان تمرکز',
      'subtitle': 'بینش عامل: شما بیشترین تلاش را برای کدنویسی صرف کردید.',
      'unit': 'h',
      'items': [
        {'label': 'طراحی', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'کد نویسی',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'خواندن', 'value': 1.5, 'icon': '📚'},
        {'label': 'جلسات', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. حلقه پیشرفت (پیشرفت هدف)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'هدف سالانه مطالعه',
      'subtitle': '12 کتاب باقی مانده است',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'تکمیل شد', 'value': 65, 'color': '#6366F1'},
        {'label': 'باقی مانده است', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. نمودار رادار (رادار)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'مدل قابلیت',
      'badge': 'تمرکز ماهانه',
      'center_value': '78',
      'center_label': 'امتیاز کلی',
      'dimensions': [
        {'label': 'اعدام', 'value': 80},
        {'label': 'فکر کردن', 'value': 60},
        {'label': 'خلاقیت', 'value': 70},
        {'label': 'نفوذ', 'value': 85},
        {'label': 'یادگیری', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. برجسته / نقل قول (نقل قول)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'بهترین راه برای پیش بینی آینده، ساختن آن است.',
      'quote_highlight': 'create it',
      'footer': '- پیتر دراکر',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. ترکیب (تجزیه)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'ترکیب انرژی امروز',
      'badge': 'کارآمد',
      'headline_items': [
        {'label': 'کل زمان', 'value': '8.5h'},
        {'label': 'کار عمیق', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'کد نویسی', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'جلسات', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'خواندن', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'یک روز بسیار پربار',
    },
  ),
  TemplateGalleryItem(
    label: '9. کنتراست/قالب بندی مجدد (فریم سازی مجدد)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'قالب بندی مجدد یک باور',
      'emotion': 'neutral',
      'context_section': {
        'title': 'فکر اصلی',
        'content': 'من خیلی سرم شلوغ است و زمانی برای یادگیری چیزهای جدید ندارم.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'دیدگاه جدید',
        'content':
            'مشغول بودن به این معنی است که فرصت های زیادی برای یادگیری از طریق تمرین وجود دارد. من می توانم با انجام دادن یاد بگیرم.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. گالری / کرونیکل (گالری)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'تکه های الهام',
      'headline': '3 Photos',
      'content': 'برخی از الهامات طراحی امروز گرفته شده است.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'بافت'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'رنگ'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'نور'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. کارت نقشه (نقشه)',
    templateId: 'map_card_v1',
    data: {
      'title': 'رد پا',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'داستان دو شهر',
      'info_detail': 'رفت و آمد بین پکن و شانگهای این هفته',
    },
  ),
  TemplateGalleryItem(
    label: '12. خلاصه کارت (خلاصه)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'هفته 4: پیشرفت و اتصال',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'حالت S-level'},
      'insight_title': 'بینش عامل',
      'insight_content':
          'این هفته شما عمدتاً روی توسعه #AI Agent تمرکز کردید و رکورد جدیدی را برای تعهدات کد کسب کردید. من همچنین متوجه شدم که شما جمعه شب یک شام خانوادگی ثبت کرده اید - این الگوی "سخت کار کنید، کاملا زندگی کنید" بسیار سالم است.',
      'metrics': [
        {'label': 'تمرکز کنید', 'value': '32h'},
        {'label': 'خلق و خوی', 'value': '8.2', 'color': '#10B981'},
        {'label': 'یادداشت ها', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'نکات مهم هفته (3 انتخاب شده)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'راه اندازی کنید'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'شام خانوادگی'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
