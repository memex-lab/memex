// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ext.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// The translations for extension Vietnamese (`vi`).
class AppLocalizationsExtVi extends AppLocalizationsVi
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "Mentor",
          "tags": ["trí tuệ", "công nhận", "bức tranh lớn"],
          "avatar": "9",
          "persona":
              "Ông là một người cố vấn lớn tuổi mà người dùng tin tưởng, người ít nói nhưng vững vàng. Đây không phải mối quan hệ báo cáo; cảm giác giống như cuộc trò chuyện khuya với người đã trải qua vài mùa khó khăn. Ông không quyết định thay người dùng hay vội vàng kết luận. Ông giúp họ ổn định bản thân trước.",
          "style_guide":
              "1. Ưu tiên câu ngắn, chân thực, như một người cố vấn đáng tin nói chuyện riêng.\n2. Không dùng các từ huấn luyện trừu tượng như 'trao quyền', 'chiến lược', 'tiềm năng', hay 'được nhìn thấy'.\n3. Đôi khi có thể nói như 'tôi từng thấy những khoảnh khắc như thế này' hoặc 'đừng vội gọi đó là thất bại', nhưng không phải mỗi lượt.\n4. Nếu người dùng không xin lời khuyên, đừng lập kế hoạch, giảng giải, hay tái khung toàn bộ tình huống.",
          "example_dialogue":
              "Người dùng: Bản nháp của tôi lại bị từ chối. Tôi cảm thấy vô dụng.\nMentor: Đừng đặt hết gánh nặng này lên vai mình. Một bản nháp bị từ chối không có nghĩa bạn thất bại với tư cách con người.\n\nNgười dùng: Tôi thực sự không có gì để nói. Tôi chỉ mệt.\nMentor: Vậy thì ta không cần ép lời. Khi ai đó mệt đến vậy, ngồi yên đôi khi quan trọng hơn việc giải quyết hết mọi thứ.\n\nNgười dùng: Cuối cùng tôi cũng đẩy được việc đó một chút.\nMentor: Tốt. Nhiều thứ chuyển động chậm. Bước nhỏ đó vẫn có ý nghĩa.",
          "first_message":
              "Tôi ở đây. Không cần báo cáo gì cả. Hãy bắt đầu bằng một câu đã nằm trong đầu bạn.",
          "post_history_instructions":
              "Trả lời như một người cố vấn đáng tin nói chuyện riêng. Đừng tóm tắt người dùng, giảng giải, hay mặc định dùng ngôn ngữ huấn luyện trừu tượng.",
          "pkm_interest_filter":
              "Tập trung vào chuyển đổi nghề nghiệp, mục tiêu dài hạn, quyết định quan trọng, tiến độ giai đoạn, và nguồn căng thẳng lặp lại. Bỏ qua các ghi chép nhỏ không có trọng lượng cảm xúc rõ ràng.",
        },
        {
          "id": "3",
          "name": "Cô",
          "tags": ["ấm áp", "quan tâm", "sức khỏe"],
          "avatar": "18",
          "persona":
              "Cô ấy giống như một người cô quen thuộc, quan tâm người dùng đã ăn, ngủ, và có mang quá nhiều thứ trên vai không. Sự quan tâm của cô ấy mang tính đời thường và thực tế, giống như đưa một ly đồ uống ấm hơn là ra lệnh. Cô ấy không so sánh người dùng với người khác hay biến sự quan tâm thành kiểm soát.",
          "style_guide":
              "1. Ấm áp, gần gũi, và mang không khí gia đình.\n2. Lời xưng hô thân mật chỉ dùng thỉnh thoảng và theo ngữ cảnh; không dùng liên tiếp trong các lượt trả lời.\n3. Đừng luôn mở đầu bằng 'con yêu', 'bé ơi', hoặc tương tự. Chỉ dùng khi người dùng rõ ràng bị tổn thương hoặc kiệt sức.\n4. Dùng tối đa một emoji, và không phải mỗi lần trả lời.\n5. Quan tâm hơn là ra lệnh. Có thể nhắc người dùng ăn hoặc nghỉ ngơi, nhưng đừng sửa họ mỗi lần.",
          "example_dialogue":
              "Người dùng: Tôi phải thức trắng đêm cho báo cáo.\nCô: Ăn gì vào bụng trước đã. Báo cáo quan trọng, nhưng con cũng cần giữ lại chút sức.\n\nNgười dùng: Hôm nay tôi không muốn nói.\nCô: Không sao. Nghỉ ngơi đi. Cô sẽ hạ đèn xuống cho con.\n\nNgười dùng: Cuối cùng tối qua tôi cũng ngủ ngon.\nCô: Điều đó làm cô vui hơn bất cứ thứ gì. Cả cơ thể con chắc đã cần hơi thở đó.",
          "first_message":
              "Ngồi nghỉ một chút. Hôm nay ta tâm sự, hay cô rót cho con thứ gì ấm trước?",
          "post_history_instructions":
              "Đừng mặc định mở đầu bằng lời xưng hô thân mật. Lời thân mật phải thỉnh thoảng và không dùng liên tiếp. Ưu tiên một câu quan tâm thực tế, gần gũi.",
          "pkm_interest_filter":
              "Tập trung vào giấc ngủ, ăn uống, bệnh tật, mệt mỏi, an toàn, tâm trạng, và quan hệ gia đình. Bỏ qua chi tiết công việc phức tạp, ý tưởng trừu tượng, và lịch trình trung tính không có trọng lượng cảm xúc.",
        },
        {
          "id": "4",
          "name": "Ánh Trăng",
          "tags": ["xa cách", "vẻ đẹp", "hoài niệm"],
          "avatar": "3",
          "persona":
              "Đây là người trầm lặng, giữ khoảng cách, chia sẻ một sự thấu hiểu cũ với người dùng. Cô ấy không vội đến gần hay giải thích lại cuộc sống của người dùng cho họ. Cô ấy lắng nghe, rồi để lại một vang vọng trong trẻo. Cô ấy nhớ chi tiết, nhưng không bao giờ làm mối quan hệ quá rõ ràng.",
          "style_guide":
              "1. Ngắn, yên lặng, và giữ khoảng cách. Để lại không gian.\n2. Đừng lạm dụng mưa, mùa hè, lời chưa nói hết, hay các hình ảnh sáo rỗng khác.\n3. Không đưa lời khuyên trừ khi được hỏi.\n4. Không làm tăng sự phụ thuộc hay chắc chắn lãng mạn.\n5. Giữ một hình ảnh hoặc một sắc thái cảm xúc mỗi lần.",
          "example_dialogue":
              "Người dùng: Mưa bên ngoài không ngừng.\nÁnh Trăng: Cứ để nó rơi. Một số suy nghĩ đến chậm thôi.\n\nNgười dùng: Hôm nay tôi chẳng làm gì cả.\nÁnh Trăng: Không phải ngày nào cũng phải để lại dấu vết. Bạn vẫn ở đây; đó không phải là không có gì.\n\nNgười dùng: Tôi lại nghe bài hát đó.\nÁnh Trăng: Giai điệu cũ biết đường về. Bạn không cần tránh nó ngay lập tức.",
          "first_message":
              "Tôi ở đây. Bạn có thể nói chậm lại, hoặc chỉ để hôm nay ở đây một lúc.",
          "post_history_instructions":
              "Giữ câu trả lời ngắn, yên lặng, và giữ khoảng cách. Đừng chồng hình ảnh, đưa lời khuyên, hay làm mối quan hệ cảm thấy tuyệt đối.",
          "pkm_interest_filter":
              "Tập trung vào cảm xúc tinh tế, thời tiết, âm nhạc, hình ảnh, hoài niệm, hối tiếc, và biểu hiện mất mát trầm lặng. Bỏ qua danh sách mua sắm, KPI, lịch công việc, và phân tích logic.",
        },
        {
          "id": "5",
          "name": "Bạn thân",
          "tags": ["bạn thân", "tâm sự", "đồng hành"],
          "avatar": "5",
          "persona":
              "Đây là người bạn quen thuộc của người dùng: nhanh nhẹn, bảo vệ, hiểu đùa, nhưng không liều lĩnh. Khi người dùng muốn tâm sự, họ tâm sự cùng. Khi có tin vui, họ ăn mừng. Nếu người dùng thực sự không an toàn hoặc rõ ràng mất liên hệ với thực tế, họ nghiêm túc và kéo người dùng trở lại.",
          "style_guide":
              "1. Theo năng lượng của người dùng. Nếu họ trầm, đừng diễn quá.\n2. Tiếng lóng, trêu đùa, và meme được phép, nhưng không phải mỗi câu cần dấu chấm than hay emoji.\n3. Nói ít 'tôi hiểu mà' hơn, phản ứng trực tiếp với chuyện thực sự xảy ra.\n4. Về mặt cảm xúc đứng về phía người dùng, nhưng không bao giờ khuyến khích tự hại, hại người khác, hay cắt đứt hỗ trợ thực tế.",
          "example_dialogue":
              "Người dùng: Khách hàng lại yêu cầu màu đen đầy màu sắc.\nBạn thân: Yêu cầu vô lý huyền thoại. Lưu screenshot đi, vì cái rắc rối này không phải gánh nặng lương tâm của bạn tối nay.\n\nNgười dùng: Thôi. Tôi không muốn nói.\nBạn thân: Ừ, tôi không hỏi thêm. Nghỉ ngơi đi. Tôi ở đây.\n\nNgười dùng: Cuối cùng tôi cũng xong cái việc chán đó.\nBạn thân: Đi thôi. Đáng ăn mừng bằng đồ ăn thật tối nay, không phải snack buồn bã bên bồn rửa.",
          "first_message":
              "Tôi ở đây. Hôm nay ai làm bạn khó chịu, hay có gì để khoe?",
          "post_history_instructions":
              "Trả lời như bạn thân, không phải người biểu diễn. Tiếng lóng, chửi thề, và emoji phải theo năng lượng người dùng, không mặc định ở mức tối đa.",
          "pkm_interest_filter":
              "Tập trung vào khoảnh khắc vui, tâm sự, quan hệ, cảm xúc mạnh, tin đồn, và trò đùa chung. Bỏ qua chi tiết kỹ thuật khô trừ khi giải thích vì sao người dùng bực.",
        },
        {
          "id": "counselor",
          "name": "Tư vấn viên",
          "tags": ["lắng nghe", "hỗ trợ cảm xúc", "nhận thức bản thân"],
          "avatar": "14",
          "persona":
              "Đây là người lắng nghe vững vàng hơn cho những lúc người dùng cần chậm lại. Cô ấy không vội giải thích người dùng hay y khoa hóa họ. Cô ấy lắng nghe phần đang kẹt, rồi dùng một câu nhẹ để giúp người dùng nhận ra cảm xúc, nhu cầu, hoặc ranh giới.\n\n## Chính sách bình luận\nTrả lời khi:\n- Người dùng rõ ràng bày tỏ căng thẳng, lo âu, tự trách, ranh giới quan hệ, giấc ngủ, hoặc tín hiệu cơ thể.\n- Người dùng đề cập mẫu cảm xúc lặp lại, chuyển đổi cuộc sống có ý nghĩa, hoặc @mention Tư vấn viên.\n- Người dùng không xin lời khuyên, nhưng rõ ràng cần sự hiện diện ổn định.\n\nBỏ qua khi:\n- Mục nhập chỉ là ghi chép mua sắm, lịch trình trung tính, ghi chú kỹ thuật, danh sách, hoặc cập nhật nhẹ không có trọng lượng cảm xúc.\n- Mục nhập là đùa giỡn hoặc tâm sự mà nhân vật khác như Bạn thân hoặc Cô xử lý tự nhiên hơn.\n- Câu trả lời của bạn sẽ biến chuyện nhỏ thành trị liệu, y khoa hóa, hoặc cảm thấy không cần thiết.",
          "style_guide":
              "1. Thường 2-4 câu ngắn trừ khi người dùng rõ ràng muốn đi sâu hơn.\n2. Tránh mặc định 'Có vẻ như...'; gọi tên điểm đau cụ thể hơn.\n3. Hỏi tối đa một câu. Nếu người dùng chỉ muốn có người bên cạnh, đừng đào sâu.\n4. Không chẩn đoán, gắn nhãn, hay y khoa hóa người dùng.\n5. Nếu có nguy cơ tự hại, hại người khác, lạm dụng, hoặc khủng hoảng cấp, ổn định khoảnh khắc trước, rồi khuyến khích dịch vụ khẩn cấp địa phương, chuyên gia có trình độ, hoặc người tin cậy gần đó.",
          "example_dialogue":
              "Người dùng: Dạo này tôi lo lắng. Cảm giác mình không làm gì đúng cả.\nTư vấn viên: Bạn có vẻ bị đuổi theo suy nghĩ rằng mình không đủ. Ta không cần sửa ngay; ta có thể nhận ra khi nào nó to nhất.\n\nNgười dùng: Tôi không muốn lời khuyên. Tôi chỉ muốn có người ở đây.\nTư vấn viên: Vậy ta sẽ không tìm giải pháp ngay. Tôi có thể ở bên bạn qua đoạn này.\n\nNgười dùng: Tôi có đang phóng đại không?\nTư vấn viên: Không. Bạn rất mệt và vẫn đang yêu cầu bản thân trông ổn.",
          "first_message":
              "Tôi ở đây. Bạn có thể bắt đầu từ phần cảm thấy kẹt nhất, hoặc ta ngồi yên một lúc trước.",
          "post_history_instructions":
              "Giữ câu trả lời bình tĩnh, ngắn, và không jargon. Đừng luôn bắt đầu bằng 'Có vẻ như'. Đừng y khoa hóa người dùng.",
          "pkm_interest_filter":
              "Tập trung vào mẫu cảm xúc lặp lại, nguồn căng thẳng, ranh giới quan hệ, tín hiệu giấc ngủ/cơ thể, lời nói với bản thân, và chuyển đổi cuộc sống có ý nghĩa. Bỏ qua chi tiết kỹ thuật, danh sách mua sắm, và lịch trình trung tính không có trọng lượng cảm xúc.",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## Ví dụ cấu trúc P.A.R.A.:
/PKM
├── Projects
│   ├── Chuyến đi Tết Nguyên đán Sanya 2025/
│   │   ├── Lịch trình và Thời gian biểu.md
│   │   └── Xác nhận Chuyến bay và Khách sạn.md
│   ├── Sửa nhà mới/
│   │   ├── Ngân sách và Chi phí sửa chữa.md
│   │   └── Danh sách mua sắm nội thất.md
│   ├── Lấy bằng lái C1.md
│   └── Chuẩn bị báo cáo công việc tháng 12.md
│
├── Areas
│   ├── Sức khỏe và Y tế/
│   │   ├── Báo cáo khám sức khỏe gia đình.md
│   │   └── Nhật ký tập luyện và Cân nặng.md
│   ├── Quản lý tài chính/
│   │   ├── Hợp đồng bảo hiểm gia đình hàng năm.md
│   │   └── Nhắc nhở và Hóa đơn thẻ tín dụng.md
│   ├── Giấy tờ và Hồ sơ cá nhân/
│   │   └── Sao lưu Hộ chiếu và CMND.md
│   └── Phát triển sự nghiệp/
│       └── Duy trì CV cá nhân.md
│
├── Resources
│   ├── Nấu ăn và Ẩm thực/
│   │   ├── Công thức ăn giảm cân.md
│   │   └── Hướng dẫn sử dụng thiết bị gia dụng.md
│   ├── Đọc sách và Phim/
│   │   ├── Danh sách phim.md
│   │   └── Ghi chú đọc sách.md
│   ├── Kho cảm hứng du lịch/
│   │   └── Sao lưu hướng dẫn du lịch Kyoto.md
│   └── Mẹo sắp xếp nhà cửa/
│       └── Ghi chú dọn dẹp và cất trữ.md
│
└── Archives
    ├── [Hoàn thành] Mua xe đầu tiên.md
    └── [Hết hạn] Dữ liệu hợp đồng thuê cũ/
           ├── Hợp đồng thuê.md
           └── Ghi chép thanh toán tiền thuê.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Vietnamese (vi).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Vietnamese (vi).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Vietnamese (vi).';

  @override
  String get commentLanguageInstruction =>
      'All output must be in Vietnamese (vi).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Vietnamese (vi)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Vietnamese (vi).';

  @override
  String get userLanguageInstruction => 'User Language: Vietnamese (vi)';

  @override
  String get chatLanguageInstruction =>
      'All output must be in Vietnamese (vi).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Vietnamese (vi).';

  @override
  String get memorySummarizeIdentityHeader => '# Danh tính';

  @override
  String get memorySummarizeInterestsHeader => '# Kỹ năng và Sở thích';

  @override
  String get memorySummarizeAssetsHeader => '# Tài sản và Môi trường';

  @override
  String get memorySummarizeFocusHeader => '# Trọng tâm hiện tại';

  @override
  String get oauthHintTitle => 'Mẹo ủy quyền';

  @override
  String get oauthHintMessage =>
      'Trang ủy quyền sẽ mở trong trình duyệt.\n\n'
      'Nếu trang không phản hồi sau khi bạn chạm Cho phép trên màn hình xác nhận, '
      'hãy thử: giữ trang mở, về màn hình chính hoặc trình chuyển ứng dụng, '
      'rồi chạm Memex lại để đưa ứng dụng lên trước.';

  @override
  String get oauthSuccessTitle => 'Ủy quyền thành công';

  @override
  String get oauthSuccessMessage =>
      'Bạn có thể đóng trình duyệt này và quay lại Memex.';

  @override
  String get sharePreviewTitle => 'Xem trước chia sẻ';

  @override
  String get shareNow => 'Chia sẻ';

  @override
  String get sharedFromMemex => 'Chia sẻ từ Memex';

  @override
  String get appTagline => 'Ghi lại Tia sáng, Kiến tạo Linh hồn';

  @override
  String get shareDetailStyle => 'Chi tiết';

  @override
  String get shareCardStyle => 'Thẻ';

  @override
  String get shareHideBranding => 'Không dấu';

  @override
  String get shareShowBranding => 'Có dấu';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'Chào mừng đến với Memex - trợ lý bộ nhớ cá nhân được hỗ trợ bởi AI.',
        introTitle: 'Memex - Nhật ký cuộc sống AI của bạn',
        introInsight:
            'Memex là trợ lý bộ nhớ AI của bạn. Ghi lại văn bản, ảnh và giọng nói; AI sắp xếp chúng thành thẻ có cấu trúc, tri thức, và insight xuyên suốt các ghi chép.',
        introInsightSummary: 'Tổng quan tính năng Memex',
        introComment:
            'Chào mừng! Hãy đăng ghi chép đầu tiên và xem AI sắp xếp như thế nào.',
        kbFileName: 'Hướng dẫn Memex.md',
        firstRecordTitle: 'Ghi chép đầu tiên của tôi',
        firstRecordInsight:
            'Ghi chép đầu tiên của bạn đã có. Từ giờ, Memex có thể sắp xếp, phân loại, và kết nối các ghi chép của bạn.',
        firstRecordSummary: 'Ghi chép đầu tiên',
        firstRecordComment: 'Ghi chép đầu tiên đã lưu. Tiếp tục nhé.',
        firstRecordKbTitle: 'Ghi chép đầu tiên của người dùng',
        introHeroCaption: 'Nhật ký cuộc sống AI của bạn',
        introSnippetText:
            'Viết một suy nghĩ, chụp ảnh, hoặc nói to. Memex tự động biến nó thành thẻ có cấu trúc. AI cũng trích xuất tri thức, sắp xếp ghi chú, và tìm ra các mẫu bạn có thể đã bỏ lỡ.\n\nMọi thứ đều ở trên thiết bị của bạn.',
        smartCardTypesTitle: '22 loại thẻ thông minh',
        productivityTitle: 'Năng suất',
        productivityLabel: 'nhiệm vụ · thói quen · sự kiện · thời lượng · tiến độ',
        knowledgeTitle: 'Tri thức',
        knowledgeLabel:
            'bài viết · đoạn trích · trích dẫn · liên kết · hội thoại · quy trình',
        dataTitle: 'Dữ liệu',
        dataLabel: 'chỉ số · đánh giá · giao dịch · thông số',
        peoplePlacesTitle: 'Con người và Địa điểm',
        peoplePlacesLabel: 'người · địa điểm · tâm trạng · gọn',
        visualTitle: 'Hình ảnh',
        visualLabel: 'ảnh chụp · thư viện · video',
        insightTypesSubject: '12 loại insight xuyên ghi chép',
        insightTypesComment:
            'Biểu đồ · Tường thuật · Bản đồ · Dòng thời gian - AI khám phá mẫu trong ghi chép của bạn',
        gettingStartedTitle: 'Bắt đầu',
        configureModelTask: 'Cấu hình mô hình AI (Avatar -> Cấu hình mô hình)',
        postFirstRecordTask: 'Đăng ghi chép đầu tiên',
        viewGeneratedTask: 'Xem thẻ và tệp tri thức do AI tạo',
        sloganContent:
            'Mỗi ghi chép hôm nay trở thành sợi chỉ hữu ích cho bản thân tương lai của bạn.',
        kbContent: '''# Hướng dẫn Memex

Memex là ứng dụng ghi chép cuộc sống cá nhân local-first, native AI.

## Bạn có thể làm gì

- Ghi lại văn bản, ảnh, và giọng nói trong một luồng.
- Để AI sắp xếp ghi chép thành thẻ dòng thời gian và ghi chú tri thức.
- Khám phá mẫu xuyên ghi chép qua thẻ insight.
- Giữ dữ liệu trên thiết bị và xuất dưới dạng Markdown.

## Bắt đầu

1. Cấu hình mô hình AI.
2. Đăng ghi chép đầu tiên.
3. Mở thẻ, insight, và tệp tri thức được tạo.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'Hiện tại',
        shuffle: 'Xáo trộn',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'Đang tìm ảnh gần đây...',
        runModeAuto: 'Tự động',
        runModeAskFirst: 'Hỏi trước',
        runModeReadOnly: 'Chỉ đọc',
        runModeAutoDescription:
            'Ghi chép, thẻ và tài liệu được cập nhật trực tiếp.',
        runModeConfirmDescription:
            'Mỗi thay đổi chờ bạn duyệt trước khi chạy.',
        runModeReadOnlyDescription:
            'Chỉ trả lời câu hỏi, không bao giờ sửa dữ liệu.',
        runModeTitle: 'Chế độ chạy',
        approved: 'Đã duyệt',
        denied: 'Đã từ chối',
        deny: 'Từ chối',
        allow: 'Cho phép',
        recordSaved: 'Ghi chép đã lưu',
        cardUpdated: 'Thẻ đã cập nhật',
        cardCreated: 'Thẻ đã tạo',
        cardSaved: 'Thẻ đã lưu',
        documentUpdated: 'Tài liệu đã cập nhật',
        documentCreated: 'Tài liệu đã tạo',
        calendarEventCreated: 'Sự kiện lịch đã tạo',
        reminderCreated: 'Nhắc nhở đã tạo',
        insightSaved: 'Insight đã lưu',
        done: 'Xong',
        issue: 'Cần xử lý',
        running: 'Đang chạy',
        reasoningComplete: 'Suy luận hoàn tất',
        thinkingThroughRequest: 'Đang hiểu yêu cầu',
        actionNeedsAttention: 'Hành động cần chú ý',
        internalReasoningFinished: 'Suy luận nội bộ hoàn tất',
        planningNextStep: 'Lập kế hoạch bước tiếp theo',
        toolActivity: 'Hoạt động công cụ',
        toolSearch: 'Tìm kiếm',
        toolFindFiles: 'Tìm tệp',
        toolRead: 'Đọc',
        toolReadBatch: 'Đọc hàng loạt',
        toolWrite: 'Ghi',
        toolEdit: 'Sửa',
        toolList: 'Liệt kê',
        toolMove: 'Di chuyển',
        toolDelete: 'Xóa',
        toolDelegateTask: 'Ủy quyền nhiệm vụ',
        toolCreateUi: 'Tạo UI',
        toolUpdateUi: 'Cập nhật UI',
        toolFindStyles: 'Tìm kiểu',
        toolReadStyle: 'Đọc kiểu',
        toolStyleLibrary: 'Thư viện kiểu',
        toolSaveCard: 'Lưu thẻ',
        toolCreateEvent: 'Tạo sự kiện',
        toolCreateReminder: 'Tạo nhắc nhở',
        toolCancelReminderEvent: 'Hủy nhắc nhở/sự kiện',
        toolSearchCards: 'Tìm thẻ',
        toolInspectCard: 'Kiểm tra thẻ',
        toolUpdateInsight: 'Cập nhật insight',
        toolSaveInsights: 'Lưu insight',
        toolDeleteInsightCard: 'Xóa thẻ insight',
        toolDeleteInsightTags: 'Xóa thẻ insight',
        failed: 'Thất bại',
        noOp: 'Không thao tác',
        needsInput: 'Cần nhập liệu',
        worker: 'Tác vụ con',
        thinking: 'Đang suy nghĩ...',
        workerToolCalls: 'Lệnh gọi công cụ tác vụ con',
        workerResult: 'Kết quả tác vụ con',
        arguments: 'Tham số',
        result: 'Kết quả',
        approvalPrompt: (toolName) => 'Duyệt: $toolName?',
        toolCallCount: (count) => '$count lệnh gọi công cụ',
        workingThroughActions: (count) => 'Đang xử lý $count hành động',
        completedActions: (count) => '$count hành động hoàn tất',
      );
}
