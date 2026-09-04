import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsEn = [
  TemplateGallerySection(
    title: 'General',
    items: [
      TemplateGalleryItem(
        label: '1. Classic Card (Text note)',
        templateId: 'classic_card',
        title: 'Reading notes',
        data: {
          'content':
              'Finished chapter 3 of "Thinking, Fast and Slow" at a café today. The examples about the anchoring effect were impressive and reminded me how our first piece of information can quietly bias every later decision.',
          'tags': ['Reading', 'Psychology'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Textual',
    items: [
      TemplateGalleryItem(
        label: '2. Snippet Card (Text snippet)',
        templateId: 'snippet',
        title: 'Tech quote',
        data: {
          'text':
              '**“Any sufficiently advanced technology is indistinguishable from magic.”**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['Quote', 'Technology', 'Future'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Article Card (Long article)',
        templateId: 'article',
        title: 'What is flow experience',
        data: {
          'body':
              '## What is flow?\n\nFlow is a psychological state proposed by Mihaly Csikszentmihalyi. When you are fully immersed in a challenging yet achievable task, you lose track of time and your attention is completely focused — this is flow.\n\n> When people do what they truly enjoy, they often forget themselves.\n\nResearch shows that people in a flow state are usually the most productive and also feel the happiest.',
        },
      ),
      TemplateGalleryItem(
        label: '4. Conversation Card (Conversation)',
        templateId: 'conversation',
        title: 'Conversation with AI',
        data: {
          'messages': [
            {
              'sender': 'AI Assistant',
              'text':
                  'You were pretty productive today! What did you get done?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  'Finished the architecture design and code review. Feels great.',
              'isMe': true,
            },
            {
              'sender': 'AI Assistant',
              'text':
                  'Awesome! Remember to rest early tonight, you have an important meeting tomorrow.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Quote Card (Quote)',
        templateId: 'quote',
        title: 'Quote of the day',
        data: {
          'content':
              'Do not wait for the perfect moment. Act, and let the moment become perfect through your action.',
          'author': 'Napoleon Hill',
          'source': 'Think and Grow Rich',
        },
      ),
      TemplateGalleryItem(
        label: '6. Compact Card (Compact row)',
        templateId: 'compact_card',
        title: '💧 Water intake',
        wrapped: true,
        data: {
          'details': ['500ml', 'Cup 4', 'Today’s goal 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Visual',
    items: [
      TemplateGalleryItem(
        label: '7. Snapshot Card (Photo)',
        templateId: 'snapshot',
        title: 'Dusk moment',
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
        label: '9. Video Card (Video)',
        templateId: 'video',
        title: 'Video log',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Canvas Card (Canvas)',
        templateId: 'canvas',
        title: 'Mindmap draft',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Quantifiable',
    items: [
      TemplateGalleryItem(
        label: '11. Metric Card (Metrics)',
        templateId: 'metric',
        title: 'Health metrics',
        data: {
          'items': [
            {
              'title': 'Deep sleep',
              'value': 2.5,
              'unit': 'h',
              'label': 'Last night',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': 'Steps',
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
              'label': 'Resting',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Rating Card (Rating)',
        templateId: 'rating',
        title: 'Movie rating',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              'Breathtaking visuals and a philosophical take on time and love that lingers long after watching.',
        },
      ),
      TemplateGalleryItem(
        label: '13. Mood Card (Mood)',
        templateId: 'mood',
        title: 'Today’s mood',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': 'New project kicked off and the team is highly motivated.',
        },
      ),
      TemplateGalleryItem(
        label: '14. Progress Card (Progress)',
        templateId: 'progress',
        title: 'Annual goal progress',
        data: {
          'label': 'Annual reading plan',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Temporal',
    items: [
      TemplateGalleryItem(
        label: '15. Event Card (Event)',
        templateId: 'event',
        title: 'AI product review meeting',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': 'Building A, Tech Park, Pudong New Area, Shanghai',
        },
      ),
      TemplateGalleryItem(
        label: '16. Duration Card (Timer)',
        templateId: 'duration',
        title: 'Pomodoro timer',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Task Card (Task)',
        templateId: 'task',
        title: 'Complete product requirements analysis',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': 'Competitive analysis report', 'completed': true},
            {'title': 'User interview synthesis', 'completed': true},
            {'title': 'First draft of requirements doc', 'completed': false},
            {'title': 'PRD review meeting', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Routine Card (Habit tracker)',
        templateId: 'routine',
        title: 'Daily meditation',
        data: {
          'habit_name': 'Daily 10-minute meditation',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Procedure Card (Steps)',
        templateId: 'procedure',
        title: 'Butter cookie recipe',
        data: {
          'steps': [
            'Prepare ingredients: 200g cake flour, 3 eggs, 100g butter',
            'Preheat the oven to 175°C',
            'Cream butter and sugar until the mixture becomes pale',
            'Add eggs one by one and mix thoroughly',
            'Sift in the flour and fold until just combined',
            'Bake in the oven for 25 minutes',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: 'Entities',
    items: [
      TemplateGalleryItem(
        label: '20. Person Card (Person)',
        templateId: 'person',
        title: 'Contact',
        data: {
          'name': 'Alex Zhang',
          'relation': 'Product Manager',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Place Card (Place)',
        templateId: 'place',
        title: 'Favorite bookstore',
        data: {
          'name': 'Tsutaya Bookstore · Jing’an Temple',
          'address': '400 Taixing Rd, Jing’an District, Shanghai',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Spec Sheet (Product specs)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Series 9',
        data: {
          'subtitle': 'Smartwatch',
          'specs': {
            'Display': '1.9" AMOLED',
            'Battery': '5-day battery life',
            'Water resistance': 'IP68',
            'Weight': '32g',
            'Chip': 'Apple S9',
            'Size': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Transaction Card (Spending)',
        templateId: 'transaction',
        title: 'Lunch spending',
        data: {
          'merchant': 'Hutong Noodle House',
          'amount': '¥ 68.00',
          'location': 'Gulou Street, Beijing',
          'items': [
            {'name': 'Signature Zhajiangmian (large)', 'amount': '¥ 38'},
            {'name': 'Marinated egg', 'amount': '¥ 8'},
            {'name': 'Chilled Beijing yogurt', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Link Card (Link)',
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

const insightTemplateGalleryItemsEn = [
  TemplateGalleryItem(
    label: '1. Timeline Card (Today’s timeline)',
    templateId: 'timeline_card_v1',
    data: {
      'title': 'Today’s timeline',
      'items': [
        {
          'time': '09:00',
          'title': 'Deep work',
          'content':
              'Finished architecture diagram v2.0 and fixed three critical bugs.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': 'Lunch & break',
          'content': 'Light salad, followed by a 20-minute walk.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': 'To be filled...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Bubble Chart (Keyword bubbles)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': 'Keywords of the week',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': 'Design', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': 'Analysis based on 42 notes',
    },
  ),
  TemplateGalleryItem(
    label: '3. Trend Line (Trend chart)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': 'Mood index (last 7 days)',
      'top_right_text': 'Average: 7.2',
      'points': [
        {'label': 'Tue', 'value': 3.5},
        {'label': 'Wed', 'value': 4.0},
        {'label': 'Thu', 'value': 5.5},
        {'label': 'Fri', 'value': 8.5, 'is_highlight': true},
        {'label': 'Sat', 'value': 7.0},
        {'label': 'Sun', 'value': 6.5},
        {'label': 'Mon', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5 points', 'subtitle': 'Friday highlight'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Bar Chart (Bar comparison)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': 'Focus time distribution',
      'subtitle': 'Agent insight: You spent the most effort on Coding.',
      'unit': 'h',
      'items': [
        {'label': 'Design', 'value': 2.5, 'icon': '🎨'},
        {
          'label': 'Coding',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Reading', 'value': 1.5, 'icon': '📚'},
        {'label': 'Meetings', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Progress Ring (Goal progress)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': 'Annual reading goal',
      'subtitle': '12 books to go',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': 'Completed', 'value': 65, 'color': '#6366F1'},
        {'label': 'Remaining', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Radar Chart (Radar)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': 'Capability model',
      'badge': 'Monthly focus',
      'center_value': '78',
      'center_label': 'Overall score',
      'dimensions': [
        {'label': 'Execution', 'value': 80},
        {'label': 'Thinking', 'value': 60},
        {'label': 'Creativity', 'value': 70},
        {'label': 'Influence', 'value': 85},
        {'label': 'Learning', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Highlight/Quote (Quote)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'The best way to predict the future is to create it.',
      'quote_highlight': 'create it',
      'footer': '- Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composition (Breakdown)',
    templateId: 'composition_card_v1',
    data: {
      'title': 'Energy composition today',
      'badge': 'Efficient',
      'headline_items': [
        {'label': 'Total time', 'value': '8.5h'},
        {'label': 'Deep work', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Coding', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Meetings', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Reading', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': 'A very productive day',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contrast/Reframing (Reframing)',
    templateId: 'contrast_card_v1',
    data: {
      'title': 'Reframing a belief',
      'emotion': 'neutral',
      'context_section': {
        'title': 'Original thought',
        'content': 'I am too busy and don’t have time to learn new things.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': 'New perspective',
        'content':
            'Being busy means there are many opportunities to learn through practice. I can learn by doing.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Gallery/Chronicle (Gallery)',
    templateId: 'gallery_card_v1',
    data: {
      'title': 'Inspiration snippets',
      'headline': '3 Photos',
      'content': 'Some design inspirations captured today.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Texture'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Color'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Light'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Map Card (Map)',
    templateId: 'map_card_v1',
    data: {
      'title': 'Footprints',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': 'A tale of two cities',
      'info_detail': 'Commuting between Beijing and Shanghai this week',
    },
  ),
  TemplateGalleryItem(
    label: '12. Summary Card (Summary)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': 'Week 4: Breakthrough & connection',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'S-level state'},
      'insight_title': 'Agent insight',
      'insight_content':
          'This week you focused mainly on #AI Agent development and hit a new record for code commits. I also noticed you logged a family dinner on Friday night — this “work hard, live fully” pattern is very healthy.',
      'metrics': [
        {'label': 'Focus', 'value': '32h'},
        {'label': 'Mood', 'value': '8.2', 'color': '#10B981'},
        {'label': 'Notes', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': 'Highlights of the week (3 selected)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': 'Launch'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': 'Family dinner'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
