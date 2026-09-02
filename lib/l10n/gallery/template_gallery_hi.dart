import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsHi = [
  TemplateGallerySection(
    title: 'सामान्य',
    items: [
      TemplateGalleryItem(
        label: '1. क्लासिक कार्ड (पाठ नोट)',
        templateId: 'classic_card',
        title: 'नोट्स पढ़ना',
        data: {
          'content':
              'आज एक कैफे में "थिंकिंग, फास्ट एंड स्लो" का अध्याय 3 समाप्त हुआ। एंकरिंग प्रभाव के बारे में उदाहरण प्रभावशाली थे और मुझे याद दिलाया कि कैसे हमारी जानकारी का पहला भाग चुपचाप हर बाद के निर्णय को पूर्वाग्रहित कर सकता है।',
          'tags': ['पढ़ना', 'मनोविज्ञान'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'शाब्दिक',
    items: [
      TemplateGalleryItem(
        label: '2. स्निपेट कार्ड (टेक्स्ट स्निपेट)',
        templateId: 'snippet',
        title: 'तकनीकी उद्धरण',
        data: {
          'text':
              '**“कोई भी पर्याप्त रूप से उन्नत तकनीक जादू से अप्रभेद्य है।”**\\n\\n- आर्थर सी. क्लार्क',
          'style': 'default',
          'tags': ['उद्धरण', 'तकनीकी', 'भविष्य'],
        },
      ),
      TemplateGalleryItem(
        label: '3. आर्टिकल कार्ड (लंबा आर्टिकल)',
        templateId: 'article',
        title: 'प्रवाह अनुभव क्या है',
        data: {
          'body':
              '## प्रवाह क्या है?\\n\\nप्रवाह एक मनोवैज्ञानिक अवस्था है जिसे मिहाली सीसिक्सजेंटमिहाली द्वारा प्रस्तावित किया गया है। जब आप एक चुनौतीपूर्ण लेकिन साध्य कार्य में पूरी तरह से डूब जाते हैं, तो आप समय का ध्यान नहीं रखते हैं और आपका ध्यान पूरी तरह से केंद्रित होता है - यह प्रवाह है।\\n\\n>जब लोग वह करते हैं जो उन्हें वास्तव में पसंद है, तो वे अक्सर खुद को भूल जाते हैं।\\n\\nशोध से पता चलता है कि प्रवाह की स्थिति में लोग आमतौर पर सबसे अधिक उत्पादक होते हैं और सबसे ज्यादा खुशी भी महसूस करते हैं।',
        },
      ),
      TemplateGalleryItem(
        label: '4. वार्तालाप कार्ड (बातचीत)',
        templateId: 'conversation',
        title: 'एआई के साथ बातचीत',
        data: {
          'messages': [
            {
              'sender': 'एआई सहायक',
              'text':
                  'आज आप काफी उत्पादक थे! आपने क्या करवाया?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'आर्किटेक्चर डिज़ाइन और कोड समीक्षा समाप्त की। बहुत अच्छा लग रहा है.',
              'isMe': true,
            },
            {
              'sender': 'एआई सहायक',
              'text':
                  'बहुत बढ़िया! आज रात जल्दी आराम करना याद रखें, कल आपकी एक महत्वपूर्ण बैठक है।',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. कोट कार्ड (उद्धरण)',
        templateId: 'quote',
        title: 'आज का विचार',
        data: {
          'content':
              'उत्तम क्षण की प्रतीक्षा न करें. कार्य करें, और इस क्षण को अपने कार्य के माध्यम से परिपूर्ण बनने दें।',
          'author': 'Napoleon Hill',
          'source': 'सोचो और अमीर बनो',
        },
      ),
      TemplateGalleryItem(
        label: '6. कॉम्पैक्ट कार्ड (कॉम्पैक्ट पंक्ति)',
        templateId: 'compact_card',
        title: '💧 पानी का सेवन',
        wrapped: true,
        data: {
          'details': ['500ml', 'कप 4', 'आज का लक्ष्य 2000 मि.ली'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'तस्वीर',
    items: [
      TemplateGalleryItem(
        label: '7. स्नैपशॉट कार्ड (फोटो)',
        templateId: 'snapshot',
        title: 'गोधूलि क्षण',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'द बंड · शंघाई',
        },
      ),
      TemplateGalleryItem(
        label: '8. गैलरी कार्ड (एल्बम)',
        templateId: 'gallery',
        title: 'सप्ताहांत कैम्पिंग',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. वीडियो कार्ड (वीडियो)',
        templateId: 'video',
        title: 'वीडियो लॉग',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. कैनवास कार्ड (कैनवास)',
        templateId: 'canvas',
        title: 'माइंडमैप ड्राफ्ट',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'मात्रात्मक',
    items: [
      TemplateGalleryItem(
        label: '11. मेट्रिक कार्ड (मेट्रिक्स)',
        templateId: 'metric',
        title: 'स्वास्थ्य मेट्रिक्स',
        data: {
          'items': [
            {
              'title': 'गहन निद्रा',
              'value': 2.5,
              'unit': 'h',
              'label': 'कल रात',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'कदम',
              'value': 8342,
              'unit': 'steps',
              'label': 'आज',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'हृदय दर',
              'value': 72,
              'unit': 'bpm',
              'label': 'आराम',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. रेटिंग कार्ड (रेटिंग)',
        templateId: 'rating',
        title: 'मूवी रेटिंग',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'लुभावने दृश्य और समय तथा प्रेम पर एक दार्शनिक दृष्टिकोण जो देखने के बाद भी लंबे समय तक बना रहता है।',
        },
      ),
      TemplateGalleryItem(
        label: '13. मूड कार्ड (मूड)',
        templateId: 'mood',
        title: 'आज का मूड',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'नया प्रोजेक्ट शुरू हुआ और टीम अत्यधिक प्रेरित है।',
        },
      ),
      TemplateGalleryItem(
        label: '14. प्रगति कार्ड (प्रगति)',
        templateId: 'progress',
        title: 'वार्षिक लक्ष्य प्रगति',
        data: {
          'label': 'वार्षिक पठन योजना',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'लौकिक',
    items: [
      TemplateGalleryItem(
        label: '15. इवेंट कार्ड (इवेंट)',
        templateId: 'event',
        title: 'एआई उत्पाद समीक्षा बैठक',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'बिल्डिंग ए, टेक पार्क, पुडोंग न्यू एरिया, शंघाई',
        },
      ),
      TemplateGalleryItem(
        label: '16. अवधि कार्ड (टाइमर)',
        templateId: 'duration',
        title: 'पोमोडोरो टाइमर',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. टास्क कार्ड (कार्य)',
        templateId: 'task',
        title: 'पूर्ण उत्पाद आवश्यकताओं का विश्लेषण',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'प्रतिस्पर्धी विश्लेषण रिपोर्ट', 'completed': true},
            {'title': 'उपयोगकर्ता साक्षात्कार संश्लेषण', 'completed': true},
            {'title': 'आवश्यकताओं के दस्तावेज़ का पहला मसौदा', 'completed': false},
            {'title': 'पीआरडी समीक्षा बैठक', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. रूटीन कार्ड (आदत ट्रैकर)',
        templateId: 'routine',
        title: 'दैनिक ध्यान',
        data: {
          'habit_name': 'प्रतिदिन 10 मिनट का ध्यान',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. प्रक्रिया कार्ड (चरण)',
        templateId: 'procedure',
        title: 'बटर कुकी रेसिपी',
        data: {
          'steps': [
            'सामग्री तैयार करें: 200 ग्राम केक का आटा, 3 अंडे, 100 ग्राम मक्खन',
            'ओवन को 175°C पर पहले से गरम कर लीजिये',
            'मक्खन और चीनी को तब तक फेंटें जब तक मिश्रण हल्का न हो जाए',
            'एक-एक करके अंडे डालें और अच्छी तरह मिलाएँ',
            'आटे को छान लें और अच्छी तरह मिलाने तक मिलाएँ',
            '25 मिनट तक ओवन में बेक करें',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'इकाइयां,',
    items: [
      TemplateGalleryItem(
        label: '20. व्यक्ति कार्ड (व्यक्ति)',
        templateId: 'person',
        title: 'संपर्क',
        data: {
          'name': 'Alex Zhang',
          'relation': 'उत्पाद प्रबंधक',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. प्लेस कार्ड (स्थान)',
        templateId: 'place',
        title: 'पसंदीदा किताबों की दुकान',
        data: {
          'name': 'त्सुताया बुकस्टोर · जिंगान मंदिर',
          'address': '400 ताइक्सिंग रोड, जिंगान जिला, शंघाई',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. स्पेक शीट (उत्पाद विवरण)',
        templateId: 'spec_sheet',
        title: 'एप्पल वॉच सीरीज 9',
        data: {
          'subtitle': 'चतुर घड़ी',
          'specs': {
            'प्रदर्शन': '1.9" AMOLED',
            'बैटरी': '5 दिन की बैटरी लाइफ',
            'पानी प्रतिरोध': 'IP68',
            'वज़न': '32g',
            'चिप': 'Apple S9',
            'आकार': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. लेनदेन कार्ड (खर्च)',
        templateId: 'transaction',
        title: 'दोपहर के भोजन का खर्च',
        data: {
          'merchant': 'हटोंग नूडल हाउस',
          'amount': '¥ 68.00',
          'location': 'गुलौ स्ट्रीट, बीजिंग',
          'items': [
            {'name': 'हस्ताक्षर झाजियांगमियान (बड़ा)', 'amount': '¥ 38'},
            {'name': 'मैरीनेट किया हुआ अंडा', 'amount': '¥ 8'},
            {'name': 'ठंडा बीजिंग दही', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. लिंक कार्ड (लिंक)',
        templateId: 'link',
        title: 'स्पंदन दस्तावेज',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsHi = [
  TemplateGalleryItem(
    label: '1. टाइमलाइन कार्ड (आज की टाइमलाइन)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'आज की समयरेखा',
      'items': [
        {
          'time': '09:00',
          'title': 'गहरा काम',
          'content':
              'आर्किटेक्चर आरेख v2.0 तैयार किया और तीन महत्वपूर्ण बग ठीक किए।',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'दोपहर का भोजनावकाश',
          'content': 'हल्का सलाद, उसके बाद 20 मिनट की सैर।',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'भरा होना...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. बबल चार्ट (कीवर्ड बबल)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'सप्ताह के कीवर्ड',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'डिज़ाइन', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': '42 नोट्स पर आधारित विश्लेषण',
    },
  ),
  TemplateGalleryItem(
    label: '3. ट्रेंड लाइन (ट्रेंड चार्ट)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'मूड सूचकांक (पिछले 7 दिन)',
      'top_right_text': 'औसत: 7.2',
      'points': [
        {'label': 'मंगल', 'value': 3.5},
        {'label': 'बुध', 'value': 4.0},
        {'label': 'गुरु', 'value': 5.5},
        {'label': 'शुक्र', 'value': 8.5, 'is_highlight': true},
        {'label': 'बैठा', 'value': 7.0},
        {'label': 'सूरज', 'value': 6.5},
        {'label': 'सोम', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5 अंक', 'subtitle': 'शुक्रवार का मुख्य आकर्षण'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. बार चार्ट (बार तुलना)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'फोकस समय वितरण',
      'subtitle': 'एजेंट अंतर्दृष्टि: आपने कोडिंग पर सबसे अधिक प्रयास खर्च किया।',
      'unit': 'h',
      'items': [
        {'label': 'डिज़ाइन', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'कोडन',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'पढ़ना', 'value': 1.5, 'icon': '📚'},
        {'label': 'बैठक', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. प्रगति रिंग (लक्ष्य प्रगति)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'वार्षिक पढ़ने का लक्ष्य',
      'subtitle': '12 किताबें जानी हैं',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'पुरा होना।', 'value': 65, 'color': '#6366F1'},
        {'label': 'शेष', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. रडार चार्ट (रडार)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'क्षमता मॉडल',
      'badge': 'मासिक फोकस',
      'center_value': '78',
      'center_label': 'समग्र प्राप्तांक',
      'dimensions': [
        {'label': 'कार्यान्वयन', 'value': 80},
        {'label': 'सोच', 'value': 60},
        {'label': 'रचनात्मकता', 'value': 70},
        {'label': 'प्रभाव', 'value': 85},
        {'label': 'सीखना', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. हाइलाइट/उद्धरण (उद्धरण)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'भविष्य की भविष्यवाणी करने का सबसे अच्छा तरीका उसे बनाना है।',
      'quote_highlight': 'create it',
      'footer': '- पीटर ड्रूक्कर',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. रचना (विभाजन)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'आज ऊर्जा संरचना',
      'badge': 'कुशल',
      'headline_items': [
        {'label': 'कुल समय', 'value': '8.5h'},
        {'label': 'गहरा काम', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'कोडन', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'बैठक', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'पढ़ना', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'बहुत ही उत्पादक दिन',
    },
  ),
  TemplateGalleryItem(
    label: '9. कंट्रास्ट/रीफ़्रेमिंग (रीफ़्रेमिंग)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'एक विश्वास को फिर से परिभाषित करना',
      'emotion': 'neutral',
      'context_section': {
        'title': 'मौलिक विचार',
        'content': 'मैं बहुत व्यस्त हूं और मेरे पास नई चीजें सीखने का समय नहीं है।',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'नया दृष्टिकोण',
        'content':
            'व्यस्त रहने का मतलब है कि अभ्यास के माध्यम से सीखने के कई अवसर हैं। मैं करके सीख सकता हूँ.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. गैलरी/क्रॉनिकल (गैलरी)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'प्रेरणा के अंश',
      'headline': '3 Photos',
      'content': 'कुछ डिज़ाइन प्रेरणाएँ आज कैप्चर की गईं।',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'बनावट'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'रंग'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'रोशनी'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. मानचित्र कार्ड (मानचित्र)',
    templateId: 'map_card_v1',
    data: {
      'title': 'पैरों के निशान',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'दो शहरों की एक कहानी',
      'info_detail': 'इस सप्ताह बीजिंग और शंघाई के बीच आवागमन',
    },
  ),
  TemplateGalleryItem(
    label: '12. सारांश कार्ड (सारांश)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'सप्ताह 4: निर्णायक और जुड़ाव',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'एस-स्तर की स्थिति'},
      'insight_title': 'एजेंट अंतर्दृष्टि',
      'insight_content':
          'इस सप्ताह आपने मुख्य रूप से #AI एजेंट विकास पर ध्यान केंद्रित किया और कोड कमिट के लिए एक नया रिकॉर्ड बनाया। मैंने यह भी देखा कि आपने शुक्रवार की रात को पारिवारिक रात्रिभोज में भाग लिया था - यह "कड़ी मेहनत करें, पूरी तरह से जिएं" पैटर्न बहुत स्वस्थ है।',
      'metrics': [
        {'label': 'केंद्र', 'value': '32h'},
        {'label': 'मनोदशा', 'value': '8.2', 'color': '#10B981'},
        {'label': 'टिप्पणियाँ', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'सप्ताह की मुख्य बातें (3 चयनित)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'शुरू करना'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'पारिवारिक डिनर'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
