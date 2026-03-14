<p align="center">
    <picture>
      <img src="https://github.com/user-attachments/assets/c603127f-98a5-4bf1-8946-778fec2b76f6" width="400">
    </picture>
</p>
<p align="center">
  一个完全运行在本地的 AI 驱动个人知识管理应用。
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README_CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/memex-lab/memex/releases"><img src="https://img.shields.io/github/v/release/memex-lab/memex?style=flat-square&label=release" alt="Release"></a>
  <a href="https://discord.gg/ftae8GeubK"><img src="https://img.shields.io/badge/discord-join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
</p>


## Memex 是什么？

Memex 是一个本地优先、AI 原生的个人知识管理应用。支持文字、图片、语音多模态输入，通过多 Agent 协作自动将你的记录整理为结构化的时间线卡片，提取知识，并生成跨记录的洞察。

所有数据存储在你的设备上。你只需要选择你偏好的模型提供商。

<div align="center">
  <img src="https://github.com/user-attachments/assets/450eb6e5-8adf-4c1f-bc46-a63c9836f22c" width="300" />
</div>

## 功能

### 🎙️ 多模态输入
- 文字、图片、语音一站式输入
- 长按录音，松手即发送
- 自动提取照片 EXIF 信息（时间、GPS 位置）
- 端侧 OCR 文字识别与图像标签分析（Google ML Kit）

### 🤖 AI 自动整理
- 多 Agent 架构：PKM（知识管理）、卡片生成、洞察分析、评论、记忆摘要、媒体分析等各司其职
- 自动识别输入内容，生成最匹配的卡片形式：
  - 生活与效率（任务、习惯、事件、时长、进度）— 追踪待办、习惯打卡、日程与目标
  - 知识与媒体（文章、片段、引用、链接、对话）— 记录笔记、参考资料与对话内容
  - 人物与地点（联系人、地点）— 记录人际关系与位置信息，支持地图预览
  - 数据与指标（指标、评分、交易、规格表）— 记录测量数据、评价与消费
  - 视觉（图集）— 用图片留存珍贵时
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
- **一键文档入库**：AI 自动整理后，所有的输入都会形成一系列相互关联的 Markdown 文件，自动帮你一键完成日记与文档的入库操作。
- **伴随 AI 共同进化**：为什么坚持用 Markdown？因为 AI 的能力在不断飞跃，唯有最纯粹的 Markdown 原始文本，才能跨越时空，真正跟上它进化的脚步。未来随着大模型的进一步提升，基于你沉淀的这些文本，系统能够源源不断地为你挖掘出不可思议的全新体验与深层洞察。
- **绝对的去留自由**：拒绝平台锁定，我们将选择权完全还给你。如果你将来觉得我们的产品不够好用，随时可以一键导出所有的 Markdown 文件，零成本、无缝迁移到世界上任何一款哪怕是最基础的笔记产品中去。

### 🔒 隐私与本地优先
- 所有数据存储在本地（文件系统 + SQLite）
- 应用锁（生物识别认证）
- 无云端依赖，数据不会离开你的设备

### 🔗 支持多种 LLM 提供商

| 提供商 | API 类型 | 备注 |
|--------|----------|------|
| Google Gemini | Gemini API | gemini-3.1-pro-preview、gemini-3-flash-preview 等 |
| Google Gemini | OAuth（无需 API Key） | 使用 Google 账号登录，非官方支持，风险自负 |
| OpenAI | Chat Completions / Responses API | GPT-5.4 等 |
| OpenAI | OAuth（无需 API Key） | 使用 OpenAI 账号登录，非官方支持，风险自负 |
| Anthropic Claude | Claude API | 直接 API 访问 |
| AWS Bedrock | Bedrock Claude | 适合 AWS 用户 |

## 安装

### iOS

在 App Store 搜索 **MemexAI**，或[点击这里](https://apps.apple.com/app/memexai)下载。

### Android

前往 [GitHub Releases](https://github.com/memex-lab/memex/releases) 下载最新 APK 安装包。

### 配置 LLM

Memex 需要 LLM API Key 来驱动 AI 功能。首次启动后：

1. 点击头像 → 模型配置
2. 选择 API 类型（Gemini / OpenAI / Claude 等）
3. 填入 API Key 和 Base URL
4. 不同 Agent 可以独立配置不同的模型

## 路线图

- [ ] 云端同步与备份（iCloud、Google Drive 等）
- [ ] 支持视频和文件附件
- [ ] 可编辑 Memory — 手动整理和修改记忆条目
- [ ] 定期刷新洞察 — 周期性重新分析记录，发现新关联
- [ ] Agent Soul — 自定义 Agent 的行为风格与个性
- [ ] 个性化定制 — 自由选择知识管理方法论（不限于 P.A.R.A）、标签规则、对话角色人设与卡片样式
- [ ] 事件总线 & Hook 系统 — 全局事件总线解耦数据源与 Agent 调度，自由扩展输入源与触发时机
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
| LLM | Gemini、OpenAI、Claude、Bedrock Claude |
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