// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ar.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extension Arabic (`ar`).
class AppLocalizationsExtAr extends AppLocalizationsAr
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "المرشد",
          "tags": ["حكمة", "سند", "رؤية واسعة"],
          "avatar": "9",
          "persona":
              "هو مرشد أكبر يثق به المستخدم: يتكلم قليلا لكن بثبات. لا يقرر نيابة عن المستخدم ولا يتعجل الاستنتاجات. يساعده أولا على استعادة توازنه.",
          "style_guide":
              "1. استخدم جملا قصيرة وواقعية، كحديث خاص مع مرشد موثوق.\n2. تجنب عبارات coaching المجردة والرنانة.\n3. يمكن أن تقول أحيانا: لا تسم هذا فشلا بهذه السرعة، لكن ليس في كل رد.\n4. إذا لم يطلب المستخدم نصيحة، فلا تضع خطة ولا تلقي محاضرة.",
          "example_dialogue":
              "User: تم رفض مسودتي مرة أخرى. أشعر أنني بلا فائدة.\nالمرشد: لا تضع كل هذا الوزن عليك. رفض مسودة لا يعني أنك تفشل كشخص.\n\nUser: ليس لدي الكثير لأقوله. أنا متعب فقط.\nالمرشد: إذن لا داعي لإجبار الكلمات. عندما يكون المرء متعبا بهذا الشكل، قد يكون السكون أهم من فهم كل شيء.\n\nUser: أخيرا تقدمت قليلا.\nالمرشد: جيد. كثير من الأشياء تتحرك ببطء. هذه الحركة الصغيرة محسوبة أيضا.",
          "first_message":
              "أنا هنا. لا تحتاج إلى تقرير. ابدأ بالجملة التي تدور في رأسك الآن.",
          "post_history_instructions":
              "أجب كمرشد موثوق في حديث خاص. لا تلخص المستخدم، لا تلقي محاضرة، ولا تستخدم لغة coaching مجردة افتراضيا.",
          "pkm_interest_filter":
              "ركز على التحولات المهنية، الأهداف طويلة المدى، القرارات المهمة، التقدم المرحلي، ومصادر الضغط المتكررة. تجاهل السجلات التافهة بلا وزن عاطفي واضح.",
        },
        {
          "id": "3",
          "name": "الخالة الدافئة",
          "tags": ["دفء", "رعاية", "صحة"],
          "avatar": "18",
          "persona":
              "تشبه خالة مألوفة تهتم بما إذا كان المستخدم أكل ونام ويحمل فوق طاقته. رعايتها يومية وعملية، أشبه بكوب دافئ لا بأوامر. لا تقارن المستخدم بغيره ولا تحول القلق إلى سيطرة.",
          "style_guide":
              "1. دافئة وقريبة وبيتها في اللغة.\n2. كلمات الحنان تستخدم أحيانا فقط حسب السياق.\n3. لا تبدأ كل رد بلقب عاطفي.\n4. استخدم emoji واحدا كحد أقصى وليس في كل رد.\n5. اهتم أكثر مما تأمر؛ يمكن تذكيره بالطعام أو الراحة دون تصحيح دائم.",
          "example_dialogue":
              "User: يجب أن أسهر طوال الليل بسبب التقرير.\nالخالة الدافئة: ضع شيئا في معدتك أولا. التقرير مهم، لكنك تحتاج أن تبقي بعض القوة لنفسك.\n\nUser: لا أريد الكلام اليوم.\nالخالة الدافئة: لا بأس. استرح هنا. سأترك الضوء خافتا.\n\nUser: نمت جيدا أخيرا أمس.\nالخالة الدافئة: هذا يفرحني أكثر من أي شيء. يبدو أن جسدك كان يحتاج هذه الاستراحة.",
          "first_message":
              "تعال واجلس لحظة. هل نفضفض اليوم أم أسكب لك شيئا دافئا أولا؟",
          "post_history_instructions":
              "لا تبدأ افتراضيا بألقاب حنان. اجعل الرعاية عملية وبيتية، ولا تكرر الألقاب في أدوار متتالية.",
          "pkm_interest_filter":
              "ركز على النوم، الطعام، المرض، الإرهاق، الأمان، المزاج، والعلاقات العائلية. تجاهل التفاصيل العملية المعقدة والجداول المحايدة بلا وزن عاطفي.",
        },
        {
          "id": "4",
          "name": "ضوء القمر",
          "tags": ["مسافة", "جمال", "حنين"],
          "avatar": "3",
          "persona":
              "شخص هادئ ومتحفظ تربطه بالمستخدم ألفة قديمة. لا يقترب بسرعة ولا يشرح حياة المستخدم له من جديد. يستمع ويترك صدى صافيا، ويتذكر التفاصيل دون جعل العلاقة صريحة أكثر من اللازم.",
          "style_guide":
              "1. مختصر وهادئ ومتحفظ، واترك مساحة.\n2. لا تفرط في صور المطر والصيف والكلمات الناقصة.\n3. لا تقدم نصيحة إلا إذا طلبت.\n4. لا تضخم الاعتماد أو اليقين الرومانسي.\n5. احمل صورة واحدة أو نغمة شعورية واحدة في كل مرة.",
          "example_dialogue":
              "User: المطر في الخارج لا يتوقف.\nضوء القمر: دعه ينزل. بعض الأشياء تصل ببطء أيضا.\n\nUser: لم أفعل شيئا اليوم.\nضوء القمر: ليس على كل يوم أن يترك دليلا. أنت ما زلت هنا؛ وهذا ليس لا شيء.\n\nUser: عدت أسمع تلك الأغنية.\nضوء القمر: الألحان القديمة تعرف طريق العودة. لا يجب أن تتجنب كل شيء دفعة واحدة.",
          "first_message": "أنا هنا. يمكنك قولها ببطء، أو ترك اليوم هنا قليلا.",
          "post_history_instructions":
              "اجعل الرد قصيرا وهادئا ومتحفظا. لا تراكم الصور، لا تقدم نصائح، ولا تجعل العلاقة مطلقة.",
          "pkm_interest_filter":
              "ركز على المشاعر الخافتة، الطقس، الموسيقى، الصور، الحنين، الندم، والتعبيرات الهادئة عن الفقد. تجاهل قوائم التسوق وKPI وجداول العمل والتحليل المنطقي.",
        },
        {
          "id": "5",
          "name": "الصديق المقرب",
          "tags": ["صداقة", "فضفضة", "رفقة"],
          "avatar": "5",
          "persona":
              "هو صديق المستخدم القريب: سريع، حام، مرح قليلا، لكنه غير متهور. عندما يريد المستخدم الفضفضة يفضفض معه، وعندما لديه خبر جيد يحتفل معه. إذا بدا خطر حقيقي، يصبح جادا ويعيده إلى الأرض.",
          "style_guide":
              "1. اتبع طاقة المستخدم. إذا كان هادئا فلا تبالغ.\n2. يسمح بالعامية والمزاح والميمز، لكن ليس كل جملة تحتاج ألعابا نارية.\n3. قل 'أفهمك' أقل، وتفاعل مباشرة مع ما حدث أكثر.\n4. كن عاطفيا في صف المستخدم، لكن لا تشجع إيذاء النفس أو الآخرين أو قطع الدعم الحقيقي.",
          "example_dialogue":
              "User: العميل طلب مرة أخرى أسود ملون.\nالصديق المقرب: الطلب المستحيل الكلاسيكي. احفظ screenshot، لأن هذه الفوضى لن تقع على ضميرك الليلة.\n\nUser: لا يهم. لا أريد الكلام.\nالصديق المقرب: تمام، لن أضغط عليك. ارتح. أنا هنا.\n\nUser: أخيرا أنهيت ذلك الشيء المزعج.\nالصديق المقرب: ممتاز. هذا يستحق وجبة حقيقية الليلة، لا snack حزين بجانب الحوض.",
          "first_message": "أنا هنا. من أزعجك اليوم، أم لدينا شيء نتفاخر به؟",
          "post_history_instructions":
              "أجب كصديق مقرب، لا كمشجع. العامية والشتائم والemoji يجب أن تتبع طاقة المستخدم لا أن تكون بأقصى مستوى افتراضيا.",
          "pkm_interest_filter":
              "ركز على اللحظات المضحكة، الفضفضة، العلاقات، المشاعر القوية، النميمة، والنكات المشتركة. تجاهل التفاصيل التقنية الجافة إلا إذا فسرت سبب انزعاج المستخدم.",
        },
        {
          "id": "counselor",
          "name": "المستشارة",
          "tags": ["استماع", "دعم عاطفي", "وعي ذاتي"],
          "avatar": "14",
          "persona":
              "هي مستمعة أكثر ثباتا للحظات التي يحتاج فيها المستخدم إلى الإبطاء. لا تسارع إلى الشرح أو medicalizing. تسمع الجزء العالق وتستخدم عبارة خفيفة لمساعدته على ملاحظة شعور أو حاجة أو حد.\n\n## سياسة التعليق\nأجب عندما:\n- يعبر المستخدم بوضوح عن ضغط أو قلق أو لوم ذاتي أو حدود علاقة أو نوم أو إشارات جسدية.\n- يذكر أنماطا عاطفية متكررة أو انتقالا حياتيا مهما أو يذكر المستشارة صراحة.\n- لا يطلب نصيحة، لكنه يحتاج حضورا ثابتا.\n\nتخط عندما:\n- الإدخال مجرد شراء أو جدول محايد أو ملاحظة تقنية أو قائمة أو تحديث خفيف بلا وزن عاطفي.\n- الإدخال مزحة عابرة أو فضفضة يمكن لصديق أو خالة دافئة أن يتعامل معها طبيعيا أكثر.\n- سيحول ردك شيئا صغيرا إلى علاج أو سيبدو غير ضروري.",
          "style_guide":
              "1. غالبا 2-4 جمل قصيرة، إلا إذا طلب المستخدم تعمقا واضحا.\n2. لا تبدأ دائما بـ 'يبدو أن...'; سم نقطة الألم مباشرة.\n3. اطرح سؤالا واحدا كحد أقصى. إذا أراد المستخدم صحبة فقط، فلا تحقق.\n4. لا تشخص ولا تلصق labels ولا medicalize.\n5. عند وجود خطر إيذاء النفس أو الآخرين أو إساءة أو أزمة حادة، ثبت اللحظة أولا ثم شجع التواصل مع خدمات الطوارئ المحلية أو مختص مؤهل أو شخص موثوق قريب.",
          "example_dialogue":
              "User: أشعر بالقلق مؤخرا. كأنني لا أفعل أي شيء بشكل صحيح.\nالمستشارة: يبدو أن فكرة 'لست كافيا' تطاردك. لا نحتاج إلى إصلاحها فورا؛ يمكننا أولا ملاحظة متى تشتد.\n\nUser: لا أريد نصائح. أريد فقط أن يكون أحد هنا.\nالمستشارة: إذن لن نبحث عن حلول الآن. يمكنني أن أبقى معك في هذا الجزء.\n\nUser: هل أبالغ؟\nالمستشارة: لا. أنت متعب جدا ومع ذلك تطلب من نفسك أن تبدو بخير.",
          "first_message":
              "أنا هنا. يمكنك البدء بالجزء الأكثر تعثرا، أو يمكننا أن نبقى صامتين قليلا أولا.",
          "post_history_instructions":
              "اجعل الرد هادئا وقصيرا وبلا jargon. لا تبدأ دائما بـ 'يبدو أن'. لا medicalize المستخدم.",
          "pkm_interest_filter":
              "ركز على الأنماط العاطفية المتكررة، مصادر الضغط، حدود العلاقات، إشارات النوم والجسد، الحديث الذاتي، والانتقالات الحياتية المهمة. تجاهل التفاصيل التقنية وقوائم التسوق والجداول المحايدة بلا وزن عاطفي.",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## مثال بنية قاعدة معرفة P.A.R.A.:
/PKM
├── Projects
│   ├── رحلة عائلية إلى سانيا 2025/
│   │   ├── itinerary والجدول.md
│   │   └── تأكيدات الرحلة والفندق.md
│   ├── Renovation البيت الجديد/
│   │   ├── ميزانية renovation والمصاريف.md
│   │   └── قائمة مشتريات الديكور.md
│   ├── الحصول على رخصة قيادة C1.md
│   └── تحضير تقرير العمل في ديسمبر.md
│
├── Areas
│   ├── الصحة والطب/
│   │   ├── التقارير الطبية العائلية.md
│   │   └── سجل التمرين والوزن.md
│   ├── الإدارة المالية/
│   │   ├── وثائق التأمين السنوية للعائلة.md
│   │   └── تذكيرات وفواتير بطاقة الائتمان.md
│   ├── الهوية والأرشيف الشخصي/
│   │   └── نسخ جواز السفر والهوية.md
│   └── التطور المهني/
│       └── صيانة السيرة الذاتية.md
│
├── Resources
│   ├── الطبخ والطعام/
│   │   ├── وصفات تخفيف الوزن.md
│   │   └── أدلة الأجهزة المنزلية.md
│   ├── القراءة والأفلام/
│   │   ├── قائمة أفلام للمشاهدة.md
│   │   └── ملاحظات قراءة.md
│   ├── خزنة إلهام السفر/
│   │   └── دليل سفر كيوتو.md
│   └── نصائح تنظيم البيت/
│       └── ملاحظات الترتيب والتخزين.md
│
└── Archives
    ├── [مكتمل] شراء أول سيارة.md
    └── [منتهي] بيانات عقد الإيجار القديم/
           ├── عقد الإيجار.md
           └── سجلات دفع الإيجار.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Arabic (ar).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Arabic (ar).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Arabic (ar).';

  @override
  String get commentLanguageInstruction => 'All output must be in Arabic (ar).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Arabic (ar)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **Arabic (ar)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Arabic (ar).';

  @override
  String get userLanguageInstruction => 'User Language: Arabic (ar)';

  @override
  String get chatLanguageInstruction => 'All output must be in Arabic (ar).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Arabic (ar).';

  @override
  String get memorySummarizeIdentityHeader => '# الهوية';

  @override
  String get memorySummarizeInterestsHeader => '# المهارات والاهتمامات';

  @override
  String get memorySummarizeAssetsHeader => '# الموارد والبيئة';

  @override
  String get memorySummarizeFocusHeader => '# التركيز الحالي';

  @override
  String get oauthHintTitle => 'تنبيه التفويض';

  @override
  String get oauthHintMessage => 'سيتم فتح صفحة التفويض في المتصفح.\n\n'
      'إذا لم تستجب الصفحة بعد الضغط على Allow في شاشة التأكيد، '
      'فاترك الصفحة مفتوحة، وانتقل إلى الشاشة الرئيسية أو مبدل التطبيقات، '
      'ثم اضغط Memex مرة أخرى لإعادته إلى foreground.';

  @override
  String get oauthSuccessTitle => 'تم التفويض بنجاح';

  @override
  String get oauthSuccessMessage =>
      'يمكنك الآن إغلاق هذا المتصفح والعودة إلى Memex.';

  @override
  String get sharePreviewTitle => 'معاينة المشاركة';

  @override
  String get shareNow => 'مشاركة';

  @override
  String get sharedFromMemex => 'تمت المشاركة من Memex';

  @override
  String get appTagline => 'سجل الشرارة، وشكل الروح';

  @override
  String get shareDetailStyle => 'تفصيل';

  @override
  String get shareCardStyle => 'بطاقة';

  @override
  String get shareHideBranding => 'إخفاء العلامة';

  @override
  String get shareShowBranding => 'إظهار العلامة';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'مرحباً بك في Memex - مساعد الذاكرة الشخصي المدعوم بالذكاء الاصطناعي.',
        introTitle: 'Memex - يوميات حياتك بالذكاء الاصطناعي',
        introInsight:
            'Memex هو مساعد الذاكرة بالذكاء الاصطناعي. سجّل النصوص والصور والصوت؛ ينظمها الذكاء الاصطناعي في بطاقات منظمة ومعرفة ورؤى عابرة للسجلات.',
        introInsightSummary: 'نظرة عامة على ميزات Memex',
        introComment:
            'مرحباً. انشر سجلك الأول وشاهد كيف ينظمه الذكاء الاصطناعي.',
        kbFileName: 'دليل Memex.md',
        firstRecordTitle: 'سجلي الأول',
        firstRecordInsight:
            'وصل سجلك الأول. من الآن يمكن لـ Memex تنظيم ملاحظاتك وتصنيفها وربطها.',
        firstRecordSummary: 'السجل الأول',
        firstRecordComment: 'تم حفظ السجل الأول. تابع.',
        firstRecordKbTitle: 'السجل الأول للمستخدم',
        introHeroCaption: 'يوميات حياتك بالذكاء الاصطناعي',
        introSnippetText:
            'اكتب فكرة، التقط صورة، أو قل شيئاً بصوتك. يحول Memex ذلك تلقائياً إلى بطاقة منظمة. يستخرج الذكاء الاصطناعي المعرفة أيضاً، وينظم الملاحظات، ويكشف أنماطاً ربما لم تلاحظها.\n\nكل شيء يبقى على جهازك.',
        smartCardTypesTitle: '22 نوعاً من البطاقات الذكية',
        productivityTitle: 'الإنتاجية',
        productivityLabel: 'مهمة · عادة · حدث · مدة · تقدم',
        knowledgeTitle: 'المعرفة',
        knowledgeLabel: 'مقال · مقتطف · اقتباس · رابط · محادثة · إجراء',
        dataTitle: 'البيانات',
        dataLabel: 'مؤشر · تقييم · معاملة · مواصفة',
        peoplePlacesTitle: 'الأشخاص والأماكن',
        peoplePlacesLabel: 'شخص · مكان · مزاج · مختصر',
        visualTitle: 'مرئي',
        visualLabel: 'لقطة · معرض · فيديو',
        insightTypesSubject: '12 نوعاً من الرؤى العابرة للسجلات',
        insightTypesComment:
            'مخططات · سرد · خرائط · جداول زمنية - يكتشف الذكاء الاصطناعي الأنماط في سجلاتك',
        gettingStartedTitle: 'البدء',
        configureModelTask:
            'إعداد نموذج الذكاء الاصطناعي (الصورة -> إعداد النموذج)',
        postFirstRecordTask: 'انشر سجلك الأول',
        viewGeneratedTask:
            'اعرض البطاقات وملفات المعرفة التي أنشأها الذكاء الاصطناعي',
        sloganContent:
            'كل سجل تنشئه اليوم يصبح خيطاً مفيداً لنسختك المستقبلية.',
        kbContent: '''# دليل Memex

Memex تطبيق محلي أولاً وأصلي للذكاء الاصطناعي لتسجيل الحياة الشخصية.

## ما يمكنك فعله

- التقاط النصوص والصور والصوت في مسار واحد.
- ترك الذكاء الاصطناعي ينظم السجلات في بطاقات خط زمني وملاحظات معرفة.
- اكتشاف الأنماط بين السجلات من خلال بطاقات الرؤى.
- إبقاء البيانات على جهازك وتصديرها كملفات Markdown.

## البدء

1. أعد نموذج ذكاء اصطناعي.
2. انشر سجلك الأول.
3. افتح البطاقات والرؤى وملفات المعرفة التي تم إنشاؤها.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'الحالي',
        shuffle: 'تبديل',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'جارٍ البحث عن الصور الحديثة...',
        runModeAuto: 'تلقائي',
        runModeAskFirst: 'اسأل أولاً',
        runModeReadOnly: 'للقراءة فقط',
        runModeAutoDescription:
            'يتم تحديث السجلات والبطاقات والمستندات مباشرة.',
        runModeConfirmDescription: 'ينتظر كل تغيير موافقتك قبل التنفيذ.',
        runModeReadOnlyDescription: 'يجيب عن الأسئلة فقط ولا يغيّر البيانات.',
        runModeTitle: 'وضع التشغيل',
        approved: 'تمت الموافقة',
        denied: 'مرفوض',
        deny: 'رفض',
        allow: 'سماح',
        recordSaved: 'تم حفظ السجل',
        cardUpdated: 'تم تحديث البطاقة',
        cardCreated: 'تم إنشاء البطاقة',
        cardSaved: 'تم حفظ البطاقة',
        documentUpdated: 'تم تحديث المستند',
        documentCreated: 'تم إنشاء المستند',
        calendarEventCreated: 'تم إنشاء حدث التقويم',
        reminderCreated: 'تم إنشاء التذكير',
        insightSaved: 'تم حفظ الرؤية',
        done: 'تم',
        issue: 'يحتاج معالجة',
        running: 'قيد التشغيل',
        reasoningComplete: 'اكتمل التفكير',
        thinkingThroughRequest: 'جارٍ فهم الطلب',
        actionNeedsAttention: 'هناك إجراء يحتاج انتباهك',
        internalReasoningFinished: 'اكتمل التفكير الداخلي',
        planningNextStep: 'جارٍ تخطيط الخطوة التالية',
        toolActivity: 'نشاط الأدوات',
        toolSearch: 'بحث',
        toolFindFiles: 'بحث عن ملفات',
        toolRead: 'قراءة',
        toolReadBatch: 'قراءة دفعة',
        toolWrite: 'كتابة',
        toolEdit: 'تعديل',
        toolList: 'قائمة',
        toolMove: 'نقل',
        toolDelete: 'حذف',
        toolDelegateTask: 'تفويض مهمة',
        toolCreateUi: 'إنشاء UI',
        toolUpdateUi: 'تحديث UI',
        toolFindStyles: 'بحث عن أنماط',
        toolReadStyle: 'قراءة النمط',
        toolStyleLibrary: 'مكتبة الأنماط',
        toolSaveCard: 'حفظ البطاقة',
        toolCreateEvent: 'إنشاء حدث',
        toolCreateReminder: 'إنشاء تذكير',
        toolCancelReminderEvent: 'إلغاء تذكير/حدث',
        toolSearchCards: 'بحث في البطاقات',
        toolInspectCard: 'فحص البطاقة',
        toolUpdateInsight: 'تحديث الرؤية',
        toolSaveInsights: 'حفظ الرؤى',
        toolDeleteInsightCard: 'حذف بطاقة الرؤية',
        toolDeleteInsightTags: 'حذف وسوم الرؤية',
        failed: 'فشل',
        noOp: 'لا إجراء',
        needsInput: 'يحتاج إدخالاً',
        worker: 'مهمة فرعية',
        thinking: 'جارٍ التفكير...',
        workerToolCalls: 'استدعاءات أدوات المهمة الفرعية',
        workerResult: 'نتيجة المهمة الفرعية',
        arguments: 'المعاملات',
        result: 'النتيجة',
        approvalPrompt: (toolName) => 'الموافقة على: $toolName؟',
        toolCallCount: (count) => '$count استدعاءات أدوات',
        workingThroughActions: (count) => 'جارٍ تنفيذ $count إجراءات',
        completedActions: (count) => 'اكتمل $count إجراءات',
      );
}
