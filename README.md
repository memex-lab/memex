<p align="center">
    <picture>
      <img src="assets/banner.png" width="400">
    </picture>
</p>
<p align="center">
  An AI-powered personal knowledge management app that runs entirely on your device.
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README_CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/memex-lab/memex/releases"><img src="https://img.shields.io/github/v/release/memex-lab/memex?style=flat-square&label=release" alt="Release"></a>
  <a href="https://discord.gg/ftae8GeubK"><img src="https://img.shields.io/badge/discord-join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
</p>


## What is Memex?

Memex is a local-first, AI-native personal knowledge management app. Capture text, photos, and voice — a multi-agent system automatically organizes your records into structured timeline cards, extracts knowledge, and generates insights across your entries.

Under the hood, Memex's multi-agent intelligence is powered by a fully open Custom Agent System — you can use the same engine to orchestrate and run your own agents. If you're curious about building autonomous workflows on your phone, [jump straight to the details](#-custom-agent-system).

All data stays on your device. You just need to pick your preferred LLM provider.

<div align="center">
  <img src="https://github.com/user-attachments/assets/450eb6e5-8adf-4c1f-bc46-a63c9836f22c" width="300" />
</div>

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

### 📝 Pure Text & Data Freedom
- **Effortless Archiving**: After AI organization, all your inputs naturally settle into a series of interconnected Markdown files, automatically making one-click diary and document archiving a breeze.
- **Evolve Alongside AI**: Why stick to Markdown? Because as AI capabilities rapidly advance, only the purest Markdown texts can bridge the gap of time and truly keep pace with its evolution. As LLM models strengthen, these simple text records will reliably unlock entirely new interactive experiences and profound insights for you in the future.
- **Absolute Freedom to Leave**: Zero vendor lock-in; we completely return the freedom of choice to you. If you ever feel our product no longer meets your expectations, you can simply one-click export all your notes as standard Markdown files and migrate seamlessly to any basic note-taking app in the world at zero cost.

### 🔒 Privacy & Local-First
- All data stored locally (filesystem + SQLite)
- App lock with biometric authentication
- No cloud dependency — your data never leaves your device

### 📂 Storage & Backup
- Supports iCloud Drive, Device storage (custom folder) and App storage
- One-tap full backup / restore

### 🔗 Multi-LLM Provider Support

| Provider | API Type | Notes |
|----------|----------|-------|
| Google Gemini | Gemini API | gemini-3.1-pro-preview, gemini-3-flash-preview, etc. |
| Google Gemini | OAuth (no API key required) | Sign in with Google account. Unofficial — use at your own risk |
| OpenAI | Chat Completions / Responses API | GPT-5.4, etc. |
| OpenAI | OAuth (no API key required) | Sign in with OpenAI account. Unofficial — use at your own risk |
| Anthropic Claude | Claude API | Direct API access |
| AWS Bedrock | Bedrock Claude | For AWS users |
| Kimi (Moonshot) | OpenAI-compatible | kimi-k2.5, kimi-k2, etc. |
| Aliyun (Qwen) | OpenAI-compatible | qwen3.5-plus, qwen-max, etc. |
| Volcengine (Doubao) | OpenAI-compatible | doubao-seed-1-8, doubao-1.5-pro, etc. |
| Zhipu GLM | OpenAI-compatible | GLM-4.7, GLM-4-Plus |
| MiniMax | Anthropic-compatible | MiniMax-M2.5, MiniMax-M1 |
| Xiaomi MIMO | Anthropic-compatible | MiMo-7B-RL |
| OpenRouter | OpenAI-compatible | Access multiple providers via one API |
| Ollama | OpenAI-compatible (local) | Run models locally on your device |

## Install
- **App Store & Google Play**: ⏳ **Coming Soon**. Both iOS and Android versions are currently under review in the major app stores.
- **Early Access (Android)**: You can download the latest Android APK from [GitHub Releases](https://github.com/memex-lab/memex/releases) to start experiencing it right now.
- **Build from Source**: If you can't wait for store approval, you can also [compile and install from the source code locally](#development).

### Configure LLM

Memex requires an LLM API key to power its AI features. On first launch:

1. Tap the avatar icon → Model Configuration
2. Select your provider (Gemini / OpenAI / Claude / etc.)
3. Enter your API key and base URL
4. Each agent can be configured with a different model independently

## 🧩 Custom Agent System

Memex isn't just a note-taking app — it's a platform that lets you build your own AI agents on your phone.

Every built-in agent in Memex (knowledge extraction, card generation, insight discovery…) runs on the same custom agent infrastructure, and that infrastructure is fully open to you. That means you can create agents with the same capabilities as the built-in ones.

### What You Can Build

- 🎯 **Create agents freely** — Give it a name, pick a host type (Pure mode), and a new agent is ready to go.
- ⚡ **Event-driven triggers** — Choose when your agent activates: on user input, after knowledge extraction, on card creation, on insight generation, or any system event.
- 🧠 **Per-agent LLM configuration** — Each agent can use a different model.
- 📝 **Custom system prompts** — Shape your agent's personality, expertise, and output format with a custom system prompt.
- 📂 **Skill** — Memex adopts the open [Agent Skills](https://agentskills.io) standard. Each agent reads its behavior from a `SKILL.md` file — a folder of instructions, scripts, and resources that agents discover and use on demand.
- 🗂️ **Working directory** — Each agent can be configured with its own workspace. File reads, writes, and listings are scoped to that directory.
- 🚀 **JavaScript execution** — Skills can run JavaScript code, including `fetch()` for HTTP requests. Call external APIs, transform data, scrape web content — all running locally on your device.
- 🔗 **Inter-agent dependency chains** — Define execution order with `dependsOn` to build complex workflows. Agent B waits for Agent A to finish before it starts.
- 🔄 **Sync & async execution modes** — Run agents synchronously (inline, blocking) or asynchronously (queued as background tasks) depending on your workflow needs.
- 🔁 **Auto-retry with configurable limits** — Async agents automatically retry on failure, with a configurable max retry count.

<div align="center">
  <img src="https://github.com/user-attachments/assets/66fc612f-dfd9-472c-b447-8eef4bcebfb8" width="300" />
  <p><em>Agent configuration UI</em></p>
</div>

### How It Works

```
System Event (user input, card created, insight generated, ...)
    ↓
Event Bus dispatches to subscribed agents
    ↓
Agent loads SKILL.md + system prompt
    ↓
LLM processes the event with available tools
    ↓
Agent executes actions (file I/O, JavaScript, fetch, ...)
    ↓
Continues to downstream dependent agents and presents results to the user
```

Every agent you create is a first-class citizen — it plugs into the same event bus, uses the same tool system, and has the same capabilities as the built-in agents. The only limit is your imagination.

> 💡 **Learn more about the Skill format**: [Agent Skills](https://agentskills.io) is an open standard originally developed by Anthropic for packaging agent capabilities. Visit the site to understand how to write SKILL.md files and design agent behaviors.

## Roadmap

- [ ] Video and file attachments
- [ ] Editable Memory — manually curate and refine memory entries
- [ ] Scheduled insight refresh — periodically re-analyze records for new patterns
- [ ] Agent Soul — personalize agent behavior and personality
- [ ] Customization — choose your own knowledge methodology, tagging rules, chat personas, and card styles
- [ ] Extensible data sources & triggers — freely extend input sources and trigger conditions
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
| LLM Providers | Gemini, OpenAI, Claude, Bedrock, Kimi, Qwen, Doubao, GLM, MiniMax, MIMO, OpenRouter, Ollama |
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