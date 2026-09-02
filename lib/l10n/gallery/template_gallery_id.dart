import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsId = [
  TemplateGallerySection(
    title: 'Umum',
    items: [
      TemplateGalleryItem(
        label: '1. Kartu Klasik (Catatan teks)',
        templateId: 'classic_card',
        title: 'Membaca catatan',
        data: {
          'content':
              'Menyelesaikan bab 3 "Berpikir, Cepat dan Lambat" di kafe hari ini. Contoh-contoh tentang efek penahan sangat mengesankan dan mengingatkan saya bagaimana informasi pertama kita dapat secara diam-diam membiaskan setiap keputusan selanjutnya.',
          'tags': ['Membaca', 'Psikologi'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Tekstual',
    items: [
      TemplateGalleryItem(
        label: '2. Kartu Cuplikan (Cuplikan teks)',
        templateId: 'snippet',
        title: 'Kutipan teknologi',
        data: {
          'text':
              '**“Teknologi apa pun yang cukup maju tidak dapat dibedakan dari sihir.”**\\n\\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Mengutip', 'Teknologi', 'Masa depan'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Kartu Artikel (Artikel panjang)',
        templateId: 'article',
        title: 'Apa itu pengalaman aliran',
        data: {
          'body':
              '## Apa itu aliran?\\n\\nAliran adalah keadaan psikologis yang dikemukakan oleh Mihaly Csikszentmihalyi. Saat Anda benar-benar tenggelam dalam tugas yang menantang namun dapat dicapai, Anda lupa waktu dan perhatian Anda benar-benar terfokus — inilah yang disebut arus.\\n\\n> Saat orang melakukan apa yang benar-benar mereka sukai, mereka sering kali melupakan diri mereka sendiri.\\n\\nPenelitian menunjukkan bahwa orang yang berada dalam kondisi mengalir biasanya adalah orang yang paling produktif dan juga merasa paling bahagia.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Kartu Percakapan (Conversation)',
        templateId: 'conversation',
        title: 'Percakapan dengan AI',
        data: {
          'messages': [
            {
              'sender': 'Asisten AI',
              'text':
                  'Anda cukup produktif hari ini! Apa yang telah kamu selesaikan?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Menyelesaikan desain arsitektur dan tinjauan kode. Terasa luar biasa.',
              'isMe': true,
            },
            {
              'sender': 'Asisten AI',
              'text':
                  'Luar biasa! Ingatlah untuk istirahat lebih awal malam ini, Anda ada pertemuan penting besok.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Kartu Kutipan (Kutipan)',
        templateId: 'quote',
        title: 'Kutipan hari ini',
        data: {
          'content':
              'Jangan menunggu momen yang tepat. Bertindak, dan biarkan momen menjadi sempurna melalui tindakan Anda.',
          'author': 'Napoleon Hill',
          'source': 'Berpikir dan Menjadi Kaya',
        },
      ),
      TemplateGalleryItem(
        label: '6. Kartu Kompak (Baris Kompak)',
        templateId: 'compact_card',
        title: '💧 Asupan air',
        wrapped: true,
        data: {
          'details': ['500ml', 'Piala 4', 'Target hari ini 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visual',
    items: [
      TemplateGalleryItem(
        label: '7. Kartu Snapshot (Foto)',
        templateId: 'snapshot',
        title: 'Momen senja',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Bund · Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '8. Kartu Galeri (Album)',
        templateId: 'gallery',
        title: 'Perkemahan akhir pekan',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Kartu Video (Video)',
        templateId: 'video',
        title: 'Catatan video',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Kartu Kanvas (Kanvas)',
        templateId: 'canvas',
        title: 'Draf peta pikiran',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Dapat diukur',
    items: [
      TemplateGalleryItem(
        label: '11. Kartu Metrik (Metrik)',
        templateId: 'metric',
        title: 'Metrik kesehatan',
        data: {
          'items': [
            {
              'title': 'Tidur nyenyak',
              'value': 2.5,
              'unit': 'h',
              'label': 'Tadi malam',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Tangga',
              'value': 8342,
              'unit': 'steps',
              'label': 'Hari ini',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Detak jantung',
              'value': 72,
              'unit': 'bpm',
              'label': 'Beristirahat',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Kartu Peringkat (Peringkat)',
        templateId: 'rating',
        title: 'Peringkat film',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Visual yang menakjubkan dan pandangan filosofis tentang waktu dan cinta yang bertahan lama setelah ditonton.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Kartu Suasana Hati (Suasana Hati)',
        templateId: 'mood',
        title: 'Suasana hati hari ini',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Proyek baru dimulai dan tim sangat termotivasi.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Kartu Kemajuan (Kemajuan)',
        templateId: 'progress',
        title: 'Kemajuan tujuan tahunan',
        data: {
          'label': 'Rencana bacaan tahunan',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Sementara',
    items: [
      TemplateGalleryItem(
        label: '15. Kartu Acara (Acara)',
        templateId: 'event',
        title: 'Pertemuan peninjauan produk AI',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Gedung A, Tech Park, Area Baru Pudong, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Kartu Durasi (Pengatur Waktu)',
        templateId: 'duration',
        title: 'Pengatur waktu Pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Kartu Tugas (Tugas)',
        templateId: 'task',
        title: 'Analisis kebutuhan produk lengkap',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Laporan analisis kompetitif', 'completed': true},
            {'title': 'Sintesis wawancara pengguna', 'completed': true},
            {'title': 'Draf persyaratan pertama dok', 'completed': false},
            {'title': 'Rapat peninjauan PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Kartu Rutin (Pelacak Kebiasaan)',
        templateId: 'routine',
        title: 'Meditasi harian',
        data: {
          'habit_name': 'Meditasi 10 menit setiap hari',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Kartu Prosedur (Langkah-Langkah)',
        templateId: 'procedure',
        title: 'Resep kue mentega',
        data: {
          'steps': [
            'Siapkan bahan : 200 gr tepung kue, 3 butir telur, 100 gr mentega',
            'Panaskan oven terlebih dahulu pada suhu 175°C',
            'Kocok mentega dan gula hingga adonan menjadi pucat',
            'Tambahkan telur satu per satu dan aduk rata',
            'Ayak tepung dan lipat hingga tercampur rata',
            'Panggang dalam oven selama 25 menit',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entitas',
    items: [
      TemplateGalleryItem(
        label: '20. Kartu Orang (Orang)',
        templateId: 'person',
        title: 'Kontak',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Manajer Produk',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Kartu Tempat (Tempat)',
        templateId: 'place',
        title: 'Toko buku favorit',
        data: {
          'name': 'Toko Buku Tsutaya · Kuil Jing\'an',
          'address': '400 Taixing Rd, Distrik Jing\'an, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Lembar Spesifikasi (Spesifikasi Produk)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Seri 9',
        data: {
          'subtitle': 'jam tangan pintar',
          'specs': {
            'Menampilkan': '1.9" AMOLED',
            'Baterai': 'Masa pakai baterai 5 hari',
            'Tahan air': 'IP68',
            'Berat': '32g',
            'Kepingan': 'Apple S9',
            'Ukuran': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Kartu Transaksi (Pengeluaran)',
        templateId: 'transaction',
        title: 'Pengeluaran makan siang',
        data: {
          'merchant': 'Rumah Mie Hutong',
          'amount': '¥ 68.00',
          'location': 'Jalan Gulou, Beijing',
          'items': [
            {'name': 'Tanda tangan Zhajiangmian (besar)', 'amount': '¥ 38'},
            {'name': 'Telur yang diasinkan', 'amount': '¥ 8'},
            {'name': 'Yoghurt Beijing dingin', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Kartu Tautan (Tautan)',
        templateId: 'link',
        title: 'Dokumentasi bergetar',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsId = [
  TemplateGalleryItem(
    label: '1. Kartu Timeline (Garis waktu hari ini)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Garis waktu hari ini',
      'items': [
        {
          'time': '09:00',
          'title': 'Pekerjaan yang mendalam',
          'content':
              'Diagram arsitektur selesai v2.0 dan memperbaiki tiga bug kritis.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Makan siang & istirahat',
          'content': 'Salad ringan, dilanjutkan dengan jalan kaki 20 menit.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Untuk diisi...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Bubble Chart (Gelembung kata kunci)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Kata kunci minggu ini',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Desain', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Analisis berdasarkan 42 catatan',
    },
  ),
  TemplateGalleryItem(
    label: '3. Garis Tren (Grafik tren)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Indeks suasana hati (7 hari terakhir)',
      'top_right_text': 'Rata-rata: 7.2',
      'points': [
        {'label': 'Selasa', 'value': 3.5},
        {'label': 'Menikahi', 'value': 4.0},
        {'label': 'Kam', 'value': 5.5},
        {'label': 'Jumat', 'value': 8.5, 'is_highlight': true},
        {'label': 'Duduk', 'value': 7.0},
        {'label': 'Matahari', 'value': 6.5},
        {'label': 'Senin', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 poin', 'subtitle': 'Sorotan hari Jumat'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Bar Chart (Perbandingan batang)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Distribusi waktu fokus',
      'subtitle': 'Wawasan agen: Anda menghabiskan sebagian besar upaya pada Coding.',
      'unit': 'h',
      'items': [
        {'label': 'Desain', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Pengkodean',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Membaca', 'value': 1.5, 'icon': '📚'},
        {'label': 'Rapat', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Cincin Kemajuan (Kemajuan tujuan)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Tujuan membaca tahunan',
      'subtitle': 'Tinggal 12 buku lagi',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Selesai', 'value': 65, 'color': '#6366F1'},
        {'label': 'Tersisa', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Bagan Radar (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Model kemampuan',
      'badge': 'Fokus bulanan',
      'center_value': '78',
      'center_label': 'Skor keseluruhan',
      'dimensions': [
        {'label': 'Eksekusi', 'value': 80},
        {'label': 'Pemikiran', 'value': 60},
        {'label': 'Kreativitas', 'value': 70},
        {'label': 'Pengaruh', 'value': 85},
        {'label': 'Sedang belajar', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Sorotan/Kutipan (Kutipan)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Cara terbaik untuk memprediksi masa depan adalah dengan menciptakannya.',
      'quote_highlight': 'create it',
      'footer': '-Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Komposisi (Rincian)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Komposisi energi saat ini',
      'badge': 'Efisien',
      'headline_items': [
        {'label': 'Total waktu', 'value': '8.5h'},
        {'label': 'Pekerjaan yang mendalam', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Pengkodean', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Rapat', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Membaca', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Hari yang sangat produktif',
    },
  ),
  TemplateGalleryItem(
    label: '9. Kontras/Pembingkaian Ulang (Pembingkaian Ulang)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Membingkai ulang suatu keyakinan',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Pemikiran orisinal',
        'content': 'Saya terlalu sibuk dan tidak punya waktu untuk mempelajari hal-hal baru.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Perspektif baru',
        'content':
            'Menjadi sibuk berarti banyak kesempatan untuk belajar melalui latihan. Saya bisa belajar sambil melakukan.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Galeri/Kronik (Galeri)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Cuplikan inspirasi',
      'headline': '3 Photos',
      'content': 'Beberapa inspirasi desain ditangkap hari ini.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Tekstur'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Warna'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Lampu'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Kartu Peta (Peta)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Jejak kaki',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Kisah dua kota',
      'info_detail': 'Perjalanan antara Beijing dan Shanghai minggu ini',
    },
  ),
  TemplateGalleryItem(
    label: '12. Kartu Ringkasan (Ringkasan)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Minggu 4: Terobosan & koneksi',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'keadaan tingkat S'},
      'insight_title': 'Wawasan agen',
      'insight_content':
          'Minggu ini Anda berfokus terutama pada pengembangan #Agen AI dan mencapai rekor baru dalam penerapan kode. Saya juga memperhatikan Anda mencatat makan malam keluarga pada Jumat malam - pola “bekerja keras, hidup sepenuhnya” ini sangat sehat.',
      'metrics': [
        {'label': 'Fokus', 'value': '32h'},
        {'label': 'Suasana hati', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Catatan', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Sorotan minggu ini (3 dipilih)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Meluncurkan'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Makan malam keluarga'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
