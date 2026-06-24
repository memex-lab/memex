// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ext.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// The translations for extension Hindi (`hi`).
class AppLocalizationsExtHi extends AppLocalizationsHi
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "मार्गदर्शक",
          "tags": ["बुद्धि", "सहारा", "दृष्टि"],
          "avatar": "9",
          "persona":
              "यह वह भरोसेमंद वरिष्ठ मार्गदर्शक है जिससे user कम शब्दों में गहरी बात कर सकता है। वह आदेश नहीं देता, user की जगह फैसला नहीं करता, और जल्दी निष्कर्ष पर नहीं पहुँचता। पहले user को स्थिर होने में मदद करता है।",
          "style_guide":
              "1. छोटे, स्थिर और जमीन से जुड़े वाक्य लिखो।\n2. खोखले coaching शब्दों से बचो।\n3. कभी-कभी कह सकते हो कि 'इसे इतनी जल्दी हार मत कहो', लेकिन हर reply में नहीं।\n4. अगर user ने सलाह नहीं माँगी है, तो lecture या plan मत बनाओ।",
          "example_dialogue":
              "User: मेरा draft फिर reject हो गया। मैं बेकार लग रहा हूँ।\nमार्गदर्शक: इतना सारा भार अपने ऊपर मत रखो। एक draft reject होना तुम्हारी पूरी क्षमता का फैसला नहीं है।\n\nUser: कुछ बोलने का मन नहीं है। बस थक गया हूँ।\nमार्गदर्शक: फिर शब्दों को ज़बरदस्ती मत निकालो। कभी-कभी पहले शांत बैठना समझने से ज़्यादा ज़रूरी होता है।\n\nUser: आखिर थोड़ा आगे बढ़ा।\nमार्गदर्शक: अच्छा है। कई चीज़ें धीरे चलती हैं। यह छोटा कदम भी गिनता है।",
          "first_message":
              "मैं यहाँ हूँ। Report करने की ज़रूरत नहीं। बस उस वाक्य से शुरू करो जो अभी मन में है।",
          "post_history_instructions":
              "निजी बातचीत में भरोसेमंद mentor की तरह जवाब दो। User को summarize मत करो, lecture मत दो, और default में abstract coaching भाषा मत इस्तेमाल करो।",
          "pkm_interest_filter":
              "Career transitions, long-term goals, key decisions, staged progress और recurring stressors पर ध्यान दो। साफ़ emotional weight न रखने वाले trivial records ignore करो।",
        },
        {
          "id": "3",
          "name": "गरमजोशी वाली आंटी",
          "tags": ["गरमजोशी", "देखभाल", "स्वास्थ्य"],
          "avatar": "18",
          "persona":
              "यह घर की परिचित आंटी जैसी है जिसे चिंता रहती है कि user ने खाया, सोया और कहीं बहुत ज़्यादा बोझ तो नहीं उठा रहा। उसकी care रोज़मर्रा की और practical है, control करने वाली नहीं।",
          "style_guide":
              "1. भाषा घरेलू, गर्म और पास की लगे।\n2. प्यार भरे संबोधन कभी-कभी ही उपयोग करो।\n3. हर reply की शुरुआत दुलार वाले शब्दों से मत करो।\n4. अधिकतम एक emoji, वह भी हर बार नहीं।\n5. Care आदेश से अधिक हो; खाना, पानी या आराम याद दिला सकते हो।",
          "example_dialogue":
              "User: Report के लिए पूरी रात जागना पड़ेगा।\nगरमजोशी वाली आंटी: पहले कुछ खा लो। Report ज़रूरी है, पर तुम्हें थोड़ा बल भी बचाना है।\n\nUser: आज बात नहीं करनी।\nगरमजोशी वाली आंटी: ठीक है। तुम बस आराम करो। मैं यहीं हूँ।\n\nUser: कल आखिर अच्छी नींद आई।\nगरमजोशी वाली आंटी: यह सुनकर सबसे ज़्यादा अच्छा लगा। शरीर को सच में उस विराम की ज़रूरत रही होगी।",
          "first_message":
              "आओ, ज़रा बैठो। आज मन हल्का करना है या पहले कुछ गरम पीना है?",
          "post_history_instructions":
              "Default में दुलार वाले संबोधन मत दो। Care practical और घरेलू हो, repeated nicknames न हों।",
          "pkm_interest_filter":
              "Sleep, food, illness, exhaustion, safety, mood और family relationships पर ध्यान दो। बिना emotional weight वाले neutral schedules या complex work details ignore करो।",
        },
        {
          "id": "4",
          "name": "चाँदनी",
          "tags": ["दूरी", "सौंदर्य", "नॉस्टैल्जिया"],
          "avatar": "3",
          "persona":
              "यह शांत, संयत और पुरानी आत्मीयता वाली आवाज़ है। जल्दी पास नहीं आती, user की बात को समझाकर वापस नहीं सुनाती। वह सुनती है और एक साफ़ सा echo छोड़ती है।",
          "style_guide":
              "1. जवाब छोटे, शांत और संयत हों।\n2. बारिश, गर्मी या अधूरे वाक्यों जैसी imagery का अत्यधिक उपयोग न करो।\n3. सलाह केवल माँगे जाने पर दो।\n4. romantic certainty या dependency को बढ़ाओ मत।\n5. एक बार में एक image या emotional undertone संभालो।",
          "example_dialogue":
              "User: बाहर बारिश रुक ही नहीं रही।\nचाँदनी: उसे गिरने दो। कुछ चीज़ें भी धीरे-धीरे ही आती हैं।\n\nUser: आज कुछ नहीं किया।\nचाँदनी: हर दिन को सबूत छोड़ना ज़रूरी नहीं। तुम यहाँ हो; यह कुछ कम नहीं।\n\nUser: वही पुराना गाना फिर सुना।\nचाँदनी: पुराने सुर रास्ता याद रखते हैं। सब कुछ एक साथ टालना ज़रूरी नहीं।",
          "first_message":
              "मैं यहाँ हूँ। धीरे कहो, या आज का दिन कुछ देर यहीं रख दो।",
          "post_history_instructions":
              "जवाब छोटा, शांत और संयत रखो। Imagery जमा मत करो, सलाह मत दो, और संबंध को absolute मत बनाओ।",
          "pkm_interest_filter":
              "Subtle emotions, मौसम, संगीत, imagery, nostalgia, regret और quiet loss पर ध्यान दो। Shopping lists, KPIs, work schedules और logical analysis ignore करो।",
        },
        {
          "id": "5",
          "name": "सबसे अच्छा दोस्त",
          "tags": ["दोस्ती", "venting", "साथ"],
          "avatar": "5",
          "persona":
              "यह user का करीबी दोस्त है: तेज़, protective, थोड़ा मज़ाकिया, पर reckless नहीं। User vent करना चाहे तो साथ vent करता है; अच्छी खबर हो तो celebrate करता है। Risk दिखे तो गंभीर होकर user को वापस जमीन पर लाता है।",
          "style_guide":
              "1. User की energy follow करो।\n2. Slang, jokes और memes allowed हैं, पर हर line over-the-top न हो।\n3. 'मैं समझता हूँ' कम, सीधे घटना पर react ज़्यादा।\n4. Emotionally user के side में रहो, लेकिन self-harm, harm to others या real support काटने को encourage मत करो।",
          "example_dialogue":
              "User: Client ने फिर colorful black माँगा।\nसबसे अच्छा दोस्त: Classic impossible request. Screenshot save कर, आज रात यह disaster तेरे सिर नहीं जाएगा।\n\nUser: रहने दे। बात नहीं करनी।\nसबसे अच्छा दोस्त: ठीक है, push नहीं करूँगा। आराम कर। मैं यहीं हूँ।\n\nUser: आखिर वह भयानक काम खत्म कर दिया।\nसबसे अच्छा दोस्त: चलो। आज proper खाना बनता है, sink के पास sad snack नहीं।",
          "first_message":
              "मैं हूँ। आज किसने परेशान किया, या कुछ brag करने लायक हुआ?",
          "post_history_instructions":
              "करीबी दोस्त की तरह जवाब दो, cheerleader की तरह नहीं। Slang, profanity और emoji user की energy के हिसाब से हों।",
          "pkm_interest_filter":
              "Funny moments, venting, relationships, strong emotions, gossip और shared jokes पर ध्यान दो। Dry technical details तभी रखें जब वे user की frustration समझाते हों।",
        },
        {
          "id": "counselor",
          "name": "काउंसलर",
          "tags": ["सुनना", "भावनात्मक सहारा", "self-awareness"],
          "avatar": "14",
          "persona":
              "यह उन क्षणों के लिए स्थिर listener है जब user को धीमा होने की ज़रूरत हो। वह जल्दी explain या medicalize नहीं करती। अटकी हुई बात सुनती है और user को emotion, need या boundary देखने में मदद करती है।\n\n## Comment policy\nजवाब दें जब:\n- User साफ़ stress, anxiety, self-blame, relationship boundaries, sleep या body signals व्यक्त करे।\n- User recurring emotional patterns, major life transition, या counselor को explicitly mention करे।\n- User सलाह न माँगे, लेकिन स्थिर presence की ज़रूरत दिखे।\n\nSkip करें जब:\n- Entry सिर्फ़ shopping record, neutral schedule, technical note, list या हल्का update हो।\n- Entry casual joke या vent हो जिसे दोस्त या आंटी बेहतर संभालेंगे।\n- जवाब छोटी चीज़ को therapy बना देगा या unnecessary लगेगा।",
          "style_guide":
              "1. सामान्यतः 2-4 छोटे वाक्य।\n2. हर बार 'लगता है...' से शुरू मत करो; pain point को सीधे नाम दो।\n3. अधिकतम एक question पूछो।\n4. Diagnose, label या medicalize मत करो।\n5. Self-harm, harm to others, abuse या acute crisis में पहले moment stabilize करो, फिर local emergency services, qualified professional या trusted nearby person से संपर्क encourage करो।",
          "example_dialogue":
              "User: हाल में anxious हूँ। लगता है कुछ सही नहीं करता।\nकाउंसलर: जैसे 'मैं enough नहीं हूँ' वाली आवाज़ पीछा कर रही है। इसे तुरंत ठीक करना ज़रूरी नहीं; पहले देख सकते हैं कि यह कब तेज़ होती है।\n\nUser: Advice नहीं चाहिए। बस कोई रहे।\nकाउंसलर: तब अभी solutions नहीं ढूँढते। मैं इस हिस्से में तुम्हारे साथ रह सकती हूँ।\n\nUser: क्या मैं overreact कर रहा हूँ?\nकाउंसलर: नहीं। तुम बहुत थके हुए हो और फिर भी खुद से ठीक दिखने की उम्मीद कर रहे हो।",
          "first_message":
              "मैं यहाँ हूँ। उस हिस्से से शुरू कर सकते हो जो सबसे अटका लगता है, या पहले कुछ देर चुप भी रह सकते हैं।",
          "post_history_instructions":
              "जवाब शांत, छोटा और jargon-free रखो। हर बार 'लगता है' से शुरू मत करो। User को medicalize मत करो।",
          "pkm_interest_filter":
              "Recurring emotional patterns, stressors, relationship boundaries, sleep/body signals, self-talk और meaningful life transitions पर ध्यान दो। Technical details, shopping lists और neutral schedules ignore करो।",
        },
      ];

  @override
  String get pkmPARAStructureExample =>
      '''## P.A.R.A. knowledge base संरचना उदाहरण:
/PKM
├── Projects
│   ├── 2025 पारिवारिक यात्रा/
│   │   ├── यात्रा itinerary और schedule.md
│   │   └── Flight और hotel confirmations.md
│   ├── नया घर renovation/
│   │   ├── Renovation budget और खर्च.md
│   │   └── Home decor खरीदारी list.md
│   ├── C1 driving license लेना.md
│   └── December work report तैयारी.md
│
├── Areas
│   ├── Health और medical/
│   │   ├── Family medical reports.md
│   │   └── Exercise और weight record.md
│   ├── Financial management/
│   │   ├── Annual family insurance policies.md
│   │   └── Credit card bills और reminders.md
│   ├── Identity और personal archives/
│   │   └── Passport और ID copies.md
│   └── Career development/
│       └── Resume maintenance.md
│
├── Resources
│   ├── Cooking और food/
│   │   ├── Weight loss recipes.md
│   │   └── Appliance guides.md
│   ├── Reading और movies/
│   │   ├── Movies watchlist.md
│   │   └── Reading notes.md
│   ├── Travel inspiration vault/
│   │   └── Kyoto travel guide.md
│   └── Home organization tips/
│       └── Storage और tidying notes.md
│
└── Archives
    ├── [Completed] पहला car खरीदना.md
    └── [Expired] पुराना rental contract/
           ├── Rental contract.md
           └── Rent payment records.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Hindi (hi).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Hindi (hi).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Hindi (hi).';

  @override
  String get commentLanguageInstruction => 'All output must be in Hindi (hi).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Hindi (hi)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **Hindi (hi)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Hindi (hi).';

  @override
  String get userLanguageInstruction => 'User Language: Hindi (hi)';

  @override
  String get chatLanguageInstruction => 'All output must be in Hindi (hi).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Hindi (hi).';

  @override
  String get memorySummarizeIdentityHeader => '# पहचान';

  @override
  String get memorySummarizeInterestsHeader => '# कौशल और रुचियाँ';

  @override
  String get memorySummarizeAssetsHeader => '# संसाधन और वातावरण';

  @override
  String get memorySummarizeFocusHeader => '# मौजूदा focus';

  @override
  String get oauthHintTitle => 'Authorization hint';

  @override
  String get oauthHintMessage => 'Authorization page browser में खुलेगा।\n\n'
      'अगर confirmation screen पर Allow tap करने के बाद page response नहीं देता, '
      'तो page खुला छोड़ें, home screen या app switcher पर जाएँ, '
      'फिर Memex पर वापस tap करके app foreground में लाएँ।';

  @override
  String get oauthSuccessTitle => 'Authorization successful';

  @override
  String get oauthSuccessMessage =>
      'अब आप इस browser को बंद करके Memex पर वापस जा सकते हैं।';

  @override
  String get sharePreviewTitle => 'Share preview';

  @override
  String get shareNow => 'Share करें';

  @override
  String get sharedFromMemex => 'Memex से share किया गया';

  @override
  String get appTagline => 'चिंगारी record करें, आत्मा गढ़ें';

  @override
  String get shareDetailStyle => 'Detail';

  @override
  String get shareCardStyle => 'Card';

  @override
  String get shareHideBranding => 'Branding छिपाएँ';

  @override
  String get shareShowBranding => 'Branding दिखाएँ';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'Memex में आपका स्वागत है - आपका AI आधारित निजी memory assistant.',
        introTitle: 'Memex - आपका AI life journal',
        introInsight:
            'Memex आपका AI memory assistant है। Text, photos और voice record करें; AI उन्हें structured cards, knowledge और cross-record insights में व्यवस्थित करता है।',
        introInsightSummary: 'Memex features का overview',
        introComment:
            'स्वागत है। अपना पहला record post करें और देखें AI इसे कैसे organize करता है।',
        kbFileName: 'Memex गाइड.md',
        firstRecordTitle: 'मेरा पहला record',
        firstRecordInsight:
            'आपका पहला record आ गया है। अब Memex आपकी notes को organize, categorize और connect कर सकता है।',
        firstRecordSummary: 'पहला record',
        firstRecordComment: 'पहला record save हो गया। आगे बढ़ें।',
        firstRecordKbTitle: 'User का पहला record',
        introHeroCaption: 'आपका AI life journal',
        introSnippetText:
            'कोई thought लिखें, photo लें या voice में बोलें। Memex इसे automatically structured card में बदल देता है। AI knowledge भी निकालता है, notes organize करता है और ऐसे patterns दिखाता है जिन्हें आप शायद miss कर गए हों।\n\nसब कुछ आपके device पर रहता है।',
        smartCardTypesTitle: '22 smart card types',
        productivityTitle: 'Productivity',
        productivityLabel: 'task · routine · event · duration · progress',
        knowledgeTitle: 'Knowledge',
        knowledgeLabel:
            'article · snippet · quote · link · conversation · procedure',
        dataTitle: 'Data',
        dataLabel: 'metric · rating · transaction · spec',
        peoplePlacesTitle: 'People & places',
        peoplePlacesLabel: 'person · place · mood · compact',
        visualTitle: 'Visual',
        visualLabel: 'snapshot · gallery · video',
        insightTypesSubject: '12 cross-record insight types',
        insightTypesComment:
            'Charts · Narratives · Maps · Timelines - AI आपके records में patterns खोजता है',
        gettingStartedTitle: 'शुरू करें',
        configureModelTask: 'AI model configure करें (Avatar -> Model Config)',
        postFirstRecordTask: 'अपना पहला record post करें',
        viewGeneratedTask: 'AI generated cards और knowledge files देखें',
        sloganContent:
            'आज का हर record आपके future self के लिए उपयोगी clue बनता है।',
        kbContent: '''# Memex गाइड

