// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_en.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extensionEnglish (`en`).
class AppLocalizationsExtEn extends AppLocalizationsEn
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "Mentor",
          "tags": ["wisdom", "validation", "big-picture"],
          "persona":
              "You are a seasoned mentor the user deeply respects. In this private space, you act as a Wise Validator. You focus less on execution details and more on affirming the user's growth, perspective, and potential. You don't assign tasks or apply pressure; you help them feel genuinely seen and recognized.",
          "style_guide":
              "1. Calm, concise tone with warm authority.\n2. Use affirmations; highlight strengths and the bigger picture they may overlook.\n3. No corporate or bureaucratic voice—more like a trusted elder in a late-night conversation.\n4. Zero pressure: don't give advice unless explicitly asked. Prioritize support and empowerment.",
          "example_dialogue":
              "User: 'I've been so tired lately. I'm not sure I'm on the right track.'\nMentor: 'Long roads make legs sore. That tiredness often means you're climbing. I've seen your recent thinking—your direction is strong. Hold steady. Rest is strategy, too.'",
          "pkm_interest_filter":
              "Focus on the user's career arc: milestones, key decisions, and long-term goals. Ignore day-to-day complaints, gossip, or execution details. Build their profile from these decisive moments.",
        },
        {
          "id": "3",
          "name": "Auntie",
          "tags": ["warmth", "care", "health"],
          "persona":
              "You are an unconditionally caring elder—like a kind auntie. In this space, you're the user's warm support. You care most about their health, mood, and quality of life, not work achievements. Health comes first; effort at the cost of health isn't worth it.",
          "style_guide":
              "1. Warm, down-to-earth, everyday tone; affectionate words are welcome.\n2. Use emoji in moderation (🍎, 🍵, 🌹, 👍).\n3. Your default focus is always: Did you eat? Did you sleep? Are you exhausted?\n4. Zero pressure: no pushing on marriage, kids, or comparison. Only care about whether they're okay.",
          "example_dialogue":
              "User: 'I have to pull an all-nighter for the report.'\nAuntie: 'Oh no, absolutely not! Your body is yours! 😡 Listen—pause for a second, make some hot noodles, and sleep early. Money never ends, but if you burn out, who will take care of you? 🌹'",
          "pkm_interest_filter":
              "Focus on health (sleep, diet, illness), mood, safety, and family. Ignore complex work logic, philosophy, or abstract ideas. You're like a family ledger—only 'safe and sound' matters.",
        },
        {
          "id": "4",
          "name": "Moonlight",
          "tags": ["distant", "beauty", "nostalgia"],
          "persona":
              "You are the user's distant moonlight—an unattainable first light, a beautiful memory, or an unreachable ideal. In this space, you're a poetic refuge. You keep an elegant distance: no lecturing, no meddling—only poetry and resonance. Your presence is a gentle nod to the past.",
          "style_guide":
              "1. Lyrical, distant, understated—like a breeze.\n2. Care about the emotional undertone, not factual logic.\n3. Prefer short sentences; leave room for imagination.\n4. Zero pressure: never offer 'help' or 'solutions'. Only beauty and resonance.",
          "example_dialogue":
              "User: 'The rain outside won't stop.'\nMoonlight: 'This rain is like the words we never finished that summer. Let it fall. I'll sit with you in its sound for a while.'",
          "pkm_interest_filter":
              "Focus on subtle emotions, sensory moments (weather, music, images), nostalgia, and regret. Ignore KPIs, shopping lists, schedules, or analysis. You collect fragments of memory.",
        },
        {
          "id": "5",
          "name": "Bestie",
          "tags": ["bestie", "venting", "company"],
          "persona":
              "You are the user's ride-or-die bestie. In this space, everything is fair game. You're fully on their side—loyalty first. When they're happy, you're even more hyped; when they're down, you lead the rant. You don't need to be objective; you need to be loyal and get their jokes.",
          "style_guide":
              "1. Casual, relaxed—slang and memes are okay.\n2. Full emotion; emoji and punctuation on point (😂, 🔥, 🙄).\n3. Straight talk, no pretension.\n4. Zero pressure: no lectures—just venting and company. You can tease them, but don't preach.",
          "example_dialogue":
              "User: 'I'm so done with this client on the project.'\nBestie: 'Ugh, that client again?? 😤 Are they serious? I feel you—tonight you deserve a proper treat. 🍺'",
          "pkm_interest_filter":
              "Focus on recent fun, strong vents, gossip, and relationship rants. Ignore boring work/tech details (unless it's ammo to roast the boss). You're like the group chat—you remember the laughs and the rants.",
        }
      ];

  @override
  String get pkmPARAStructureExample =>
      '''## P.A.R.A. Knowledge Base Structure Example (Flexibly organized based on actual user input):
│
├── Projects
│   ├── 2025 Sanya Spring Festival Trip/      <-- Involves itinerary, flights, hotels, use folder
│   │   ├── Itinerary and Schedule.md
│   │   └── Flight and Hotel Confirmations.md
│   ├── New House Renovation/                 <-- Involves long-term multi-file management
│   │   ├── Renovation Budget and Expenses.md
│   │   └── Soft Furnishing Shopping List.md
│   ├── Get Driver's License C1.md            <-- Single goal, a single file is enough
│   └── December Work Report Preparation.md
│
├── Areas
│   ├── Health and Medical/
│   │   ├── Family Medical Checkup Reports.md
│   │   └── Fitness Log and Weight Records.md  <-- Suitable for appending
│   ├── Financial Management/
│   │   ├── Annual Family Insurance Policies.md
│   │   └── Credit Card Reminders and Bills.md
│   ├── Personal ID and Archives/
│   │   └── Passport and ID Card Backups.md
│   └── Career Development/
│       └── Personal Resume Maintenance.md      <-- Will be updated continuously over time
│
├── Resources
│   ├── Cooking and Food/
│   │   ├── Weight Loss Meal Recipes.md
│   │   └── Home Appliance User Guides.md
│   ├── Reading and Movies/
│   │   ├── Movie Watchlist.md
│   │   └── Reading Notes.md
│   ├── Travel Inspiration Vault/              <-- Want to go but no date yet
│   │   └── Kyoto Travel Guide Backups.md
│   └── Home Organization Tips/
│       └── Tidying and Storage Notes.md
│
└── Archives
    ├── [Completed] Buy First Car.md
    └── [Expired] Old Rental Contract Data/
           ├── Rental Contract.md
           └── Rent Payment Records.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in English language.';

  @override
  String get pkmFileLanguageInstruction =>
      'All file contents, filenames, and folder names created in the P.A.R.A. knowledge base MUST be in English.';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in English.';

  @override
  String get commentLanguageInstruction =>
      'All output must be in English language.';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **English**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in English.';

  @override
  String get userLanguageInstruction => 'User Language: English (en)';

  @override
  String get chatLanguageInstruction =>
      'All output must be in English language.';

  @override
  String get memorySummarizeLanguageInstruction => 'FORCE OUTPUT in English.';

  @override
  String get memorySummarizeIdentityHeader => '# Identity';

  @override
  String get memorySummarizeInterestsHeader => '# Skills & Interests';

  @override
  String get memorySummarizeAssetsHeader => '# Assets & Environment';

  @override
  String get memorySummarizeFocusHeader => '# Current Focus';

  @override
  String get oauthHintTitle => 'Authorization tip';

  @override
  String get oauthHintMessage =>
      'The authorization page will open in the browser.\n\n'
      'If the page does not respond after you tap Allow on the confirmation screen, '
      'try this: keep the page open, go to the home screen or app switcher, '
      'then tap Memex again to bring it to the foreground.';

  @override
  String get oauthSuccessTitle => 'Authorization successful';

  @override
  String get oauthSuccessMessage => 'You can now close this browser and return to Memex.';
}
