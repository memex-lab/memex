<p align="center">
  <img src="assets/icon.png" width="120" alt="Memex Logo" />
</p>

<h1 align="center">Memex</h1>

<p align="center">
  一个完全运行在本地的 AI 驱动个人知识管理应用。
</p>

<p align="center">
  <a href="README.md">English</a> •
  <a href="#功能">功能</a> •
  <a href="#快速开始">快速开始</a> •
  <a href="#架构">架构</a> •
  <a href="#参与贡献">参与贡献</a> •
  <a href="#许可证">许可证</a>
</p>

<div align="center">
  <img src="https://github.com/user-attachments/assets/450eb6e5-8adf-4c1f-bc46-a63c9836f22c" width="300" />
</div>

## Memex 是什么？

Memex 是一个本地优先、AI 原生的个人知识管理应用，基于 Flutter 构建。支持文字、图片、语音多模态输入，通过多 Agent 协作自动将你的记录整理为结构化的时间线卡片，提取知识，并生成跨记录的洞察。

所有数据存储在你的设备上。你只需要选择你偏好的模型提供商。

## 功能

### 多模态输入
- 文字、图片、语音一站式输入
- 长按录音，松手即发送
- 自动提取照片 EXIF 信息（时间、GPS 位置）
- 端侧 OCR 文字识别与图像标签分析（Google ML Kit）

### AI 自动整理
- 多 Agent 架构：PKM（知识管理）、卡片生成、洞察分析、评论、记忆摘要、媒体分析等各司其职
- 输入内容自动生成结构化时间线卡片
- 自动打标签、实体提取、关联关系链接
- AI 对话助手，可针对任意卡片或主题展开讨论

### 知识与洞察
- 时间线视图，支持按标签筛选
- 知识库自动归纳主题
- 洞察卡片，跨记录发现关联模式
- 地图视图展示足迹（OpenStreetMap）

### 隐私与本地优先
- 所有数据存储在本地（文件系统 + SQLite）
- 内置本地 HTTP 服务器提供资源访问
- 应用锁（生物识别认证）
- 健康数据集成（HealthKit）
- 无云端依赖，数据不会离开你的设备

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter (Dart ≥ 3.6) |
| 平台 | iOS、Android |
| 数据库 | Drift (SQLite) |
| 状态管理 | Provider + MVVM |
| LLM | Gemini、OpenAI、Claude、Bedrock Claude |
| 地图 | flutter_map + OpenStreetMap |
| 端侧 ML | Google ML Kit（文字识别、图像标签） |
| Agent 框架 | dart_agent_core |

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.6.0
- Xcode（iOS 开发）
- Android Studio（Android 开发）

### 安装

```bash
git clone https://github.com/your-username/memex.git
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

### 配置 LLM

Memex 需要 LLM API Key 来驱动 AI 功能。首次启动后：

1. 点击头像 → 模型配置
2. 选择 API 类型（Gemini / OpenAI / Claude 等）
3. 填入 API Key 和 Base URL
4. 不同 Agent 可以独立配置不同的模型

## 架构

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
│   ├── timeline/         # 时间线
│   ├── knowledge/        # 知识库
│   ├── insight/          # 洞察卡片
│   ├── chat/             # AI 对话
│   ├── calendar/         # 日历视图
│   └── settings/         # 设置
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

## 支持的 LLM 提供商

| 提供商 | API 类型 | 备注 |
|--------|----------|------|
| Google Gemini | Gemini API | 性价比推荐 |
| OpenAI | Chat Completions / Responses API | GPT-4o、o1 等 |
| Anthropic Claude | Claude API | 直接 API 访问 |
| AWS Bedrock | Bedrock Claude | 适合 AWS 用户 |

## 路线图

- [ ] Claude / Gemini OAuth 授权登录（无需手动管理 API Key）
- [ ] 云端同步与备份（iCloud、Google Drive 等）
- [ ] 支持视频和文件附件
- [ ] 可编辑 Memory — 手动整理和修改记忆条目
- [ ] 定期刷新洞察 — 周期性重新分析记录，发现新关联
- [ ] Agent Soul — 自定义 Agent 的行为风格与个性
- [ ] 事件总线 & Hook 系统 — 引入全局事件总线，将数据源接入与 Agent 调度彻底解耦。任意输入源（系统分享面板、URL Scheme、目录监听器、定时调度器）均以类型化事件投递到总线；多维 Hook 注册表在关键生命周期节点拦截事件并触发对应 Agent，无需改动核心逻辑即可自由扩展数据源与调度时机。
- [ ] 扩展市场 & 插件架构 — 云端注册中心作为 Agent、卡片模板、角色配置的扩展市场，用户可一键浏览并安装扩展，热重载生效，无需重启应用。

## 参与贡献

欢迎贡献代码。请先开 Issue 讨论你想要的改动。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 发起 Pull Request

## 许可证

本项目基于 MIT 许可证开源 — 详见 [LICENSE](LICENSE) 文件。