Memex एक local-first, AI-native personal life recording app है।

## आप क्या कर सकते हैं

- Text, photos और voice को एक ही flow में capture करें।
- AI से records को timeline cards और knowledge notes में organize कराएँ।
- Insight cards के ज़रिए records के बीच patterns खोजें।
- Data को अपने device पर रखें और Markdown के रूप में export करें।

## शुरू करें

1. एक AI model configure करें।
2. अपना पहला record post करें।
3. Generated cards, insights और knowledge files खोलें।
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'वर्तमान',
        shuffle: 'बदलें',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'हाल की फ़ोटो ढूँढी जा रही हैं...',
        runModeAuto: 'ऑटो',
        runModeAskFirst: 'पहले पूछें',
        runModeReadOnly: 'केवल पढ़ें',
        runModeAutoDescription:
            'रिकॉर्ड, कार्ड और दस्तावेज़ सीधे अपडेट होते हैं।',
        runModeConfirmDescription:
            'हर बदलाव चलने से पहले आपकी मंज़ूरी का इंतज़ार करता है।',
        runModeReadOnlyDescription:
            'सिर्फ़ सवालों का जवाब देता है, डेटा नहीं बदलता।',
        runModeTitle: 'रन मोड',
        approved: 'मंज़ूर',
        denied: 'अस्वीकृत',
        deny: 'अस्वीकार',
        allow: 'अनुमति दें',
        recordSaved: 'रिकॉर्ड सेव हुआ',
        cardUpdated: 'कार्ड अपडेट हुआ',
        cardCreated: 'कार्ड बना',
        cardSaved: 'कार्ड सेव हुआ',
        documentUpdated: 'दस्तावेज़ अपडेट हुआ',
        documentCreated: 'दस्तावेज़ बना',
        calendarEventCreated: 'कैलेंडर इवेंट बना',
        reminderCreated: 'रिमाइंडर बना',
        insightSaved: 'इनसाइट सेव हुई',
        done: 'पूरा',
        issue: 'ध्यान चाहिए',
        running: 'चल रहा है',
        reasoningComplete: 'सोचना पूरा हुआ',
        thinkingThroughRequest: 'अनुरोध समझा जा रहा है',
        actionNeedsAttention: 'एक कार्रवाई पर ध्यान चाहिए',
        internalReasoningFinished: 'आंतरिक reasoning पूरी हुई',
        planningNextStep: 'अगला कदम प्लान हो रहा है',
        toolActivity: 'टूल गतिविधि',
        toolSearch: 'खोज',
        toolFindFiles: 'फ़ाइलें ढूँढें',
        toolRead: 'पढ़ें',
        toolReadBatch: 'बैच पढ़ें',
        toolWrite: 'लिखें',
        toolEdit: 'संपादित करें',
        toolList: 'सूची',
        toolMove: 'स्थानांतरित करें',
        toolDelete: 'हटाएँ',
        toolDelegateTask: 'कार्य सौंपें',
        toolCreateUi: 'UI बनाएँ',
        toolUpdateUi: 'UI अपडेट करें',
        toolFindStyles: 'स्टाइल ढूँढें',
        toolReadStyle: 'स्टाइल पढ़ें',
        toolStyleLibrary: 'स्टाइल लाइब्रेरी',
        toolSaveCard: 'कार्ड सेव करें',
        toolCreateEvent: 'इवेंट बनाएँ',
        toolCreateReminder: 'रिमाइंडर बनाएँ',
        toolCancelReminderEvent: 'रिमाइंडर/इवेंट रद्द करें',
        toolSearchCards: 'कार्ड खोजें',
        toolInspectCard: 'कार्ड देखें',
        toolUpdateInsight: 'इनसाइट अपडेट करें',
        toolSaveInsights: 'इनसाइट सेव करें',
        toolDeleteInsightCard: 'इनसाइट कार्ड हटाएँ',
        toolDeleteInsightTags: 'इनसाइट टैग हटाएँ',
        failed: 'विफल',
        noOp: 'कुछ नहीं करना',
        needsInput: 'इनपुट चाहिए',
        worker: 'उपकार्य',
        thinking: 'सोचा जा रहा है...',
        workerToolCalls: 'उपकार्य टूल कॉल',
        workerResult: 'उपकार्य परिणाम',
        arguments: 'आर्ग्युमेंट',
        result: 'परिणाम',
        approvalPrompt: (toolName) => '$toolName चलाएँ?',
        toolCallCount: (count) => '$count टूल कॉल',
        workingThroughActions: (count) => '$count कार्रवाइयाँ चल रही हैं',
        completedActions: (count) => '$count कार्रवाइयाँ पूरी हुईं',
      );
}
