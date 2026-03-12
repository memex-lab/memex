<p align="center">
  <img src="assets/icon.png" width="120" alt="Memex Logo" />
</p>

<h1 align="center">Memex</h1>

<p align="center">
  An AI-powered personal knowledge management app that runs entirely on your device.
</p>

<p align="center">
  <a href="README_CN.md">中文文档</a> •
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<div align="center">
  <video src="https://github.com/sparkleMing/file/releases/download/demo/demo.mp4" width="350" controls autoplay muted loop>
  </video>
</div>

## What is Memex?

Memex is a local-first, AI-native personal knowledge management app built with Flutter. Capture text, photos, and voice — a multi-agent system automatically organizes your records into structured timeline cards, extracts knowledge, and generates insights across your entries.

All data stays on your device. You just need to pick your preferred LLM provider.

## Features

### Multi-Modal Input
- Text, images, and voice recording in a single input flow
- Long-press to record audio, release to send
- Automatic EXIF extraction (timestamp, GPS location) from photos
- On-device OCR and image labeling via Google ML Kit

### AI-Powered Organization
- Multi-agent architecture: each agent handles a specific domain (PKM, card generation, insights, comments, memory summarization, media analysis)
- Automatically generates structured timeline cards from raw input
- Auto-tagging, entity extraction, and cross-reference linking
- Conversational AI assistant for discussing any card or topic

### Knowledge & Insights
- Timeline view with tag-based filtering
- Knowledge Base with auto-organized topics
- Insight cards that surface connections across records
- Map view for location-based entries (OpenStreetMap)

### Privacy & Local-First
- All data stored locally (filesystem + SQLite)
- Built-in local HTTP server for asset serving
- App lock with biometric authentication
- HealthKit integration for health data tracking
- No cloud dependency — your data never leaves your device

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart ≥ 3.6) |
| Platforms | iOS, Android |
| Database | Drift (SQLite) |
| State Management | Provider + MVVM |
| LLM Providers | Gemini, OpenAI, Claude, Bedrock Claude |
| Maps | flutter_map + OpenStreetMap |
| On-Device ML | Google ML Kit (text recognition, image labeling) |
| Agent Framework | dart_agent_core |

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.6.0
- Xcode (for iOS)
- Android Studio (for Android)

### Installation

```bash
git clone https://github.com/your-username/memex.git
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

### Configure LLM

Memex requires an LLM API key to power its AI features. On first launch:

1. Tap the avatar icon → Model Configuration
2. Select your provider (Gemini / OpenAI / Claude / etc.)
3. Enter your API key and base URL
4. Each agent can be configured with a different model independently

## Architecture

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
│   ├── timeline/         # Timeline feed
│   ├── knowledge/        # Knowledge base
│   ├── insight/          # Insight cards
│   ├── chat/             # AI chat interface
│   ├── calendar/         # Calendar view
│   └── settings/         # App settings
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

## Supported LLM Providers

| Provider | API Type | Notes |
|----------|----------|-------|
| Google Gemini | Gemini API | Recommended for cost efficiency |
| OpenAI | Chat Completions / Responses API | GPT-4o, o1, etc. |
| Anthropic Claude | Claude API | Direct API access |
| AWS Bedrock | Bedrock Claude | For AWS users |

## Roadmap

- [ ] OAuth login for Claude and Gemini (no API key management)
- [ ] Cloud sync & backup (iCloud, Google Drive, etc.)
- [ ] Video and file attachments
- [ ] Editable Memory — manually curate and refine memory entries
- [ ] Scheduled insight refresh — periodically re-analyze records for new patterns
- [ ] Agent Soul — personalize agent behavior and personality
- [ ] Event Bus & Hook System — a global event bus that decouples data sources from agent execution. Any input source (Share Extension, URL Scheme, Directory Watcher, Cron Scheduler) emits typed events onto the bus; a multi-dimensional Hook Registry intercepts them at key lifecycle points to trigger the right agent at the right moment — making both data source integration and agent scheduling fully extensible without touching core logic.
- [ ] Extension Market & Plugin Architecture — a cloud registry serves as a marketplace for agents, UI card templates, and persona configs. Users can browse and install extensions with one tap, and changes hot-reload instantly without restarting the app.

## Contributing

Contributions are welcome. Please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
