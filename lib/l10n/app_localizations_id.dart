// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get timesLabel => 'Kali';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Tetapkan $modelId sebagai model default';
  }

  @override
  String get retry => 'Coba lagi';

  @override
  String get unknownModel => 'Model tidak dikenal';

  @override
  String get notSet => 'Belum diatur';

  @override
  String get confirmClear => 'Konfirmasi penghapusan';

  @override
  String get confirmClearTokenMessage =>
      'Hapus pengguna saat ini? Anda perlu memasukkan ID pengguna lagi.';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get tokenCleared => 'Pengguna dihapus';

  @override
  String clearTokenFailed(Object error) {
    return 'Gagal menghapus pengguna: $error';
  }

  @override
  String get selectDateRangeOptional => 'Pilih rentang tanggal (opsional):';

  @override
  String get startDate => 'Tanggal mulai';

  @override
  String get endDate => 'Tanggal akhir';

  @override
  String get select => 'Pilih';

  @override
  String get processLimitOptional => 'Batas pemrosesan (opsional)';

  @override
  String get leaveEmptyForAll => 'Kosongkan untuk memproses semua';

  @override
  String get startProcessing => 'Mulai memproses';

  @override
  String get userIdNotFound => 'ID pengguna tidak ditemukan';

  @override
  String createTaskFailed(Object error) {
    return 'Gagal membuat tugas: $error';
  }

  @override
  String get reprocessCards => 'Proses ulang kartu';

  @override
  String get reprocessCardsTaskCreated =>
      'Permintaan proses ulang masuk antrean di Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Cakupan';

  @override
  String get reprocessCardsCardOnly => 'Hanya kartu';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Minta Super Agent meninjau dan membuat ulang kartu linimasa yang dipilih.';

  @override
  String get reprocessCardsRerunDownstream => 'Kartu dan tindak lanjut terkait';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Minta Super Agent juga mempertimbangkan pembaruan PKM dan insight terkait bila diperlukan.';

  @override
  String get reanalyzeMediaAssets => 'Baca ulang lampiran media';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Minta Super Agent memeriksa media terlampir lagi saat membuat ulang kartu.';

  @override
  String get regenerateComments => 'Buat ulang komentar';

  @override
  String get regenerateCommentsTaskCreated =>
      'Tugas pembuatan ulang komentar dibuat dan berjalan di latar belakang';

  @override
  String get rebuildSearchIndex => 'Bangun ulang indeks pencarian';

  @override
  String get rebuildSearchIndexSuccess =>
      'Indeks pencarian berhasil dibangun ulang';

  @override
  String get rebuildSearchIndexFailed =>
      'Gagal membangun ulang indeks pencarian';

  @override
  String get clearData => 'Hapus data';

  @override
  String get confirmClearDataMessage => 'Hapus data?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Semua data workspace lokal untuk pengguna saat ini akan dihapus, termasuk kartu, media, berkas pengetahuan, insight, memori, riwayat chat, dan status sistem.\\n\\nTindakan ini tidak dapat dibatalkan!';

  @override
  String get clearFailedAgentContexts => 'Hapus konteks percakapan yang gagal';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Hapus konteks percakapan tersimpan untuk agen Insight dan Jadwal? Ini berguna setelah mengganti model ketika pesan agen sebelumnya tidak lagi kompatibel. Fakta, kartu, pengetahuan, memori, dan pengaturan model tidak akan dihapus.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count konteks percakapan tersimpan dihapus';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Gagal menghapus konteks percakapan: $error';
  }

  @override
  String get cloneToTestUser => 'Kloning ke pengguna uji';

  @override
  String get confirmCloneToTestUserMessage =>
      'Salin workspace saat ini ke pengguna uji lokal baru dan beralih ke sana. Status runtime agen tidak disalin. Data pengguna saat ini tidak akan diubah.';

  @override
  String get testUserIdLabel => 'ID pengguna uji';

  @override
  String get testUserIdHelper =>
      'Gunakan huruf, angka, tanda hubung, atau garis bawah.';

  @override
  String get testUserIdInvalid =>
      'Gunakan hanya huruf, angka, tanda hubung, atau garis bawah.';

  @override
  String get overwriteExistingTestUser =>
      'Ganti pengguna uji yang ada dengan ID yang sama';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Beralih ke pengguna uji $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Gagal mengkloning pengguna uji: $error';
  }

  @override
  String get dataClearedSuccess => 'Data berhasil dihapus';

  @override
  String clearDataFailed(Object error) {
    return 'Gagal menghapus data: $error';
  }

  @override
  String get personalCenter => 'Pusat pribadi';

  @override
  String get viewLogs => 'Lihat log';

  @override
  String get systemAuthorization => 'Otorisasi sistem';

  @override
  String get aiCharacterConfig => 'Konfigurasi karakter AI';

  @override
  String get modelConfig => 'Konfigurasi model';

  @override
  String get agentConfig => 'Konfigurasi agen';

  @override
  String get experimentalLab => 'Lab';

  @override
  String get experimentalLabDescription =>
      'Fitur eksperimental yang dapat berubah atau dipindahkan nanti.';

  @override
  String get modelUsageStats => 'Statistik penggunaan model';

  @override
  String get asyncTaskList => 'Daftar tugas asinkron';

  @override
  String get clearLocalToken => 'Hapus pengguna';

  @override
  String get insightCardTemplates => 'Template kartu insight';

  @override
  String get timelineCardTemplates => 'Template kartu linimasa';

  @override
  String get logViewer => 'Penampil log';

  @override
  String get autoRefresh => 'Refresh otomatis';

  @override
  String get lineCount => 'Jumlah baris: ';

  @override
  String get all => 'Semua';

  @override
  String get schedule => 'Jadwal';

  @override
  String get appLockConfig => 'Konfigurasi kunci aplikasi';

  @override
  String loadStatsFailed(Object error) {
    return 'Gagal memuat statistik: $error';
  }

  @override
  String get overview => 'Ikhtisar';

  @override
  String get daily => 'Harian';

  @override
  String get modelStatsByAgent => 'Menurut agen';

  @override
  String get detail => 'Rincian';

  @override
  String get date => 'Tanggal';

  @override
  String get agent => 'Agen';

  @override
  String get noData => 'Tidak ada data';

  @override
  String get totalCalls => 'Total panggilan';

  @override
  String get calls => 'Panggilan';

  @override
  String callsCount(Object count) {
    return '$count panggilan';
  }

  @override
  String get selectDateRange => 'Pilih rentang tanggal';

  @override
  String get totalTokens => 'Total token';

  @override
  String get cacheRate => 'Rasio cache';

  @override
  String get promptTokens => 'Token prompt';

  @override
  String get completionTokens => 'Token jawaban';

  @override
  String get cachedTokens => 'Token cache';

  @override
  String get thoughtTokens => 'Token pemikiran';

  @override
  String get prompt => 'Instruksi';

  @override
  String get completion => 'Jawaban';

  @override
  String get cached => 'Tersimpan cache';

  @override
  String get thought => 'Pemikiran';

  @override
  String get model => 'Model';

  @override
  String get scene => 'Skenario';

  @override
  String get sceneId => 'ID skenario';

  @override
  String get tokenUsage => 'Penggunaan token';

  @override
  String get handler => 'Penangan';

  @override
  String get modelBreakdown => 'Rincian model';

  @override
  String get callDetails => 'Detail panggilan';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Detail catatan: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Gagal menyimpan konfigurasi LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Pratinjau HTML tidak tersedia di web. Silakan lihat di perangkat seluler.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Gagal menyimpan info pengguna: $error';
  }

  @override
  String get totalEstimatedCost => 'Estimasi biaya total';

  @override
  String get close => 'Tutup';

  @override
  String get totalTokenConsumption => 'Total konsumsi token';

  @override
  String get dataLoadFailedRetry => 'Gagal memuat data, coba lagi nanti.';

  @override
  String get timelineLoadFailedRetry =>
      'Gagal memuat linimasa, coba lagi nanti.';

  @override
  String get newPerspective => 'Sudut pandang baru';

  @override
  String get startPoint => 'Mulai';

  @override
  String get endPoint => 'Akhir';

  @override
  String get originalInput => 'Input asli';

  @override
  String get referenceContent => 'Konten referensi';

  @override
  String referenceWithTitle(Object title) {
    return 'Referensi: $title';
  }

  @override
  String get actionCenterTitle => 'Tindakan tertunda';

  @override
  String get noPendingActions => 'Tidak ada tindakan tertunda';

  @override
  String get clarificationNeeded => 'Memex ingin mengonfirmasi';

  @override
  String get clarificationTextHint => 'Ketik jawaban singkat';

  @override
  String get clarificationTextRequired =>
      'Tambahkan jawaban singkat terlebih dahulu';

  @override
  String get clarificationAnswered => 'Terjawab';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Jawaban: $answer';
  }

  @override
  String get answerSaved => 'Jawaban tersimpan';

  @override
  String get clarificationOtherAnswer => 'Input manual';

  @override
  String get clarificationNotSure => 'Tidak yakin / memilih tidak menjawab';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get footprintMap => 'Peta jejak';

  @override
  String get waypointPlaces => 'Tempat persinggahan';

  @override
  String get unknownPlace => 'Tempat tidak dikenal';

  @override
  String get releaseToSend => 'Lepas untuk mengirim';

  @override
  String get selectFromAlbum => 'Pilih dari album';

  @override
  String get clipboardPreviewTitle => 'Clipboard baru';

  @override
  String get clipboardPreviewImageTitle => 'Gambar clipboard';

  @override
  String get clipboardPreviewImageDescription => 'Gambar siap ditambahkan';

  @override
  String get clipboardPreviewUnprocessed => 'Belum ditempel';

  @override
  String get clipboardPreviewPasteToInput => 'Tempel ke input';

  @override
  String get clipboardPreviewAddImageToInput => 'Tambahkan gambar';

  @override
  String get clipboardPreviewImageFailed =>
      'Tidak dapat membaca gambar clipboard';

  @override
  String get tellAiWhatHappened => 'Beri tahu AI apa yang terjadi...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Merekam: $duration';
  }

  @override
  String get playing => 'Memutar...';

  @override
  String get sendLabel => 'Kirim';

  @override
  String attachedImagesMessage(Object count) {
    return 'Mengirim $count gambar';
  }

  @override
  String get noTaskData => 'Tidak ada data tugas';

  @override
  String createdAtDate(Object date) {
    return 'Dibuat: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Diperbarui: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Durasi: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Coba lagi: $count';
  }

  @override
  String get loadDetailFailedRetry => 'Gagal memuat detail, coba lagi nanti.';

  @override
  String get loadFailed => 'Gagal memuat';

  @override
  String loadHistoryFailed(Object error) {
    return 'Gagal memuat riwayat: $error';
  }

  @override
  String get reload => 'Muat ulang';

  @override
  String get aiInsightDetail => 'Detail insight';

  @override
  String relatedRecordsCount(Object count) {
    return 'Catatan terkait ($count)';
  }

  @override
  String get noRelatedRecords => 'Tidak ada catatan terkait';

  @override
  String get useFingerprintToUnlock => 'Gunakan sidik jari untuk membuka';

  @override
  String get locked => 'Terkunci';

  @override
  String get wrongPassword => 'Kata sandi salah';

  @override
  String get enterPassword => 'Masukkan kata sandi';

  @override
  String get memexLocked => 'Memex terkunci';

  @override
  String get calendarShortSun => 'Min';

  @override
  String get calendarShortMon => 'Sen';

  @override
  String get calendarShortTue => 'Sel';

  @override
  String get calendarShortWed => 'Rab';

  @override
  String get calendarShortThu => 'Kam';

  @override
  String get calendarShortFri => 'Jum';

  @override
  String get calendarShortSat => 'Sab';

  @override
  String noRecordsOnDate(Object date) {
    return 'Tidak ada catatan pada $date';
  }

  @override
  String get footprintPath => 'Jalur jejak';

  @override
  String get lifeCompositionTable => 'Komposisi hidup';

  @override
  String get emotionReframe => 'Bingkai ulang emosi';

  @override
  String get chronicleOfThings => 'Kronik berbagai hal';

  @override
  String get goalProgress => 'Progres tujuan';

  @override
  String get trendChart => 'Bagan tren';

  @override
  String get comparisonChart => 'Bagan perbandingan';

  @override
  String get todayTimeFlow => 'Alur waktu hari ini';

  @override
  String get aiInputHint => 'Entah kenangan atau saat ini, saya di sini...';

  @override
  String get refreshSuperAgentStateTooltip => 'Hapus konteks Memex Agent';

  @override
  String get refreshSuperAgentStateTitle =>
      'Hapus konteks riwayat Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'Riwayat chat yang terlihat akan tetap ada, tetapi konteks runtime historis Memex Agent akan dihapus dan balasan berikutnya akan dimulai dari konteks baru. Memori persisten, berkas basis pengetahuan, kartu, dan data tersimpan lain tidak terpengaruh. Gunakan ini ketika Memex Agent terus berperilaku tidak normal. Lanjutkan?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Tunggu sampai pesan Memex Agent saat ini selesai sebelum menghapus konteks.';

  @override
  String get refreshSuperAgentStateSuccess => 'Konteks Memex Agent dihapus';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Gagal menghapus konteks Memex Agent: $error';
  }

  @override
  String get nothingHere => 'Belum ada apa pun di sini';

  @override
  String get nothingHereHint =>
      'Ketuk tombol di bawah untuk membuat kartu pertama Anda';

  @override
  String get agentProcessing => 'AI sedang memproses...';

  @override
  String get keepAppOpen => 'Jangan tutup aplikasi';

  @override
  String get activityDetail => 'Detail aktivitas';

  @override
  String get noAgentActivityYet => 'Belum ada aktivitas agen';

  @override
  String get processingEllipsis => 'Memproses...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent dijeda';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent perlu perhatian';

  @override
  String get agentBackgroundStageIdle => 'Diam';

  @override
  String get agentBackgroundStageProcessing => 'Memproses';

  @override
  String get agentBackgroundStageQueued => 'Dalam antrean';

  @override
  String get agentBackgroundStageRetrying => 'Menunggu coba ulang';

  @override
  String get agentBackgroundStagePaused => 'Dijeda';

  @override
  String get agentBackgroundStageCompleted => 'Selesai';

  @override
  String get agentBackgroundStageNeedsAttention => 'Perlu perhatian';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Menganalisis media';

  @override
  String get agentBackgroundStageGeneratingCard => 'Membuat kartu';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Memperbarui pengetahuan';

  @override
  String get agentBackgroundStagePreparingComment => 'Menyiapkan komentar';

  @override
  String get agentBackgroundStageRoutingFollowUps =>
      'Mengarahkan tindak lanjut';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return 'Berjalan $running, Tertunda $pending, Coba ulang $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Memproses $count tugas dalam antrean.';
  }

  @override
  String get agentBackgroundNoTasks => 'Tidak ada tugas latar belakang.';

  @override
  String get agentBackgroundStarting => 'Pemrosesan sedang dimulai.';

  @override
  String get agentBackgroundCompletedDetail =>
      'Semua tugas latar belakang selesai.';

  @override
  String get agentBackgroundFailedDetail => 'Pemrosesan berhenti karena error.';

  @override
  String get agentBackgroundPausedDetail =>
      'Pemrosesan dijeda dan akan dilanjutkan nanti.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Menunggu langkah pemrosesan berikutnya.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Langkah saat ini akan dicoba ulang secara otomatis.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Membaca lampiran dan konteks lokal.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Mengubah catatan menjadi kartu linimasa.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Memperbarui pengetahuan dan memori lokal.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Menyiapkan tindak lanjut asisten.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Memeriksa tindakan lanjutan untuk kartu ini.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Dijeda - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Perlu perhatian - $summary';
  }

  @override
  String get settings => 'Pengaturan';

  @override
  String get languageSettings => 'Bahasa';

  @override
  String get languageSettingsDesc => 'Ubah bahasa tampilan aplikasi';

  @override
  String get noPendingActionsToast => 'Tidak ada tindakan tertunda';

  @override
  String get knowledgeNewDiscovery => 'Penemuan pengetahuan baru';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Menemukan $count insight baru';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Memperbarui $count insight yang ada';
  }

  @override
  String get sectionNewInsights => 'Insight baru';

  @override
  String get sectionUpdatedInsights => 'Insight diperbarui';

  @override
  String get unnamedInsight => 'Insight tanpa nama';

  @override
  String get copiedToClipboard => 'Disalin ke clipboard';

  @override
  String get copy => 'Salin';

  @override
  String get selectedLocation => 'Lokasi terpilih';

  @override
  String get confirmLocationName => 'Konfirmasi nama lokasi';

  @override
  String get confirmLocationNameHint =>
      'Anda dapat mengedit nama (koordinat tetap sama)';

  @override
  String get nameLabel => 'Nama';

  @override
  String get inputPlaceNameHint => 'Masukkan nama tempat...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Koordinat: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Konfirmasi lokasi';

  @override
  String get welcomeToMemex => 'Selamat datang di Memex';

  @override
  String get createUserIdToStart => 'Buat profil Anda';

  @override
  String get userIdLabel => 'Nama / panggilan Anda';

  @override
  String get userIdHint => 'Masukkan nama atau panggilan Anda';

  @override
  String get pleaseEnterUserId => 'Masukkan nama Anda';

  @override
  String get userIdMaxLength => 'Nama tidak boleh lebih dari 50 karakter';

  @override
  String get startUsing => 'Lanjutkan';

  @override
  String get userIdTip =>
      'Ini akan digunakan untuk mempersonalisasi pengalaman Anda.';

  @override
  String get setupModelConfigTitle => 'Siapkan model AI';

  @override
  String get setupModelConfigSubtitle =>
      'Memex membutuhkan model AI frontier untuk mengatur catatan, menganalisis gambar, dan menghasilkan insight. Pilih satu metode koneksi.';

  @override
  String get setupModelConfigComplete => 'Selesai & masuk';

  @override
  String get aiService => 'Layanan Model Memex';

  @override
  String get aiModelHubTitle => 'Model dan layanan AI';

  @override
  String get aiModelHubSubtitle =>
      'Pilih layanan resmi Memex atau gunakan penyedia Anda sendiri. Routing model lanjutan tetap tersedia saat dibutuhkan.';

  @override
  String get aiSetupCurrentStatusTitle => 'Pengaturan saat ini';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'Layanan AI belum dikonfigurasi';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Pilih satu metode koneksi untuk mengaktifkan pengorganisasian AI atas catatan, media, dan insight.';

  @override
  String get aiSetupStatusMemexTitle => 'Menggunakan layanan resmi MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex akan memakai koneksi resmi dan kredensial API yang dikelola oleh akun MemeX Anda.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Menggunakan pengaturan penyedia khusus';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex akan memakai kredensial penyedia dan pilihan peran model yang Anda konfigurasi.';

  @override
  String get aiSetupChooseConnectionTitle => 'Pilih metode koneksi';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Mulai dari jalur yang sesuai dengan cara Anda ingin Memex mengakses model AI.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Masuk ke MemeX dan gunakan layanan resmi tanpa memilih penyedia, key, atau model tingkat agen.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Tambahkan kredensial penyedia Anda sendiri, pilih model yang digunakan Super Agent, dan opsional timpa model per agen.';

  @override
  String get aiSetupCustomPageTitle => 'Layanan AI khusus';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Konfigurasikan kredensial penyedia terlebih dahulu, lalu pilih model yang harus digunakan Memex.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Penyedia dan API key';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Tambah atau edit OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama, atau penyedia kompatibel lain.';

  @override
  String get modelRolesTitle => 'Pilih model utama';

  @override
  String get modelRolesDescription =>
      'Super Agent menggunakan satu model untuk input teks dan gambar. Override agen lanjutan tetap tersedia di bawah.';

  @override
  String get textModelRoleTitle => 'Model utama';

  @override
  String get textModelRoleDescription =>
      'Digunakan oleh Super Agent untuk teks, gambar, kartu, pengetahuan, insight, chat, komentar, dan memori.';

  @override
  String get modelConnectionsTitle => 'Penyedia model dan API key';

  @override
  String get modelConnectionsDescription =>
      'Hubungkan layanan resmi Memex atau tambahkan kredensial penyedia Anda sendiri.';

  @override
  String get relatedAiCapabilitiesTitle => 'Kemampuan lanjutan dan terkait';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Sempurnakan penugasan agen, penyedia lokasi, dan perilaku transkripsi suara.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Kemampuan layanan';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Pilih penyedia yang digunakan Memex untuk kemampuan pendukung berbasis AI seperti suara dan reverse geocoding.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Routing model lanjutan';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Untuk pengguna mahir yang ingin tiap agen memakai penyedia atau konfigurasi model berbeda.';

  @override
  String get locationProviderSettings => 'Penyedia lokasi';

  @override
  String get speechProviderSettings => 'Transkripsi suara';

  @override
  String get advancedAgentModelAssignments => 'Penugasan model agen';

  @override
  String get openAdvancedAgentModelAssignments => 'Override agen individual';

  @override
  String get noConfiguredModelOptions =>
      'Tambahkan penyedia atau API key sebelum memilih peran model.';

  @override
  String get modelSlotUpdated => 'Peran model diperbarui';

  @override
  String get aiServiceMemexRouteTitle => 'Hubungkan lewat Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex menggunakan sistem multi-agen untuk mengatur catatan hidup, catatan pengetahuan, dan konteks sosial, menemukan insight yang lebih dalam, serta menyediakan pendamping AI dengan memori persisten. Data Anda disimpan sebagai Markdown teks biasa, menjaga kebebasan dan portabilitas data.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Saya punya API key';

  @override
  String get aiServiceCustomModelDescription =>
      'Pilih ini terlebih dahulu jika Anda sudah punya API key dari OpenAI, Anthropic, DeepSeek, Gemini, atau penyedia lain.';

  @override
  String get enableAiService => 'Hubungkan dengan Memex';

  @override
  String get aiServiceReadyToast => 'Pengorganisasian AI aktif';

  @override
  String get aiServiceSettingsDescription =>
      'Jika Anda tidak punya API key, gunakan akun Memex untuk terhubung ke layanan model utama.';

  @override
  String get advancedModelConfiguration => 'Konfigurasikan API key';

  @override
  String get skipForNow => 'Lewati sekarang';

  @override
  String get clearAuth => 'Hapus otorisasi';

  @override
  String get authorizing => 'Mengotorisasi...';

  @override
  String authFailed(Object error) {
    return 'Otorisasi gagal: $error';
  }

  @override
  String get authorized => 'Terotorisasi';

  @override
  String authorizedAs(Object email) {
    return 'Diotorisasi sebagai $email';
  }

  @override
  String get authorizedSuccessfully => 'Berhasil diotorisasi';

  @override
  String get reAuthorize => 'Otorisasi ulang';

  @override
  String get authorizeWithOpenAi => 'Otorisasi dengan OpenAI';

  @override
  String get authorizeWithGoogle => 'Otorisasi dengan Google';

  @override
  String get config => 'Konfigurasi';

  @override
  String get calendar => 'Kalender';

  @override
  String get reminders => 'Pengingat';

  @override
  String get writeToSystemFailed => 'Gagal menulis ke sistem';

  @override
  String permissionRequired(Object name) {
    return 'Izin $name diperlukan';
  }

  @override
  String permissionRationale(Object name) {
    return 'Izinkan aplikasi mengakses $name Anda di Pengaturan agar kami dapat membuatnya untuk Anda.';
  }

  @override
  String get goToSettings => 'Buka Pengaturan';

  @override
  String get unknownAction => 'Tindakan tidak dikenal';

  @override
  String get discoveredCalendarEvent => 'Acara kalender ditemukan';

  @override
  String get discoveredReminder => 'Pengingat ditemukan';

  @override
  String get addToCalendar => 'Tambahkan ke kalender';

  @override
  String get addToReminders => 'Tambahkan ke pengingat';

  @override
  String get systemActionPendingExplanation =>
      'Belum ditambahkan. Ketuk di bawah untuk meminta izin dan menambahkannya ke perangkat Anda.';

  @override
  String addedToSuccess(Object target) {
    return 'Berhasil ditambahkan ke $target';
  }

  @override
  String get ignore => 'Abaikan';

  @override
  String get confirmDelete => 'Konfirmasi hapus';

  @override
  String get confirmDeleteSessionMessage =>
      'Hapus percakapan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteSuccess => 'Berhasil dihapus';

  @override
  String deleteFailed(Object error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count hari lalu';
  }

  @override
  String get chatHistory => 'Riwayat chat';

  @override
  String get enterFullScreenTooltip => 'Masuk layar penuh';

  @override
  String get exitFullScreenTooltip => 'Keluar layar penuh';

  @override
  String get noConversations => 'Tidak ada percakapan';

  @override
  String loadSessionListFailed(Object error) {
    return 'Gagal memuat daftar sesi: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Kemarin $time';
  }

  @override
  String get newChat => 'Chat baru';

  @override
  String messageCount(Object count) {
    return '$count pesan';
  }

  @override
  String get organize => 'Organisasi';

  @override
  String get pkmCategoryProject => 'Proyek';

  @override
  String get pkmCategoryProjectSubtitle => 'Jangka pendek · Tujuan · Tenggat';

  @override
  String get pkmCategoryArea => 'Bidang';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Jangka panjang · Tanggung jawab · Standar';

  @override
  String get pkmCategoryResource => 'Sumber daya';

  @override
  String get pkmCategoryResourceSubtitle => 'Minat · Inspirasi · Cadangan';

  @override
  String get pkmCategoryArchive => 'Arsip';

  @override
  String get pkmCategoryArchiveSubtitle => 'Selesai · Dormant · Referensi';

  @override
  String get recentChanges => 'Perubahan terbaru';

  @override
  String get noRecentChangesInThreeDays =>
      'Tidak ada perubahan dalam 3 hari terakhir';

  @override
  String get unpinned => 'Tidak disematkan';

  @override
  String get pinnedStyle => 'Gaya disematkan';

  @override
  String operationFailed(Object error) {
    return 'Operasi gagal: $error';
  }

  @override
  String get refreshingInsightData =>
      'Menyegarkan data insight, ini mungkin perlu beberapa saat...';

  @override
  String refreshFailed(Object error) {
    return 'Gagal menyegarkan: $error';
  }

  @override
  String get sortUpdated => 'Urutan sortir diperbarui';

  @override
  String sortSaveFailed(Object error) {
    return 'Gagal menyimpan urutan: $error';
  }

  @override
  String get insightCardDeleted => 'Kartu insight dihapus';

  @override
  String deleteFailedShort(Object error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String get knowledgeInsight => 'Insight pengetahuan';

  @override
  String get completeSort => 'Selesaikan sortir';

  @override
  String get noKnowledgeInsight => 'Tidak ada insight pengetahuan';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count tugas latar belakang masih diproses.';
  }

  @override
  String get insightUnavailableMessage =>
      'Insight ini masih dibuat atau telah diperbarui. Segarkan insight dan coba lagi nanti.';

  @override
  String get artifactOpen => 'Buka';

  @override
  String get updating => 'Memperbarui...';

  @override
  String get update => 'Perbarui';

  @override
  String get enabled => 'Aktif';

  @override
  String get disabled => 'Nonaktif';

  @override
  String get appLockOn => 'Kunci aplikasi aktif';

  @override
  String get appLockOff => 'Kunci aplikasi nonaktif';

  @override
  String get enableAppLockFirst => 'Aktifkan kunci aplikasi terlebih dahulu';

  @override
  String get enterFourDigitPassword => 'Masukkan kata sandi 4 digit';

  @override
  String get passwordSetAndLockOn =>
      'Kata sandi diatur dan kunci aplikasi aktif';

  @override
  String get appLockSettings => 'Pengaturan kunci aplikasi';

  @override
  String get enableAppLock => 'Aktifkan kunci aplikasi';

  @override
  String get enableAppLockSubtitle =>
      'Kata sandi diperlukan saat membuka aplikasi';

  @override
  String get enableBiometrics => 'Aktifkan biometrik';

  @override
  String get biometricsSubtitle =>
      'Gunakan Face ID atau Touch ID untuk membuka';

  @override
  String get changePassword => 'Ubah kata sandi';

  @override
  String get setFourDigitPassword => 'Atur kata sandi 4 digit';

  @override
  String get reenterPasswordToConfirm =>
      'Masukkan ulang kata sandi untuk konfirmasi';

  @override
  String get passwordMismatch => 'Kata sandi tidak cocok. Coba lagi.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Hapus karakter \"$name\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get configureAiCharacter => 'Konfigurasikan karakter AI';

  @override
  String get addCharacter => 'Tambah karakter';

  @override
  String get addCharacterSubtitle =>
      'Pilih karakter AI untuk bergabung dengan tim insight Anda. Mereka akan menganalisis data hidup Anda dari sudut yang berbeda.';

  @override
  String get noCharacters => 'Tidak ada karakter';

  @override
  String loadCharacterFailed(Object error) {
    return 'Gagal memuat karakter: $error';
  }

  @override
  String get noTags => 'Tidak ada tag';

  @override
  String get createSuccess => 'Berhasil dibuat';

  @override
  String get updateSuccess => 'Berhasil diperbarui';

  @override
  String saveFailed(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get newCharacter => 'Karakter baru';

  @override
  String get editCharacter => 'Edit karakter';

  @override
  String get save => 'Simpan';

  @override
  String get characterName => 'Nama karakter';

  @override
  String get characterNameHint => 'Beri nama karakter Anda';

  @override
  String get pleaseEnterCharacterName => 'Masukkan nama karakter';

  @override
  String get tagsLabel => 'Tag';

  @override
  String get tagsHint =>
      'mis. wisdom, recognition, macro\\nPisahkan beberapa tag dengan koma';

  @override
  String get characterPersonaLabel => 'Persona karakter';

  @override
  String get characterPersonaHint =>
      'Sertakan persona, panduan gaya, contoh dialog, filter pengetahuan, dll.\\nGunakan ## untuk judul bagian.';

  @override
  String get pleaseEnterCharacterPersona => 'Masukkan persona karakter';

  @override
  String permissionRequestError(Object error) {
    return 'Error permintaan izin: $error';
  }

  @override
  String get permissionRequiredTitle => 'Izin diperlukan';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Anda telah menolak izin ini secara permanen atau sistem memerlukannya. Aktifkan di pengaturan sistem.';

  @override
  String get getting => 'Mengambil...';

  @override
  String get unauthorized => 'Belum diotorisasi';

  @override
  String get authorizedGoToSettings =>
      'Terotorisasi. Buka pengaturan sistem untuk mengubah.';

  @override
  String get location => 'Lokasi';

  @override
  String get locationPermissionReason =>
      'Untuk mencatat tempat dan fitur terkait lokasi';

  @override
  String get photos => 'Foto';

  @override
  String get photosPermissionReason =>
      'Untuk memilih foto, menyimpan gambar yang dibuat, dll.';

  @override
  String get camera => 'Kamera';

  @override
  String get cameraPermissionReason => 'Untuk mengambil foto dan video';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get microphonePermissionReason =>
      'Untuk pengenalan suara, rekaman, dll.';

  @override
  String get calendarPermissionReason =>
      'Untuk mencatat jadwal dan membaca acara kalender';

  @override
  String get remindersPermissionReason =>
      'Untuk mencatat dan membaca pengingat Anda';

  @override
  String get fitnessAndMotion => 'Kebugaran & gerakan';

  @override
  String get fitnessPermissionReason =>
      'Untuk mencatat data kesehatan dan gerakan';

  @override
  String get notification => 'Notifikasi';

  @override
  String get notificationPermissionReason =>
      'Untuk mengirim jadwal dan pengingat penting';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Biarkan Memex Agent berjalan di latar belakang';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent berjalan secara lokal di perangkat Anda. Dengan notifikasi, Memex dapat menampilkan progres dan terus memproses setelah Anda keluar dari app atau mematikan layar. Jika notifikasi dimatikan, biarkan Memex tetap terbuka di depan sampai tugas selesai.';

  @override
  String get loadDetailFailedRetryShort =>
      'Gagal memuat detail, coba lagi nanti.';

  @override
  String get total => 'Jumlah';

  @override
  String get estimatedCost => 'Estimasi biaya';

  @override
  String get byAgent => 'Menurut Agen';

  @override
  String get timeUpdated => 'Waktu diperbarui';

  @override
  String updateFailed(Object error) {
    return 'Gagal memperbarui: $error';
  }

  @override
  String get locationUpdated => 'Lokasi diperbarui';

  @override
  String get confirmDeleteCardMessage =>
      'Hapus kartu ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get cardDetailNotFound => 'Detail kartu tidak ditemukan';

  @override
  String get saySomething => 'Katakan sesuatu...';

  @override
  String get relatedMemories => 'Memori terkait';

  @override
  String get viewMore => 'Lihat lebih banyak';

  @override
  String get relatedRecords => 'Catatan terkait';

  @override
  String get reply => 'Balas';

  @override
  String get replySent => 'Balasan terkirim';

  @override
  String get insightTemplateGalleryTitle => 'Template kartu insight';

  @override
  String get timelineTemplateGalleryTitle => 'Template kartu linimasa';

  @override
  String get categoryTextual => 'Tekstual';

  @override
  String get timelineFilterAll => 'SEMUA';

  @override
  String get insights => 'Insight';

  @override
  String get memoryTitle => 'Memori';

  @override
  String get longTermProfile => 'Profil jangka panjang';

  @override
  String get recentBuffer => 'Buffer terbaru';

  @override
  String errorLoadingMemory(Object error) {
    return 'Error memuat memori: $error';
  }

  @override
  String get agentConfiguration => 'Konfigurasi Agen';

  @override
  String get resetToDefaults => 'Reset ke Default';

  @override
  String get resetAllAgentConfigurationsTitle => 'Reset Semua Konfigurasi Agen';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Yakin ingin mereset semua konfigurasi agen ke nilai default? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get resetButton => 'Atur ulang';

  @override
  String loadDataFailed(Object error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Gagal menyimpan konfigurasi: $error';
  }

  @override
  String get selectLlmClient => 'Pilih LLM Client:';

  @override
  String get agentConfigurationsReset => 'Konfigurasi agen direset';

  @override
  String resetFailed(Object error) {
    return 'Gagal mereset: $error';
  }

  @override
  String get modelConfiguration => 'Konfigurasi Model';

  @override
  String get resetAllConfigurationsTitle => 'Reset Semua Konfigurasi';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Yakin ingin mereset semua konfigurasi model ke nilai default? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get modelConfigurationsReset => 'Konfigurasi model direset';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Tidak dapat menghapus konfigurasi default';

  @override
  String get cannotDeleteConfigurationTitle =>
      'Tidak Dapat Menghapus Konfigurasi';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Konfigurasi ini sedang digunakan oleh agen berikut:\\n\\n$agentList\\n\\nTetapkan ulang agen tersebut sebelum menghapus.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Hapus Konfigurasi';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Yakin ingin menghapus \"$key\"?';
  }

  @override
  String get defaultLabel => 'Bawaan';

  @override
  String get setAsDefault => 'Jadikan default';

  @override
  String get invalidJsonInExtraField => 'JSON tidak valid di kolom Extra';

  @override
  String get keyAlreadyExists => 'Key sudah ada';

  @override
  String get resetConfigurationTitle => 'Reset Konfigurasi';

  @override
  String get resetConfigurationMessage =>
      'Reset konfigurasi ini ke nilai default awal? Perubahan saat ini akan hilang.';

  @override
  String get configurationResetPressSave =>
      'Konfigurasi direset. Tekan Simpan untuk menerapkan.';

  @override
  String get addConfiguration => 'Tambah Konfigurasi';

  @override
  String get editConfiguration => 'Edit Konfigurasi';

  @override
  String get duplicateConfiguration => 'Duplikat Konfigurasi';

  @override
  String get duplicate => 'Duplikat';

  @override
  String get keyIdLabel => 'ID konfigurasi';

  @override
  String get keyIdHelper =>
      'Beri nama setup ini, misalnya deepseek atau work-gpt.';

  @override
  String get required => 'Wajib';

  @override
  String get clientLabel => 'Penyedia model';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Populer';

  @override
  String get providerOpenAiApiKey => 'Kunci API';

  @override
  String get providerOpenAiResponses => 'Kunci API (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'Kunci API';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Moonshot)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (Lokal)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Layanan proxy Memex';

  @override
  String get memexSignIn => 'Masuk';

  @override
  String get memexCreateAccount => 'Buat Akun';

  @override
  String get memexUsername => 'Nama pengguna';

  @override
  String get memexPassword => 'Kata sandi';

  @override
  String get memexCreateAccountLink => 'Buat akun';

  @override
  String get memexSignInLink => 'Masuk sebagai gantinya';

  @override
  String get memexTopUp => 'Isi saldo untuk mulai memakai Memex AI';

  @override
  String get memexTopUpSuccess => 'Isi saldo berhasil!';

  @override
  String get memexFillAllFields => 'Lengkapi semua kolom';

  @override
  String get memexUsernameTooShort => 'Nama pengguna minimal 6 karakter';

  @override
  String get memexAuthFailed => 'Autentikasi gagal';

  @override
  String get memexPaymentFailed => 'Gagal membuat pembayaran';

  @override
  String get memexLogout => 'Keluar';

  @override
  String get memexTopUpButton => 'Isi saldo';

  @override
  String get memexTopUpChooseAmount => 'Pilih jumlah';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Sekitar $range catatan';
  }

  @override
  String get memexTopUpPlanStarter => 'Pemula';

  @override
  String get memexTopUpPlanEveryday => 'Harian';

  @override
  String get memexTopUpPlanHighVolume => 'Volume tinggi';

  @override
  String get memexTopUpPlanCustom => 'Kredit khusus';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Cocok untuk mencoba Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Cocok untuk pengorganisasian rutin';

  @override
  String get memexTopUpPlanHighVolumeSubtitle =>
      'Cocok untuk batch lebih besar';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Masukkan USD 1-10.000';

  @override
  String get memexTopUpCustomEstimate =>
      'Estimasi didasarkan pada jumlah yang dimasukkan';

  @override
  String get memexCustomAmount => 'Jumlah khusus';

  @override
  String get memexViewHistory => 'Riwayat penggunaan';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Saldo: $amount';
  }

  @override
  String get memexConfirmPassword => 'Konfirmasi kata sandi';

  @override
  String get memexPasswordMismatch => 'Kata sandi tidak cocok';

  @override
  String memexPayAmount(Object amount) {
    return 'Isi $amount';
  }

  @override
  String get modelIdLabel => 'Model AI';

  @override
  String get modelIdHelper => 'mis. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Mengambil model...';

  @override
  String get fetchModelsButton => 'Ambil Model';

  @override
  String get enterApiKeyFirst =>
      'Masukkan API Key terlebih dahulu untuk mengambil model';

  @override
  String get apiKeyLabel => 'Kunci API';

  @override
  String get baseUrlLabel => 'Endpoint API';

  @override
  String get advancedSettings => 'Pengaturan Lanjutan';

  @override
  String get testConnectionSuccess => 'Koneksi Berhasil';

  @override
  String get testConnectionFailed => 'Koneksi Gagal';

  @override
  String get testTypeText => 'Teks';

  @override
  String get testTypeVision => 'Vision';

  @override
  String get testButton => 'Tes';

  @override
  String get testing => 'Menguji...';

  @override
  String get proxyUrlOptional => 'URL proxy (Opsional)';

  @override
  String get proxyUrlHelper => 'mis. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => 'Parameter ekstra (JSON)';

  @override
  String get invalidJson => 'JSON tidak valid';

  @override
  String get warning => 'Setup Belum Lengkap';

  @override
  String get invalidConfigurationWarning =>
      'Konfigurasi belum lengkap (misalnya API Key atau Model ID hilang). Anda tetap dapat menyimpannya dan mengonfigurasikannya nanti. Lanjutkan?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" membutuhkan konfigurasi model yang valid (key: \"$configKey\") agar dapat berjalan. Periksa pengaturan model.';
  }

  @override
  String get discardChangesTitle => 'Tinggalkan halaman ini?';

  @override
  String get discardChangesMessage =>
      'Jika Anda membuat perubahan, simpan sebelum keluar.';

  @override
  String get discardButton => 'Buang';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get chooseAvatar => 'Pilih Avatar';

  @override
  String get configureNow => 'Konfigurasi Sekarang';

  @override
  String get modelNotConfiguredBanner =>
      'Model AI belum dikonfigurasi. Siapkan untuk membuka semua fitur.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Konfigurasikan model AI sebelum menerbitkan';

  @override
  String get processingStatus => 'Memproses';

  @override
  String get failedStatus => 'Gagal';

  @override
  String get failureReason => 'Alasan kegagalan';

  @override
  String get unknownError => 'Terjadi error tidak dikenal';

  @override
  String get enableFitness => 'Aktifkan Kebugaran';

  @override
  String get fitnessBannerMessage =>
      'Izinkan akses kebugaran untuk melacak data kesehatan dan aktivitas Anda.';

  @override
  String get fitnessDismissTitle => 'Lewati Akses Kebugaran?';

  @override
  String get fitnessDismissMessage =>
      'Tanpa izin kebugaran, aplikasi tidak dapat mengumpulkan data kesehatan Anda secara otomatis untuk insight dan pencatatan otomatis.';

  @override
  String get skipAnyway => 'Tetap lewati';

  @override
  String get proModelHint =>
      'Model ini membutuhkan langganan ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Cari basis pengetahuan...';

  @override
  String get searchKnowledgeHint =>
      'Masukkan kata kunci untuk mencari nama file atau isi';

  @override
  String noSearchResults(Object query) {
    return 'Tidak ada hasil untuk \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'Hanya pratinjau Markdown yang didukung';

  @override
  String get backupAndRestore => 'Cadangkan & Pulihkan';

  @override
  String get createBackup => 'Buat Cadangan';

  @override
  String get restoreBackup => 'Pulihkan Cadangan';

  @override
  String get backupDescription =>
      'Kemas semua data Anda (kartu, basis pengetahuan, insight, pengaturan) ke dalam file .memex. Simpan ke iCloud Drive, Google Drive, atau lokasi mana pun melalui share sheet.';

  @override
  String get restoreDescription =>
      'Pilih file cadangan .memex untuk memulihkan semua data. Ini akan menimpa data saat ini.';

  @override
  String get selectBackupFile => 'Pilih File Cadangan';

  @override
  String get estimatedSize => 'Estimasi ukuran';

  @override
  String get backupComplete => 'Cadangan dibuat';

  @override
  String backupFailed(Object error) {
    return 'Cadangan gagal: $error';
  }

  @override
  String get confirmRestore => 'Konfirmasi Pemulihan';

  @override
  String get confirmRestoreMessage =>
      'Pemulihan akan menimpa semua data saat ini termasuk kartu, basis pengetahuan, insight, dan pengaturan. Ini tidak dapat dibatalkan. Lanjutkan?';

  @override
  String get restoreComplete => 'Pemulihan selesai';

  @override
  String get restoreRestartHint =>
      'Data telah dipulihkan. Mulai ulang aplikasi agar semua perubahan berlaku.';

  @override
  String restoreFailed(Object error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String get invalidBackupFile =>
      'File cadangan tidak valid. Pilih file .memex.';

  @override
  String get automaticBackup => 'Cadangan Otomatis';

  @override
  String get autoBackupDescription =>
      'Jika aktif, Memex membuat paling banyak satu snapshot lokal per hari setelah startup atau saat kembali ke foreground.';

  @override
  String get backupSensitiveSettingsHint =>
      'Cadangan menyertakan pengaturan dan key penyedia model. Simpan file cadangan di tempat yang Anda percaya.';

  @override
  String get backupLocation => 'Lokasi';

  @override
  String get backupLocationDetails => 'Detail lokasi';

  @override
  String get backupLocationSummary => 'Ditampilkan di aplikasi';

  @override
  String get backupLocationFullPath => 'Path lengkap';

  @override
  String get backupLocationUri => 'URI akses folder';

  @override
  String get copyBackupLocationPath => 'Salin path';

  @override
  String get backupLocationCopied => 'Lokasi cadangan disalin';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Folder terpilih: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'Keadaan';

  @override
  String get noAutoBackupYet => 'Belum ada cadangan otomatis';

  @override
  String lastBackupAt(Object time) {
    return 'Cadangan terakhir: $time';
  }

  @override
  String get autoBackupRetention => 'Retensi';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days hari';
  }

  @override
  String get autoBackupRetentionForever => 'Simpan selamanya';

  @override
  String get autoBackupMaxSize => 'Batas penyimpanan';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Pembersihan otomatis menjaga snapshot otomatis di bawah $size. Snapshot keamanan dan ekspor manual disimpan terpisah.';
  }

  @override
  String get createSnapshotNow => 'Cadangkan sekarang';

  @override
  String get backupLocationMenu => 'Ubah lokasi';

  @override
  String get defaultBackupLocation => 'Folder cadangan default';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Gunakan folder file eksternal khusus aplikasi Memex. Tidak perlu izin penyimpanan.';

  @override
  String get chooseBackupLocation => 'Pilih folder cadangan';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Pilih folder dengan pemilih sistem Android dan beri Memex akses persisten.';

  @override
  String get storedBackups => 'Cadangan Tersimpan';

  @override
  String get noStoredBackups =>
      'Cadangan otomatis akan muncul di sini setelah snapshot pertama.';

  @override
  String get backupTypeAutoSnapshot => 'Snapshot otomatis';

  @override
  String get backupTypeSafetySnapshot => 'Snapshot keamanan';

  @override
  String get backupTypeManualBackup => 'Cadangan manual';

  @override
  String get refresh => 'Segarkan';

  @override
  String get restoreThisBackup => 'Pulihkan cadangan ini';

  @override
  String get deleteThisBackup => 'Hapus cadangan ini';

  @override
  String get confirmDeleteBackup => 'Hapus cadangan?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Hapus $fileName? Ini menghapus file cadangan tersimpan dan tidak dapat dibatalkan.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Cadangan dihapus: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Tidak dapat menghapus cadangan: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Membuat snapshot keamanan...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Snapshot dibuat: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Tidak dapat memperbarui lokasi cadangan: $error';
  }

  @override
  String get backupImportCreatedAt => 'Dibuat';

  @override
  String get backupImportSourceVersion => 'Versi sumber';

  @override
  String get backupImportFlavor => 'Varian build';

  @override
  String get backupLegacyFormat => 'Cadangan lama (tanpa manifest)';

  @override
  String get restoreInProgress => 'Memulihkan cadangan...';

  @override
  String get dataStorage => 'Penyimpanan Data';

  @override
  String get dataStorageDescriptionAndroid =>
      'Pilih folder khusus untuk menyimpan workspace Anda. Data tetap ada saat aplikasi dipasang ulang.';

  @override
  String get dataStorageDescriptionIOS =>
      'Aktifkan iCloud untuk menyinkronkan workspace lintas perangkat dan menjaga data saat aplikasi dipasang ulang.';

  @override
  String get storageLocationApp => 'Penyimpanan aplikasi';

  @override
  String get storageLocationAppDesc =>
      'Data disimpan di dalam aplikasi dan akan dihapus saat Anda menghapus aplikasi.';

  @override
  String get storageLocationCustom => 'Penyimpanan perangkat (folder khusus)';

  @override
  String get storageLocationCustomDesc =>
      'Simpan data di folder pilihan Anda. Data tetap ada setelah pemasangan ulang jika folder masih ada.';

  @override
  String get storageLocationICloud => 'Simpan di iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Sinkronkan workspace Anda di perangkat Apple. Data tetap ada setelah pemasangan ulang.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Saat ini: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Masuk ke iCloud dan aktifkan iCloud Drive untuk menggunakan penyimpanan iCloud.';

  @override
  String get loadingFromICloud => 'Memulihkan data dari iCloud…';

  @override
  String get switchingToICloud => 'Beralih ke penyimpanan iCloud…';

  @override
  String get switchingStorage => 'Beralih penyimpanan…';

  @override
  String get customFolderAccessDenied =>
      'Tidak dapat membaca atau menulis folder ini. Berikan izin penyimpanan atau pilih lokasi lain.';

  @override
  String get configured => 'Terkonfigurasi';

  @override
  String get apiKeyNotSet =>
      'API Key belum diatur — ketuk untuk mengonfigurasi';

  @override
  String get bottomNavTimeline => 'Linimasa';

  @override
  String get bottomNavLibrary => 'Pustaka';

  @override
  String get aiGeneratedLabel => 'Dihasilkan AI';

  @override
  String sourceTraceWithCount(Object count) {
    return 'JEJAK SUMBER ($count)';
  }

  @override
  String get deleteAccount => 'Hapus Akun';

  @override
  String get deleteAccountDesc =>
      'Hapus semua data lokal secara permanen dan reset aplikasi.';

  @override
  String get deleteAccountConfirmTitle => 'Hapus Akun?';

  @override
  String get deleteAccountConfirmMessage =>
      'Ini akan menghapus semua data Anda secara permanen, termasuk kartu linimasa, basis pengetahuan, rekaman, dan pengaturan. Tindakan ini tidak dapat dibatalkan.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Ketik \"$name\" untuk konfirmasi';
  }

  @override
  String get deleteAccountTypeHint => 'Masukkan nama pengguna untuk konfirmasi';

  @override
  String get llmConsentTitle => 'Persetujuan Berbagi Data';

  @override
  String llmConsentMessage(Object provider) {
    return 'Untuk mengaktifkan fitur AI, Memex perlu mengirim data Anda ke $provider untuk diproses. Ini mencakup:\\n\\n• Teks yang Anda masukkan (catatan, transkripsi suara)\\n• Metadata foto dan teks yang diekstrak (OCR)\\n• Ringkasan kesehatan dan kebugaran\\n• Konten kartu linimasa\\n\\nData Anda dikirim langsung dari perangkat Anda ke $provider. Memex tidak menyimpan atau meneruskan data Anda melalui server lain.\\n\\nTinjau kebijakan privasi $provider untuk mengetahui cara mereka menangani data Anda.\\n\\nApakah Anda setuju mengirim data Anda ke $provider untuk pemrosesan AI?';
  }

  @override
  String get llmConsentAgree => 'Saya Setuju';

  @override
  String get llmConsentDecline => 'Tolak';

  @override
  String get customAgents => 'Agen Khusus';

  @override
  String get noCustomAgents => 'Belum ada agen khusus yang dikonfigurasi.';

  @override
  String get deleteAgent => 'Hapus Agen';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Hapus agen khusus \"$name\"?';
  }

  @override
  String get deleted => 'Dihapus';

  @override
  String get saved => 'Disimpan';

  @override
  String get newAgent => 'Agen Baru';

  @override
  String get editAgent => 'Edit Agen';

  @override
  String get agentName => 'Nama Agen';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Wajib';

  @override
  String get agentNameInvalid => 'Hanya huruf, angka, dan tanda hubung';

  @override
  String get agentNameExists => 'Nama sudah ada';

  @override
  String get hostAgentType => 'Tipe Agen Host';

  @override
  String get skillDirectory => 'Direktori Skill';

  @override
  String get skillDirInvalid =>
      'Harus berupa path relatif (tanpa / di awal atau ..)';

  @override
  String get workingDirectory => 'Direktori Kerja (opsional)';

  @override
  String get workingDirectoryHint => 'Kosongkan untuk default workspace';

  @override
  String get llmConfig => 'Konfigurasi LLM';

  @override
  String get eventType => 'Tipe Event';

  @override
  String get executionMode => 'Mode Eksekusi';

  @override
  String get executionModeAsync => 'Async';

  @override
  String get executionModeSync => 'Sync';

  @override
  String get dependsOn => 'Bergantung Pada';

  @override
  String get dependsOnHint => 'Pilih dependensi';

  @override
  String get priority => 'Prioritas';

  @override
  String get maxRetries => 'Maks. Coba Ulang';

  @override
  String get systemPromptLabel => 'System Prompt (opsional)';

  @override
  String get systemPromptHint =>
      'Instruksi tambahan yang ditambahkan ke prompt agen host';

  @override
  String get eventSerializer => 'Serializer event';

  @override
  String get eventSerializerDefault => 'Bawaan (XML)';

  @override
  String get enabledLabel => 'Aktif';

  @override
  String get skillsManagement => 'Manajemen Skill';

  @override
  String get skillsManagementEmpty => 'Belum ada skill';

  @override
  String get downloadSkill => 'Unduh Skill';

  @override
  String get downloadFile => 'Unduh file';

  @override
  String get downloading => 'Mengunduh...';

  @override
  String get downloadSuccess => 'Skill berhasil diunduh';

  @override
  String downloadFailed(Object error) {
    return 'Unduhan gagal: $error';
  }

  @override
  String get deleteConfirm => 'Konfirmasi Hapus';

  @override
  String deleteConfirmMessage(String name) {
    return 'Yakin ingin menghapus \"$name\"?';
  }

  @override
  String get invalidUrl => 'Masukkan URL yang valid';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Folder Baru';

  @override
  String get newFile => 'File Baru';

  @override
  String get folderName => 'Nama Folder';

  @override
  String get fileName => 'Nama File';

  @override
  String get nameRequired => 'Nama wajib diisi';

  @override
  String get nameInvalid => 'Nama tidak boleh mengandung / atau ..';

  @override
  String createFailed(Object error) {
    return 'Gagal membuat: $error';
  }

  @override
  String get fileContent => 'Konten File';

  @override
  String get saveSuccess => 'Berhasil disimpan';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Zip akan diekstrak ke direktori saat ini: $dir';
  }

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get privacyPolicyDesc => 'Cara Memex menangani data Anda';

  @override
  String get llmAuthError =>
      'Autentikasi API gagal. Periksa konfigurasi LLM Anda di Pengaturan.';

  @override
  String get llmBadRequestError =>
      'Permintaan ditolak oleh penyedia LLM. Format input mungkin tidak didukung oleh model saat ini.';

  @override
  String get llmRateLimitError => 'Batas rate API terlampaui. Coba lagi nanti.';

  @override
  String get llmServerError =>
      'Layanan LLM sementara tidak tersedia. Coba lagi nanti.';

  @override
  String get llmNetworkError =>
      'Koneksi jaringan gagal. Periksa koneksi internet Anda.';

  @override
  String get llmUnknownError =>
      'Terjadi error tak terduga saat memproses konten Anda.';

  @override
  String get llmErrorDialogTitle => 'Pemrosesan Gagal';

  @override
  String get goToModelConfig => 'Buka Pengaturan';

  @override
  String get speechModelDownloadTitle => 'Unduh Model Suara';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Unduhan model satu kali (~${sizeMB}MB) diperlukan.\\n\\nSetelah diunduh, transkripsi berjalan sepenuhnya di perangkat.';
  }

  @override
  String get speechModelStartDownload => 'Mulai Unduhan';

  @override
  String get speechModelChooseSource => 'Pilih sumber unduhan:';

  @override
  String get speechModelChinaMirror => '🇨🇳 Mirror China (Lebih cepat di CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (Global)';

  @override
  String get speechModelDownloading => 'Mengunduh model...';

  @override
  String get speechModelConnecting => 'Menghubungkan...';

  @override
  String get deleteSpeechModel => 'Hapus model suara';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Hapus file model pengenalan suara lokal yang telah diunduh? File akan diunduh lagi saat speech-to-text lokal digunakan berikutnya.';

  @override
  String get speechModelDeletedSuccess => 'File model suara dihapus';

  @override
  String get speechModelNotDownloaded =>
      'Tidak ditemukan file model suara yang diunduh';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Gagal menghapus file model suara: $error';
  }

  @override
  String get speechTranscribing => 'Mengenali...';

  @override
  String get speechNoResult => 'Tidak ada suara terdeteksi';

  @override
  String get useLocalSpeechToTextTitle => 'Gunakan speech-to-text lokal';

  @override
  String get useLocalSpeechToTextDesc =>
      'Jika aktif, audio ditranskripsi di perangkat sebelum dikirim — berguna untuk model yang tidak mendukung input audio. Jika nonaktif, audio asli dikirim langsung ke model.';

  @override
  String get pendingAiProcessingHint => 'Siapkan model AI untuk memproses';

  @override
  String get demoWelcome =>
      'Selamat datang di Memex!\\nMari tur singkat melihat apa yang bisa AI lakukan untuk catatan Anda.';

  @override
  String get demoTapAdd => 'Ketuk di sini untuk membuat catatan pertama Anda';

  @override
  String get demoTapSend => 'Ketuk untuk mengirim catatan pertama Anda';

  @override
  String get demoTapCard =>
      'Ketuk untuk melihat bagaimana AI mengatur catatan Anda';

  @override
  String get demoDetailHint =>
      'Ini detail catatan yang diorganisasi AI. Jelajahi, lalu kembali untuk melanjutkan tur.';

  @override
  String get demoTapInsight => 'Ketuk untuk melihat insight yang dihasilkan AI';

  @override
  String get demoTapInsightUpdate =>
      'Ketuk untuk menghasilkan insight dari catatan Anda';

  @override
  String get demoTapKnowledge =>
      'Periksa file pengetahuan yang diatur otomatis';

  @override
  String get demoDone => 'Mulai mencatat hidup Anda.';

  @override
  String get demoStartTour => 'Mulai Tur';

  @override
  String get demoGetStarted => 'Mulai';

  @override
  String get demoSkip => 'Lewati';

  @override
  String get demoPrefillText => 'Halo Memex! Ini catatan pertama saya 🎉';

  @override
  String get visionBadge => 'Penglihatan';

  @override
  String get notMultimodalHint =>
      'Memex mengandalkan kemampuan model multimodal untuk analisis media. Jika catatan Anda berisi gambar, pastikan model yang Anda konfigurasi mendukung input gambar.';

  @override
  String get defaultModelPrefix => 'Bawaan';

  @override
  String get recommendedBadge => 'Direkomendasikan';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Ganti pendamping';

  @override
  String get personaChatInputHint => 'Ketik pesan...';

  @override
  String get today => 'Hari ini';

  @override
  String get tomorrow => 'Besok';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get showInsightTextTitle => 'Tampilkan komentar insight Memex';

  @override
  String get showInsightTextDesc =>
      'Apakah insight Memex ditampilkan sebagai komentar yang disematkan di bagian komentar detail kartu.';

  @override
  String get enableCharacterCommentTitle => 'Komentar otomatis karakter';

  @override
  String get enableCharacterCommentDesc =>
      'Karakter otomatis mengomentari catatan baru.';

  @override
  String get maxCommentCharactersTitle => 'Maks. karakter yang berkomentar';

  @override
  String get maxCommentCharactersDesc =>
      'Berapa banyak karakter yang dapat berkomentar pada setiap catatan.';

  @override
  String replyTo(String name) {
    return 'Balas ke $name';
  }

  @override
  String get cdnSignalsComments => 'Balasan baru diterima';

  @override
  String get cdnSignalsInsight => 'Insight baru dihasilkan';

  @override
  String get cdnSignalsBoth => 'Balasan dan insight baru';

  @override
  String get untitledCard => 'Kartu tanpa judul';

  @override
  String get locationContextTitle => 'Konteks Lokasi';

  @override
  String get locationContextDescription =>
      'Konteks kota dan lingkungan saat ini untuk chat agen';

  @override
  String get locationContextAttachTitle => 'Lampirkan lokasi saat ini ke chat';

  @override
  String get locationContextAttachDesc =>
      'Menggunakan GPS perangkat dan reverse geocoding untuk memberi konteks kota, distrik, dan lingkungan kepada agen.';

  @override
  String get reverseGeocodingProvider => 'Penyedia reverse geocoding';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap menggunakan koordinat GCJ-02. GPS perangkat dikonversi sebelum reverse geocoding.';

  @override
  String get contextGranularity => 'Tingkat detail konteks';

  @override
  String get granularityCity => 'Kota';

  @override
  String get granularityDistrict => 'Distrik';

  @override
  String get granularityNeighborhood => 'Lingkungan';

  @override
  String get granularityStreet => 'Jalan';

  @override
  String get granularityFullAddress => 'Kandidat alamat lengkap';

  @override
  String get locationFreshness => 'Kesegaran lokasi';

  @override
  String minutesShort(int minutes) {
    return '$minutes menit';
  }

  @override
  String get oneHour => '1 jam';

  @override
  String get testCurrentLocation => 'Uji lokasi saat ini';

  @override
  String locationTestFailed(String error) {
    return 'Gagal: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Geocode balik';

  @override
  String get locationDebugProvider => 'Penyedia';

  @override
  String get locationDebugAgentContext => 'Konteks agen';

  @override
  String get locationDebugSource => 'Sumber';

  @override
  String get locationDebugAddressSummary => 'Ringkasan alamat';

  @override
  String get locationDebugFullAddress => 'Alamat lengkap';

  @override
  String get locationDebugCoordinates => 'Koordinat';

  @override
  String get locationDebugAccuracy => 'Akurasi';

  @override
  String get locationDebugReason => 'Alasan';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'tidak tersedia';

  @override
  String get locationDebugInjected => 'disisipkan';

  @override
  String get locationDebugNotInjected => 'tidak disisipkan';

  @override
  String get locationStatusUpdatedAt => 'Diperbarui';

  @override
  String get locationStatusSuccessTitle => 'Lokasi saat ini siap';

  @override
  String get locationStatusSuccessBody =>
      'Memex dapat melampirkan ringkasan lokasi ini saat konteks lokasi relevan.';

  @override
  String get locationStatusApproximateTitle => 'Hanya lokasi perkiraan';

  @override
  String get locationStatusApproximateBody =>
      'Akurasi tampak setingkat kota atau area. Anda dapat tetap memakainya, atau mengaktifkan Lokasi Presisi di pengaturan sistem untuk konteks yang lebih dekat.';

  @override
  String get locationStatusServiceDisabledTitle => 'Lokasi sistem nonaktif';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex hanya memakai GPS perangkat dan tidak menyimpulkan lokasi dari jaringan atau IP. Di Android, buka pengaturan Lokasi; di iOS, aktifkan Settings > Privacy & Security > Location Services.';

  @override
  String get locationStatusPermissionDeniedTitle => 'Izin lokasi diperlukan';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Izinkan Memex memakai lokasi saat pengujian atau saat konteks lokasi diperlukan. Akses selalu tidak diminta.';

  @override
  String get locationStatusPermissionForeverTitle => 'Izin lokasi diblokir';

  @override
  String get locationStatusPermissionForeverBody =>
      'Buka pengaturan aplikasi dan izinkan lokasi untuk Memex. Di iOS, While Using the App sudah cukup.';

  @override
  String get locationStatusDisabledTitle => 'Konteks Lokasi nonaktif';

  @override
  String get locationStatusDisabledBody =>
      'Aktifkan sakelar di atas dan simpan saat Anda ingin Memex melampirkan lokasi perangkat ke konteks agen.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS berfungsi, pencarian alamat gagal';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex memiliki koordinat tetapi tidak akan menyisipkan konteks GPS saja ke agen. Periksa penyedia reverse geocoding dan coba lagi.';

  @override
  String get locationStatusUnavailableTitle => 'Lokasi tidak tersedia';

  @override
  String get locationStatusUnavailableBody =>
      'Periksa layanan lokasi sistem dan izin aplikasi, lalu uji lagi.';

  @override
  String get allowLocationPermissionButton => 'Izinkan akses lokasi';

  @override
  String get openAppSettingsButton => 'Buka pengaturan aplikasi';

  @override
  String get openLocationSettingsButton => 'Buka pengaturan lokasi';

  @override
  String get locationSettingsOpenFailed =>
      'Tidak dapat membuka pengaturan sistem.';

  @override
  String locationActionFailed(String error) {
    return 'Tindakan lokasi gagal: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Cari pengaturan...';

  @override
  String get settingsSearchEmpty => 'Tidak ada pengaturan yang cocok';

  @override
  String get importCharacterCard => 'Impor Kartu Karakter';

  @override
  String get firstMessageLabel => 'Pesan Pertama';

  @override
  String get firstMessageHint =>
      'Sapaan yang dikirim pada percakapan pertama (opsional)';

  @override
  String get systemPromptOverrideLabel => 'Override System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'Timpa system prompt default (lanjutan, opsional)';

  @override
  String get postHistoryInstructionsLabel => 'Instruksi Setelah Riwayat';

  @override
  String get postHistoryInstructionsHint =>
      'Instruksi yang disisipkan setelah riwayat chat, sebelum balasan (opsional)';

  @override
  String get mesExampleLabel => 'Contoh Pesan';

  @override
  String get mesExampleHint =>
      'Contoh dialog yang menunjukkan gaya karakter (opsional)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Pengetahuan latar yang disisipkan saat kata kunci terpicu';

  @override
  String get characterMemoryTitle => 'Memori Karakter';

  @override
  String get characterMemorySubtitle =>
      'Dinamika hubungan dan memori interaksi antara karakter dan pengguna';

  @override
  String get addTooltip => 'Tambah';

  @override
  String get constantBadge => 'Konstan';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Entri $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Kata kunci: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Memori $index';
  }

  @override
  String get addWorldEntry => 'Tambah Entri World Book';

  @override
  String get editWorldEntry => 'Edit Entri World Book';

  @override
  String get commentTitleLabel => 'Komentar / Judul';

  @override
  String get entryDescriptionHint => 'Deskripsi entri (opsional)';

  @override
  String get triggerKeywordsLabel => 'Kata Kunci Pemicu';

  @override
  String get triggerKeywordsHint => 'Dipisah koma, mis.: magic, spell';

  @override
  String get contentLabel => 'Konten';

  @override
  String get worldEntryContentHint =>
      'Pengetahuan latar yang disisipkan saat kata kunci terpicu';

  @override
  String get enabledCheckbox => 'Aktif';

  @override
  String get addMemory => 'Tambah Memori';

  @override
  String get editMemory => 'Edit Memori';

  @override
  String get memoryLabelField => 'Label memori';

  @override
  String get memoryLabelHint => 'Pengidentifikasi unik, mis.: preferensi nama';

  @override
  String get memoryContentHint => 'Konten memori';

  @override
  String get salienceLabel => 'Kepentingan: ';

  @override
  String get labelCannotBeEmpty => 'Label tidak boleh kosong';

  @override
  String importSuccess(Object name) {
    return '$name berhasil diimpor';
  }

  @override
  String importFailed(Object error) {
    return 'Impor gagal: $error';
  }

  @override
  String get supportedFormats => 'Format yang Didukung';

  @override
  String get tavernImportDescription =>
      '• Kartu karakter SillyTavern V2 (.json)\\n• Gambar PNG dengan kartu tertanam (.png)\\n\\nKolom seperti persona, world book, dll. akan otomatis dipetakan ke format karakter Memex.';

  @override
  String get pickCharacterFile => 'Pilih File Karakter';

  @override
  String get repickFile => 'Pilih File Lain';

  @override
  String get personaSettingSection => 'Persona karakter';

  @override
  String get systemPromptSection => 'Prompt Sistem';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count entri';
  }

  @override
  String fileLabel(Object filename) {
    return 'Berkas: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Karakter dengan nama yang sama sudah ada: $names. Impor akan membuat karakter baru tanpa menimpa yang sudah ada.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Jadikan Pendamping Utama';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Otomatis jadikan pendamping utama Anda setelah impor';

  @override
  String get confirmImport => 'Konfirmasi Impor';

  @override
  String get chatBackground => 'Latar Chat';

  @override
  String get chooseChatBackgroundImage => 'Pilih gambar latar';

  @override
  String get earlyUpdateSettingsTitle => 'Pembaruan akses awal';

  @override
  String get earlyUpdateSettingsDesc =>
      'Periksa pre-release GitHub untuk Early APK yang cocok, unduh, lalu serahkan ke installer Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Pembaruan awal hanya tersedia di build Android Early.';

  @override
  String get earlyUpdateAutoCheckTitle => 'Cek pembaruan otomatis';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Cek saat startup paling banyak sekali tiap 12 jam.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Unduh hanya di Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Lewati unduhan pembaruan saat memakai data seluler.';

  @override
  String get earlyUpdateAutoInstallTitle => 'Unduh dan instal otomatis';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Saat build baru ditemukan, unduh dan buka installer Android secara otomatis.';

  @override
  String get earlyUpdateCheckNow => 'Cek sekarang';

  @override
  String get earlyUpdateChecking => 'Memeriksa pre-release GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Dilewati karena unduhan hanya Wi-Fi diaktifkan.';

  @override
  String get earlyUpdateNoUpdate => 'Anda sudah memakai build Early terbaru.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Build Early $version+$build tersedia.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Unduh dan instal';

  @override
  String get earlyUpdateDownloadInProgress => 'Mengunduh pembaruan...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Mengunduh pembaruan: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Paket pembaruan diunduh. Siap diinstal.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'Instal paket yang diunduh';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Hapus paket yang diunduh';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Paket pembaruan yang diunduh dihapus.';

  @override
  String get earlyUpdateInstallStarted => 'Installer Android dibuka.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Izinkan Memex menginstal aplikasi tidak dikenal, lalu ketuk unduh dan instal lagi.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Terakhir dicek: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Cek pembaruan gagal: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Pembaruan Early tersedia';

  @override
  String get earlyUpdateReleaseNotes => 'Catatan rilis';

  @override
  String get dismissAllNotifications => 'Hapus semua';

  @override
  String get dismissByType => 'Hapus menurut tipe';

  @override
  String get dismissTypeSystemAction => 'Pengingat & acara';

  @override
  String get dismissTypeClarification => 'Klarifikasi';

  @override
  String get dismissTypeCardUpdate => 'Pembaruan kartu';

  @override
  String dismissedCount(Object count) {
    return '$count dihapus';
  }

  @override
  String get dataImportTitle => 'Impor file';

  @override
  String get dataImportSettingsDescription =>
      'Bawa file lama ke Memex, lalu putuskan apakah ingin mengaturnya.';

  @override
  String get dataImportDescription =>
      'Pilih catatan lama, rekaman ekspor, dokumen, atau arsip ZIP. Memex menyimpan salinan terlebih dahulu dan tidak mengubah file asli. Setelah impor, Anda bisa memilih apakah Memex perlu membantu mengaturnya.';

  @override
  String get dataImportSelectFiles => 'Pilih file untuk diimpor';

  @override
  String get dataImportImporting => 'Menyimpan file...';

  @override
  String get dataImportSuccess => 'File disimpan di Memex';

  @override
  String get dataImportOnlyStored =>
      'File disimpan. Tidak ada pengaturan yang dimulai.';

  @override
  String get dataImportQueued =>
      'Memex akan mengatur impor ini di latar belakang.';

  @override
  String get dataImportResultTitle => 'Impor selesai';

  @override
  String dataImportResultSummary(Object count) {
    return '$count file telah disimpan. Anda bisa mengaturnya sekarang atau membiarkannya sebagai bahan sumber asli.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count item memiliki nama yang sama dan diganti nama agar tidak menimpa apa pun.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count item arsip yang tidak biasa dilewati; sisanya diimpor seperti biasa.';
  }

  @override
  String get dataImportChooseProcessing => 'Atur file ini';

  @override
  String get dataImportProcessTitle => 'Atur impor ini?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Anda mengimpor $count file. Pilih apakah Memex perlu mengaturnya sekarang atau hanya menyimpan aslinya.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'Atur ke basis pengetahuan';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Cocok untuk dokumen, catatan, materi proyek, dan referensi. Memex akan mengambil informasi berguna dan mengelompokkannya untuk dipakai nanti.';

  @override
  String get dataImportProcessTimelineCards => 'Buat catatan timeline';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Cocok untuk jurnal, riwayat chat, riwayat aktivitas, dan ekspor lama. Memex akan mengubah konten berbasis waktu menjadi catatan bila masuk akal.';

  @override
  String get dataImportImpactNone =>
      'Memex hanya akan menyimpan file asli ini. Tidak ada pengaturan AI yang dimulai.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex akan membaca file ini dan mengatur informasi jangka panjang yang berguna ke basis pengetahuan. Catatan timeline tidak akan dibuat secara proaktif.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex akan membaca file ini dan membuat catatan timeline untuk peristiwa hidup atau riwayat bertanggal bila sesuai. Basis pengetahuan tidak akan diatur secara proaktif.';

  @override
  String get dataImportImpactBoth =>
      'Memex akan mencoba membuat catatan timeline dan mengatur informasi yang dapat digunakan kembali ke basis pengetahuan. Ini cocok untuk arsip pribadi yang lengkap.';

  @override
  String get dataImportFinish => 'Simpan saja';

  @override
  String get noImages => 'Tidak ada gambar';

  @override
  String get noMessages => 'Tidak ada pesan';

  @override
  String get sketchContent => 'Konten sketsa';

  @override
  String get emptyFolder => 'Folder kosong';

  @override
  String get usernameAlreadyTaken => 'Nama pengguna sudah dipakai';

  @override
  String get registrationFailed => 'Pendaftaran gagal';

  @override
  String get loginFailed => 'Login gagal';

  @override
  String get paymentCreationFailed => 'Tidak bisa memulai pembayaran';

  @override
  String get completePayment => 'Selesaikan pembayaran';

  @override
  String get commentReplyToYou => 'Anda';

  @override
  String get commentAuthorUser => 'Pengguna';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => 'Otorisasi dibatalkan';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Minggu $week';
  }

  @override
  String get timelineWeekLabel => 'Minggu';

  @override
  String get eventCardDefaultTitle => 'Acara';

  @override
  String get memoryNoLongTermYet => 'Belum ada memori jangka panjang.';

  @override
  String get memoryNoRecentBuffer => 'Tidak ada memori terbaru di buffer.';

  @override
  String get memoryGeneralSubject => 'Umum';
}
