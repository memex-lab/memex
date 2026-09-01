// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get timesLabel => 'Kez';

  @override
  String modelSetAsDefault(Object modelId) {
    return '$modelId\'yi varsayılan model olarak ayarla';
  }

  @override
  String get retry => 'Yeniden dene';

  @override
  String get unknownModel => 'Bilinmeyen model';

  @override
  String get notSet => 'Ayarlanmadı';

  @override
  String get confirmClear => 'Temizlemeyi onayla';

  @override
  String get confirmClearTokenMessage =>
      'Mevcut kullanıcı silinsin mi? Kullanıcı kimliğini tekrar girmeniz gerekecektir.';

  @override
  String get cancel => 'İptal etmek';

  @override
  String get confirm => 'Onaylamak';

  @override
  String get tokenCleared => 'Kullanıcı temizlendi';

  @override
  String clearTokenFailed(Object error) {
    return 'Kullanıcı temizlenemedi: $error';
  }

  @override
  String get selectDateRangeOptional => 'Tarih aralığını seçin (isteğe bağlı):';

  @override
  String get startDate => 'Başlangıç ​​tarihi';

  @override
  String get endDate => 'Bitiş tarihi';

  @override
  String get select => 'Seçme';

  @override
  String get processLimitOptional => 'İşlem sınırı (isteğe bağlı)';

  @override
  String get leaveEmptyForAll => 'Tümünü işlemek için boş bırakın';

  @override
  String get startProcessing => 'İşlemeyi başlat';

  @override
  String get userIdNotFound => 'Kullanıcı kimliği bulunamadı';

  @override
  String createTaskFailed(Object error) {
    return 'Görev oluşturulamadı: $error';
  }

  @override
  String get reprocessCards => 'Kartları yeniden işle';

  @override
  String get reprocessCardsTaskCreated =>
      'Yeniden işleme isteği Super Agent\'ta kuyruğa alındı';

  @override
  String get reprocessCardsDownstreamMode => 'Kapsam';

  @override
  String get reprocessCardsCardOnly => 'Yalnızca kartlar';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Süper Temsilciden seçilen zaman çizelgesi kartlarını incelemesini ve yeniden oluşturmasını isteyin.';

  @override
  String get reprocessCardsRerunDownstream => 'Kartlar ve ilgili takipler';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Süper Temsilciden, gerektiğinde ilgili PKM ve içgörü güncellemelerini de dikkate almasını isteyin.';

  @override
  String get reanalyzeMediaAssets => 'Medya eklerini yeniden okuyun';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Süper Temsilciden kartları yeniden oluştururken ekli medyayı tekrar incelemesini isteyin.';

  @override
  String get regenerateComments => 'Yorumları yeniden oluştur';

  @override
  String get regenerateCommentsTaskCreated =>
      'Arka planda çalışan, oluşturulan yorumları yeniden oluşturma görevi';

  @override
  String get rebuildSearchIndex => 'Arama dizinini yeniden oluştur';

  @override
  String get rebuildSearchIndexSuccess =>
      'Arama dizini başarıyla yeniden oluşturuldu';

  @override
  String get rebuildSearchIndexFailed => 'Arama dizini yeniden oluşturulamadı';

  @override
  String get clearData => 'Verileri temizle';

  @override
  String get confirmClearDataMessage => 'Veriler temizlensin mi?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Kartlar, medya, bilgi dosyaları, öngörüler, bellek, sohbet geçmişi ve sistem durumu dahil olmak üzere mevcut kullanıcıya ait tüm yerel çalışma alanı verileri silinecek.\n\nBu işlem geri alınamaz!';

  @override
  String get clearFailedAgentContexts =>
      'Başarısız olan görüşme içeriğini temizle';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Insight ve Schedule aracıları için kayıtlı konuşma bağlamı temizlensin mi? Bu, önceki temsilci mesajları artık uyumlu olmadığında modelleri değiştirdikten sonra kullanışlıdır. Gerçekler, kartlar, bilgiler, anılar ve model ayarları silinmeyecektir.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count kayıtlı görüşme bağlamı temizlendi';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Görüşme bağlamı temizlenemedi: $error';
  }

  @override
  String get cloneToTestUser => 'Kullanıcıyı test etmek için klonlayın';

  @override
  String get confirmCloneToTestUserMessage =>
      'Geçerli çalışma alanını yeni bir yerel test kullanıcısına kopyalayın ve ona geçin. Aracı çalışma zamanı durumu kopyalanmaz. Mevcut kullanıcı verileriniz değiştirilmeyecektir.';

  @override
  String get testUserIdLabel => 'Kullanıcı kimliğini test edin';

  @override
  String get testUserIdHelper =>
      'Harf, sayı, kısa çizgi veya alt çizgi kullanın.';

  @override
  String get testUserIdInvalid =>
      'Yalnızca harf, sayı, kısa çizgi veya alt çizgi kullanın.';

  @override
  String get overwriteExistingTestUser =>
      'Mevcut test kullanıcısını aynı kimlikle değiştir';

  @override
  String testUserCloneSuccess(Object userId) {
    return '$userId test kullanıcısına geçildi';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Test kullanıcısı klonlanamadı: $error';
  }

  @override
  String get dataClearedSuccess => 'Veriler başarıyla temizlendi';

  @override
  String clearDataFailed(Object error) {
    return 'Veriler temizlenemedi: $error';
  }

  @override
  String get personalCenter => 'Kişisel merkez';

  @override
  String get viewLogs => 'Günlükleri görüntüle';

  @override
  String get systemAuthorization => 'Sistem yetkilendirmesi';

  @override
  String get aiCharacterConfig => 'AI karakter yapılandırması';

  @override
  String get modelConfig => 'Model yapılandırması';

  @override
  String get agentConfig => 'Aracı yapılandırması';

  @override
  String get experimentalLab => 'Laboratuvarlar';

  @override
  String get experimentalLabDescription =>
      'Daha sonra değişebilecek veya taşınabilecek deneysel özellikler.';

  @override
  String get modelUsageStats => 'Model kullanım istatistikleri';

  @override
  String get asyncTaskList => 'Eşzamansız görev listesi';

  @override
  String get clearLocalToken => 'Kullanıcıyı temizle';

  @override
  String get insightCardTemplates => 'İçgörü kartı şablonları';

  @override
  String get timelineCardTemplates => 'Zaman çizelgesi kartı şablonları';

  @override
  String get logViewer => 'Günlük görüntüleyici';

  @override
  String get autoRefresh => 'Otomatik yenileme';

  @override
  String get lineCount => 'Satır sayısı:';

  @override
  String get all => 'Tüm';

  @override
  String get schedule => 'Takvim';

  @override
  String get appLockConfig => 'Uygulama kilidi yapılandırması';

  @override
  String loadStatsFailed(Object error) {
    return 'İstatistikler yüklenemedi: $error';
  }

  @override
  String get overview => 'Genel Bakış';

  @override
  String get daily => 'Günlük';

  @override
  String get modelStatsByAgent => 'Temsilci tarafından';

  @override
  String get detail => 'Detay';

  @override
  String get date => 'Tarih';

  @override
  String get agent => 'Ajan';

  @override
  String get noData => 'Veri yok';

  @override
  String get totalCalls => 'Toplam çağrı';

  @override
  String get calls => 'Aramalar';

  @override
  String callsCount(Object count) {
    return '$count çağrı';
  }

  @override
  String get selectDateRange => 'Tarih aralığını seçin';

  @override
  String get totalTokens => 'Toplam jeton';

  @override
  String get cacheRate => 'Önbellek oranı';

  @override
  String get promptTokens => 'İstem jetonları';

  @override
  String get completionTokens => 'Tamamlama jetonları';

  @override
  String get cachedTokens => 'Önbelleğe alınmış jetonlar';

  @override
  String get thoughtTokens => 'Düşünce belirteçleri';

  @override
  String get prompt => 'Çabuk';

  @override
  String get completion => 'Tamamlama';

  @override
  String get cached => 'Önbelleğe alındı';

  @override
  String get thought => 'Düşünce';

  @override
  String get model => 'Modeli';

  @override
  String get scene => 'Sahne';

  @override
  String get sceneId => 'Sahne Kimliği';

  @override
  String get tokenUsage => 'Jeton kullanımı';

  @override
  String get handler => 'İşleyici';

  @override
  String get modelBreakdown => 'Model dökümü';

  @override
  String get callDetails => 'Arama ayrıntıları';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Kayıt ayrıntıları: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'LLM yapılandırması kaydedilemedi: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'HTML önizlemesi web\'de mevcut değildir. Lütfen mobilden görüntüleyiniz.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Kullanıcı bilgileri kaydedilemedi: $error';
  }

  @override
  String get totalEstimatedCost => 'Toplam tahmini maliyet';

  @override
  String get close => 'Kapalı';

  @override
  String get totalTokenConsumption => 'Toplam jeton tüketimi';

  @override
  String get dataLoadFailedRetry =>
      'Veri yükleme başarısız oldu, lütfen daha sonra tekrar deneyin.';

  @override
  String get timelineLoadFailedRetry =>
      'Zaman çizelgesi yüklemesi başarısız oldu. Lütfen daha sonra tekrar deneyin.';

  @override
  String get newPerspective => 'Yeni bakış açısı';

  @override
  String get startPoint => 'Başlangıç';

  @override
  String get endPoint => 'Son';

  @override
  String get originalInput => 'Orijinal giriş';

  @override
  String get referenceContent => 'Referans içeriği';

  @override
  String referenceWithTitle(Object title) {
    return 'Referans: $title';
  }

  @override
  String get actionCenterTitle => 'Bekleyen işlemler';

  @override
  String get noPendingActions => 'Bekleyen işlem yok';

  @override
  String get clarificationNeeded => 'Memex onaylamak istiyor';

  @override
  String get clarificationTextHint => 'Kısa bir yanıt yazın';

  @override
  String get clarificationTextRequired => 'Önce kısa bir cevap ekleyin';

  @override
  String get clarificationAnswered => 'Yanıtlandı';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Cevap: $answer';
  }

  @override
  String get answerSaved => 'Yanıt kaydedildi';

  @override
  String get clarificationOtherAnswer => 'Manuel giriş';

  @override
  String get clarificationNotSure =>
      'Emin değilim / söylememeyi tercih ediyorum';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'HAYIR';

  @override
  String get footprintMap => 'Ayak izi haritası';

  @override
  String get waypointPlaces => 'Ara nokta yerleri';

  @override
  String get unknownPlace => 'Bilinmeyen yer';

  @override
  String get releaseToSend => 'Göndermek için bırakın';

  @override
  String get selectFromAlbum => 'Albümden seç';

  @override
  String get clipboardPreviewTitle => 'Yeni pano';

  @override
  String get clipboardPreviewImageTitle => 'Pano resmi';

  @override
  String get clipboardPreviewImageDescription => 'Resim eklenmeye hazır';

  @override
  String get clipboardPreviewUnprocessed => 'Henüz yapıştırılmadı';

  @override
  String get clipboardPreviewPasteToInput => 'Girişe yapıştır';

  @override
  String get clipboardPreviewAddImageToInput => 'Resim ekle';

  @override
  String get clipboardPreviewImageFailed => 'Pano resmi okunamadı';

  @override
  String get tellAiWhatHappened => 'AI\'a ne olduğunu anlat...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Kayıt: $duration';
  }

  @override
  String get playing => 'Oynanıyor...';

  @override
  String get sendLabel => 'Göndermek';

  @override
  String attachedImagesMessage(Object count) {
    return '$count resim gönderildi';
  }

  @override
  String get noTaskData => 'Görev verisi yok';

  @override
  String createdAtDate(Object date) {
    return 'Oluşturuldu: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Güncellendi: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Süre: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Tekrar dene: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Ayrıntı yüklenemedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get loadFailed => 'Yükleme başarısız oldu';

  @override
  String loadHistoryFailed(Object error) {
    return 'Geçmiş yüklenemedi: $error';
  }

  @override
  String get reload => 'Yeniden yükle';

  @override
  String get aiInsightDetail => 'Analiz Detayı';

  @override
  String relatedRecordsCount(Object count) {
    return 'İlgili kayıtlar ($count)';
  }

  @override
  String get noRelatedRecords => 'İlgili kayıt yok';

  @override
  String get useFingerprintToUnlock =>
      'Kilidi açmak için parmak izini kullanın';

  @override
  String get locked => 'Kilitli';

  @override
  String get wrongPassword => 'Yanlış şifre';

  @override
  String get enterPassword => 'Şifreyi girin';

  @override
  String get memexLocked => 'Memex kilitlendi';

  @override
  String get calendarShortSun => 'Güneş';

  @override
  String get calendarShortMon => 'Pazartesi';

  @override
  String get calendarShortTue => 'Salı';

  @override
  String get calendarShortWed => 'Çar';

  @override
  String get calendarShortThu => 'Per';

  @override
  String get calendarShortFri => 'Cuma';

  @override
  String get calendarShortSat => 'Doygunluk';

  @override
  String noRecordsOnDate(Object date) {
    return '$date tarihinde kayıt yok';
  }

  @override
  String get footprintPath => 'Ayak izi yolu';

  @override
  String get lifeCompositionTable => 'Yaşam kompozisyonu';

  @override
  String get emotionReframe => 'Duygu yeniden çerçeveleme';

  @override
  String get chronicleOfThings => 'Şeylerin kroniği';

  @override
  String get goalProgress => 'Hedef ilerlemesi';

  @override
  String get trendChart => 'Trend grafiği';

  @override
  String get comparisonChart => 'Karşılaştırma tablosu';

  @override
  String get todayTimeFlow => 'Bugünün zaman akışı';

  @override
  String get aiInputHint => 'Anılar olsun, şimdiki zaman olsun, buradayım...';

  @override
  String get refreshSuperAgentStateTooltip => 'Memex Agent içeriğini temizle';

  @override
  String get refreshSuperAgentStateTitle =>
      'Memex Agent geçmişi bağlamı temizlensin mi?';

  @override
  String get refreshSuperAgentStateMessage =>
      'Görünür sohbet geçmişi kalacak ancak Memex Agent\'ın geçmiş çalışma zamanı bağlamı temizlenecek ve gelecekteki yanıtlar yeni bir bağlamdan başlayacak. Kalıcı bellek, bilgi tabanı dosyaları, kartlar ve kayıtlı diğer veriler etkilenmez. Memex Agent anormal davranmaya devam ettiğinde bunu kullanın. Devam etmek?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Bağlamı temizlemeden önce mevcut Memex Agent mesajının bitmesini bekleyin.';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex Agent bağlamı temizlendi';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Memex Agent bağlamı temizlenemedi: $error';
  }

  @override
  String get nothingHere => 'Henüz burada hiçbir şey yok';

  @override
  String get nothingHereHint =>
      'İlk kartınızı oluşturmak için aşağıdaki düğmeye dokunun';

  @override
  String get agentProcessing => 'Yapay zeka işliyor...';

  @override
  String get keepAppOpen => 'Uygulamayı kapatmayın';

  @override
  String get activityDetail => 'Etkinlik Detayı';

  @override
  String get noAgentActivityYet => 'Henüz temsilci etkinliği yok';

  @override
  String get processingEllipsis => 'İşleme...';

  @override
  String get agentBackgroundTitle => 'Memex Temsilcisi';

  @override
  String get agentBackgroundPausedTitle => 'Memex Aracısı duraklatıldı';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent\'ın dikkat etmesi gerekiyor';

  @override
  String get agentBackgroundStageIdle => 'Boşta';

  @override
  String get agentBackgroundStageProcessing => 'İşleme';

  @override
  String get agentBackgroundStageQueued => 'Sıraya alındı';

  @override
  String get agentBackgroundStageRetrying => 'Yeniden denemek bekleniyor';

  @override
  String get agentBackgroundStagePaused => 'Duraklatıldı';

  @override
  String get agentBackgroundStageCompleted => 'Tamamlanmış';

  @override
  String get agentBackgroundStageNeedsAttention => 'Dikkat edilmesi gerekiyor';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Medyayı analiz etme';

  @override
  String get agentBackgroundStageGeneratingCard => 'Kart oluşturuluyor';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Bilgiyi güncelleme';

  @override
  String get agentBackgroundStagePreparingComment => 'Yorum hazırlanıyor';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Yönlendirme takipleri';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'Çalıştırılıyor $running, Beklemede $pending, Yeniden Dene $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '$count sıraya alınmış görev işleniyor.';
  }

  @override
  String get agentBackgroundNoTasks => 'Arka plan görevi yok.';

  @override
  String get agentBackgroundStarting => 'İşleme başlıyor.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Tüm arka plan görevleri tamamlandı.';

  @override
  String get agentBackgroundFailedDetail =>
      'İşleme bir hata nedeniyle durduruldu.';

  @override
  String get agentBackgroundPausedDetail =>
      'İşleme duraklatıldı ve daha sonra devam edecek.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Bir sonraki işlem adımı bekleniyor.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Geçerli adım otomatik olarak yeniden denenecektir.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Ekleri ve yerel bağlamı okuma.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Kaydı bir zaman çizelgesi kartına dönüştürmek.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Yerel bilgi ve hafızanın güncellenmesi.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Asistan takibi hazırlamak.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Bu kart için takip işlemleri kontrol ediliyor.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Duraklatıldı - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Dikkat edilmesi gerekiyor - $summary';
  }

  @override
  String get settings => 'Ayarlar';

  @override
  String get languageSettings => 'Dil';

  @override
  String get languageSettingsDesc => 'Uygulama görüntüleme dilini değiştirme';

  @override
  String get noPendingActionsToast => 'Bekleyen işlem yok';

  @override
  String get knowledgeNewDiscovery => 'Bilgi yeni keşif';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count yeni analiz keşfedildi';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count mevcut analiz güncellendi';
  }

  @override
  String get sectionNewInsights => 'Yeni bilgiler';

  @override
  String get sectionUpdatedInsights => 'Güncellenen bilgiler';

  @override
  String get unnamedInsight => 'Adsız analiz';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get copy => 'Kopyala';

  @override
  String get selectedLocation => 'Seçilen konum';

  @override
  String get confirmLocationName => 'Konum adını onaylayın';

  @override
  String get confirmLocationNameHint =>
      'Adı düzenleyebilirsiniz (koordinatlar aynı kalır)';

  @override
  String get nameLabel => 'İsim';

  @override
  String get inputPlaceNameHint => 'Yer adını girin...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Koordinatlar: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Konumu onayla';

  @override
  String get welcomeToMemex => 'Memex\'e hoş geldiniz';

  @override
  String get createUserIdToStart => 'Profilinizi oluşturun';

  @override
  String get userIdLabel => 'Adınız / Takma Adınız';

  @override
  String get userIdHint => 'Adınızı veya takma adınızı girin';

  @override
  String get pleaseEnterUserId => 'Lütfen adınızı girin';

  @override
  String get userIdMaxLength => 'Ad 50 karakteri geçmemelidir';

  @override
  String get startUsing => 'Devam etmek';

  @override
  String get userIdTip =>
      'Bu, deneyiminizi kişiselleştirmek için kullanılacaktır.';

  @override
  String get setupModelConfigTitle => 'Yapay zeka modeli kurma';

  @override
  String get setupModelConfigSubtitle =>
      'Memex\'in kayıtları düzenlemek, görüntüleri analiz etmek ve içgörüler oluşturmak için öncü bir yapay zeka modeline ihtiyacı var. Bir bağlantı yöntemi seçin.';

  @override
  String get setupModelConfigComplete => 'Tamamla ve Git';

  @override
  String get aiService => 'Memex Model Hizmeti';

  @override
  String get aiModelHubTitle => 'Yapay zeka modelleri ve hizmetleri';

  @override
  String get aiModelHubSubtitle =>
      'Memex\'in resmi hizmetini seçin veya kendi sağlayıcınızı getirin. Gelişmiş model yönlendirme, ihtiyacınız olduğunda kullanılabilir durumda kalır.';

  @override
  String get aiSetupCurrentStatusTitle => 'Mevcut kurulum';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'AI hizmeti yapılandırılmadı';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Kayıtlar, medya ve öngörüler için yapay zeka organizasyonunu etkinleştirmek üzere bir bağlantı yöntemi seçin.';

  @override
  String get aiSetupStatusMemexTitle => 'Memex resmi hizmeti kullanılıyor';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex, Memex hesabınız tarafından yönetilen resmi bağlantıyı ve API kimlik bilgilerini kullanacaktır.';

  @override
  String get aiSetupStatusCustomTitle => 'Özel sağlayıcı ayarlarını kullanma';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex, yapılandırılmış sağlayıcı kimlik bilgilerinizi ve model rolü seçimlerinizi kullanacaktır.';

  @override
  String get aiSetupChooseConnectionTitle => 'Bir bağlantı yöntemi seçin';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Memex\'in yapay zeka modellerine nasıl erişmesini istediğinizle eşleşen yolla başlayın.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Resmi AI hizmetini kullanmak için Memex\'te oturum açın.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Kendi sağlayıcınızı ve API anahtarınızı ekleyin.';

  @override
  String get aiSetupCustomPageTitle => 'Özel yapay zeka hizmeti';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Önce sağlayıcı kimlik bilgilerini yapılandırın, ardından Memex\'in kullanması gereken modeli seçin.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Sağlayıcı ve API anahtarları';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama veya başka bir uyumlu sağlayıcıyı ekleyin veya düzenleyin.';

  @override
  String get modelRolesTitle => 'Birincil modeli seçin';

  @override
  String get modelRolesDescription =>
      'Super Agent, metin ve resim girişleri için tek bir model kullanır. Gelişmiş aracı geçersiz kılmaları aşağıda mevcuttur.';

  @override
  String get textModelRoleTitle => 'Birincil model';

  @override
  String get textModelRoleDescription =>
      'Super Agent tarafından metin, görseller, kartlar, bilgi, içgörüler, sohbet, yorumlar ve hafıza için kullanılır.';

  @override
  String get modelConnectionsTitle => 'Model sağlayıcıları ve API anahtarları';

  @override
  String get modelConnectionsDescription =>
      'Memex\'in resmi hizmetine bağlanın veya kendi sağlayıcı kimlik bilgilerinizi ekleyin.';

  @override
  String get relatedAiCapabilitiesTitle => 'Gelişmiş ve ilgili yetenekler';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Temsilci atamalarına, konum sağlayıcısına ve konuşma transkripsiyon davranışına ince ayar yapın.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Hizmet yetenekleri';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Memex\'in konuşma ve ters coğrafi kodlama gibi bitişik yapay zeka destekli yetenekler için kullandığı sağlayıcıları seçin.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Gelişmiş model yönlendirme';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Bireysel aracıların farklı sağlayıcılar veya model yapılandırmaları kullanmasını isteyen uzman kullanıcılar için.';

  @override
  String get locationProviderSettings => 'Konum sağlayıcı';

  @override
  String get speechProviderSettings => 'Konuşma transkripsiyonu';

  @override
  String get advancedAgentModelAssignments => 'Aracı modeli atamaları';

  @override
  String get openAdvancedAgentModelAssignments =>
      'Bireysel aracıları geçersiz kıl';

  @override
  String get noConfiguredModelOptions =>
      'Model rollerini seçmeden önce bir sağlayıcı veya API anahtarı ekleyin.';

  @override
  String get modelSlotUpdated => 'Model rolü güncellendi';

  @override
  String get aiServiceMemexRouteTitle => 'Memex aracılığıyla bağlanın';

  @override
  String get aiServiceLongDescription =>
      'Memex, yaşam kayıtlarını, bilgi notlarını ve sosyal bağlamı düzenlemek, daha derin içgörüler keşfetmek ve kalıcı hafıza ile yapay zeka yoldaşlığı sağlamak için çok aracılı bir sistem kullanıyor. Verileriniz, veri özgürlüğünü ve taşınabilirliğini koruyarak düz metin Markdown olarak depolanır.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Bir API anahtarım var';

  @override
  String get aiServiceCustomModelDescription =>
      'OpenAI, Anthropic, DeepSeek, Gemini veya başka bir sağlayıcıdan zaten bir API anahtarınız varsa önce bunu seçin.';

  @override
  String get enableAiService => 'Memex\'e bağlanın';

  @override
  String get aiServiceReadyToast => 'Yapay zeka organizasyonu açık';

  @override
  String get aiServiceSettingsDescription =>
      'API anahtarınız yoksa ana model hizmetlere bağlanmak için Memex hesabını kullanın.';

  @override
  String get advancedModelConfiguration => 'API anahtarını yapılandırın';

  @override
  String get skipForNow => 'Şimdilik atla';

  @override
  String get clearAuth => 'Yetkilendirmeyi temizle';

  @override
  String get authorizing => 'Yetki veriliyor...';

  @override
  String authFailed(Object error) {
    return 'Kimlik doğrulama başarısız oldu: $error';
  }

  @override
  String get authorized => 'Yetkili';

  @override
  String authorizedAs(Object email) {
    return '$email olarak yetkilendirildi';
  }

  @override
  String get authorizedSuccessfully => 'Yetkilendirme başarılı';

  @override
  String get reAuthorize => 'Yeniden yetkilendir';

  @override
  String get authorizeWithOpenAi => 'OpenAI ile yetkilendir';

  @override
  String get authorizeWithGoogle => 'Google ile yetkilendir';

  @override
  String get config => 'Yapılandırma';

  @override
  String get calendar => 'Takvim';

  @override
  String get reminders => 'Hatırlatıcılar';

  @override
  String get writeToSystemFailed => 'Sisteme yazılamadı';

  @override
  String permissionRequired(Object name) {
    return '$name izin gerekli';
  }

  @override
  String permissionRationale(Object name) {
    return 'Sizin için oluşturabilmemiz için lütfen uygulamanın Ayarlar\'da $name cihazınıza erişmesine izin verin.';
  }

  @override
  String get goToSettings => 'Ayarlar\'a gidin';

  @override
  String get unknownAction => 'Bilinmeyen eylem';

  @override
  String get discoveredCalendarEvent => 'Onay bekleyen takvim etkinliği';

  @override
  String get discoveredReminder => 'Onay bekleyen hatırlatıcı';

  @override
  String get addToCalendar => 'Takvime ekle';

  @override
  String get addToReminders => 'Hatırlatıcılara ekle';

  @override
  String get systemActionPendingExplanation =>
      'Henüz eklenmedi. İzin istemek ve cihazınıza eklemek için aşağıya dokunun.';

  @override
  String addedToSuccess(Object target) {
    return '$target öğesine başarıyla eklendi';
  }

  @override
  String get ignore => 'Görmezden gelmek';

  @override
  String get confirmDelete => 'Silmeyi onayla';

  @override
  String get confirmDeleteSessionMessage =>
      'Bu görüşme silinsin mi? Bu geri alınamaz.';

  @override
  String get delete => 'Silmek';

  @override
  String get deleteSuccess => 'Başarıyla silindi';

  @override
  String deleteFailed(Object error) {
    return 'Silinemedi: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count gün önce';
  }

  @override
  String get chatHistory => 'Sohbet geçmişi';

  @override
  String get enterFullScreenTooltip => 'Tam ekrana girin';

  @override
  String get exitFullScreenTooltip => 'Tam ekrandan çık';

  @override
  String get noConversations => 'Konuşma yok';

  @override
  String loadSessionListFailed(Object error) {
    return 'Oturum listesi yüklenemedi: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Dün $time';
  }

  @override
  String get newChat => 'Yeni sohbet';

  @override
  String messageCount(Object count) {
    return '$count mesaj';
  }

  @override
  String get organize => 'Organize et';

  @override
  String get pkmCategoryProject => 'Proje';

  @override
  String get pkmCategoryProjectSubtitle =>
      'Kısa vadeli · Hedefler · Son teslim tarihleri';

  @override
  String get pkmCategoryArea => 'Alan';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Uzun Vadeli · Sorumluluk · Standartlar';

  @override
  String get pkmCategoryResource => 'Kaynak';

  @override
  String get pkmCategoryResourceSubtitle => 'İlgi Alanları · İlham · Rezerv';

  @override
  String get pkmCategoryArchive => 'Arşiv';

  @override
  String get pkmCategoryArchiveSubtitle => 'Bitti · Hareketsiz · Referans';

  @override
  String get recentChanges => 'Son değişiklikler';

  @override
  String get noRecentChangesInThreeDays => 'Son 3 günde değişiklik yok';

  @override
  String get unpinned => 'Sabitleme kaldırıldı';

  @override
  String get pinnedStyle => 'Stil sabitlendi';

  @override
  String operationFailed(Object error) {
    return 'İşlem başarısız oldu: $error';
  }

  @override
  String get refreshingInsightData =>
      'Analiz verileri yenileniyor. Bu işlem biraz zaman alabilir...';

  @override
  String refreshFailed(Object error) {
    return 'Yenileme başarısız oldu: $error';
  }

  @override
  String get sortUpdated => 'Sıralama düzeni güncellendi';

  @override
  String sortSaveFailed(Object error) {
    return 'Sıralama kaydedilemedi: $error';
  }

  @override
  String get insightCardDeleted => 'Analiz kartı silindi';

  @override
  String deleteFailedShort(Object error) {
    return 'Silinemedi: $error';
  }

  @override
  String get knowledgeInsight => 'Bilgi içgörüsü';

  @override
  String get completeSort => 'Sıralamayı tamamla';

  @override
  String get noKnowledgeInsight => 'Bilgi içgörüsü yok';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count arka plan görevleri hâlâ işleniyor.';
  }

  @override
  String get insightUnavailableMessage =>
      'Bu analiz hâlâ oluşturuluyor veya güncelleniyor. Analizleri yenileyin ve daha sonra tekrar deneyin.';

  @override
  String get artifactOpen => 'Açık';

  @override
  String get updating => 'Güncelleniyor...';

  @override
  String get update => 'Güncelleme';

  @override
  String get enabled => 'Etkinleştirilmiş';

  @override
  String get disabled => 'Engelli';

  @override
  String get appLockOn => 'Uygulama kilidi etkin';

  @override
  String get appLockOff => 'Uygulama kilidi devre dışı bırakıldı';

  @override
  String get enableAppLockFirst =>
      'Lütfen önce uygulama kilidini etkinleştirin';

  @override
  String get enterFourDigitPassword => '4 haneli şifreyi girin';

  @override
  String get passwordSetAndLockOn =>
      'Şifre ayarlandı ve uygulama kilidi etkinleştirildi';

  @override
  String get appLockSettings => 'Uygulama kilidi ayarları';

  @override
  String get enableAppLock => 'Uygulama kilidini etkinleştir';

  @override
  String get enableAppLockSubtitle => 'Uygulamayı başlatırken şifre gerekli';

  @override
  String get enableBiometrics => 'Biyometriyi etkinleştir';

  @override
  String get biometricsSubtitle =>
      'Kilidi açmak için Face ID veya Touch ID\'yi kullanın';

  @override
  String get changePassword => 'Şifre değiştir';

  @override
  String get setFourDigitPassword => '4 haneli şifre belirleyin';

  @override
  String get reenterPasswordToConfirm => 'Onaylamak için şifreyi tekrar girin';

  @override
  String get passwordMismatch => 'Şifreler eşleşmiyor. Lütfen tekrar deneyin.';

  @override
  String confirmDeleteCharacter(Object name) {
    return '\"$name\" karakteri silinsin mi? Bu geri alınamaz.';
  }

  @override
  String get configureAiCharacter => 'AI karakterini yapılandırın';

  @override
  String get addCharacter => 'Karakter ekle';

  @override
  String get addCharacterSubtitle =>
      'İçgörü ekibinize katılmak için AI karakterlerini seçin. Yaşam verilerinizi farklı açılardan analiz edecekler.';

  @override
  String get noCharacters => 'Karakter yok';

  @override
  String loadCharacterFailed(Object error) {
    return 'Karakterler yüklenemedi: $error';
  }

  @override
  String get noTags => 'Etiket yok';

  @override
  String get createSuccess => 'Başarıyla oluşturuldu';

  @override
  String get updateSuccess => 'Başarıyla güncellendi';

  @override
  String saveFailed(Object error) {
    return 'Kaydetme başarısız oldu: $error';
  }

  @override
  String get newCharacter => 'Yeni karakter';

  @override
  String get editCharacter => 'Karakteri düzenle';

  @override
  String get save => 'Kaydetmek';

  @override
  String get characterName => 'Karakter adı';

  @override
  String get characterNameHint => 'Karakterinize bir isim verin';

  @override
  String get pleaseEnterCharacterName => 'Lütfen karakter adını girin';

  @override
  String get tagsLabel => 'Etiketler';

  @override
  String get tagsHint =>
      'örneğin bilgelik, tanınma, makro\nBirden fazla etiketi virgülle ayırın';

  @override
  String get characterPersonaLabel => 'Karakter kişiliği';

  @override
  String get characterPersonaHint =>
      'Persona, stil kılavuzu, örnek diyalog, bilgi filtreleri vb. ekleyin.\nBölüm başlıkları için ## kullanın.';

  @override
  String get pleaseEnterCharacterPersona =>
      'Lütfen karakterin kişiliğini girin';

  @override
  String permissionRequestError(Object error) {
    return 'İzin isteği hatası: $error';
  }

  @override
  String get permissionRequiredTitle => 'İzin gerekli';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Bu izni kalıcı olarak reddettiniz veya sistem bunu gerektiriyor. Lütfen sistem ayarlarında etkinleştirin.';

  @override
  String get getting => 'Edinme...';

  @override
  String get unauthorized => 'Yetkisiz';

  @override
  String get authorizedGoToSettings =>
      'Yetkili. Değiştirmek için sistem ayarlarına gidin.';

  @override
  String get location => 'Konum';

  @override
  String get locationPermissionReason =>
      'Yerleri ve konumla ilgili özellikleri kaydetmek için';

  @override
  String get photos => 'Fotoğraflar';

  @override
  String get photosPermissionReason =>
      'Fotoğrafları seçmek, oluşturulan görüntüleri kaydetmek vb. için.';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraPermissionReason => 'Fotoğraf ve video çekmek için';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get microphonePermissionReason => 'Ses tanıma, kayıt vb. için.';

  @override
  String get calendarPermissionReason =>
      'Programı kaydetmek ve takvim etkinliklerini okumak için';

  @override
  String get remindersPermissionReason =>
      'Hatırlatıcılarınızı kaydetmek ve okumak için';

  @override
  String get fitnessAndMotion => 'Fitness ve hareket';

  @override
  String get fitnessPermissionReason =>
      'Sağlık ve hareket verilerini kaydetmek için';

  @override
  String get notification => 'Bildiri';

  @override
  String get notificationPermissionReason =>
      'Program ve önemli hatırlatıcıların gönderilmesi için';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Memex Agent\'ın arka planda çalışmasını sağlayın';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent cihazınızda yerel olarak çalışır. Bildirimler, Memex\'in ilerlemeyi göstermesine ve uygulamadan çıktıktan veya ekranı kapattıktan sonra işleme devam etmesine olanak tanır. Bildirimler kapalıysa görev bitene kadar Memex\'i ön planda açık tutun.';

  @override
  String get loadDetailFailedRetryShort =>
      'Ayrıntı yüklenemedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get total => 'Toplam';

  @override
  String get estimatedCost => 'Tahmini maliyet';

  @override
  String get byAgent => 'Temsilci tarafından';

  @override
  String get timeUpdated => 'Zaman güncellendi';

  @override
  String updateFailed(Object error) {
    return 'Güncelleme başarısız oldu: $error';
  }

  @override
  String get locationUpdated => 'Konum güncellendi';

  @override
  String get confirmDeleteCardMessage =>
      'Bu kart silinsin mi? Bu geri alınamaz.';

  @override
  String get cardDetailNotFound => 'Kart detayı bulunamadı';

  @override
  String get saySomething => 'Bir şey söylemek...';

  @override
  String get relatedMemories => 'İlgili anılar';

  @override
  String get viewMore => 'Daha fazlasını görüntüle';

  @override
  String get relatedRecords => 'İlgili kayıtlar';

  @override
  String get reply => 'Cevap vermek';

  @override
  String get replySent => 'Yanıt gönderildi';

  @override
  String get insightTemplateGalleryTitle => 'İçgörü kartı şablonları';

  @override
  String get timelineTemplateGalleryTitle => 'Zaman çizelgesi kartı şablonları';

  @override
  String get categoryTextual => 'Metinsel';

  @override
  String get timelineFilterAll => 'TÜM';

  @override
  String get insights => 'Analizler';

  @override
  String get memoryTitle => 'Hafıza';

  @override
  String get longTermProfile => 'Uzun Vadeli Profil';

  @override
  String get recentBuffer => 'Son Arabellek';

  @override
  String errorLoadingMemory(Object error) {
    return 'Bellek yüklenirken hata oluştu: $error';
  }

  @override
  String get agentConfiguration => 'Aracı Yapılandırması';

  @override
  String get resetToDefaults => 'Varsayılanlara Sıfırla';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Tüm Aracı Yapılandırmalarını Sıfırla';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Tüm aracı yapılandırmalarını varsayılan değerlerine sıfırlamak istediğinizden emin misiniz? Bu eylem geri alınamaz.';

  @override
  String get resetButton => 'Sıfırla';

  @override
  String loadDataFailed(Object error) {
    return 'Veriler yüklenemedi: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Yapılandırma kaydedilemedi: $error';
  }

  @override
  String get selectLlmClient => 'LLM İstemcisini seçin:';

  @override
  String get agentConfigurationsReset => 'Aracı yapılandırmaları sıfırlandı';

  @override
  String resetFailed(Object error) {
    return 'Sıfırlanamadı: $error';
  }

  @override
  String get modelConfiguration => 'Model Yapılandırması';

  @override
  String get resetAllConfigurationsTitle => 'Tüm Yapılandırmaları Sıfırla';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Tüm model konfigürasyonlarını varsayılan değerlerine sıfırlamak istediğinizden emin misiniz? Bu eylem geri alınamaz.';

  @override
  String get modelConfigurationsReset => 'Model yapılandırmaları sıfırlandı';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Varsayılan yapılandırma silinemiyor';

  @override
  String get cannotDeleteConfigurationTitle => 'Yapılandırma Silinemiyor';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Bu yapılandırma şu anda aşağıdaki aracılar tarafından kullanılmaktadır:\n\n$agentList\n\nLütfen silmeden önce bu temsilcileri yeniden atayın.';
  }

  @override
  String get ok => 'TAMAM';

  @override
  String get deleteConfigurationTitle => 'Yapılandırmayı Sil';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '\"$key\" ifadesini silmek istediğinizden emin misiniz?';
  }

  @override
  String get defaultLabel => 'Varsayılan';

  @override
  String get setAsDefault => 'Varsayılan olarak ayarla';

  @override
  String get invalidJsonInExtraField => 'Ekstra alanda geçersiz JSON';

  @override
  String get keyAlreadyExists => 'Anahtar zaten mevcut';

  @override
  String get resetConfigurationTitle => 'Yapılandırmayı Sıfırla';

  @override
  String get resetConfigurationMessage =>
      'Bu yapılandırma başlangıçtaki varsayılan değerlerine sıfırlansın mı? Mevcut değişiklikler kaybolacak.';

  @override
  String get configurationResetPressSave =>
      'Yapılandırma sıfırlama. Uygulamak için Kaydet\'e basın.';

  @override
  String get addConfiguration => 'Yapılandırma Ekle';

  @override
  String get editConfiguration => 'Yapılandırmayı Düzenle';

  @override
  String get duplicateConfiguration => 'Yinelenen Yapılandırma';

  @override
  String get duplicate => 'Kopyalamak';

  @override
  String get keyIdLabel => 'Yapılandırma Kimliği';

  @override
  String get keyIdHelper =>
      'Bu kuruluma deepseek veya work-gpt gibi bir ad verin.';

  @override
  String get required => 'Gerekli';

  @override
  String get clientLabel => 'Model sağlayıcı';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Antropik';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Popüler';

  @override
  String get providerOpenAiApiKey => 'API Anahtarı';

  @override
  String get providerOpenAiResponses => 'API Anahtarı (Yanıtlar)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Artı';

  @override
  String get providerClaudeApiKey => 'API Anahtarı';

  @override
  String get providerBedrockSecret => 'Ana Kaya Sırrı';

  @override
  String get providerGemini => 'İkizler burcu';

  @override
  String get providerGeminiOauth => 'İkizler (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Ay Atışı)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengin';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'Derin Arama';

  @override
  String get providerMinimax => 'MiniMaks';

  @override
  String get providerOpenRouter => 'Açık Yönlendirici';

  @override
  String get providerOllama => 'Ollama (Yerel)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Memex proxy hizmeti';

  @override
  String get memexSignIn => 'Oturum aç';

  @override
  String get memexCreateAccount => 'Hesap oluşturmak';

  @override
  String get memexUsername => 'Kullanıcı adı';

  @override
  String get memexPassword => 'Şifre';

  @override
  String get memexCreateAccountLink => 'Hesap oluşturmak';

  @override
  String get memexSignInLink => 'Bunun yerine oturum açın';

  @override
  String get memexTopUp =>
      'Memex AI\'yi kullanmaya başlamak için yükleme yapın';

  @override
  String get memexTopUpSuccess => 'Başarılı bir şekilde tamamlayın!';

  @override
  String get memexFillAllFields => 'Lütfen tüm alanları doldurun';

  @override
  String get memexUsernameTooShort =>
      'Kullanıcı adı en az 6 karakterden oluşmalıdır';

  @override
  String get memexAuthFailed => 'Kimlik doğrulama başarısız oldu';

  @override
  String get memexPaymentFailed => 'Ödeme oluşturulamadı';

  @override
  String get memexLogout => 'Oturumu kapat';

  @override
  String get memexTopUpButton => 'Yükleme';

  @override
  String get memexTopUpChooseAmount => 'Bir miktar seçin';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return '$range kayıtları hakkında';
  }

  @override
  String get memexTopUpPlanStarter => 'Başlangıç';

  @override
  String get memexTopUpPlanEveryday => 'Her gün';

  @override
  String get memexTopUpPlanHighVolume => 'Yüksek hacim';

  @override
  String get memexTopUpPlanCustom => 'Özel krediler';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Memex AI\'yi denemek için iyi';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'Düzenli organizasyon için iyi';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Daha büyük partiler için iyi';

  @override
  String get memexTopUpPlanCustomSubtitle => '1-10.000 ABD Doları girin';

  @override
  String get memexTopUpCustomEstimate => 'Tahmin girilen tutara dayanmaktadır';

  @override
  String get memexCustomAmount => 'Özel Tutar';

  @override
  String get memexViewHistory => 'Kullanım Geçmişi';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Bakiye: $amount';
  }

  @override
  String get memexConfirmPassword => 'Şifreyi Onayla';

  @override
  String get memexPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String memexPayAmount(Object amount) {
    return '$amount yükleme yapın';
  }

  @override
  String get modelIdLabel => 'Modeli';

  @override
  String get modelIdHelper => 'örneğin gemini-3.1-pro-önizleme, gpt-4o';

  @override
  String get fetchingModels => 'Modeller getiriliyor...';

  @override
  String get fetchModelsButton => 'Modelleri Getir';

  @override
  String get enterApiKeyFirst =>
      'Modelleri getirmek için önce API Anahtarını girin';

  @override
  String get apiKeyLabel => 'API Anahtarı';

  @override
  String get baseUrlLabel => 'API uç noktası';

  @override
  String get advancedSettings => 'Gelişmiş Ayarlar';

  @override
  String get testConnectionSuccess => 'Bağlantı Başarılı';

  @override
  String get testConnectionFailed => 'Bağlantı Başarısız';

  @override
  String get testTypeText => 'Metin';

  @override
  String get testTypeVision => 'Görüş';

  @override
  String get testButton => 'Test';

  @override
  String get testing => 'Test...';

  @override
  String get proxyUrlOptional => 'Proxy URL\'si (İsteğe bağlı)';

  @override
  String get proxyUrlHelper => 'örneğin http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Sıcaklık';

  @override
  String get topPLabel => 'Üst P';

  @override
  String get maxTokensLabel => 'Maksimum Jeton';

  @override
  String get extraParamsJson => 'Ekstra Parametreler (JSON)';

  @override
  String get invalidJson => 'Geçersiz JSON';

  @override
  String get warning => 'Eksik Kurulum';

  @override
  String get invalidConfigurationWarning =>
      'Yapılandırma henüz tamamlanmadı (ör. API Anahtarı veya Model Kimliği eksik). Daha sonra kaydedip yapılandırabilirsiniz. Devam etmek?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Aracısı \"$agentId\", çalışması için geçerli bir model yapılandırmasına (anahtar: \"$configKey\") ihtiyaç duyar. Lütfen model ayarlarını kontrol edin.';
  }

  @override
  String get discardChangesTitle => 'Bu sayfadan ayrılmak mı istiyorsunuz?';

  @override
  String get discardChangesMessage =>
      'Herhangi bir değişiklik yaptıysanız lütfen ayrılmadan önce bunları kaydedin.';

  @override
  String get discardButton => 'At';

  @override
  String get chooseLanguage => 'Dil Seçin';

  @override
  String get chooseAvatar => 'Avatar\'ı seçin';

  @override
  String get configureNow => 'Şimdi Yapılandır';

  @override
  String get modelNotConfiguredBanner =>
      'AI modeli henüz yapılandırılmadı. Tüm özelliklerin kilidini açmak için ayarlayın.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Lütfen yayınlamadan önce bir AI modeli yapılandırın';

  @override
  String get processingStatus => 'İşleme';

  @override
  String get failedStatus => 'Arızalı';

  @override
  String get failureReason => 'Arıza Sebebi';

  @override
  String get unknownError => 'Bilinmeyen hata oluştu';

  @override
  String get enableFitness => 'Fitness\'ı Etkinleştir';

  @override
  String get fitnessBannerMessage =>
      'Sağlık ve etkinlik verilerinizi takip etmek için fitness erişimine izin verin.';

  @override
  String get fitnessDismissTitle => 'Fitness Erişimi atlansın mı?';

  @override
  String get fitnessDismissMessage =>
      'Fitness izni olmadan uygulama, öngörüler ve otomatik kayıt için sağlık verilerinizi otomatik olarak toplayamayacaktır.';

  @override
  String get skipAnyway => 'Yine de Atla';

  @override
  String get proModelHint => 'Bu model ChatGPT Pro/Plus aboneliği gerektirir.';

  @override
  String get searchKnowledgeBase => 'Bilgi tabanında ara...';

  @override
  String get searchKnowledgeHint =>
      'Dosya adlarını veya içeriğini aramak için anahtar kelimeyi girin';

  @override
  String noSearchResults(Object query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String get onlyMarkdownPreview => 'Yalnızca Markdown önizlemesi desteklenir';

  @override
  String get backupAndRestore => 'Yedekleme ve Geri Yükleme';

  @override
  String get createBackup => 'Yedekleme Oluştur';

  @override
  String get restoreBackup => 'Yedeklemeyi Geri Yükle';

  @override
  String get backupDescription =>
      'Tüm verilerinizi (kartlar, bilgi tabanı, öngörüler, ayarlar) bir .memex dosyasına paketleyin. Paylaşım sayfasını kullanarak bunu iCloud Drive\'a, Google Drive\'a veya herhangi bir konuma kaydedin.';

  @override
  String get restoreDescription =>
      'Tüm verileri geri yüklemek için bir .memex yedekleme dosyası seçin. Bu, mevcut verilerin üzerine yazacaktır.';

  @override
  String get selectBackupFile => 'Yedekleme Dosyasını Seçin';

  @override
  String get estimatedSize => 'Tahmini boyut';

  @override
  String get backupComplete => 'Yedekleme oluşturuldu';

  @override
  String backupFailed(Object error) {
    return 'Yedekleme başarısız oldu: $error';
  }

  @override
  String get confirmRestore => 'Geri Yüklemeyi Onayla';

  @override
  String get confirmRestoreMessage =>
      'Geri yükleme işlemi kartlar, bilgi tabanı, analizler ve ayarlar dahil tüm mevcut verilerin üzerine yazılacaktır. Bu geri alınamaz. Devam etmek?';

  @override
  String get restoreComplete => 'Geri yükleme tamamlandı';

  @override
  String get restoreRestartHint =>
      'Veriler geri yüklendi. Tüm değişikliklerin etkili olması için lütfen uygulamayı yeniden başlatın.';

  @override
  String restoreFailed(Object error) {
    return 'Geri yükleme başarısız oldu: $error';
  }

  @override
  String get invalidBackupFile =>
      'Geçersiz yedekleme dosyası. Lütfen bir .memex dosyası seçin.';

  @override
  String get automaticBackup => 'Otomatik Yedekleme';

  @override
  String get autoBackupDescription =>
      'Etkinleştirildiğinde Memex, başlangıçtan sonra veya ön plana geri döndüğünüzde günde en fazla bir yerel anlık görüntü oluşturur.';

  @override
  String get backupSensitiveSettingsHint =>
      'Yedeklemeler, ayarları ve model sağlayıcı anahtarlarını içerir. Yedekleme dosyalarını güvendiğiniz bir yerde saklayın.';

  @override
  String get backupLocation => 'Konum';

  @override
  String get backupLocationDetails => 'Konum ayrıntıları';

  @override
  String get backupLocationSummary => 'Uygulamada gösteriliyor';

  @override
  String get backupLocationFullPath => 'Tam yol';

  @override
  String get backupLocationUri => 'Klasör erişim URI\'si';

  @override
  String get copyBackupLocationPath => 'Yolu kopyala';

  @override
  String get backupLocationCopied => 'Yedekleme konumu kopyalandı';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Seçilen klasör: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Yedeklemeler';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Dosyalar > iPhone\'umda > Memex > Yedeklemeler';

  @override
  String get autoBackupStatus => 'Durum';

  @override
  String get noAutoBackupYet => 'Henüz otomatik yedekleme yok';

  @override
  String lastBackupAt(Object time) {
    return 'Son yedekleme: $time';
  }

  @override
  String get autoBackupRetention => 'Tutulma';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days gün';
  }

  @override
  String get autoBackupRetentionForever => 'Sonsuza kadar sakla';

  @override
  String get autoBackupMaxSize => 'Saklama kapağı';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Otomatik temizleme, otomatik anlık görüntüleri $size altında tutar. Güvenlik anlık görüntüleri ve manuel dışa aktarmalar ayrı tutulur.';
  }

  @override
  String get createSnapshotNow => 'Şimdi yedekle';

  @override
  String get backupLocationMenu => 'Konumu değiştir';

  @override
  String get defaultBackupLocation => 'Varsayılan yedekleme klasörü';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Memex\'in uygulamaya özel harici dosyalar klasörünü kullanın. Depolama iznine gerek yok.';

  @override
  String get chooseBackupLocation => 'Yedekleme klasörünü seçin';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Android\'in sistem seçicisini kullanarak bir klasör seçin ve Memex\'e kalıcı erişim izni verin.';

  @override
  String get storedBackups => 'Saklanan Yedeklemeler';

  @override
  String get noStoredBackups =>
      'Otomatik yedeklemeler ilk anlık görüntüden sonra burada görünecektir.';

  @override
  String get backupTypeAutoSnapshot => 'Otomatik anlık görüntü';

  @override
  String get backupTypeSafetySnapshot => 'Güvenlik anlık görüntüsü';

  @override
  String get backupTypeManualBackup => 'Manuel yedekleme';

  @override
  String get refresh => 'Yenile';

  @override
  String get restoreThisBackup => 'Bu yedeği geri yükle';

  @override
  String get deleteThisBackup => 'Bu yedeği sil';

  @override
  String get confirmDeleteBackup => 'Yedekleme silinsin mi?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName silinsin mi? Bu, depolanan yedekleme dosyasını kaldırır ve geri alınamaz.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Yedekleme silindi: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Yedekleme silinemedi: $error';
  }

  @override
  String get creatingSafetySnapshot =>
      'Güvenlik anlık görüntüsü oluşturuluyor...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Anlık görüntü oluşturuldu: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Yedekleme konumu güncellenemedi: $error';
  }

  @override
  String get backupImportCreatedAt => 'Oluşturuldu';

  @override
  String get backupImportSourceVersion => 'Kaynak sürümü';

  @override
  String get backupImportFlavor => 'İnşa etmek';

  @override
  String get backupLegacyFormat => 'Eski yedekleme (bildirim yok)';

  @override
  String get restoreInProgress => 'Yedekleme geri yükleniyor...';

  @override
  String get dataStorage => 'Veri Depolama';

  @override
  String get dataStorageDescriptionAndroid =>
      'Çalışma alanınızı depolamak için özel bir klasör seçin. Uygulamayı yeniden yüklediğinizde veriler korunur.';

  @override
  String get dataStorageDescriptionIOS =>
      'Çalışma alanınızı aygıtlar arasında senkronize etmek ve uygulamayı yeniden yüklediğinizde verileri korumak için iCloud\'u açın.';

  @override
  String get storageLocationApp => 'Uygulama depolama';

  @override
  String get storageLocationAppDesc =>
      'Veriler uygulamanın içinde saklanır ve uygulamayı kaldırdığınızda kaldırılır.';

  @override
  String get storageLocationCustom => 'Cihaz depolama alanı (özel klasör)';

  @override
  String get storageLocationCustomDesc =>
      'Verileri seçtiğiniz bir klasörde saklayın. Klasör kalırsa, yeniden yükleme sırasında veriler kalır.';

  @override
  String get storageLocationICloud => 'iCloud\'da saklayın';

  @override
  String get storageLocationICloudDesc =>
      'Çalışma alanınızı Apple aygıtları arasında senkronize edin. Yeniden yükleme sonrasında veriler kalır.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Güncel: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'iCloud saklama alanını kullanmak için iCloud\'da oturum açın ve iCloud Drive\'ı açın.';

  @override
  String get loadingFromICloud => 'Veriler iCloud\'dan geri yükleniyor…';

  @override
  String get switchingToICloud => 'iCloud saklama alanına geçiliyor…';

  @override
  String get switchingStorage => 'Depolama alanı değiştiriliyor…';

  @override
  String get customFolderAccessDenied =>
      'Bu klasör okunamıyor veya yazılamıyor. Lütfen depolama izni verin veya başka bir konum seçin.';

  @override
  String get configured => 'Yapılandırılmış';

  @override
  String get apiKeyNotSet =>
      'API Anahtarı ayarlanmadı — yapılandırmak için dokunun';

  @override
  String get bottomNavTimeline => 'Zaman çizelgesi';

  @override
  String get bottomNavLibrary => 'Kütüphane';

  @override
  String get aiGeneratedLabel => 'Yapay Zeka Oluşturuldu';

  @override
  String sourceTraceWithCount(Object count) {
    return 'KAYNAK İZLEME ($count)';
  }

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountDesc =>
      'Tüm yerel verileri kalıcı olarak silin ve uygulamayı sıfırlayın.';

  @override
  String get deleteAccountConfirmTitle => 'Hesap Silinsin mi?';

  @override
  String get deleteAccountConfirmMessage =>
      'Bu, zaman çizelgesi kartları, bilgi tabanı, kayıtlar ve ayarlar dahil tüm verilerinizi kalıcı olarak silecektir. Bu eylem geri alınamaz.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Onaylamak için \"$name\" yazın';
  }

  @override
  String get deleteAccountTypeHint => 'Onaylamak için kullanıcı adınızı girin';

  @override
  String get llmConsentTitle => 'Veri Paylaşım Onayı';

  @override
  String llmConsentMessage(Object provider) {
    return 'Yapay zeka özelliklerini etkinleştirmek için Memex\'in verilerinizi işlenmek üzere $provider adresine göndermesi gerekiyor. Bu şunları içerir:\n\n• Girdiğiniz metin (notlar, sesli çeviriler)\n• Fotoğraf meta verileri ve çıkarılan metin (OCR)\n• Sağlık ve fitness özetleri\n• Zaman çizelgesi kartı içeriği\n\nVerileriniz doğrudan cihazınızdan $provider adresine gönderilir. Memex, verilerinizi başka bir sunucu üzerinden saklamaz veya aktarmaz.\n\nVerilerinizi nasıl kullandıklarını öğrenmek için lütfen $provider\'nin gizlilik politikasını inceleyin.\n\nYapay zekanın işlenmesi için verilerinizi $provider adresine göndermeyi kabul ediyor musunuz?';
  }

  @override
  String get llmConsentAgree => 'Kabul ediyorum';

  @override
  String get llmConsentDecline => 'Reddetmek';

  @override
  String get customAgents => 'Özel Temsilciler';

  @override
  String get noCustomAgents => 'Hiçbir özel aracı yapılandırılmadı.';

  @override
  String get deleteAgent => 'Temsilciyi Sil';

  @override
  String deleteAgentConfirm(Object name) {
    return '\"$name\" özel aracısı silinsin mi?';
  }

  @override
  String get deleted => 'Silindi';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get newAgent => 'Yeni Temsilci';

  @override
  String get editAgent => 'Temsilciyi Düzenle';

  @override
  String get agentName => 'Temsilci Adı';

  @override
  String get agentNameHint => 'benim-gümrük-acentem';

  @override
  String get agentNameRequired => 'Gerekli';

  @override
  String get agentNameInvalid => 'Yalnızca harfler, rakamlar ve kısa çizgiler';

  @override
  String get agentNameExists => 'Ad zaten mevcut';

  @override
  String get hostAgentType => 'Ana Bilgisayar Aracısı Türü';

  @override
  String get skillDirectory => 'Beceri Dizini';

  @override
  String get skillDirInvalid =>
      'Göreli bir yol olmalı (önde gelen / veya .. yok)';

  @override
  String get workingDirectory => 'Çalışma Dizini (isteğe bağlı)';

  @override
  String get workingDirectoryHint =>
      'Çalışma alanı varsayılanı için boş bırakın';

  @override
  String get llmConfig => 'Yüksek Lisans Yapılandırması';

  @override
  String get eventType => 'Etkinlik Türü';

  @override
  String get executionMode => 'Yürütme Modu';

  @override
  String get executionModeAsync => 'Eşzamansız';

  @override
  String get executionModeSync => 'Senkronizasyon';

  @override
  String get dependsOn => 'bağlıdır';

  @override
  String get dependsOnHint => 'Bağımlılıkları seçin';

  @override
  String get priority => 'Öncelik';

  @override
  String get maxRetries => 'Maksimum Yeniden Deneme Sayısı';

  @override
  String get systemPromptLabel => 'Sistem İstemi (isteğe bağlı)';

  @override
  String get systemPromptHint =>
      'Ana makine aracısı istemine eklenen ek talimatlar';

  @override
  String get eventSerializer => 'Olay Serileştirici';

  @override
  String get eventSerializerDefault => 'Varsayılan (XML)';

  @override
  String get enabledLabel => 'Etkinleştirilmiş';

  @override
  String get skillsManagement => 'Beceri Yönetimi';

  @override
  String get skillsManagementEmpty => 'Henüz beceri yok';

  @override
  String get downloadSkill => 'Beceriyi İndir';

  @override
  String get downloadFile => 'Dosyayı indir';

  @override
  String get downloading => 'İndiriliyor...';

  @override
  String get downloadSuccess => 'Beceri başarıyla indirildi';

  @override
  String downloadFailed(Object error) {
    return 'İndirme başarısız oldu: $error';
  }

  @override
  String get deleteConfirm => 'Silmeyi Onayla';

  @override
  String deleteConfirmMessage(String name) {
    return '\"$name\" ifadesini silmek istediğinizden emin misiniz?';
  }

  @override
  String get invalidUrl => 'Lütfen geçerli bir URL girin';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Yeni Klasör';

  @override
  String get newFile => 'Yeni Dosya';

  @override
  String get folderName => 'Klasör Adı';

  @override
  String get fileName => 'Dosya adı';

  @override
  String get nameRequired => 'Ad gerekli';

  @override
  String get nameInvalid => 'Ad / veya .. içeremez.';

  @override
  String createFailed(Object error) {
    return 'Oluşturulamadı: $error';
  }

  @override
  String get fileContent => 'Dosya İçeriği';

  @override
  String get saveSuccess => 'Başarıyla kaydedildi';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Zip geçerli dizine çıkarılacak: $dir';
  }

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get privacyPolicyDesc => 'Memex verilerinizi nasıl işler?';

  @override
  String get llmAuthError =>
      'API kimlik doğrulaması başarısız oldu. Lütfen Ayarlar\'da LLM yapılandırmanızı kontrol edin.';

  @override
  String get llmBadRequestError =>
      'İstek LLM sağlayıcısı tarafından reddedildi. Giriş formatı mevcut model tarafından desteklenmiyor olabilir.';

  @override
  String get llmRateLimitError =>
      'API oranı sınırı aşıldı. Lütfen daha sonra tekrar deneyin.';

  @override
  String get llmServerError =>
      'LLM hizmeti geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get llmNetworkError =>
      'Ağ bağlantısı başarısız oldu. Lütfen internet bağlantınızı kontrol edin.';

  @override
  String get llmUnknownError =>
      'İçeriğiniz işlenirken beklenmeyen bir hata oluştu.';

  @override
  String get llmErrorDialogTitle => 'İşleme Başarısız';

  @override
  String get goToModelConfig => 'Ayarlar\'a gidin';

  @override
  String get speechModelDownloadTitle => 'Konuşma Modelini İndirin';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Bir kerelik model indirmesi (~${sizeMB}MB) gerekiyor.\n\nİndirildikten sonra transkripsiyon tamamen cihazda çalışır.';
  }

  @override
  String get speechModelStartDownload => 'İndirmeyi Başlat';

  @override
  String get speechModelChooseSource => 'İndirme kaynağını seçin:';

  @override
  String get speechModelChinaMirror => '🇨🇳 Çin Aynası (CN\'de daha hızlı)';

  @override
  String get speechModelGithub => '🌐 GitHub (Global)';

  @override
  String get speechModelDownloading => 'Model indiriliyor...';

  @override
  String get speechModelConnecting => 'Bağlanıyor...';

  @override
  String get deleteSpeechModel => 'Konuşma modelini sil';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'İndirilen yerel konuşma tanıma modeli dosyaları silinsin mi? Yerel konuşmayı metne dönüştürme özelliğinin bir sonraki kullanımında bunlar yeniden indirilecektir.';

  @override
  String get speechModelDeletedSuccess => 'Konuşma modeli dosyaları silindi';

  @override
  String get speechModelNotDownloaded =>
      'İndirilmiş konuşma modeli dosyası bulunamadı';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Konuşma modeli dosyaları silinemedi: $error';
  }

  @override
  String get speechTranscribing => 'Tanınıyor...';

  @override
  String get speechNoResult => 'Konuşma algılanmadı';

  @override
  String get useLocalSpeechToTextTitle => 'Metne yerel konuşmayı kullanma';

  @override
  String get useLocalSpeechToTextDesc =>
      'Etkinleştirildiğinde, ses gönderilmeden önce cihazda metne dönüştürülür; bu, ses girişini desteklemeyen modeller için kullanışlıdır. Devre dışı bırakıldığında orijinal ses doğrudan modele gönderilir.';

  @override
  String get pendingAiProcessingHint => 'İşlemek için AI modelini ayarlayın';

  @override
  String get demoWelcome =>
      'Memex\'e hoş geldiniz!\nYapay zekanın kayıtlarınız için neler yapabileceğine dair kısa bir tur atalım.';

  @override
  String get demoTapAdd => 'İlk kaydınızı oluşturmak için buraya dokunun';

  @override
  String get demoTapSend => 'İlk kaydınızı göndermek için dokunun';

  @override
  String get demoTapCard =>
      'Yapay zekanın kaydınızı nasıl düzenlediğini görmek için dokunun';

  @override
  String get demoDetailHint =>
      'Bu, yapay zeka tarafından düzenlenen kayıt ayrıntınızdır. Etrafı kaydırın ve tura devam etmek için geri dönün.';

  @override
  String get demoTapInsight =>
      'Yapay zeka tarafından oluşturulan öngörüleri görmek için dokunun';

  @override
  String get demoTapInsightUpdate =>
      'Kayıtlarınızdan öngörüler oluşturmak için dokunun';

  @override
  String get demoTapKnowledge =>
      'Otomatik olarak düzenlenen bilgi dosyalarınızı kontrol edin';

  @override
  String get demoDone => 'Hayatınızı kaydetmeye başlayın.';

  @override
  String get demoStartTour => 'Turu Başlat';

  @override
  String get demoGetStarted => 'Başlayın';

  @override
  String get demoSkip => 'Atlamak';

  @override
  String get demoPrefillText => 'Merhaba Memex! Bu benim ilk kaydım 🎉';

  @override
  String get visionBadge => 'Görüş';

  @override
  String get notMultimodalHint =>
      'Memex, medya analizi için çok modlu model yeteneklerine güvenir. Kayıtlarınız görseller içeriyorsa lütfen yapılandırdığınız modelin görsel girişini desteklediğinden emin olun.';

  @override
  String get defaultModelPrefix => 'Varsayılan';

  @override
  String get recommendedBadge => 'Tavsiye edilen';

  @override
  String get readOnlyBadge => 'SOHBET';

  @override
  String get switchCompanion => 'Tamamlayıcıyı değiştir';

  @override
  String get personaChatInputHint => 'Bir mesaj yazın...';

  @override
  String get today => 'Bugün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get yesterday => 'Dün';

  @override
  String get showInsightTextTitle => 'Memex içgörü yorumunu göster';

  @override
  String get showInsightTextDesc =>
      'Kart ayrıntısı yorum bölümünde Memex öngörüsünün sabitlenmiş yorum olarak gösterilip gösterilmeyeceği.';

  @override
  String get enableCharacterCommentTitle => 'Karakter otomatik yorumu';

  @override
  String get enableCharacterCommentDesc =>
      'Karakterler yeni kayıtlara otomatik olarak yorum yapar.';

  @override
  String get maxCommentCharactersTitle => 'Maksimum yorum yapma karakterleri';

  @override
  String get maxCommentCharactersDesc =>
      'Her kayda kaç karakter yorum yapabilir?';

  @override
  String replyTo(String name) {
    return '$name adlı kullanıcıya yanıt ver';
  }

  @override
  String get cdnSignalsComments => 'Yeni yanıt alındı';

  @override
  String get cdnSignalsInsight => 'Yeni içgörü oluşturuldu';

  @override
  String get cdnSignalsBoth => 'Yeni yanıt ve içgörü';

  @override
  String get untitledCard => 'Başlıksız kart';

  @override
  String get locationContextTitle => 'Konum Bağlamı';

  @override
  String get locationContextDescription =>
      'Temsilci sohbeti için mevcut şehir ve mahalle bağlamı';

  @override
  String get locationContextAttachTitle => 'Geçerli konumu sohbete ekle';

  @override
  String get locationContextAttachDesc =>
      'Temsilciye şehir, bölge ve mahalle bağlamını sağlamak için cihaz GPS\'sini ve ters coğrafi kodlamayı kullanır.';

  @override
  String get reverseGeocodingProvider => 'Ters coğrafi kodlama sağlayıcısı';

  @override
  String get amapProviderName => 'Harita';

  @override
  String get amapApiKey => 'Amap API Anahtarı';

  @override
  String get amapGcj02Note =>
      'Amap, GCJ-02 koordinatlarını kullanır. Cihaz GPS\'si ters coğrafi kodlamadan önce dönüştürülür.';

  @override
  String get contextGranularity => 'Bağlam ayrıntı düzeyi';

  @override
  String get granularityCity => 'Şehir';

  @override
  String get granularityDistrict => 'Semt';

  @override
  String get granularityNeighborhood => 'Komşu';

  @override
  String get granularityStreet => 'Sokak';

  @override
  String get granularityFullAddress => 'Tam adres adayı';

  @override
  String get locationFreshness => 'Konum tazeliği';

  @override
  String minutesShort(int minutes) {
    return '$minutes dakika';
  }

  @override
  String get oneHour => '1 saat';

  @override
  String get testCurrentLocation => 'Mevcut konumu test et';

  @override
  String locationTestFailed(String error) {
    return 'Başarısız: $error';
  }

  @override
  String get locationDebugGps => 'Küresel Konumlama Sistemi';

  @override
  String get locationDebugReverseGeocode => 'Coğrafi kodu ters çevir';

  @override
  String get locationDebugProvider => 'sağlayıcı';

  @override
  String get locationDebugAgentContext => 'Aracı bağlamı';

  @override
  String get locationDebugSource => 'Kaynak';

  @override
  String get locationDebugAddressSummary => 'Adres özeti';

  @override
  String get locationDebugFullAddress => 'Tam adres';

  @override
  String get locationDebugCoordinates => 'Koordinatlar';

  @override
  String get locationDebugAccuracy => 'Kesinlik';

  @override
  String get locationDebugReason => 'Sebep';

  @override
  String get locationDebugOk => 'TAMAM';

  @override
  String get locationDebugUnavailable => 'müsait değil';

  @override
  String get locationDebugInjected => 'enjekte edildi';

  @override
  String get locationDebugNotInjected => 'enjekte edilmemiş';

  @override
  String get locationStatusUpdatedAt => 'Güncellendi';

  @override
  String get locationStatusSuccessTitle => 'Mevcut konum hazır';

  @override
  String get locationStatusSuccessBody =>
      'Memex, konum bağlamı ilgili olduğunda bu konum özetini ekleyebilir.';

  @override
  String get locationStatusApproximateTitle => 'Yalnızca yaklaşık konum';

  @override
  String get locationStatusApproximateBody =>
      'Doğruluk şehir veya bölge düzeyinde görünüyor. Bunu kullanmaya devam edebilir veya daha sıkı bir bağlam için sistem ayarlarında Kesin Konum\'u etkinleştirebilirsiniz.';

  @override
  String get locationStatusServiceDisabledTitle => 'Sistem konumu kapalı';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex yalnızca cihazın GPS\'ini kullanır ve ağdan veya IP\'den konum çıkarımı yapmaz. Android\'de Konum ayarlarını açın; iOS\'ta Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri\'ni etkinleştirin.';

  @override
  String get locationStatusPermissionDeniedTitle => 'Konum izni gerekli';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Memex\'in test sırasında veya konum bağlamına ihtiyaç duyulduğunda konumu kullanmasına izin verin. Her zaman erişim talep edilmez.';

  @override
  String get locationStatusPermissionForeverTitle => 'Konum izni engellendi';

  @override
  String get locationStatusPermissionForeverBody =>
      'Uygulama ayarlarını açın ve Memex için konuma izin verin. İOS\'ta Uygulamayı Kullanırken yeterlidir.';

  @override
  String get locationStatusDisabledTitle => 'Konum Bağlamı kapalı';

  @override
  String get locationStatusDisabledBody =>
      'Memex\'in cihaz konumunu aracı bağlamına eklemesini istediğinizde yukarıdaki anahtarı açın ve kaydedin.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS çalışıyor, adres araması başarısız oldu';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex\'in koordinatları vardır ancak aracıya yalnızca GPS içeriğini eklemez. Ters coğrafi kodlama sağlayıcısını kontrol edin ve tekrar deneyin.';

  @override
  String get locationStatusUnavailableTitle => 'Konum kullanılamıyor';

  @override
  String get locationStatusUnavailableBody =>
      'Sistem konum hizmetlerini ve uygulama iznini kontrol edip tekrar test edin.';

  @override
  String get allowLocationPermissionButton => 'Konum iznine izin ver';

  @override
  String get openAppSettingsButton => 'Uygulama ayarlarını aç';

  @override
  String get openLocationSettingsButton => 'Konum ayarlarını aç';

  @override
  String get locationSettingsOpenFailed => 'Sistem ayarları açılamadı.';

  @override
  String locationActionFailed(String error) {
    return 'Konum işlemi başarısız oldu: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Arama ayarları...';

  @override
  String get settingsSearchEmpty => 'Eşleşen ayar bulunamadı';

  @override
  String get importCharacterCard => 'Karakter Kartını İçe Aktar';

  @override
  String get firstMessageLabel => 'İlk Mesaj';

  @override
  String get firstMessageHint =>
      'İlk görüşmede gönderilen tebrik (isteğe bağlı)';

  @override
  String get systemPromptOverrideLabel => 'Sistem İstemini Geçersiz Kılma';

  @override
  String get systemPromptOverrideHint =>
      'Varsayılan sistem istemini geçersiz kıl (gelişmiş, isteğe bağlı)';

  @override
  String get postHistoryInstructionsLabel => 'Tarih Sonrası Talimatlar';

  @override
  String get postHistoryInstructionsHint =>
      'Sohbet geçmişinden sonra, yanıtlamadan önce eklenen talimatlar (isteğe bağlı)';

  @override
  String get mesExampleLabel => 'Mesaj Örnekleri';

  @override
  String get mesExampleHint =>
      'Karakter stilini gösteren örnek diyaloglar (isteğe bağlı)';

  @override
  String get worldBookTitle => 'Dünya Kitabı';

  @override
  String get worldBookSubtitle =>
      'Anahtar kelimeler tetiklendiğinde enjekte edilen arka plan bilgisi';

  @override
  String get characterMemoryTitle => 'Karakter Hafızası';

  @override
  String get characterMemorySubtitle =>
      'Karakter ve kullanıcı arasındaki ilişki dinamikleri ve etkileşim anıları';

  @override
  String get addTooltip => 'Eklemek';

  @override
  String get constantBadge => 'Devamlı';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Giriş $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Anahtar kelimeler: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Bellek $index';
  }

  @override
  String get addWorldEntry => 'Dünya Kitap Girişi Ekle';

  @override
  String get editWorldEntry => 'Dünya Kitap Girişini Düzenle';

  @override
  String get commentTitleLabel => 'Yorum / Başlık';

  @override
  String get entryDescriptionHint => 'Giriş açıklaması (isteğe bağlı)';

  @override
  String get triggerKeywordsLabel => 'Tetikleyici Anahtar Kelimeler';

  @override
  String get triggerKeywordsHint => 'Virgülle ayrılmış, örneğin: büyü, büyü';

  @override
  String get contentLabel => 'İçerik';

  @override
  String get worldEntryContentHint =>
      'Anahtar kelimeler tetiklendiğinde enjekte edilen arka plan bilgisi';

  @override
  String get enabledCheckbox => 'Etkinleştirilmiş';

  @override
  String get addMemory => 'Bellek Ekle';

  @override
  String get editMemory => 'Belleği Düzenle';

  @override
  String get memoryLabelField => 'Etiket';

  @override
  String get memoryLabelHint => 'Benzersiz tanımlayıcı, örneğin: ad tercihi';

  @override
  String get memoryContentHint => 'Bellek içeriği';

  @override
  String get salienceLabel => 'belirginlik:';

  @override
  String get labelCannotBeEmpty => 'Etiket boş olamaz';

  @override
  String importSuccess(Object name) {
    return '$name başarıyla içe aktarıldı';
  }

  @override
  String importFailed(Object error) {
    return 'İçe aktarma başarısız oldu: $error';
  }

  @override
  String get supportedFormats => 'Desteklenen Formatlar';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 karakter kartları (.json)\n• Gömülü kartlar içeren PNG resimleri (.png)\n\nPersona, dünya kitabı vb. alanlar otomatik olarak Memex karakter formatına eşlenecektir.';

  @override
  String get pickCharacterFile => 'Karakter Dosyasını Seç';

  @override
  String get repickFile => 'Başka Bir Dosya Seç';

  @override
  String get personaSettingSection => 'Kişilik';

  @override
  String get systemPromptSection => 'Sistem İstemi';

  @override
  String worldEntriesCount(Object count) {
    return 'Dünya Kitabı: $count giriş';
  }

  @override
  String fileLabel(Object filename) {
    return 'Dosya: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Aynı ada sahip bir karakter zaten mevcut: $names. İçe aktarma, mevcut karakterlerin üzerine yazmadan yeni bir karakter oluşturacaktır.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Birincil Yardımcı Olarak Ayarla';

  @override
  String get setPrimaryCompanionSubtitle =>
      'İçe aktarma sonrasında otomatik olarak birincil arkadaşınız olarak ayarlayın';

  @override
  String get confirmImport => 'İçe Aktarmayı Onayla';

  @override
  String get chatBackground => 'Sohbet Arka Planı';

  @override
  String get chooseChatBackgroundImage => 'Arka plan resmini seçin';

  @override
  String get earlyUpdateSettingsTitle => 'Erken erişim güncellemeleri';

  @override
  String get earlyUpdateSettingsDesc =>
      'Eşleşen Erken APK için GitHub ön sürümlerini kontrol edin, indirin ve Android\'in yükleyicisine verin.';

  @override
  String get earlyUpdateUnsupported =>
      'Erken güncellemeler yalnızca Android Early sürümünde mevcuttur.';

  @override
  String get earlyUpdateAutoCheckTitle =>
      'Güncellemeleri otomatik olarak kontrol et';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Başlangıçta en fazla 12 saatte bir kontrol edin.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Yalnızca Wi-Fi üzerinden indirin';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Mobil verileri kullanırken güncelleme indirmelerini atlayın.';

  @override
  String get earlyUpdateAutoInstallTitle => 'Otomatik indirme ve yükleme';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Yeni bir yapı bulunduğunda onu indirin ve Android yükleyicisini otomatik olarak açın.';

  @override
  String get earlyUpdateCheckNow => 'Şimdi kontrol et';

  @override
  String get earlyUpdateChecking => 'GitHub ön sürümleri kontrol ediliyor...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Yalnızca Wi-Fi üzerinden indirmeler etkinleştirildiği için atlandı.';

  @override
  String get earlyUpdateNoUpdate => 'Zaten en son Erken sürümdesiniz.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Erken derleme $version+$build mevcut.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'İndirin ve yükleyin';

  @override
  String get earlyUpdateDownloadInProgress => 'Güncelleme indiriliyor...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Güncelleme indiriliyor: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Güncelleme paketi indirildi. Kuruluma hazır.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'İndirilen paketi yükleyin';

  @override
  String get earlyUpdateClearDownloadedPackage => 'İndirilen paketi temizle';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'İndirilen güncelleme paketi temizlendi.';

  @override
  String get earlyUpdateInstallStarted => 'Android yükleyici açıldı.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Memex\'in bilinmeyen uygulamaları yüklemesine izin verin, ardından indir ve yükle\'ye tekrar dokunun.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Son kontrol: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Güncelleme kontrolü başarısız oldu: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Erken güncelleme mevcut';

  @override
  String get earlyUpdateReleaseNotes => 'Sürüm notları';

  @override
  String get dismissAllNotifications => 'Tümünü temizle';

  @override
  String get dismissByType => 'Türe göre temizle';

  @override
  String get dismissTypeSystemAction => 'Hatırlatıcılar ve etkinlikler';

  @override
  String get dismissTypeClarification => 'Açıklamalar';

  @override
  String get dismissTypeCardUpdate => 'Kart güncellemeleri';

  @override
  String dismissedCount(Object count) {
    return '$count temizlendi';
  }

  @override
  String get dataImportTitle => 'Dosyaları içe aktar';

  @override
  String get dataImportSettingsDescription =>
      'Eski dosyaları Memex\'e taşıyın ve ardından bunları organize edip etmeyeceğinize karar verin.';

  @override
  String get dataImportDescription =>
      'Eski notları, dışa aktarılan kayıtları, belgeleri veya ZIP arşivlerini seçin. Memex önce bir kopyasını kaydeder ve orijinal dosyalara dokunmadan bırakır. İçe aktarma işleminden sonra Memex\'in bunları düzenlemeye yardımcı olup olmayacağına karar verebilirsiniz.';

  @override
  String get dataImportSelectFiles => 'İçe aktarılacak dosyaları seçin';

  @override
  String get dataImportImporting => 'Dosyalar kaydediliyor...';

  @override
  String get dataImportSuccess => 'Memex\'e kaydedilen dosyalar';

  @override
  String get dataImportOnlyStored =>
      'Dosyalar kaydedildi. Herhangi bir organizasyon başlamadı.';

  @override
  String get dataImportQueued =>
      'Memex bu içe aktarma işlemini arka planda düzenleyecektir.';

  @override
  String get dataImportResultTitle => 'İçe aktarma tamamlandı';

  @override
  String dataImportResultSummary(Object count) {
    return '$count dosya kaydedildi. Bunları şimdi düzenleyebilir veya orijinal kaynak materyal olarak bırakabilirsiniz.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count öğe/öğeler aynı ada sahipti ve herhangi bir şeyin üzerine yazılmasını önlemek için yeniden adlandırıldı.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count sıra dışı arşiv öğesi atlandı; geri kalanı normal şekilde ithal edildi.';
  }

  @override
  String get dataImportChooseProcessing => 'Bu dosyaları düzenleyin';

  @override
  String get dataImportProcessTitle => 'Bu içe aktarma organize edilsin mi?';

  @override
  String dataImportProcessPrompt(Object count) {
    return '$count dosyayı içe aktardınız. Memex\'in bunları şimdi mi organize edeceğini yoksa sadece orijinalleri mi saklayacağını seçin.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'Bilgi tabanında organize olun';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Belgeler, notlar, proje materyalleri ve referanslar için en iyisi. Memex yararlı bilgileri çıkaracak ve daha sonra kullanmak üzere gruplayacaktır.';

  @override
  String get dataImportProcessTimelineCards =>
      'Zaman çizelgesi kayıtları oluşturun';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Günlükler, sohbet günlükleri, etkinlik geçmişi ve eski dışa aktarmalar için en iyisi. Memex, mantıklı olduğunda zamana dayalı içerikleri kayıtlara dönüştürecek.';

  @override
  String get dataImportImpactNone =>
      'Memex yalnızca bu orijinal dosyaları saklayacaktır. Hiçbir AI organizasyonu başlamayacak.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex bu dosyaları okuyacak ve uzun vadeli yararlı bilgileri bilgi tabanında düzenleyecektir. Proaktif olarak zaman çizelgesi kayıtları oluşturmaz.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex bu dosyaları okuyacak ve uygun olduğunda yaşam olayları veya tarihli geçmiş için zaman çizelgesi kayıtları oluşturacaktır. Bilgi tabanını proaktif olarak organize etmeyecektir.';

  @override
  String get dataImportImpactBoth =>
      'Memex, zaman çizelgesi kayıtları oluşturmaya ve yeniden kullanılabilir bilgileri bilgi tabanında düzenlemeye çalışacaktır. Bu tam bir kişisel arşiv için en iyisidir.';

  @override
  String get dataImportFinish => 'Sadece onları kurtar';

  @override
  String get noImages => 'Resim yok';

  @override
  String get noMessages => 'Mesaj yok';

  @override
  String get sketchContent => 'Taslak içeriği';

  @override
  String get emptyFolder => 'Boş klasör';

  @override
  String get usernameAlreadyTaken => 'Kullanıcı adı zaten alınmış';

  @override
  String get registrationFailed => 'Kayıt başarısız oldu';

  @override
  String get loginFailed => 'giriş başarısız oldu';

  @override
  String get paymentCreationFailed => 'Ödeme başlatılamadı';

  @override
  String get completePayment => 'Ödemeyi tamamla';

  @override
  String get commentReplyToYou => 'Sen';

  @override
  String get commentAuthorUser => 'Kullanıcı';

  @override
  String get commentAuthorAi => 'yapay zeka';

  @override
  String get authorizationCancelled => 'Yetkilendirme iptal edildi';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Hafta $week';
  }

  @override
  String get timelineWeekLabel => 'Hafta';

  @override
  String get eventCardDefaultTitle => 'Etkinlik';

  @override
  String get memoryNoLongTermYet => 'Henüz uzun süreli anılar yok.';

  @override
  String get memoryNoRecentBuffer => 'Ara bellekte yeni anı yok.';

  @override
  String get memoryGeneralSubject => 'Genel';
}
