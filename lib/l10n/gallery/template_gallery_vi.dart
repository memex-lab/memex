import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsVi = [
  TemplateGallerySection(
    title: 'Tổng quan',
    items: [
      TemplateGalleryItem(
        label: '1. Thẻ cổ điển (Văn bản ghi chú)',
        templateId: 'classic_card',
        title: 'Đọc ghi chú',
        data: {
          'content':
              'Hôm nay đã đọc xong chương 3 của cuốn sách “Tư duy nhanh và chậm” ở quán cà phê. Các ví dụ về hiệu ứng neo đậu rất ấn tượng và nhắc nhở tôi rằng mẩu thông tin đầu tiên của chúng ta có thể âm thầm làm sai lệch mọi quyết định sau này.',
          'tags': ['Đọc', 'Tâm lý'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'văn bản',
    items: [
      TemplateGalleryItem(
        label: '2. Thẻ Snippet (Đoạn văn bản)',
        templateId: 'snippet',
        title: 'Báo giá công nghệ',
        data: {
          'text':
              '**“Bất kỳ công nghệ đủ tiên tiến nào cũng không thể phân biệt được với ma thuật.”**\\n\\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Trích dẫn', 'Công nghệ', 'Tương lai'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Thẻ bài viết (Bài viết dài)',
        templateId: 'article',
        title: 'Trải nghiệm dòng chảy là gì',
        data: {
          'body':
              '## Dòng chảy là gì?\\n\\nDòng chảy là một trạng thái tâm lý do Mihaly Csikszentmihalyi đề xuất. Khi hoàn toàn đắm chìm trong một nhiệm vụ đầy thách thức nhưng có thể đạt được, bạn sẽ mất dấu thời gian và sự chú ý của bạn hoàn toàn tập trung — đây là dòng chảy.\\n\\n> Khi mọi người làm những gì họ thực sự thích, họ thường quên mất chính mình.\\n\\nNghiên cứu cho thấy những người ở trạng thái dòng chảy thường làm việc hiệu quả nhất và cũng cảm thấy hạnh phúc nhất.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Thẻ hội thoại (Conversation)',
        templateId: 'conversation',
        title: 'Cuộc trò chuyện với AI',
        data: {
          'messages': [
            {
              'sender': 'Trợ lý AI',
              'text':
                  'Hôm nay bạn làm việc khá hiệu quả! Bạn đã làm được gì?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Hoàn thành thiết kế kiến ​​trúc và xem xét mã. Cảm thấy tuyệt vời.',
              'isMe': true,
            },
            {
              'sender': 'Trợ lý AI',
              'text':
                  'Tuyệt vời! Tối nay nhớ nghỉ sớm nhé, ngày mai cậu có cuộc họp quan trọng đấy.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Thẻ Trích Dẫn (Quote)',
        templateId: 'quote',
        title: 'Trích dẫn trong ngày',
        data: {
          'content':
              'Đừng chờ đợi thời điểm hoàn hảo. Hãy hành động và để khoảnh khắc trở nên hoàn hảo thông qua hành động của bạn.',
          'author': 'Napoleon Hill',
          'source': 'Nghĩ giàu và làm giàu',
        },
      ),
      TemplateGalleryItem(
        label: '6. Thẻ Compact (Hàng Compact)',
        templateId: 'compact_card',
        title: '💧 Lượng nước uống',
        wrapped: true,
        data: {
          'details': ['500ml', 'Cúp 4', 'Today’s goal 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visual',
    items: [
      TemplateGalleryItem(
        label: '7. Thẻ chụp nhanh (Ảnh)',
        templateId: 'snapshot',
        title: 'Khoảnh khắc hoàng hôn',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': 'Bến Thượng Hải · Thượng Hải',
        },
      ),
      TemplateGalleryItem(
        label: '8. Thẻ Thư viện (Album)',
        templateId: 'gallery',
        title: 'Cắm trại cuối tuần',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Card màn hình (Video)',
        templateId: 'video',
        title: 'Nhật ký video',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Thẻ Canvas (Canvas)',
        templateId: 'canvas',
        title: 'bản phác thảo sơ đồ tư duy',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Có thể định lượng',
    items: [
      TemplateGalleryItem(
        label: '11. Thẻ Metric (Số liệu)',
        templateId: 'metric',
        title: 'Chỉ số sức khỏe',
        data: {
          'items': [
            {
              'title': 'Ngủ sâu',
              'value': 2.5,
              'unit': 'h',
              'label': 'Tối hôm qua',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'bước',
              'value': 8342,
              'unit': 'steps',
              'label': 'Hôm nay',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': 'Nhịp tim',
              'value': 72,
              'unit': 'bpm',
              'label': 'Nghỉ ngơi',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Thẻ xếp hạng (Rating)',
        templateId: 'rating',
        title: 'Xếp hạng phim',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Hình ảnh ngoạn mục và tính triết lý về thời gian cũng như tình yêu đọng lại rất lâu sau khi xem.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Thẻ Tâm Trạng (Mood)',
        templateId: 'mood',
        title: 'Tâm trạng hôm nay',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'Dự án mới đã khởi động và nhóm đang rất có động lực.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Thẻ Tiến Bộ (Progress)',
        templateId: 'progress',
        title: 'Tiến độ mục tiêu hàng năm',
        data: {
          'label': 'Kế hoạch đọc hàng năm',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Thời gian',
    items: [
      TemplateGalleryItem(
        label: '15. Thẻ sự kiện (Sự kiện)',
        templateId: 'event',
        title: 'Cuộc họp đánh giá sản phẩm AI',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Tòa nhà A, Khu công nghệ, Khu mới Phố Đông, Thượng Hải',
        },
      ),
      TemplateGalleryItem(
        label: '16. Thẻ thời lượng (Timer)',
        templateId: 'duration',
        title: 'Đồng hồ bấm giờ Pomodoro',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Thẻ nhiệm vụ (Task)',
        templateId: 'task',
        title: 'Hoàn thành phân tích yêu cầu sản phẩm',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Báo cáo phân tích cạnh tranh', 'completed': true},
            {'title': 'Tổng hợp phỏng vấn người dùng', 'completed': true},
            {'title': 'Bản thảo đầu tiên của tài liệu yêu cầu', 'completed': false},
            {'title': 'Cuộc họp đánh giá PRD', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Thẻ thường lệ (Theo dõi thói quen)',
        templateId: 'routine',
        title: 'Thiền hàng ngày',
        data: {
          'habit_name': 'Thiền 10 phút mỗi ngày',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Thẻ thủ tục (Các bước)',
        templateId: 'procedure',
        title: 'Công thức làm bánh quy bơ',
        data: {
          'steps': [
            'Chuẩn bị nguyên liệu: 200g bột bánh, 3 quả trứng, 100g bơ',
            'Làm nóng lò ở nhiệt độ 175°C',
            'Đánh bơ và đường cho đến khi hỗn hợp nhạt màu',
            'Thêm từng quả trứng vào và trộn đều',
            'Rây bột vào và trộn đều cho đến khi hòa quyện',
            'Nướng trong lò trong 25 phút',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Thực thể',
    items: [
      TemplateGalleryItem(
        label: '20. Thẻ Người (Người)',
        templateId: 'person',
        title: 'Liên hệ',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Giám đốc sản phẩm',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Thẻ địa điểm (Place)',
        templateId: 'place',
        title: 'Hiệu sách yêu thích',
        data: {
          'name': 'Hiệu sách Tsutaya · Chùa Tĩnh An',
          'address': '400 Taixing Rd, quận Tĩnh An, Thượng Hải',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Spec Sheet (Thông số kỹ thuật của sản phẩm)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Dòng 9',
        data: {
          'subtitle': 'Đồng hồ thông minh',
          'specs': {
            'Trưng bày': '1.9" AMOLED',
            'Ắc quy': 'Thời lượng pin 5 ngày',
            'Chống nước': 'IP68',
            'Cân nặng': '32g',
            'chip': 'Apple S9',
            'Kích cỡ': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Thẻ giao dịch (Chi tiêu)',
        templateId: 'transaction',
        title: 'Chi tiêu ăn trưa',
        data: {
          'merchant': 'Nhà mì Hutong',
          'amount': '¥ 68.00',
          'location': 'Phố Gulou, Bắc Kinh',
          'items': [
            {'name': 'Chữ ký Chiết Giang Mian (lớn)', 'amount': '¥ 38'},
            {'name': 'Trứng ướp', 'amount': '¥ 8'},
            {'name': 'Sữa chua Bắc Kinh ướp lạnh', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Thẻ Liên Kết (Link)',
        templateId: 'link',
        title: 'Flutter documentation',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsVi = [
  TemplateGalleryItem(
    label: '1. Thẻ Dòng thời gian (Dòng thời gian hôm nay)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Dòng thời gian hôm nay',
      'items': [
        {
          'time': '09:00',
          'title': 'Làm việc sâu',
          'content':
              'Hoàn thiện sơ đồ kiến ​​trúc v2.0 và sửa ba lỗi nghiêm trọng.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Ăn trưa và nghỉ giải lao',
          'content': 'Ăn salad nhẹ, sau đó đi bộ 20 phút.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'Để được lấp đầy...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Biểu đồ bong bóng (Bong bóng từ khóa)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Từ khóa trong tuần',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Thiết kế', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Phân tích dựa trên 42 ghi chú',
    },
  ),
  TemplateGalleryItem(
    label: '3. Đường xu hướng (Biểu đồ xu hướng)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Chỉ số tâm trạng (7 ngày qua)',
      'top_right_text': 'Trung bình: 7,2',
      'points': [
        {'label': 'thứ ba', 'value': 3.5},
        {'label': 'Thứ tư', 'value': 4.0},
        {'label': 'Thứ năm', 'value': 5.5},
        {'label': 'Thứ sáu', 'value': 8.5, 'is_highlight': true},
        {'label': 'Đã ngồi', 'value': 7.0},
        {'label': 'Mặt trời', 'value': 6.5},
        {'label': 'Thứ hai', 'value': 7.5},
      ],
      'highlight_info': {'title': '8,5 điểm', 'subtitle': 'điểm nổi bật thứ sáu'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Biểu đồ thanh (So sánh thanh)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Phân phối thời gian tập trung',
      'subtitle': 'Thông tin chuyên sâu về đại lý: Bạn đã dành nhiều công sức nhất cho Mã hóa.',
      'unit': 'h',
      'items': [
        {'label': 'Thiết kế', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Mã hóa',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Đọc', 'value': 1.5, 'icon': '📚'},
        {'label': 'Cuộc họp', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Vòng tiến bộ (Tiến trình mục tiêu)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Mục tiêu đọc hàng năm',
      'subtitle': '12 cuốn sách còn lại',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Hoàn thành', 'value': 65, 'color': '#6366F1'},
        {'label': 'Còn lại', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Biểu đồ Radar (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Mô hình năng lực',
      'badge': 'Trọng tâm hàng tháng',
      'center_value': '78',
      'center_label': 'Tổng điểm',
      'dimensions': [
        {'label': 'Thi hành', 'value': 80},
        {'label': 'suy nghĩ', 'value': 60},
        {'label': 'Sáng tạo', 'value': 70},
        {'label': 'Ảnh hưởng', 'value': 85},
        {'label': 'Học hỏi', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Highlight/Quote (Trích dẫn)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'Cách tốt nhất để dự đoán tương lai là tạo ra nó.',
      'quote_highlight': 'create it',
      'footer': '- Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Thành phần (Chia nhỏ)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Thành phần năng lượng ngày nay',
      'badge': 'Có hiệu quả',
      'headline_items': [
        {'label': 'Tổng thời gian', 'value': '8.5h'},
        {'label': 'Làm việc sâu', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Mã hóa', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Cuộc họp', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Đọc', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'Một ngày rất hiệu quả',
    },
  ),
  TemplateGalleryItem(
    label: '9. Tương phản/Reframing (Reframing)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Tái định hình một niềm tin',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Suy nghĩ ban đầu',
        'content': 'Tôi quá bận và không có thời gian để học những điều mới.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'Góc nhìn mới',
        'content':
            'Bận rộn đồng nghĩa với việc có nhiều cơ hội học hỏi thông qua thực hành. Tôi có thể học bằng cách làm.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Thư viện/Biên niên sử (Thư viện)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Đoạn trích truyền cảm hứng',
      'headline': '3 Photos',
      'content': 'Một số cảm hứng thiết kế được ghi lại ngày hôm nay.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Kết cấu'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Màu sắc'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Ánh sáng'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Thẻ bản đồ (Bản đồ)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Dấu chân',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'Câu chuyện về hai thành phố',
      'info_detail': 'Đi lại giữa Bắc Kinh và Thượng Hải trong tuần này',
    },
  ),
  TemplateGalleryItem(
    label: '12. Thẻ Tóm Tắt (Summary)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Tuần 4: Đột phá & kết nối',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'Trạng thái cấp S'},
      'insight_title': 'Thông tin chi tiết về đại lý',
      'insight_content':
          'Tuần này, bạn chủ yếu tập trung vào việc phát triển #AI ​​Agent và đạt kỷ lục mới về số lần cam kết mã. Tôi cũng nhận thấy bạn đã ghi lại một bữa tối gia đình vào tối thứ Sáu - mô hình “làm việc chăm chỉ, sống trọn vẹn” này rất lành mạnh.',
      'metrics': [
        {'label': 'Tập trung', 'value': '32h'},
        {'label': 'Tâm trạng', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Ghi chú', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Điểm nổi bật trong tuần (3 đã chọn)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Phóng'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Bữa tối gia đình'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
