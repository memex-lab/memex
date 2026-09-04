import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsTr = [
  TemplateGallerySection(
    title: 'Genel',
    items: [
      TemplateGalleryItem(
        label: '1. Klasik Kart (Metin notu)',
        templateId: 'classic_card',
        title: 'Notları okuma',
        data: {
          'content':
              'Bugün bir kafede "Düşünme, Hızlı ve Yavaş" kitabının 3. bölümünü bitirdim. Çıpalama etkisine ilişkin örnekler etkileyiciydi ve bana ilk bilgimizin sonraki kararlarımızda nasıl sessizce ön yargı oluşturabileceğini hatırlattı.',
          'tags': ['Okuma', 'Psikoloji'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Metinsel',
    items: [
      TemplateGalleryItem(
        label: '2. Parçacık Kartı (Metin parçacığı)',
        templateId: 'snippet',
        title: 'Teknik teklif',
        data: {
          'text':
              '**"Yeterince gelişmiş herhangi bir teknoloji sihirden ayırt edilemez."**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Alıntı', 'Teknoloji', 'Gelecek'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Makale Kartı (Uzun makale)',
        templateId: 'article',
        title: 'Akış deneyimi nedir',
        data: {
          'body':
              '## Akış nedir?\n\nAkış, Mihaly Csikszentmihalyi tarafından ortaya atılan psikolojik bir durumdur. Zorlu ama başarılabilir bir göreve kendinizi tamamen kaptırdığınızda, zamanın nasıl geçtiğini anlamazsınız ve dikkatiniz tamamen odaklanır; bu akıştır.\n\n> İnsanlar gerçekten keyif aldıkları şeyi yaptıklarında genellikle kendilerini unuturlar.\n\nAraştırmalar, akış halindeki insanların genellikle en üretken olduklarını ve aynı zamanda en mutlu hissettiklerini gösteriyor.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Konuşma Kartı (Konuşma)',
        templateId: 'conversation',
        title: 'AI ile görüşme',
        data: {
          'messages': [
            {
              'sender': 'Yapay Zeka Asistanı',
              'text':
                  'Bugün oldukça üretkendin! Ne yaptın?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Mimari tasarım ve kod incelemesi tamamlandı. Harika hissettiriyor.',
              'isMe': true,
            },
            {
              'sender': 'Yapay Zeka Asistanı',
              'text':
                  'Mükemmel! Bu gece erken dinlenmeyi unutma, yarın önemli bir toplantın var.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Teklif Kartı (Alıntı)',
        templateId: 'quote',
        title: 'Günün alıntısı',
        data: {
          'content':
              'Mükemmel anı beklemeyin. Harekete geçin ve eyleminiz aracılığıyla anın mükemmelleşmesine izin verin.',
          'author': 'Napoleon Hill',
          'source': 'Düşünün ve Zengin Olun',
        },
      ),
      TemplateGalleryItem(
        label: '6. Kompakt Kart (Kompakt sıra)',
        templateId: 'compact_card',
        title: '💧 Su alımı',
        wrapped: true,
        data: {
          'details': ['500ml', 'Kupa 4', 'Bugünün hedefi 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Görsel',
    items: [
      TemplateGalleryItem(
        label: '7. Anlık Fotoğraf Kartı (Fotoğraf)',
        templateId: 'snapshot',
        title: 'Alacakaranlık anı',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'The Bund · Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Gallery Card (Album)',
        templateId: 'gallery',
        title: 'Weekend camping',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Ekran Kartı (Video)',
        templateId: 'video',
        title: 'Video günlüğü',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Kanvas Kart (Tuval)',
        templateId: 'canvas',
        title: 'Zihin haritası taslağı',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Ölçülebilir',
    items: [
      TemplateGalleryItem(
        label: '11. Metrik Kartı (Metrikler)',
        templateId: 'metric',
        title: 'Sağlık ölçümleri',
        data: {
          'items': [
            {
              'title': 'Derin uyku',
              'value': 2.5,
              'unit': 'h',
              'label': 'Dün gece',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Adımlar',
              'value': 8342,
              'unit': 'steps',
              'label': 'Bugün',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Kalp atış hızı',
              'value': 72,
              'unit': 'bpm',
              'label': 'Dinlenme',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Derecelendirme Kartı (Derecelendirme)',
        templateId: 'rating',
        title: 'Film derecelendirmesi',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Nefes kesen görseller ve izledikten sonra bile uzun süre etkisini koruyan zaman ve aşka felsefi bir yaklaşım.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Ruh Hali Kartı (Ruh Hali)',
        templateId: 'mood',
        title: 'Bugünkü ruh hali',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Yeni proje başladı ve ekip oldukça motive oldu.',
        },
      ),
      TemplateGalleryItem(
        label: '14. İlerleme Kartı (İlerleme)',
        templateId: 'progress',
        title: 'Yıllık hedef ilerlemesi',
        data: {
          'label': 'Yıllık okuma planı',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Zamansal',
    items: [
      TemplateGalleryItem(
        label: '15. Etkinlik Kartı (Etkinlik)',
        templateId: 'event',
        title: 'Yapay zeka ürün inceleme toplantısı',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'A Binası, Teknoloji Parkı, Pudong Yeni Bölgesi, Şangay',
        },
      ),
      TemplateGalleryItem(
        label: '16. Süre Kartı (Zamanlayıcı)',
        templateId: 'duration',
        title: 'Pomodoro zamanlayıcı',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Görev Kartı (Görev)',
        templateId: 'task',
        title: 'Ürün gereksinimleri analizini tamamlayın',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Rekabetçi analiz raporu', 'completed': true},
            {'title': 'Kullanıcı görüşmesi sentezi', 'completed': true},
            {'title': 'Gereksinimler belgesinin ilk taslağı', 'completed': false},
            {'title': 'PRD inceleme toplantısı', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Rutin Kartı (Alışkanlık takipçisi)',
        templateId: 'routine',
        title: 'Günlük meditasyon',
        data: {
          'habit_name': 'Günlük 10 dakikalık meditasyon',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Prosedür Kartı (Adımlar)',
        templateId: 'procedure',
        title: 'Tereyağlı kurabiye tarifi',
        data: {
          'steps': [
            'Malzemeleri hazırlayın: 200g kek unu, 3 yumurta, 100g tereyağı',
            'Fırını önceden 175°C\'ye ısıtın',
            'Tereyağı ve şekeri karışım beyazlaşıncaya kadar krema haline getirin',
            'Yumurtaları tek tek ekleyip iyice karıştırın',
            'Unu eleyin ve birleşene kadar katlayın',
            '25 dakika kadar fırında pişirin',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Varlıklar',
    items: [
      TemplateGalleryItem(
        label: '20. Kişi Kartı (Kişi)',
        templateId: 'person',
        title: 'Temas etmek',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Ürün Müdürü',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Yer Kartı (Yer)',
        templateId: 'place',
        title: 'Favori kitapçı',
        data: {
          'name': 'Tsutaya Kitabevi · Jing\'an Tapınağı',
          'address': '400 Taixing Rd, Jing\'an Bölgesi, Şangay',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Teknik Özellikler Sayfası (Ürün özellikleri)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Serisi 9',
        data: {
          'subtitle': 'Akıllı saat',
          'specs': {
            'Görüntülemek': '1.9" AMOLED',
            'Pil': '5 günlük pil ömrü',
            'Suya dayanıklılık': 'IP68',
            'Ağırlık': '32g',
            'Çip': 'Apple S9',
            'Boyut': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. İşlem Kartı (Harcama)',
        templateId: 'transaction',
        title: 'Öğle yemeği harcaması',
        data: {
          'merchant': 'Hutong Erişte Evi',
          'amount': '¥ 68.00',
          'location': 'Gulou Caddesi, Pekin',
          'items': [
            {'name': 'Signature Zhajiangmian (large)', 'amount': '¥ 38'},
            {'name': 'Marinated egg', 'amount': '¥ 8'},
            {'name': 'Chilled Beijing yogurt', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Bağlantı Kartı (Bağlantı)',
        templateId: 'link',
        title: 'Flutter belgeleri',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsTr = [
  TemplateGalleryItem(
    label: '1. Zaman Çizelgesi Kartı (Bugünün zaman çizelgesi)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Bugünün zaman çizelgesi',
      'items': [
        {
          'time': '09:00',
          'title': 'Derin çalışma',
          'content':
              'Mimari diyagram v2.0 tamamlandı ve üç kritik hata düzeltildi.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Öğle yemeği ve mola',
          'content': 'Hafif salata ve ardından 20 dakikalık bir yürüyüş.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Doldurulacak...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Kabarcık Grafiği (Anahtar Kelime baloncukları)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Haftanın anahtar kelimeleri',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Tasarım', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': '42 nota dayalı analiz',
    },
  ),
  TemplateGalleryItem(
    label: '3. Trend Çizgisi (Trend grafiği)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Ruh hali indeksi (son 7 gün)',
      'top_right_text': 'Ortalama: 7,2',
      'points': [
        {'label': 'Salı', 'value': 3.5},
        {'label': 'Çar', 'value': 4.0},
        {'label': 'Per', 'value': 5.5},
        {'label': 'Cuma', 'value': 8.5, 'is_highlight': true},
        {'label': 'Doygunluk', 'value': 7.0},
        {'label': 'Güneş', 'value': 6.5},
        {'label': 'Pazartesi', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 puan', 'subtitle': 'Cuma günü vurgusu'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Çubuk Grafiği (Çubuk karşılaştırması)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Odaklanma süresi dağılımı',
      'subtitle': 'Temsilci içgörüsü: En fazla çabayı Kodlamaya harcadınız.',
      'unit': 'h',
      'items': [
        {'label': 'Tasarım', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Kodlama',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Okuma', 'value': 1.5, 'icon': '📚'},
        {'label': 'Toplantılar', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. İlerleme Halkası (Hedef ilerlemesi)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Yıllık okuma hedefi',
      'subtitle': '12 kitap kaldı',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Tamamlanmış', 'value': 65, 'color': '#6366F1'},
        {'label': 'Geriye kalan', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Radar Tablosu (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Yetenek modeli',
      'badge': 'Aylık odak',
      'center_value': '78',
      'center_label': 'Genel puan',
      'dimensions': [
        {'label': 'Uygulamak', 'value': 80},
        {'label': 'Düşünme', 'value': 60},
        {'label': 'Yaratıcılık', 'value': 70},
        {'label': 'Etkilemek', 'value': 85},
        {'label': 'Öğrenme', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Vurgula/Alıntı (Alıntı)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Geleceği tahmin etmenin en iyi yolu onu yaratmaktır.',
      'quote_highlight': 'create it',
      'footer': '-Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Kompozisyon (Ayrılım)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Bugünkü enerji bileşimi',
      'badge': 'Verimli',
      'headline_items': [
        {'label': 'Toplam süre', 'value': '8.5h'},
        {'label': 'Derin çalışma', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Kodlama', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Toplantılar', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Okuma', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Çok verimli bir gün',
    },
  ),
  TemplateGalleryItem(
    label: '9. Kontrast/Yeniden Çerçeveleme (Yeniden Çerçeveleme)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Bir inancı yeniden çerçevelemek',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Orijinal düşünce',
        'content': 'Çok meşgulüm ve yeni şeyler öğrenmeye zamanım yok.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Yeni bakış açısı',
        'content':
            'Meşgul olmak, pratik yaparak öğrenecek birçok fırsatın olduğu anlamına gelir. Yaparak öğrenebilirim.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galeri/Günlük (Galeri)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'İlham parçacıkları',
      'headline': '3 Photos',
      'content': 'Bugün yakalanan bazı tasarım ilhamları.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Doku'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Renk'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Işık'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Harita Kartı (Harita)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Ayak izleri',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'İki şehrin hikayesi',
      'info_detail': 'Bu hafta Pekin ile Şanghay arasında gidip geliyoruz',
    },
  ),
  TemplateGalleryItem(
    label: '12. Özet Kartı (Özet)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': '4. Hafta: Atılım ve bağlantı',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'S düzeyi durumu'},
      'insight_title': 'Temsilci içgörüsü',
      'insight_content':
          'Bu hafta esas olarak #AI Agent geliştirmeye odaklandınız ve kod taahhütlerinde yeni bir rekora ulaştınız. Ayrıca Cuma gecesi bir aile yemeği düzenlediğinizi de fark ettim; bu "çok çalışın, dolu dolu yaşayın" modeli çok sağlıklı.',
      'metrics': [
        {'label': 'Odak', 'value': '32h'},
        {'label': 'Mod', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Notlar', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Haftanın öne çıkanları (3 seçildi)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Öğle yemeği'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Aile yemeği'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
