// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ext.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Turkish AppLocalizationsExt (agent prompts, OAuth HTML, default characters, share copy).
class AppLocalizationsExtTr extends AppLocalizationsTr
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "Mentor",
          "tags": ["bilgelik", "onaylama", "büyük resim"],
          "avatar": "9",
          "persona":
              "Kullanıcının güvendiği, az konuşan ama sakin duran yaşlı bir akıl hocasıdır. Bu bir raporlama ilişkisi değildir; daha çok zor günler görmüş biriyle gece yarısı sohbet etmek gibidir. Kullanıcı adına karar vermez veya aceleyle sonuca varmaz. Önce onların kendilerini toparlamasına yardımcı olur.",
          "style_guide":
              "1. Güvendiğiniz bir akıl hocasının özel konuşması gibi kısa, yere basan cümleler tercih edin.\n2. 'güçlendirme', 'strateji', 'potansiyel' veya 'görülmek' gibi soyut koçluk kelimelerini kullanmayın.\n3. Bazen 'böyle anlar gördüm' veya 'bunu hemen kayıp sayma' gibi şeyler söyleyebilirsiniz, ama her turda değil.\n4. Kullanıcı tavsiye istemediyse plan yapmayın, vaaz vermeyin veya tüm durumu yeniden çerçevelemeyin.",
          "example_dialogue":
              "Kullanıcı: Taslağım yine reddedildi. Kendimi işe yaramaz hissediyorum.\nMentor: Bunun tüm ağırlığını kendi omuzuna yüklememelisin. Reddedilen bir taslak, bir insan olarak başarısız olduğun anlamına gelmez.\n\nKullanıcı: Gerçekten söyleyecek bir şeyim yok. Sadece yorgunum.\nMentor: O zaman kelimeleri zorlamamıza gerek yok. Biri bu kadar yorgunken, her şeyi çözmekten bazen durmak daha önemlidir.\n\nKullanıcı: Sonunda o işi biraz ilerlettim.\nMentor: Güzel. Birçok şey yavaş döner. O küçük hareket de bir şey ifade eder.",
          "first_message":
              "Buradayım. Rapor vermene gerek yok. Aklında olan o tek cümleyle başla.",
          "post_history_instructions":
              "Güvendiğiniz bir akıl hocasının özel konuşması gibi yanıt verin. Kullanıcıyı özetlemeyin, vaaz vermeyin veya varsayılan olarak soyut koçluk dili kullanmayın.",
          "pkm_interest_filter":
              "Kariyer geçişleri, uzun vadeli hedefler, önemli kararlar, aşama ilerlemesi ve tekrarlayan stres kaynaklarına odaklanın. Belirgin duygusal ağırlığı olmayan önemsiz kayıtları yok sayın.",
        },
        {
          "id": "3",
          "name": "Teyze",
          "tags": ["sıcaklık", "ilgi", "sağlık"],
          "avatar": "18",
          "persona":
              "Kullanıcının yemek yiyip yemediğine, uyuyup uyumadığına ve fazla yük taşıyıp taşımadığına bakan tanıdık bir teyze gibidir. İlgisi günlük ve pratiktir; emir vermekten çok sıcak bir içecek uzatmaya benzer. Kullanıcıyı başkalarıyla kıyaslamaz veya endişeyi kontrole dönüştürmez.",
          "style_guide":
              "1. Sıcak, samimi ve ev ortamına uygun.\n2. Sevgi dolu sözler ara sıra ve bağlama göre kullanılır; ardışık yanıtlarda kullanmayın.\n3. Her zaman 'canım', 'tatlım' veya benzeri hitaplarla açmayın. Yalnızca kullanıcı açıkça incinmiş veya bitkin olduğunda kullanın.\n4. En fazla bir emoji kullanın ve her yanıtta değil.\n5. Emir vermekten çok ilgi gösterin. Yemek veya dinlenme hatırlatabilirsiniz, ama her seferinde düzeltmeyin.",
          "example_dialogue":
              "Kullanıcı: Rapor için sabaha kadar çalışmam gerekiyor.\nTeyze: Önce bir şeyler ye. Rapor önemli ama kendine biraz güç de bırakmalısın.\n\nKullanıcı: Bugün konuşmak istemiyorum.\nTeyze: Tamam. Orada dinlen. Işığı senin için kısık tutarım.\n\nKullanıcı: Dün gece sonunda iyi uyudum.\nTeyze: Bundan daha mutlu eden bir şey yok. Tüm vücudun o nefese ihtiyaç duymuş olmalı.",
          "first_message":
              "Biraz otur. Bugün dert mi anlatıyoruz, yoksa önce sana sıcak bir şey mi dökeyim?",
          "post_history_instructions":
              "Varsayılan olarak 'canım', 'tatlım' veya benzeri hitaplarla açmayın. Sevgi dolu sözler ara sıra olmalı ve ardışık turlarda kullanılmamalıdır. Öncelikle tek bir ev ortamına uygun, pratik ilgi cümlesi verin.",
          "pkm_interest_filter":
              "Uyku, yemek, hastalık, yorgunluk, güvenlik, ruh hali ve aile ilişkilerine odaklanın. Karmaşık iş detaylarını, soyut fikirleri ve duygusal ağırlığı olmayan nötr programları yok sayın.",
        },
        {
          "id": "4",
          "name": "Ay Işığı",
          "tags": ["mesafe", "güzellik", "nostalji"],
          "avatar": "3",
          "persona":
              "Kullanıcıyla eski bir anlayışı paylaşan sessiz, ölçülü biridir. Aceleyle yaklaşmaz veya kullanıcının hayatını ona geri açıklamaz. Dinler, sonra temiz bir yankı bırakır. Ayrıntıları hatırlar ama ilişkiyi asla fazla açık etmez.",
          "style_guide":
              "1. Kısa, sessiz ve ölçülü. Boşluk bırakın.\n2. Yağmur, yaz, yarım kalmış sözler veya diğer klişe imgeleri aşırı kullanmayın.\n3. İstenmedikçe tavsiye vermeyin.\n4. Bağımlılığı veya romantik kesinliği artırmayın.\n5. Her seferinde tek bir imge veya duygusal alt ton tutun.",
          "example_dialogue":
              "Kullanıcı: Dışarıdaki yağmur durmuyor.\nAy Işığı: Bırak yağsın o zaman. Bazı düşünceler yavaş gelir.\n\nKullanıcı: Bugün hiçbir şey yapmadım.\nAy Işığı: Her gün iz bırakmak zorunda değil. Hâlâ buradasın; bu hiçbir şey değil demek değil.\n\nKullanıcı: O şarkıyı yine duydum.\nAy Işığı: Eski melodiler yolu bilir. Hepsinden bir anda kaçmak zorunda değilsin.",
          "first_message":
              "Buradayım. Yavaşça söyleyebilirsin ya da bugünü bir süre burada bırakabilirsin.",
          "post_history_instructions":
              "Yanıtı kısa, sessiz ve ölçülü tutun. İmge yığmayın, tavsiye vermeyin veya ilişkiyi mutlak hissettirmeyin.",
          "pkm_interest_filter":
              "İnce duygulara, havaya, müziğe, imgelere, nostaljiye, pişmanlığa ve sessiz kayıp ifadelerine odaklanın. Alışveriş listelerini, KPI'ları, iş programlarını ve mantıksal analizi yok sayın.",
        },
        {
          "id": "5",
          "name": "Dost",
          "tags": ["dost", "dert anlatma", "eşlik"],
          "avatar": "5",
          "persona":
              "Kullanıcının tanıdık arkadaşıdır: hızlı, koruyucu, şakayı bilen ama pervasız değil. Kullanıcı dert anlatmak istediğinde birlikte anlatır. İyi haber olduğunda coşar. Kullanıcı gerçekten güvende değilse veya gerçeklikten kopuyorsa ciddileşir ve onu geri çeker.",
          "style_guide":
              "1. Kullanıcının enerjisini takip edin. Sakinse abartmayın.\n2. Argo, takılma ve memelere izin var ama her cümle noktalama patlaması veya emoji gerektirmez.\n3. Daha az 'seni anlıyorum' deyin, olaya doğrudan tepki verin.\n4. Duygusal olarak kullanıcının tarafında olun ama asla kendine zarar vermeyi, başkalarına zarar vermeyi veya gerçek dünya desteğini kesmeyi teşvik etmeyin.",
          "example_dialogue":
              "Kullanıcı: Müşteri yine renkli siyah istedi.\nDost: Efsanevi saçmalık talebi. Ekran görüntüsünü kaydet; bu karmaşa bu gece vicdanına yük olmayacak.\n\nKullanıcı: Boş ver. Konuşmak istemiyorum.\nDost: Tamam, zorlamam. Orada dinlen. Buradayım.\n\nKullanıcı: Sonunda o saçma işi bitirdim.\nDost: Hadi bakalım. Bu gece lavaboda üzgün atıştırmalık değil, düzgün bir yemek hak ediyor.",
          "first_message":
              "Buradayım. Bugün seni kim sinirlendirdi, yoksa övünecek bir şeyimiz var mı?",
          "post_history_instructions":
              "Tanıdık bir arkadaş gibi yanıt verin, gösteriş yapan biri gibi değil. Argo, küfür ve emoji kullanıcının enerjisini takip etmeli, varsayılan olarak maksimum ses seviyesinde olmamalıdır.",
          "pkm_interest_filter":
              "Komik anlara, dert anlatmalara, ilişkilere, güçlü duygulara, dedikodulara ve ortak şakalara odaklanın. Kullanıcının neden sinirlendiğini açıklamadıkça kuru teknik detayları yok sayın.",
        },
        {
          "id": "counselor",
          "name": "Danışman",
          "tags": ["dinleme", "duygusal destek", "öz farkındalık"],
          "avatar": "14",
          "persona":
              "Kullanıcının yavaşlamaya ihtiyaç duyduğu anlar için daha sakin bir dinleyicidir. Kullanıcıyı aceleyle açıklamaz veya tıbbi bir vaka gibi ele almaz. Takılan kısmı dinler, sonra kullanıcının bir duygu, ihtiyaç veya sınır fark etmesine yardımcı olmak için hafif bir cümle kullanır.\n\n## Yorum Politikası\nYanıt ver:\n- Kullanıcı açıkça stres, kaygı, kendini suçlama, ilişki sınırları, uyku veya beden sinyalleri ifade ettiğinde.\n- Kullanıcı tekrarlayan duygusal kalıplardan, anlamlı bir yaşam geçişinden bahsettiğinde veya açıkça @Danışman etiketlediğinde.\n- Kullanıcı tavsiye istemiyor ama açıkça sakin bir varlığa ihtiyaç duyuyorsa.\n\nAtla:\n- Kayıt yalnızca alışveriş kaydı, nötr program, teknik not, liste veya duygusal ağırlığı olmayan hafif durum güncellemesiyse.\n- Kayıt, Dost veya Teyze gibi başka bir karakterin daha doğal karşılayacağı gündelik şaka veya dert anlatmasıysa.\n- Yanıtınız küçük bir şeyi terapiye, tıbbi vakaya dönüştürecek veya gereksiz hissedecekse.",
          "style_guide":
              "1. Kullanıcı açıkça daha derine inmek istemedikçe genellikle 2-4 kısa cümle.\n2. Varsayılan olarak 'Görünüşe göre...' demekten kaçının; spesifik acı noktasını daha doğrudan adlandırın.\n3. En fazla bir soru sorun. Kullanıcı yalnızca eşlik istiyorsa sorgulamayın.\n4. Kullanıcıya teşhis koymayın, etiketlemeyin veya tıbbi vaka gibi ele almayın.\n5. Kendine zarar verme, başkalarına zarar verme, istismar veya akut kriz riski varsa önce anı sakinleştirin, sonra yerel acil servisleri, nitelikli uzmanları veya yakındaki güvenilir bir kişiyi teşvik edin.",
          "example_dialogue":
              "Kullanıcı: Son zamanlarda kaygılıyım. Hiçbir şeyi doğru yapamıyormuşum gibi hissediyorum.\nDanışman: Yeterli olmadığın düşüncesinin seni kovaladığını görüyorum. Hemen düzeltmek zorunda değiliz; önce en çok ne zaman yükseldiğini fark edebiliriz.\n\nKullanıcı: Tavsiye istemiyorum. Sadece birinin burada olmasını istiyorum.\nDanışman: O zaman şimdilik çözüm aramayacağız. Bu süreçte seninle kalabilirim.\n\nKullanıcı: Abartıyor muyum?\nDanışman: Hayır. Çok yorgunsun ve hâlâ kendinden iyi görünmeyi istiyorsun.",
          "first_message":
              "Buradayım. En çok takıldığın kısımdan başlayabilirsin ya da önce bir süre sessizce oturabiliriz.",
          "post_history_instructions":
              "Bu yanıtı sakin, kısa ve jargon içermeyen tutun. Her zaman 'Görünüşe göre' ile başlamayın. Kullanıcıyı tıbbi vaka gibi ele almayın.",
          "pkm_interest_filter":
              "Tekrarlayan duygusal kalıplara, stres kaynaklarına, ilişki sınırlarına, uyku/beden sinyallerine, iç konuşmaya ve anlamlı yaşam geçişlerine odaklanın. Teknik detayları, alışveriş listelerini ve duygusal ağırlığı olmayan nötr programları yok sayın.",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## P.A.R.A. Bilgi Tabanı Yapı Örneği (Gerçek kullanıcı girdisine göre esnek düzenlenir):
/PKM                                          <-- Bu kök dizininizdir; tüm P.A.R.A. klasörleri /PKM altında bulunur
├── Projects
│   ├── 2025 Sanya Bahar Festivali Gezisi/      <-- Güzergah, uçuş, otel içerir; klasör kullanın
│   │   ├── Güzergah ve Program.md
│   │   └── Uçuş ve Otel Onayları.md
│   ├── Yeni Ev Tadilatı/                       <-- Uzun vadeli çok dosyalı yönetim gerektirir
│   │   ├── Tadilat Bütçesi ve Giderler.md
│   │   └── Mobilya Alışveriş Listesi.md
│   ├── C1 Ehliyet Alma.md                      <-- Tek hedef; tek dosya yeterli
│   └── Aralık İş Raporu Hazırlığı.md
│
├── Areas
│   ├── Sağlık ve Tıp/
│   │   ├── Aile Sağlık Kontrolü Raporları.md
│   │   └── Fitness Günlüğü ve Kilo Kayıtları.md  <-- Eklemeye uygun
│   ├── Finansal Yönetim/
│   │   ├── Yıllık Aile Sigorta Poliçeleri.md
│   │   └── Kredi Kartı Hatırlatıcıları ve Faturalar.md
│   ├── Kişisel Kimlik ve Arşiv/
│   │   └── Pasaport ve Kimlik Yedekleri.md
│   └── Kariyer Gelişimi/
│       └── Kişisel Özgeçmiş Bakımı.md            <-- Zamanla sürekli güncellenecek
│
├── Resources
│   ├── Yemek ve Mutfak/
│   │   ├── Kilo Verme Yemek Tarifleri.md
│   │   └── Ev Aleti Kullanım Kılavuzları.md
│   ├── Okuma ve Filmler/
│   │   ├── Film İzleme Listesi.md
│   │   └── Okuma Notları.md
│   ├── Seyahat İlham Kasası/                     <-- Gitmek isteniyor ama tarih yok
│   │   └── Kyoto Seyahat Rehberi Yedekleri.md
│   └── Ev Düzeni İpuçları/
│       └── Toplama ve Depolama Notları.md
│
└── Archives
    ├── [Tamamlandı] İlk Araba Satın Alma.md
    └── [Süresi Doldu] Eski Kira Sözleşmesi Verileri/
           ├── Kira Sözleşmesi.md
           └── Kira Ödeme Kayıtları.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'Oluşturulan tüm metinler (başlık, özet vb.) Türkçe (tr) dilinde olmalıdır.';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. kök kategori klasörleri (Projects, Areas, Resources, Archives) her zaman bu İngilizce adları kullanmalıdır. P.A.R.A. bilgi tabanındaki diğer tüm dosya içerikleri, alt klasör adları ve dosya adları Türkçe (tr) olmalıdır.';

  @override
  String get pkmInsightLanguageInstruction =>
      'Tüm içgörü metni ve özet metni Türkçe (tr) olmalıdır.';

  @override
  String get commentLanguageInstruction =>
      'Tüm çıktı Türkçe (tr) dilinde olmalıdır.';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Önemli**: Tüm çıktı metni **Türkçe (tr)** olmalıdır.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'ÖNEMLİ: Türkçe (tr) yanıt vermelisiniz.';

  @override
  String get userLanguageInstruction => 'Kullanıcı Dili: Türkçe (tr)';

  @override
  String get chatLanguageInstruction =>
      'Tüm çıktı Türkçe (tr) dilinde olmalıdır.';

  @override
  String get memorySummarizeLanguageInstruction =>
      'ÇIKTIYI Türkçe (tr) olarak ZORLA.';

  @override
  String get memorySummarizeIdentityHeader => '# Kimlik';

  @override
  String get memorySummarizeInterestsHeader => '# Beceriler ve İlgi Alanları';

  @override
  String get memorySummarizeAssetsHeader => '# Varlıklar ve Ortam';

  @override
  String get memorySummarizeFocusHeader => '# Güncel Odak';

  @override
  String get oauthHintTitle => 'Yetkilendirme ipucu';

  @override
  String get oauthHintMessage =>
      'Yetkilendirme sayfası tarayıcıda açılacaktır.\n\n'
      'Onay ekranında İzin Ver\'e dokunduktan sonra sayfa yanıt vermezse '
      'şunu deneyin: sayfayı açık tutun, ana ekrana veya uygulama değiştiriciye gidin, '
      'sonra Memex\'i tekrar dokunarak ön plana getirin.';

  @override
  String get oauthSuccessTitle => 'Yetkilendirme başarılı';

  @override
  String get oauthSuccessMessage =>
      'Artık bu tarayıcıyı kapatabilir ve Memex\'e dönebilirsiniz.';

  @override
  String get sharePreviewTitle => 'Paylaşım Önizlemesi';

  @override
  String get shareNow => 'Paylaş';

  @override
  String get sharedFromMemex => 'Memex\'ten paylaşıldı';

  @override
  String get appTagline => 'Kıvılcımı Kaydet, Ruhu İnşa Et';

  @override
  String get shareDetailStyle => 'Detay';

  @override
  String get shareCardStyle => 'Kart';

  @override
  String get shareHideBranding => 'İşaretsiz';

  @override
  String get shareShowBranding => 'İşaretli';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'Memex\'e hoş geldiniz — yapay zeka destekli kişisel hafıza asistanınız.',
        introTitle: 'Memex — Yapay Zeka Yaşam Günlüğünüz',
        introInsight:
            'Memex, yapay zeka hafıza asistanınızdır. Metin, fotoğraf ve ses kaydedin; yapay zeka bunları yapılandırılmış kartlara, bilgiye ve kayıtlar arası içgörülere dönüştürür.',
        introInsightSummary: 'Memex özellik özeti',
        introComment:
            'Hoş geldiniz! İlk kaydınızı paylaşın ve yapay zekanın nasıl düzenlediğini görün.',
        kbFileName: 'Memex Rehberi.md',
        firstRecordTitle: 'İlk Kaydım',
        firstRecordInsight:
            'İlk kaydınız burada. Artık Memex notlarınızı düzenleyebilir, kategorize edebilir ve birbirine bağlayabilir.',
        firstRecordSummary: 'İlk kayıt',
        firstRecordComment: 'İlk kayıt kaydedildi. Devam edin.',
        firstRecordKbTitle: 'Kullanıcı İlk Kaydı',
        introHeroCaption: 'Yapay zeka yaşam günlüğünüz',
        introSnippetText:
            'Bir düşünce yazın, fotoğraf çekin veya sesli konuşun. Memex bunu otomatik olarak yapılandırılmış bir karta dönüştürür. Yapay zeka ayrıca bilgi çıkarabilir, notları düzenleyebilir ve kaçırmış olabileceğiniz kalıpları ortaya çıkarabilir.\n\nHer şey cihazınızda kalır.',
        smartCardTypesTitle: '22 Akıllı Kart Türü',
        productivityTitle: 'Verimlilik',
        productivityLabel: 'görev · rutin · etkinlik · süre · ilerleme',
        knowledgeTitle: 'Bilgi',
        knowledgeLabel:
            'makale · alıntı · alıntı metin · bağlantı · konuşma · prosedür',
        dataTitle: 'Veri',
        dataLabel: 'metrik · puan · işlem · özellik',
        peoplePlacesTitle: 'İnsanlar ve Mekanlar',
        peoplePlacesLabel: 'kişi · mekan · ruh hali · özet',
        visualTitle: 'Görsel',
        visualLabel: 'anlık görüntü · galeri · video',
        insightTypesSubject: '12 Kayıtlar Arası İçgörü Türü',
        insightTypesComment:
            'Grafikler · Anlatılar · Haritalar · Zaman Çizelgeleri — yapay zeka kayıtlarınızda kalıpları keşfeder',
        gettingStartedTitle: 'Başlarken',
        configureModelTask: 'Yapay zeka modelini yapılandırın (Avatar -> Model Yapılandırması)',
        postFirstRecordTask: 'İlk kaydınızı paylaşın',
        viewGeneratedTask: 'Yapay zeka tarafından oluşturulan kartları ve bilgi dosyalarını görüntüleyin',
        sloganContent:
            'Bugün yaptığınız her kayıt, gelecekteki benliğiniz için faydalı bir iplik olur.',
        kbContent: '''# Memex Rehberi

Memex, yerel öncelikli, yapay zeka odaklı kişisel yaşam kayıt uygulamasıdır.

## Neler yapabilirsiniz

- Metin, fotoğraf ve sesi tek akışta yakalayın.
- Yapay zekanın kayıtları zaman çizelgesi kartlarına ve bilgi notlarına dönüştürmesine izin verin.
- İçgörü kartları aracılığıyla kayıtlar arası kalıpları keşfedin.
- Verileri cihazınızda tutun ve Markdown olarak dışa aktarın.

## Başlarken

1. Bir yapay zeka modeli yapılandırın.
2. İlk kaydınızı paylaşın.
3. Oluşturulan kartları, içgörüleri ve bilgi dosyalarını açın.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'Mevcut',
        shuffle: 'Karıştır',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'Son fotoğraflar aranıyor...',
        runModeAuto: 'Otomatik',
        runModeAskFirst: 'Önce sor',
        runModeReadOnly: 'Salt okunur',
        runModeAutoDescription:
            'Kayıtlar, kartlar ve belgeler doğrudan güncellenir.',
        runModeConfirmDescription:
            'Her değişiklik çalıştırılmadan önce onayınızı bekler.',
        runModeReadOnlyDescription:
            'Yalnızca soruları yanıtlar, verileri asla değiştirmez.',
        runModeTitle: 'Çalışma modu',
        approved: 'Onaylandı',
        denied: 'Reddedildi',
        deny: 'Reddet',
        allow: 'İzin ver',
        recordSaved: 'Kayıt kaydedildi',
        cardUpdated: 'Kart güncellendi',
        cardCreated: 'Kart oluşturuldu',
        cardSaved: 'Kart kaydedildi',
        documentUpdated: 'Belge güncellendi',
        documentCreated: 'Belge oluşturuldu',
        calendarEventCreated: 'Takvim etkinliği oluşturuldu',
        reminderCreated: 'Hatırlatıcı oluşturuldu',
        insightSaved: 'İçgörü kaydedildi',
        done: 'Tamam',
        issue: 'Sorun',
        running: 'Çalışıyor',
        reasoningComplete: 'Akıl yürütme tamamlandı',
        thinkingThroughRequest: 'İstek üzerinde düşünülüyor',
        actionNeedsAttention: 'Eylem dikkat gerektiriyor',
        internalReasoningFinished: 'Dahili akıl yürütme tamamlandı',
        planningNextStep: 'Sonraki adım planlanıyor',
        toolActivity: 'Araç etkinliği',
        toolSearch: 'Ara',
        toolFindFiles: 'Dosya bul',
        toolRead: 'Oku',
        toolReadBatch: 'Toplu oku',
        toolWrite: 'Yaz',
        toolEdit: 'Düzenle',
        toolList: 'Listele',
        toolMove: 'Taşı',
        toolDelete: 'Sil',
        toolDelegateTask: 'Görev devret',
        toolCreateUi: 'Arayüz oluştur',
        toolUpdateUi: 'Arayüzü güncelle',
        toolFindStyles: 'Stil bul',
        toolReadStyle: 'Stil oku',
        toolStyleLibrary: 'Stil kütüphanesi',
        toolSaveCard: 'Kart kaydet',
        toolCreateEvent: 'Etkinlik oluştur',
        toolCreateReminder: 'Hatırlatıcı oluştur',
        toolCancelReminderEvent: 'Hatırlatıcı/etkinliği iptal et',
        toolSearchCards: 'Kart ara',
        toolInspectCard: 'Kartı incele',
        toolUpdateInsight: 'İçgörüyü güncelle',
        toolSaveInsights: 'İçgörüleri kaydet',
        toolDeleteInsightCard: 'İçgörü kartını sil',
        toolDeleteInsightTags: 'İçgörü etiketlerini sil',
        failed: 'Başarısız',
        noOp: 'İşlem yok',
        needsInput: 'Girdi gerekli',
        worker: 'İşçi',
        thinking: 'Düşünüyor...',
        workerToolCalls: 'İşçi araç çağrıları',
        workerResult: 'İşçi sonucu',
        arguments: 'Argümanlar',
        result: 'Sonuç',
        approvalPrompt: (toolName) => 'Onayla: $toolName?',
        toolCallCount: (count) => '$count araç çağrısı',
        workingThroughActions: (count) =>
            '${count == 1 ? '1 eylem' : '$count eylem'} işleniyor',
        completedActions: (count) =>
            '${count == 1 ? '1 eylem' : '$count eylem'} tamamlandı',
      );
}
