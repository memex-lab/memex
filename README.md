<p align="center">
    <picture>
      <img src="https://github.com/user-attachments/assets/c603127f-98a5-4bf1-8946-778fec2b76f6" width="400">
    </picture>
</p>
<p align="center">
  An AI-powered personal knowledge management app that runs entirely on your device.
</p>

<p align="center">
  <a href="https://github.com/memex-lab/memex/releases"><img src="https://img.shields.io/github/v/release/memex-lab/memex?style=flat-square&label=release" alt="Release"></a>
  <a href="https://discord.gg/ftae8GeubK"><img src="https://img.shields.io/badge/discord-join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
  <a href="README_CN.md"><img src="https://img.shields.io/badge/文档-中文-blue?style=flat-square" alt="中文文档"></a>
</p>

<div align="center">
  <img src="https://github.com/user-attachments/assets/450eb6e5-8adf-4c1f-bc46-a63c9836f22c" width="300" />
</div>

## What is Memex?

Memex is a local-first, AI-native personal knowledge management app. Capture text, photos, and voice — a multi-agent system automatically organizes your records into structured timeline cards, extracts knowledge, and generates insights across your entries.

All data stays on your device. You just need to pick your preferred LLM provider.

## Features

### 🎙️ Multi-Modal Input
- Text, images, and voice recording in a single input flow
- Long-press to record audio, release to send
- Automatic EXIF extraction (timestamp, GPS location) from photos
- On-device OCR and image labeling via Google ML Kit

### 🤖 AI-Powered Organization
- Multi-agent architecture: each agent handles a specific domain (PKM, card generation, insights, comments, memory summarization, media analysis)
- Automatically generates the most fitting card for each type of input:
  - Life & productivity (task, routine, event, duration, progress) — track todos, habits, schedules and goals
  - Knowledge & media (article, snippet, quote, link, conversation) — capture notes, references and dialogues
  - People & places (person, place) — log contacts and locations with map preview
  - Data & metrics (metric, rating, transaction, spec sheet) — record measurements, reviews and expenses
  - Visual (gallery) — preserve moments through photos
- Auto-tagging, entity extraction, and cross-reference linking
- Conversational AI assistant for discussing any card or topic

### 💡 Knowledge & Insights
- P.A.R.A-based knowledge organization (Projects, Areas, Resources, Archives)
- Insight cards that surface connections across records:
  - Charts (trend, bar, radar, bubble, composition, progress ring) — visualize patterns, distributions and goal progress over time
  - Narrative (highlight, contrast, summary) — surface key conclusions, before/after comparisons, and periodic reviews
  - Spatial & temporal (map, route, timeline) — reconstruct where and when things happened
  - Gallery — visual memory from your photos

### 🔒 Privacy & Local-First
- All data stored locally (filesystem + SQLite)
- App lock with biometric authentication
- No cloud dependency — your data never leaves your device

### 🔗 Multi-LLM Provider Support

| Provider | API Type | Notes |
|----------|----------|-------|
| Google Gemini | Gemini API | gemini-3.1-pro-preview, gemini-3-flash-preview, etc. |
| Google Gemini | OAuth (no API key required) | Sign in with Google account. Unofficial — use at your own risk |
| OpenAI | Chat Completions / Responses API | GPT-5.4, etc. |
| OpenAI | OAuth (no API key required) | Sign in with OpenAI account. Unofficial — use at your own risk |
| Anthropic Claude | Claude API | Direct API access |
| AWS Bedrock | Bedrock Claude | For AWS users |

## Install

### iOS

Search **MemexAI** on the App Store, or [click here](https://apps.apple.com/app/memexai) to download.

### Android

Download the latest APK from [GitHub Releases](https://github.com/memex-lab/memex/releases).

### Configure LLM

Memex requires an LLM API key to power its AI features. On first launch:

1. Tap the avatar icon → Model Configuration
2. Select your provider (Gemini / OpenAI / Claude / etc.)
3. Enter your API key and base URL
4. Each agent can be configured with a different model independently

## Roadmap

- [ ] Cloud sync & backup (iCloud, Google Drive, etc.)
- [ ] Video and file attachments
- [ ] Editable Memory — manually curate and refine memory entries
- [ ] Scheduled insight refresh — periodically re-analyze records for new patterns
- [ ] Agent Soul — personalize agent behavior and personality
- [ ] Customization — choose your own knowledge methodology, tagging rules, chat personas, and card styles
- [ ] Event Bus & Hook System — a global event bus that decouples data sources from agent execution, making both data source integration and agent scheduling fully extensible
- [ ] Extension Market & Plugin Architecture — a cloud registry for agents, UI card templates, and persona configs with one-tap install and hot-reload

## Development

<details>
<summary>Build from source</summary>

### Prerequisites

- Flutter SDK ≥ 3.6.0
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

```bash
git clone https://github.com/memex-lab/memex.git
cd memex
flutter pub get
```

For iOS:

```bash
cd ios && pod install && cd ..
```

### Run

```bash
flutter run
```

</details>

<details>
<summary>Architecture</summary>

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart ≥ 3.6) |
| Platforms | iOS, Android |
| Database | Drift (SQLite) |
| State Management | Provider + MVVM |
| LLM Providers | Gemini, OpenAI, Claude, Bedrock Claude |
| Agent Framework | dart_agent_core |

### Project Structure

```
lib/
├── agent/          # Multi-agent system
│   ├── pkm_agent/        # Personal knowledge management
│   ├── card_agent/       # Timeline card generation
│   ├── insight_agent/    # Cross-record insight discovery
│   ├── comment_agent/    # AI commentary
│   ├── memory_agent/     # Memory summarization
│   ├── persona_agent/    # User profile modeling
│   ├── super_agent/      # Orchestrator agent
│   └── skills/           # Composable agent skills
├── data/           # Repositories & services
├── db/             # Drift database schema
├── domain/         # Domain models
├── l10n/           # i18n (English, Chinese)
├── llm_client/     # LLM client abstraction layer
├── ui/             # Presentation layer (MVVM)
└── utils/          # Shared utilities
```

### Data Flow

```
User Input (text/image/voice)
    ↓
Input Processing & Asset Analysis (ML Kit)
    ↓
PKM Agent → Knowledge extraction & linking
    ↓
Card Agent → Structured timeline card
    ↓
Insight Agent → Cross-record pattern discovery
    ↓
Local Storage (filesystem + SQLite)
```

</details>

## Contributing

Contributions are welcome. Please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the GPL-3.0 License — see the [LICENSE](LICENSE) file for details.