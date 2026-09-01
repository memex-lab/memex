# 为 Memex 做贡献

简体中文 | [English](CONTRIBUTING.md)

感谢你愿意帮助 Memex 变得更好。Memex 是一款本地优先、AI 原生的个人知识应用，因此我们对可能影响隐私、本地数据、数据库迁移、Agent 行为以及 LLM 提供商边界的改动会格外谨慎。

提交 Issue 有助于我们了解需求，但并不保证该功能一定会被实现。维护者将 Issue 视为需求信号池，将项目看板视为执行队列，将路线图视为方向声明。

## 贡献方式

- 报告可复现的 Bug。
- 改进文档、本地化和示例。
- 修复小型 UI 问题或移动端平台 Bug。
- 为现有行为补充测试。
- 新增或改进 LLM 提供商适配器。
- 提出 Agent Skill、卡片模板、导入/导出流程以及本地优先的数据工作流。

对于大型产品改动，请先通过 Issue 或讨论说明方向，再开始写代码。

## 需要先设计确认的内容

在提交大型 PR 之前，请先等待维护者反馈，尤其是涉及以下改动时：

- 数据库 Schema、迁移或存储路径。
- Agent 编排、事件总线行为、后台任务调度或 Skill 执行。
- 安全、应用锁、本地文件访问或隐私边界。
- LLM 客户端抽象或提供商认证流程。
- 导航结构、核心时间线/卡片模型，或备份/恢复行为。
- 任何会增加云依赖、遥测、账号系统或服务端存储的功能。

这些领域仍然欢迎社区贡献，但需要在实施前达成共同设计。

## Issue 分类

我们使用标签让 Issue 状态清晰可见：

- `type: bug`、`type: feature`、`type: enhancement`、`type: docs`、`type: question`
- `area: timeline`、`area: ai-agents`、`area: llm-provider`、`area: local-first`、`area: ios`、`area: android`、`area: i18n`、`area: ux`
- `priority: p0`、`priority: p1`、`priority: p2`、`priority: p3`
- `needs info`、`needs reproduction`、`needs product decision`、`accepted`、`ready for contributor`
- `good first issue`、`help wanted`、`not planned`、`duplicate`

Issue 状态通常按以下流程推进：

```text
new issue
-> triage
-> needs info / discussion / accepted / not planned
-> ready for contributor
-> in progress
-> done
```

`accepted` 表示方向符合 Memex 的产品定位。`ready for contributor` 表示范围已足够清晰，可以开始实现。

## 优先级说明

- `priority: p0`：数据丢失、隐私泄露、应用无法启动、核心记录流程损坏。
- `priority: p1`：常见工作流受阻，例如输入、卡片生成、LLM 配置、备份/恢复或应用锁。
- `priority: p2`：有意义的可用性改进、常见平台 Bug，或广泛请求的功能增强。
- `priority: p3`：锦上添花、实验性想法、长期产品方向。

社区需求很重要，但维护者也会综合考虑战略契合度、实现成本、维护风险，以及改动是否保持 Memex 本地优先和隐私优先的原则。

## Pull Request 流程

1. Fork 仓库并创建聚焦的分支。
2. 保持 PR 足够小，便于审查。将无关改动拆分。
3. 遵循代码库中已有的架构：
   - 在屏幕层使用 `ChangeNotifier` ViewModel 的 MVVM。
   - 通过 `lib/config/dependencies.dart` 注册 Repository/Service。
   - 以 `MemexRouter` 作为中央门面。
   - 使用 `Result<T>` 和 `Command` 显式处理异步状态与错误。
   - 不要手动编辑生成的 `*.g.dart` 文件。
4. 在改动行为时，添加或更新所需测试。
5. 填写 PR 模板，UI 改动需附上截图或录屏。

维护者可能会关闭超出范围、过于宽泛或与本地优先产品方向冲突的 PR。我们会尽量尽早说明，避免贡献者投入不必要的时间。

## 测试要求

行为改动应在同一 PR 中提供测试证据。清晰的测试计划是改动的一部分，而不是后续事项。

- 为变更的领域模型、工具类、Repository、Service、任务处理器、Agent、路由决策、数据库行为或非 UI ViewModel 逻辑添加或更新单元测试。
- 为 UI 渲染、状态、导航、对话框或底部弹层、按钮、手势、错误/空态/加载态、本地化或用户交互添加或更新 Widget 测试。
- 当改动跨越 Repository、Service、Router、事件、任务或 Agent 边界，或修复核心流程（如捕获、卡片生成、时间线刷新、备份/恢复或 LLM 配置）时，添加集成或全链路回归测试。
- 不要删除或削弱现有测试来让 PR 通过。如果行为发生变化，请更新断言并在 PR 中说明新的预期。
- 如果未添加或未运行测试，请在 PR 测试计划中说明原因。对于行为改动，仅写「未运行」而没有具体理由是不够的。

## 开发环境

各 Flavor 的构建命令见 [BUILD.md](BUILD.md)。

常用命令：

```bash
flutter pub get
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

iOS：

```bash
cd ios && pod install && cd ..
```

## 代码风格

- 优先沿用现有模式，而不是引入新抽象。
- 除非用户明确配置外部 LLM 提供商，否则保持用户数据本地存储。
- 避免隐藏的遥测或网络请求。
- 为卡片、Agent、记忆、时间线和知识功能使用清晰的领域命名。
- 保持用户可见字符串的本地化同步。
- 不要提交密钥、签名文件、生成的构建产物或本地配置文件。

## 使用编程 Agent

如果你使用 AI 编程 Agent（Cursor、Codex、Claude Code、GitHub Copilot、Gemini、Windsurf、Kiro 等）参与开发，请确保 Agent 在写代码前阅读 `AGENTS.md`。大多数 Agent 会自动查找该文件；如果你的不会，请将其加入上下文，或提示 Agent 先阅读该文件。`AGENTS.md` 包含架构规则、层级边界、命名约定、数据访问模式，以及容易在缺少上下文时违反的单元/Widget 测试要求。

## 安全与隐私

不要公开提交可能暴露私人数据、文件、模型凭证、应用锁行为或备份内容的漏洞。请先私下联系维护者。
