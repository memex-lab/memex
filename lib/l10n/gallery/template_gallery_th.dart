import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsTh = [
  TemplateGallerySection(
    title: 'ทั่วไป',
    items: [
      TemplateGalleryItem(
        label: '1. การ์ดคลาสสิก (บันทึกข้อความ)',
        templateId: 'classic_card',
        title: 'อ่านบันทึก',
        data: {
          'content':
              'จบบทที่ 3 ของ "คิดเร็วและช้า" ที่คาเฟ่ได้แล้ววันนี้ ตัวอย่างเกี่ยวกับเอฟเฟกต์การยึดนั้นน่าประทับใจและเตือนฉันว่าข้อมูลชิ้นแรกของเราสามารถอคติอย่างเงียบ ๆ ในการตัดสินใจในภายหลังได้อย่างไร',
          'tags': ['การอ่าน', 'จิตวิทยา'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'ข้อความ',
    items: [
      TemplateGalleryItem(
        label: '2. การ์ดตัวอย่าง (ตัวอย่างข้อความ)',
        templateId: 'snippet',
        title: 'ใบเสนอราคาทางเทคนิค',
        data: {
          'text':
              '**“เทคโนโลยีขั้นสูงใดๆ ก็แยกไม่ออกจากเวทมนตร์”**\\n\\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['อ้าง', 'เทคโนโลยี', 'อนาคต'],
        },
      ),
      TemplateGalleryItem(
        label: '3. การ์ดบทความ (บทความยาว)',
        templateId: 'article',
        title: 'ประสบการณ์การไหลคืออะไร',
        data: {
          'body':
              '## การไหลคืออะไร\\n\\nการไหลเป็นสภาวะทางจิตวิทยาที่เสนอโดย Mihaly Csikszentmihalyi เมื่อคุณหมกมุ่นอยู่กับงานที่ท้าทายแต่ทำได้สำเร็จ คุณจะสูญเสียเวลาและความสนใจของคุณจะถูกจดจ่ออยู่กับที่ นั่นคือความลื่นไหล\\n\\n> เมื่อผู้คนทำสิ่งที่พวกเขาชอบอย่างแท้จริง พวกเขามักจะลืมตัวเอง\\n\\nการวิจัยแสดงให้เห็นว่าผู้คนในสภาวะที่ไหลลื่นมักจะมีประสิทธิภาพมากที่สุดและยังรู้สึกมีความสุขที่สุดอีกด้วย',
        },
      ),
      TemplateGalleryItem(
        label: '4. การ์ดสนทนา (บทสนทนา)',
        templateId: 'conversation',
        title: 'สนทนากับเอไอ',
        data: {
          'messages': [
            {
              'sender': 'ผู้ช่วยเอไอ',
              'text':
                  'วันนี้คุณมีประสิทธิผลมาก! คุณทำอะไรลงไป?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'เสร็จสิ้นการออกแบบสถาปัตยกรรมและการตรวจสอบโค้ด รู้สึกดีมาก',
              'isMe': true,
            },
            {
              'sender': 'ผู้ช่วยเอไอ',
              'text':
                  'สุดยอด! คืนนี้อย่าลืมพักผ่อนแต่เช้า พรุ่งนี้คุณมีประชุมสำคัญ',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. บัตรใบเสนอราคา (Quote)',
        templateId: 'quote',
        title: 'คำคมประจำวันนี้',
        data: {
          'content':
              'อย่ารอช่วงเวลาที่สมบูรณ์แบบ ลงมือปฏิบัติ และปล่อยให้ช่วงเวลาสมบูรณ์แบบผ่านการกระทำของคุณ',
          'author': 'Napoleon Hill',
          'source': 'คิดแล้วรวย',
        },
      ),
      TemplateGalleryItem(
        label: '6. การ์ดขนาดกะทัดรัด (แถวกะทัดรัด)',
        templateId: 'compact_card',
        title: 'ดื่มน้ำ',
        wrapped: true,
        data: {
          'details': ['500ml', 'คัพ 4', 'เป้าหมายวันนี้ 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'ภาพ',
    items: [
      TemplateGalleryItem(
        label: '7. การ์ดสแนปชอต (ภาพถ่าย)',
        templateId: 'snapshot',
        title: 'ช่วงค่ำ',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'เดอะบันด์ · เซี่ยงไฮ้',
        },
      ),
      TemplateGalleryItem(
        label: '8. การ์ดแกลเลอรี (อัลบั้ม)',
        templateId: 'gallery',
        title: 'ตั้งแคมป์วันหยุดสุดสัปดาห์',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. การ์ดแสดงผล (วิดีโอ)',
        templateId: 'video',
        title: 'บันทึกวีดีโอ',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. การ์ดแคนวาส (แคนวาส)',
        templateId: 'canvas',
        title: 'ร่างแผนที่ความคิด',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'วัดปริมาณได้',
    items: [
      TemplateGalleryItem(
        label: '11. การ์ดเมตริก (เมตริก)',
        templateId: 'metric',
        title: 'ตัวชี้วัดด้านสุขภาพ',
        data: {
          'items': [
            {
              'title': 'นอนหลับลึก',
              'value': 2.5,
              'unit': 'h',
              'label': 'Last night',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'ขั้นตอน',
              'value': 8342,
              'unit': 'steps',
              'label': 'Today',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Heart rate',
              'value': 72,
              'unit': 'bpm',
              'label': 'พักผ่อน',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. บัตรจัดอันดับ (เรตติ้ง)',
        templateId: 'rating',
        title: 'เรตติ้งภาพยนตร์',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Breathtaking visuals and a philosophical take on time and love that lingers long after watching.',
        },
      ),
      TemplateGalleryItem(
        label: '13. การ์ดอารมณ์ (อารมณ์)',
        templateId: 'mood',
        title: 'Today’s mood',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'โครงการใหม่เริ่มต้นขึ้นและทีมงานมีแรงจูงใจอย่างมาก',
        },
      ),
      TemplateGalleryItem(
        label: '14. การ์ดความก้าวหน้า (ความคืบหน้า)',
        templateId: 'progress',
        title: 'ความก้าวหน้าของเป้าหมายประจำปี',
        data: {
          'label': 'แผนการอ่านหนังสือประจำปี',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'ชั่วขณะ',
    items: [
      TemplateGalleryItem(
        label: '15. การ์ดกิจกรรม (กิจกรรม)',
        templateId: 'event',
        title: 'การประชุมทบทวนผลิตภัณฑ์ AI',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'อาคาร A, เทคพาร์ค, พื้นที่ใหม่ผู่ตง, เซี่ยงไฮ้',
        },
      ),
      TemplateGalleryItem(
        label: '16. การ์ดระยะเวลา (ตัวจับเวลา)',
        templateId: 'duration',
        title: 'เครื่องจับเวลาโพโมโดโร',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. การ์ดงาน (งาน)',
        templateId: 'task',
        title: 'วิเคราะห์ข้อกำหนดผลิตภัณฑ์ให้สมบูรณ์',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'รายงานการวิเคราะห์การแข่งขัน', 'completed': true},
            {'title': 'การสังเคราะห์การสัมภาษณ์ผู้ใช้', 'completed': true},
            {'title': 'ร่างเอกสารข้อกำหนดฉบับแรก', 'completed': false},
            {'title': 'ประชุมทบทวน กปปส', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. การ์ดประจำ (ตัวติดตามนิสัย)',
        templateId: 'routine',
        title: 'การทำสมาธิทุกวัน',
        data: {
          'habit_name': 'นั่งสมาธิวันละ 10 นาที',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. บัตรขั้นตอน (ขั้นตอน)',
        templateId: 'procedure',
        title: 'สูตรคุกกี้เนย',
        data: {
          'steps': [
            'เตรียมส่วนผสม: แป้งเค้ก 200 กรัม, ไข่ 3 ฟอง, เนย 100 กรัม',
            'เปิดเตาอบที่ 175°C',
            'ครีมเนยและน้ำตาลจนส่วนผสมกลายเป็นสีซีด',
            'เพิ่มไข่ทีละฟองและผสมให้เข้ากัน',
            'ร่อนแป้งแล้วตะล่อมจนเข้ากัน',
            'อบในเตาอบเป็นเวลา 25 นาที',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'เอนทิตี',
    items: [
      TemplateGalleryItem(
        label: '20. บัตรบุคคล (บุคคล)',
        templateId: 'person',
        title: 'ติดต่อ',
        data: {
          'name': 'Alex Zhang',
          'relation': 'ผู้จัดการผลิตภัณฑ์',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. บัตรสถานที่ (สถานที่)',
        templateId: 'place',
        title: 'ร้านหนังสือที่ชื่นชอบ',
        data: {
          'name': 'ร้านหนังสือสึทายะ · วัดจิ้งอัน',
          'address': '400 ถนน Taixing เขต Jing\'an เซี่ยงไฮ้',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. เอกสารข้อมูลจำเพาะ (รายละเอียดสินค้า)',
        templateId: 'spec_sheet',
        title: 'แอปเปิ้ลวอทช์ซีรีส์ 9',
        data: {
          'subtitle': 'สมาร์ทวอทช์',
          'specs': {
            'แสดง': '1.9" AMOLED',
            'แบตเตอรี่': 'อายุการใช้งานแบตเตอรี่ 5 วัน',
            'ต้านทานน้ำ': 'IP68',
            'น้ำหนัก': '32g',
            'Chip': 'Apple S9',
            'Size': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. บัตรธุรกรรม (การใช้จ่าย)',
        templateId: 'transaction',
        title: 'การใช้จ่ายอาหารกลางวัน',
        data: {
          'merchant': 'ร้านก๋วยเตี๋ยวหูต่ง',
          'amount': '¥ 68.00',
          'location': 'ถนนกู่โหลว ปักกิ่ง',
          'items': [
            {'name': 'เมนูซิกเนเจอร์ Zhajiangmian (ใหญ่)', 'amount': '¥ 38'},
            {'name': 'ไข่หมัก', 'amount': '¥ 8'},
            {'name': 'โยเกิร์ตปักกิ่งแช่เย็น', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. ลิงค์การ์ด (ลิงค์)',
        templateId: 'link',
        title: 'เอกสารกระพือ',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsTh = [
  TemplateGalleryItem(
    label: '1. การ์ดไทม์ไลน์ (ไทม์ไลน์ของวันนี้)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'ไทม์ไลน์ของวันนี้',
      'items': [
        {
          'time': '09:00',
          'title': 'งานลึก',
          'content':
              'เสร็จสิ้นแผนภาพสถาปัตยกรรม v2.0 และแก้ไขจุดบกพร่องร้ายแรงสามจุด',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'อาหารกลางวันและพักเบรค',
          'content': 'สลัดเบา ๆ ตามด้วยเดิน 20 นาที',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'ที่จะเต็มไปด้วย...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. แผนภูมิฟอง (ฟองคำสำคัญ)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'คำสำคัญประจำสัปดาห์',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'ออกแบบ', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'วิเคราะห์จาก 42 หมายเหตุ',
    },
  ),
  TemplateGalleryItem(
    label: '3. เส้นแนวโน้ม (แผนภูมิแนวโน้ม)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'ดัชนีอารมณ์ (7 วันที่ผ่านมา)',
      'top_right_text': 'เฉลี่ย: 7.2',
      'points': [
        {'label': 'อ', 'value': 3.5},
        {'label': 'พ', 'value': 4.0},
        {'label': 'พฤ', 'value': 5.5},
        {'label': 'ศุกร์', 'value': 8.5, 'is_highlight': true},
        {'label': 'นั่ง', 'value': 7.0},
        {'label': 'ดวงอาทิตย์', 'value': 6.5},
        {'label': 'จันทร์', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5 แต้ม', 'subtitle': 'ไฮไลท์วันศุกร์'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. แผนภูมิแท่ง (การเปรียบเทียบแท่ง)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'การกระจายเวลาโฟกัส',
      'subtitle': 'ข้อมูลเชิงลึกของตัวแทน: คุณใช้ความพยายามอย่างเต็มที่กับการเขียนโค้ด',
      'unit': 'h',
      'items': [
        {'label': 'ออกแบบ', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'การเข้ารหัส',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'การอ่าน', 'value': 1.5, 'icon': '📚'},
        {'label': 'การประชุม', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. แหวนความคืบหน้า (ความคืบหน้าของเป้าหมาย)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'เป้าหมายการอ่านประจำปี',
      'subtitle': 'เหลือ 12 เล่มครับ',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'สมบูรณ์', 'value': 65, 'color': '#6366F1'},
        {'label': 'ที่เหลืออยู่', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. แผนภูมิเรดาร์ (เรดาร์)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'แบบจำลองความสามารถ',
      'badge': 'เน้นรายเดือน',
      'center_value': '78',
      'center_label': 'คะแนนรวม',
      'dimensions': [
        {'label': 'การดำเนินการ', 'value': 80},
        {'label': 'กำลังคิด', 'value': 60},
        {'label': 'ความคิดสร้างสรรค์', 'value': 70},
        {'label': 'อิทธิพล', 'value': 85},
        {'label': 'การเรียนรู้', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. ไฮไลท์/คำคม (Quote)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'วิธีที่ดีที่สุดในการทำนายอนาคตคือการสร้างมันขึ้นมา',
      'quote_highlight': 'create it',
      'footer': '- ปีเตอร์ ดรักเกอร์',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. องค์ประกอบ (พังทลาย)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'องค์ประกอบพลังงานในปัจจุบัน',
      'badge': 'มีประสิทธิภาพ',
      'headline_items': [
        {'label': 'เวลาทั้งหมด', 'value': '8.5h'},
        {'label': 'งานลึก', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'การเข้ารหัส', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'การประชุม', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'การอ่าน', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'วันที่มีประสิทธิผลมาก',
    },
  ),
  TemplateGalleryItem(
    label: '9. คอนทราสต์/รีเฟรม (Reframing)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'การตีกรอบความเชื่อใหม่',
      'emotion': 'neutral',
      'context_section': {
        'title': 'ความคิดเดิม',
        'content': 'ฉันยุ่งมากและไม่มีเวลาเรียนรู้สิ่งใหม่ๆ',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'มุมมองใหม่',
        'content':
            'การมีความยุ่งหมายความว่ามีโอกาสมากมายที่จะเรียนรู้ผ่านการฝึกฝน ฉันสามารถเรียนรู้โดยการทำ',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. คลังภาพ/พงศาวดาร (คลังภาพ)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'ตัวอย่างแรงบันดาลใจ',
      'headline': '3 Photos',
      'content': 'แรงบันดาลใจในการออกแบบบางส่วนที่บันทึกไว้ในวันนี้',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'พื้นผิว'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'สี'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'แสงสว่าง'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. การ์ดแผนที่ (แผนที่)',
    templateId: 'map_card_v1',
    data: {
      'title': 'รอยเท้า',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'เรื่องราวของสองเมือง',
      'info_detail': 'การเดินทางระหว่างปักกิ่งและเซี่ยงไฮ้ในสัปดาห์นี้',
    },
  ),
  TemplateGalleryItem(
    label: '12. การ์ดสรุป (สรุป)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'สัปดาห์ที่ 4: ความก้าวหน้าและการเชื่อมต่อ',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'สถานะระดับ S'},
      'insight_title': 'ข้อมูลเชิงลึกของตัวแทน',
      'insight_content':
          'สัปดาห์นี้คุณมุ่งเน้นไปที่การพัฒนา #AI Agent เป็นหลัก และทำลายสถิติใหม่สำหรับการคอมมิตโค้ด ฉันยังสังเกตเห็นว่าคุณร่วมรับประทานอาหารเย็นกับครอบครัวในคืนวันศุกร์ รูปแบบ "ทำงานหนัก ใช้ชีวิตอย่างเต็มที่" นี้ดีต่อสุขภาพมาก',
      'metrics': [
        {'label': 'จุดสนใจ', 'value': '32h'},
        {'label': 'อารมณ์', 'value': '8.2', 'color': '#10B981'},
        {'label': 'หมายเหตุ', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'ไฮไลท์ประจำสัปดาห์ (เลือก 3 รายการ)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'ปล่อย'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'มื้อเย็นกับครอบครัว'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
