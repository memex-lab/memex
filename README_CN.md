<p align="center">
    <picture>
      <img src="brand.png"/>
    </picture>
</p>
<p align="center">
  一个完全运行在本地的 AI 驱动个人生活记录应用。
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README_CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/memex-lab/memex/releases"><img src="https://img.shields.io/github/v/release/memex-lab/memex?style=flat-square&label=release" alt="Release"></a>
  <a href="https://discord.gg/TJGpXwn85F"><img src="https://img.shields.io/badge/discord-join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
</p>


## Memex 是什么？

Memex 是一个本地优先、AI 原生的个人生活记录应用。支持文字、图片、语音多模态输入，通过多 Agent 协作自动将你的记录整理为结构化的时间线卡片，提取知识，并生成跨记录的洞察。

Memex 的多 Agent 智能底座是一套完全开放的自定义 Agent 系统 — 你可以基于这个系统编排和运行自己的 Agent，如果你对在手机上构建自主化工作流感兴趣，可以直接[跳转到详细介绍](#-自定义-agent-系统)。

所有数据存储在你的设备上，你只需要选择你偏好的模型提供商。

<div align="center">
  <img src="https://github.com/user-attachments/assets/450eb6e5-8adf-4c1f-bc46-a63c9836f22c" width="300" />
</div>

## 功能

### 🎙️ 多模态记录
- 文字、图片、语音一站式记录
- 长按录音，松手即发送
- 自动提取照片 EXIF 信息（时间、GPS 位置）
- 端侧 OCR 文字识别与图像标签分析（Google ML Kit）

### 🤖 AI 自动整理
- 多 Agent 架构：记录整理、卡片生成、洞察分析、评论、记忆摘要、媒体分析等各司其职
- 自动识别记录内容，生成最匹配的卡片形式：
  - 生活与效率（任务、习惯、事件、时长、进度）— 记录待办、习惯打卡、日程与目标
  - 知识与媒体（文章、片段、引用、链接、对话）— 记录笔记、参考资料与对话内容
  - 人物与地点（联系人、地点）— 记录人际关系与位置信息，支持地图预览
  - 数据与指标（指标、评分、交易、规格表）— 记录测量数据、评价与消费
  - 视觉（图集）— 用图片留存珍贵时刻
- 自动打标签、实体提取、关联关系链接
- AI 对话助手，可针对任意卡片或主题展开讨论

### 💡 知识与洞察
- 基于 P.A.R.A 方法论的知识组织（项目、领域、资源、归档）
- 洞察卡片，跨记录发现关联模式：
  - 图表类（趋势、柱状、雷达、气泡、构成比例、进度环）— 可视化数据规律、分布与目标进展
  - 叙事类（高亮、对比、总结）— 提炼关键结论、呈现前后变化、生成周期性回顾
  - 时空类（地图、路线、时间线）— 还原事件发生的地点与时间脉络
  - 图集 — 以照片形式唤起视觉记忆

### 📝 纯文本与数据自由
- **一键文档入库**：AI 自动整理后，所有的记录都会形成一系列相互关联的 Markdown 文件，自动帮你一键完成日记与文档的入库操作。
- **伴随 AI 共同进化**：为什么坚持用 Markdown？因为 AI 的能力在不断飞跃，唯有最纯粹的原始文本记录，才能跨越时空，真正跟上它进化的脚步。未来随着大模型的进一步提升，基于你沉淀的这些记录，系统能够源源不断地为你挖掘出全新的体验与深层洞察。
- **绝对的去留自由**：拒绝平台锁定，我们将选择权完全还给你。如果你将来觉得我们的产品不够好用，随时可以一键导出所有的记录为 Markdown 文件，零成本、无缝迁移到任何一款笔记产品中去。

### 🔒 隐私与本地优先
- 所有数据存储在本地（文件系统 + SQLite）
- 应用锁（生物识别认证）
- 无云端依赖，数据不会离开你的设备

### 📂 存储与备份
- 支持 iCloud Drive、设备存储（自定义文件夹）与应用存储
- 一键完整备份 / 恢复

### 🔗 支持多种 LLM 提供商

| 提供商 | API 类型 | 备注 |
|--------|----------|------|
| Google Gemini | Gemini API | gemini-3.1-pro-preview、gemini-3-flash-preview 等 |
| Google Gemini | OAuth（无需 API Key） | 使用 Google 账号登录，非官方支持，风险自负 |
| OpenAI | Chat Completions / Responses API | GPT-5.4 等 |
| OpenAI | OAuth（无需 API Key） | 使用 OpenAI 账号登录，非官方支持，风险自负 |
| Anthropic Claude | Claude API | 直接 API 访问 |
| AWS Bedrock | Bedrock Claude | 适合 AWS 用户 |
| Kimi（月之暗面） | OpenAI 兼容 | kimi-k2.5、kimi-k2 等 |
| 阿里云（通义千问） | OpenAI 兼容 | qwen3.5-plus、qwen-max 等 |
| 火山引擎（豆包） | OpenAI 兼容 | doubao-seed-1-8、doubao-1.5-pro 等 |
| 智谱 GLM | OpenAI 兼容 | GLM-4.7、GLM-4-Plus |
| MiniMax | Anthropic 兼容 | MiniMax-M2.5、MiniMax-M1 |
| 小米 MIMO | Anthropic 兼容 | MiMo-7B-RL |
| OpenRouter | OpenAI 兼容 | 通过一个 API 访问多个提供商 |
| Ollama | OpenAI 兼容（本地） | 在本地设备上运行模型 |

## 安装
- **iOS**: 在 [App Store](https://apps.apple.com/app/memexai/id6760325170) 下载
- **Android**: 在 [Google Play](https://play.google.com/store/apps/details?id=com.memexlab.memex) 下载
- **Android APK**: 也可直接从 [GitHub Releases](https://github.com/memex-lab/memex/releases) 下载最新 APK。
- **从源码编译**: [本地编译安装](#开发)。

### 配置 LLM

Memex 需要 LLM API Key 来驱动 AI 功能。首次启动后：

1. 点击头像 → 模型配置
2. 选择 API 类型（Gemini / OpenAI / Claude 等）
3. 填入 API Key 和 Base URL
4. 不同 Agent 可以独立配置不同的模型

## 🧩 自定义 Agent 系统

Memex 不只是一个记录应用 — 它是一个让你能够在手机上构建自己 AI Agent 的平台。

Memex 内置的每一个 Agent（知识提取、卡片生成、洞察发现……）都运行在同一套自定义 Agent 基础设施之上，而这套基础设施完全向你开放。这意味着你可以创建与内置 Agent 同等能力的 Agent。

### 你可以构建什么

- 🎯 **自由创建 Agent** — 取个名字，选择宿主类型（Pure 纯净模式），一个新 Agent 即刻就绪。
- ⚡ **事件驱动触发** — 选择 Agent 何时激活：用户输入时、知识提取后、卡片创建时、洞察生成后，或任何系统事件。
- 🧠 **独立 LLM 配置** — 每个 Agent 可以使用不同的模型。
- 📝 **自定义系统提示词** — 通过自定义 System Prompt 塑造 Agent 的人格、专业领域和输出格式。
- 📂 **Skill** — Memex 采用开放的 [Agent Skills](https://agentskills.io) 标准。每个 Agent 从 `SKILL.md` 文件读取行为定义 — 一个包含指令、脚本和资源的文件夹，Agent 按需发现和使用。
- 🗂️ **工作目录** — 每个 Agent 能够单独配置工作区。文件读写和目录列表都限定在该目录内。
- 🚀 **JavaScript 脚本执行** — Skill 可以运行 JavaScript 代码，包括 `fetch()` 发起 HTTP 请求。调用外部 API、转换数据、抓取网页内容 — 一切都在你的设备上本地运行。
- 🔗 **Agent 间依赖链** — 通过 `dependsOn` 定义执行顺序，构建复杂工作流。Agent B 等待 Agent A 完成后再启动。
- 🔄 **同步 & 异步执行模式** — 根据工作流需要，选择同步执行（内联阻塞）或异步执行（排队为后台任务）。
- 🔁 **自动重试与可配置上限** — 异步 Agent 在失败时自动重试，重试次数可配置。

<div align="center">
  <img src="https://github.com/user-attachments/assets/371573d0-9fa8-405d-8932-aff6a03d7a5b" width="300" />
  <p><em>Agent 配置界面</em></p>
</div>

### 工作原理

```
系统事件（用户输入、卡片创建、洞察生成……）
    ↓
事件总线分发给已订阅的 Agent
    ↓
Agent 加载 SKILL.md + 系统提示词
    ↓
LLM 处理事件，调用可用工具
    ↓
Agent 执行操作（文件读写、JavaScript、fetch……）
    ↓
继续执行依赖的下游 Agent 并展示结果给用户
```

你创建的每一个 Agent 都是一等公民 — 它接入同一个事件总线，使用同一套工具系统，拥有与内置 Agent 完全相同的能力。唯一的限制是你的想象力。

> 💡 **了解更多 Skill 格式**: [Agent Skills](https://agentskills.io) 是由 Anthropic 最初开发的开放标准，用于封装 Agent 能力。访问该网站了解如何编写 SKILL.md 文件和设计 Agent 行为。

## 路线图

- [ ] 支持视频和文件附件
- [ ] 可编辑 Memory — 手动整理和修改记忆条目
- [ ] 定期刷新洞察 — 周期性重新分析记录，发现新关联
- [ ] Agent Soul — 自定义 Agent 的行为风格与个性
- [ ] 个性化定制 — 自由选择知识管理方法论（不限于 P.A.R.A）、标签规则、对话角色人设与卡片样式
- [ ] 可扩展输入源与触发时机 — 自由扩展输入源与触发条件
- [ ] 扩展市场 & 插件架构 — Agent、卡片模板、角色配置的云端市场，一键安装，热重载生效

## 开发

<details>
<summary>从源码构建</summary>

### 环境要求

- Flutter SDK ≥ 3.6.0
- Xcode（iOS 开发）
- Android Studio（Android 开发）

### 安装依赖

```bash
git clone https://github.com/memex-lab/memex.git
cd memex
flutter pub get
```

iOS 额外步骤：

```bash
cd ios && pod install && cd ..
```

### 运行

```bash
flutter run
```

</details>

<details>
<summary>架构</summary>

### 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter (Dart ≥ 3.6) |
| 平台 | iOS、Android |
| 数据库 | Drift (SQLite) |
| 状态管理 | Provider + MVVM |
| LLM | Gemini、OpenAI、Claude、Bedrock、Kimi、通义千问、豆包、智谱 GLM、MiniMax、MIMO、OpenRouter、Ollama |
| Agent 框架 | dart_agent_core |

### 项目结构

```
lib/
├── agent/          # 多 Agent 系统
│   ├── pkm_agent/        # 个人知识管理
│   ├── card_agent/       # 时间线卡片生成
│   ├── insight_agent/    # 跨记录洞察发现
│   ├── comment_agent/    # AI 评论
│   ├── memory_agent/     # 记忆摘要
│   ├── persona_agent/    # 用户画像建模
│   ├── super_agent/      # 编排调度 Agent
│   └── skills/           # 可组合的 Agent 技能
├── data/           # 数据仓库与服务
├── db/             # Drift 数据库定义
├── domain/         # 领域模型
├── l10n/           # 国际化（中文/英文）
├── llm_client/     # LLM 客户端抽象层
├── ui/             # 展示层 (MVVM)
└── utils/          # 工具类
```

### 数据流

```
用户输入（文字/图片/语音）
    ↓
输入处理 & 资源分析（ML Kit）
    ↓
PKM Agent → 知识提取与关联
    ↓
Card Agent → 结构化时间线卡片
    ↓
Insight Agent → 跨记录模式发现
    ↓
本地存储（文件系统 + SQLite）
```

</details>

## 参与贡献

欢迎贡献代码。请先开 Issue 讨论你想要的改动。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 发起 Pull Request

## 许可证

本项目基于 GPL-3.0 许可证开源 — 详见 [LICENSE](LICENSE) 文件。
