import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsJa = [
  TemplateGallerySection(
    title: '一般的な',
    items: [
      TemplateGalleryItem(
        label: '1. クラシックカード（テキストメモ）',
        templateId: 'classic_card',
        title: '読書メモ',
        data: {
          'content':
              '今日カフェで『思考、速く、遅く』の第3章を読み終えた。アンカリング効果に関する例は印象的で、最初の情報がその後のあらゆる決定に密かにバイアスを与える可能性があることを思い出させてくれました。',
          'tags': ['読む', '心理学'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'テキスト',
    items: [
      TemplateGalleryItem(
        label: '2. スニペット カード (テキスト スニペット)',
        templateId: 'snippet',
        title: '技術的な見積もり',
        data: {
          'text':
              '**「十分に高度なテクノロジーは魔法と区別がつきません。」**\n\n— アーサー C. クラーク',
          'style': 'default',
          'tags': ['引用', 'テクノロジー', '未来'],
        },
      ),
      TemplateGalleryItem(
        label: '3. 記事カード（長文）',
        templateId: 'article',
        title: 'フロー体験とは',
        data: {
          'body':
              '## フローとは何ですか?\n\nフローとは、ミハイ チクセントミハイによって提案された心理状態です。やりがいはあるが達成可能なタスクに完全に没頭していると、時間を忘れて注意が完全に集中します。これがフローです。\n\n> 人は本当に楽しいことをしているとき、自分自身を忘れることがよくあります。\n\n研究によると、フロー状態にある人は通常、最も生産的であり、最も幸福を感じていることがわかっています。',
        },
      ),
      TemplateGalleryItem(
        label: '4. 会話カード（会話）',
        templateId: 'conversation',
        title: 'AIとの会話',
        data: {
          'messages': [
            {
              'sender': 'AIアシスタント',
              'text':
                  '今日はとても生産的でした！何をしてもらいましたか？',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'アーキテクチャ設計とコードレビューが完了しました。とても気持ちいいです。',
              'isMe': true,
            },
            {
              'sender': 'AIアシスタント',
              'text':
                  '素晴らしい！明日は重要な会議があるので、今夜は早めに休むことを忘れないでください。',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5.クオカード（名言）',
        templateId: 'quote',
        title: '今日の名言',
        data: {
          'content':
              '完璧な瞬間を待ってはいけません。行動し、あなたの行動を通じてその瞬間を完璧なものにしましょう。',
          'author': 'Napoleon Hill',
          'source': '考えて豊かに成長する',
        },
      ),
      TemplateGalleryItem(
        label: '6. コンパクトカード（コンパクトロウ）',
        templateId: 'compact_card',
        title: '💧水分摂取量',
        wrapped: true,
        data: {
          'details': ['500ml', 'カップ4', '本日の目標2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'ビジュアル',
    items: [
      TemplateGalleryItem(
        label: '7. スナップショットカード（写真）',
        templateId: 'snapshot',
        title: '夕暮れの瞬間',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': '外灘・上海',
        },
      ),
      TemplateGalleryItem(
        label: '8. ギャラリーカード(アルバム)',
        templateId: 'gallery',
        title: '週末キャンプ',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9.ビデオカード（ビデオ）',
        templateId: 'video',
        title: 'ビデオログ',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10.キャンバスカード(キャンバス)',
        templateId: 'canvas',
        title: 'マインドマップのドラフト',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: '定量化可能',
    items: [
      TemplateGalleryItem(
        label: '11. メトリクスカード (メトリクス)',
        templateId: 'metric',
        title: '健康指標',
        data: {
          'items': [
            {
              'title': '深い眠り',
              'value': 2.5,
              'unit': 'h',
              'label': '昨晩',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'ステップ',
              'value': 8342,
              'unit': 'steps',
              'label': '今日',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': '心拍',
              'value': 72,
              'unit': 'bpm',
              'label': '休憩中',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. 評価カード（評価）',
        templateId: 'rating',
        title: '映画の評価',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              '息をのむようなビジュアルと、観た後も長く残る時間と愛についての哲学的な見方。',
        },
      ),
      TemplateGalleryItem(
        label: '13. ムードカード（ムード）',
        templateId: 'mood',
        title: '今日の気分',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': '新しいプロジェクトが始まり、チームは非常にモチベーションが高まっています。',
        },
      ),
      TemplateGalleryItem(
        label: '14. プログレスカード（プログレス）',
        templateId: 'progress',
        title: '年間目​​標の進捗状況',
        data: {
          'label': '年間読書計画',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '時間的',
    items: [
      TemplateGalleryItem(
        label: '15. イベントカード(イベント)',
        templateId: 'event',
        title: 'AI製品検討会',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': '上海、浦東新区テックパーク、ビルディングA',
        },
      ),
      TemplateGalleryItem(
        label: '16. デュレーションカード（タイマー）',
        templateId: 'duration',
        title: 'ポモドーロタイマー',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. タスクカード（タスク）',
        templateId: 'task',
        title: '完全な製品要件分析',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': '競合分析レポート', 'completed': true},
            {'title': 'ユーザーインタビューの合成', 'completed': true},
            {'title': '要件ドキュメントの初稿', 'completed': false},
            {'title': 'PRD検討会議', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. ルーティンカード（習慣トラッカー）',
        templateId: 'routine',
        title: '毎日の瞑想',
        data: {
          'habit_name': '毎日10分間の瞑想',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. 手順カード（手順）',
        templateId: 'procedure',
        title: 'バタークッキーのレシピ',
        data: {
          'steps': [
            '材料を準備します：薄力粉 200g、卵 3個、バター 100g',
            'オーブンを175℃に予熱します',
            'バターと砂糖を白っぽくなるまでクリーム状にする',
            '卵を一つずつ加えてよく混ぜる',
            '小麦粉をふるいにかけて、ちょうど混ざるまで混ぜる',
            'オーブンで25分焼きます',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'エンティティ',
    items: [
      TemplateGalleryItem(
        label: '20.人物カード（人物）',
        templateId: 'person',
        title: '接触',
        data: {
          'name': 'Alex Zhang',
          'relation': 'プロダクトマネージャー',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. プレイスカード（プレイス）',
        templateId: 'place',
        title: '好きな本屋',
        data: {
          'name': '蔦屋書店・静安寺',
          'address': '上海市静安区泰興路400号',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. スペックシート（製品仕様）',
        templateId: 'spec_sheet',
        title: 'アップルウォッチシリーズ9',
        data: {
          'subtitle': 'スマートウォッチ',
          'specs': {
            '画面': '1.9" AMOLED',
            'バッテリー': '5日間のバッテリー寿命',
            '耐水性': 'IP68',
            '重さ': '32g',
            'チップ': 'Apple S9',
            'サイズ': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. トランザクションカード（支出）',
        templateId: 'transaction',
        title: '昼食の支出',
        data: {
          'merchant': '胡同ヌードルハウス',
          'amount': '¥ 68.00',
          'location': '鼓楼街、北京',
          'items': [
            {'name': 'シグネチャーザージャンミェン（大）', 'amount': '¥ 38'},
            {'name': 'マリネエッグ', 'amount': '¥ 8'},
            {'name': '冷やし北京ヨーグルト', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. リンクカード(リンク)',
        templateId: 'link',
        title: 'フラッターのドキュメント',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsJa = [
  TemplateGalleryItem(
    label: '1.タイムラインカード（今日のタイムライン）',
    templateId: 'timeline_card_v1',
    data: {
      'title': '今日のタイムライン',
      'items': [
        {
          'time': '09:00',
          'title': '深い仕事',
          'content':
              'アーキテクチャ図 v2.0 が完成し、3 つの重大なバグが修正されました。',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'お昼休み',
          'content': '軽いサラダを食べてから20分ほど散歩。',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': '満たされるために…',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. バブルチャート（キーワードバブル）',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': '今週のキーワード',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'デザイン', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': '42 個のノートに基づく分析',
    },
  ),
  TemplateGalleryItem(
    label: '3. トレンドライン（トレンドチャート）',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': '気分指数 (過去 7 日間)',
      'top_right_text': '平均: 7.2',
      'points': [
        {'label': '火', 'value': 3.5},
        {'label': '水', 'value': 4.0},
        {'label': '木', 'value': 5.5},
        {'label': '金', 'value': 8.5, 'is_highlight': true},
        {'label': '土', 'value': 7.0},
        {'label': '太陽', 'value': 6.5},
        {'label': '月', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5点', 'subtitle': '金曜日のハイライト'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. 棒グラフ（棒比較）',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': '集中時間の配分',
      'subtitle': 'エージェントの洞察: あなたはコーディングに最も労力を費やしました。',
      'unit': 'h',
      'items': [
        {'label': 'デザイン', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'コーディング',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': '読む', 'value': 1.5, 'icon': '📚'},
        {'label': '会議', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. プログレスリング（目標の進捗状況）',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': '年間読書目標',
      'subtitle': 'あと12冊',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': '完了', 'value': 65, 'color': '#6366F1'},
        {'label': '残り', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. レーダーチャート（レーダー）',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': '機能モデル',
      'badge': '毎月の焦点',
      'center_value': '78',
      'center_label': '総合スコア',
      'dimensions': [
        {'label': '実行', 'value': 80},
        {'label': '考え', 'value': 60},
        {'label': '創造性', 'value': 70},
        {'label': '影響', 'value': 85},
        {'label': '学ぶ', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. ハイライト/引用 (引用)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': '未来を予測する最良の方法は、未来を創造することです。',
      'quote_highlight': 'create it',
      'footer': '- ピーター・ドラッカー',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. 構成（内訳）',
    templateId: 'composition_card_v1',
    data: {
      'title': '今日のエネルギー構成',
      'badge': '効率的',
      'headline_items': [
        {'label': '合計時間', 'value': '8.5h'},
        {'label': '深い仕事', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'コーディング', 'percentage': 50, 'color': '#6366F1'},
        {'label': '会議', 'percentage': 30, 'color': '#F43F5E'},
        {'label': '読む', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'とても生産的な一日',
    },
  ),
  TemplateGalleryItem(
    label: '9. コントラスト/リフレーミング（リフレーミング）',
    templateId: 'contrast_card_v1',
    data: {
      'title': '信念を再構成する',
      'emotion': 'neutral',
      'context_section': {
        'title': '独自の考え',
        'content': '忙しすぎて、新しいことを学ぶ時間がありません。',
        'icon': '😫'
      },
      'highlight_section': {
        'title': '新しい視点',
        'content':
            '忙しいということは、実践を通じて学ぶ機会がたくさんあるということです。実践することで学ぶことができます。',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. ギャラリー/クロニクル (ギャラリー)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'インスピレーションのスニペット',
      'headline': '3 Photos',
      'content': '今日得られたデザインのインスピレーションの一部。',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'テクスチャ'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': '色'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'ライト'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. マップカード(地図)',
    templateId: 'map_card_v1',
    data: {
      'title': '足跡',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': '二つの都市の物語',
      'info_detail': '今週は北京と上海の間で通勤します',
    },
  ),
  TemplateGalleryItem(
    label: '12. サマリーカード（概要）',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': '第 4 週: 突破口とつながり',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'Sレベルの状態'},
      'insight_title': 'エージェントの洞察',
      'insight_content':
          '今週は主に #AI エージェントの開発に重点を置き、コードコミットの新記録を達成しました。また、金曜日の夜に家族との夕食を記録していたことにも気づきました。この「一生懸命働き、全力で生きる」パターンは非常に健康的です。',
      'metrics': [
        {'label': '集中', 'value': '32h'},
        {'label': '気分', 'value': '8.2', 'color': '#10B981'},
        {'label': '記録', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': '今週のハイライト (3 つ選択)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': '打ち上げ'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': '家族の夕食'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
