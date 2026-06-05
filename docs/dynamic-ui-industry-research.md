# 动态 UI 生成行业调研报告

截至日期：2026-06-01

## 0. 摘要

“动态 UI 生成”已经从早期的“LLM 写一段 HTML/React 代码”分化成三类产品和技术路线：

1. **Prompt-to-app / prompt-to-code 产品**：v0、Figma Make、Lovable、Bolt、Replit Agent、Claude Artifacts 等，让用户用自然语言生成原型、Web app、dashboard 或交互组件。它们的核心价值是降低开发门槛和缩短从 idea 到可运行原型的距离。
2. **Agent runtime UI 协议和框架**：OpenAI Apps SDK / MCP Apps、AG-UI、A2UI、LangGraph Generative UI、OpenUI、Vercel AI SDK Generative UI 等，试图解决 agent 与用户界面之间的长期状态同步、工具调用、交互审批、组件渲染和安全沙箱问题。
3. **Server-driven / backend-driven UI**：Flutter RFW、Adaptive Cards、JSON/RFW/OpenUI-like DSL 等，用声明式 schema 让 host app 在运行时渲染 UI，但实际组件、动作和权限仍由宿主应用控制。

行业共识正在变得清晰：**生产可用的动态 UI 不应等同于任意代码执行**。更稳的形态是“模型/agent 产生结构化数据或受限组件树，宿主应用验证后渲染”；只有在需要高表达力时，才把 HTML/JS 放入强沙箱，并通过有限 bridge 调用宿主能力。

对移动端本地应用尤其如此。iOS/Android 对下载和执行动态代码有明确审核和安全风险，Flutter 也不适合把整个 app shell 变成 remote UI。动态能力更适合落在卡片、洞察、dashboard、表单、局部 tab 内容、任务进度、agent 交互面板这些“surface”内。

## 1. 定义与范围

本报告讨论的动态 UI 指：

- AI 或 agent 能在运行时决定使用什么界面表达信息。
- UI 可由用户本地数据、工具结果、Markdown 文件、schema、HTML、组件目录或 agent 状态驱动。
- UI 能支持交互：筛选、选择、确认、编辑、执行动作、进入详情或反馈给 agent。
- UI 可以长期保存、版本化、回滚、迁移，而不是一次性的聊天回答。

不把以下内容当成本文核心：

- 单纯让 LLM 生成一张静态图片或 SVG。
- 传统 CMS 的页面模板配置。
- 只在开发阶段生成代码、最终仍走完整发布流程的普通 AI 编程助手。
- 绕过平台审核的动态 Dart/Swift/Kotlin/native binary 下载执行。

## 2. 行业版图

### 2.1 Prompt-to-app / prompt-to-code 产品

这类产品的共同点是：用户通过自然语言描述目标，系统生成代码、页面、原型或应用，并提供预览、部署、修复和迭代能力。

#### v0 by Vercel

官方定位：v0 是一个 AI agent，帮助用户用 prompt 创建真实代码、full-stack apps、agents 和 live prototypes；可以部署到生产或打开 PR 进入 review。v0 docs 也强调它可以连接后端、生成 data-driven apps，并使用 Next.js、Tailwind、shadcn/ui 等现代 Web stack。来源：[v0 docs](https://v0.app/docs)、[v0 full-stack apps](https://v0.app/docs/full-stack-apps)

产品特征：

- 强项是生成 React/Next.js UI 和 full-stack web app。
- 支持从文字、截图、文件、Figma 等输入开始。
- 结果是可继续编辑的真实代码，适合开发团队接管。
- 与 Vercel 部署、数据库、GitHub/PR 工作流连接紧密。

对动态 UI 的启发：

- “生成-预览-诊断-修复-部署/PR”的闭环是动态 UI authoring 工具应学习的体验。
- 高质量 UI 生成需要设计系统、组件库和运行环境约束，不是只靠模型自由发挥。
- 对宿主应用来说，v0 更像“生成插件/界面包的工作台”，不是移动端 runtime 本身。

局限：

- 输出主要是 Web 代码；在 iOS/Android Flutter app 中直接运行这些代码会落入 WebView 沙箱或动态代码风险。
- 成品仍需要工程审查、依赖管理和部署；不适合让普通移动端用户无限制安装代码。

#### Figma Make

官方定位：Figma Make 是 AI-driven prompt-to-code 工具，可把 idea 或现有 Figma design 变成 functional prototypes、web apps、interactive UI；Figma 也说明 Make 使用 TypeScript files 构造 React app，并可连接 Supabase。来源：[Figma Make](https://www.figma.com/make/)、[Figma developer docs](https://developers.figma.com/docs/code)、[Figma Supabase backend help](https://help.figma.com/hc/en-us/articles/32640822050199-Add-a-backend-to-a-functional-prototype-or-web-app)

产品特征：

- 从设计工具内部出发，强调“设计稿/原型 -> 可交互实现”。
- 对产品经理、设计师、研究验证很友好。
- 能 prompt 修改局部 UI、连接 Supabase 后端、构建更接近真实 app 的原型。

对动态 UI 的启发：

- 动态 UI 不只是代码问题，也是“用户如何表达需求、如何预览、如何局部修改”的产品问题。
- 从现有设计/数据/文档出发，比纯空白 prompt 更稳定。
- 对 Memex 类应用，未来可以支持“从我现有记录生成一个 dashboard，并用对话局部调整布局”。

局限：

- 运行目标是 Web app/React 原型，不是本地 Flutter runtime。
- 生成结果进入生产仍需要工程治理和安全审查。

#### Lovable

官方定位：Lovable 是 full-stack AI development platform，用自然语言构建、迭代和部署 Web apps，强调 real code、security、enterprise governance；FAQ 也称它让任意技能水平的用户用自然语言创建 full-stack websites，并支持 API 集成、Supabase/Lovable Cloud、GitHub 等。来源：[Lovable docs](https://docs.lovable.dev/)、[Lovable FAQ](https://docs.lovable.dev/introduction/faq)、[Lovable Supabase integration](https://docs.lovable.dev/integrations/supabase)

产品特征：

- 面向非技术用户和创业/MVP 场景。
- Chat interface + real code + hosted backend/deployment。
- 与 Supabase、GitHub、第三方 API 深度连接。
- 不只是 UI，还生成数据库 schema、auth、serverless functions 等。

对动态 UI 的启发：

- 用户真正想要的往往不是一个组件，而是“一个能持续解决问题的小应用”。
- 动态 UI 如果要有长期价值，需要把数据、权限、动作、部署/安装、版本、回滚一起产品化。
- 对普通用户必须有 guided workflow：先问目标、再确认数据源、再预览、再启用。

局限：

- 云端/hosted web-first，与 local-first、BYO LLM、移动端本地数据隔离存在天然差异。
- 一旦生成 backend 和 auth，复杂度迅速上升；对 Memex 来说不应在第一阶段复制 full-stack builder。

#### Bolt.new / StackBlitz WebContainers

官方定位：Bolt 是 AI-powered builder for websites, web apps, and mobile apps；StackBlitz WebContainers 是浏览器内执行 Node.js apps 和 OS commands 的 runtime。来源：[Bolt docs](https://support.bolt.new/building/getting-started)、[WebContainer API docs](https://developer.stackblitz.com/platform/api/webcontainer-api)、[StackBlitz WebContainers intro](https://developer.stackblitz.com/guides/user-guide/what-is-stackblitz)

产品特征：

- 浏览器内 dev environment，可安装依赖、运行 Node、预览 app。
- AI agent 能写代码、运行、修复。
- 与 WebContainers 结合后，用户不需要本地开发环境。

对动态 UI 的启发：

- 安全运行用户/AI 生成代码的关键不是“相信模型”，而是强沙箱和可重置环境。
- 预览和测试环境应与真实数据隔离；把生成产物转正前要有验证 gate。
- 对 Memex 来说，如果未来要支持 HTML/JS 动态 UI，应该更像 WebContainer/iframe sandbox 的思想，而不是直接接入宿主能力。

局限：

- WebContainers 依赖浏览器能力和 Node/Web stack；不适合直接作为 Flutter iOS/Android runtime。
- 大型项目在移动端资源和兼容性上会遇到限制。

#### Replit Agent

官方定位：Replit Agent 可从 plain language 把想法变成 apps、designs、slides、data dashboards、files/documents，并能规划、创建、检查、修复和部署。来源：[Replit Agent docs](https://docs.replit.com/core-concepts/agent/)、[Replit AI docs](https://docs.replit.com/replitai/getting-started)

产品特征：

- 云 IDE + AI agent + deployment。
- 支持 App Testing、checkpoint、rollback、设计画布等工作流。
- 重点不只是生成代码，还包括运行、测试、修复、部署。

对动态 UI 的启发：

- checkpoint/rollback 是动态 UI authoring 的必备能力。
- agent 必须能看到错误、运行验证，并基于反馈修复。
- 对用户要暴露“当前 agent 改了什么、为什么、能否撤销”。

局限：

- Replit 是 cloud development + hosting 平台；Memex 是本地优先移动应用。
- 适合学习 agent authoring workflow，不适合照搬 runtime。

#### Claude Artifacts

官方定位：Artifacts 让 Claude 生成可编辑、可迭代、可复用的 standalone content，包括 Markdown/plain text、code snippets、single-page HTML、SVG、diagrams、interactive React components。来源：[Anthropic Artifacts help](https://support.anthropic.com/en/articles/9487310-what-are-artifacts-and-how-do-i-use-them)、[Artifacts announcement](https://www.anthropic.com/news/artifacts)

产品特征：

- 对话旁边出现独立 artifact panel。
- HTML/React/SVG/Markdown 等内容可即时查看和迭代。
- 更像“聊天中的小应用/小文档/可交互工具”。

对动态 UI 的启发：

- 用户对“一段对话生成一个可交互界面”已经有心理模型。
- artifact 应作为独立对象保存、命名、版本化，而不是藏在聊天消息里。
- 对 Memex 来说，insight/detail/custom tab 都可以类比为本地 artifact。

局限：

- Claude host 提供了专有运行环境；外部应用要复刻需要自己实现 sandbox、数据桥、权限和持久化。

### 2.2 Agent runtime UI / 协议层

这类工作更接近“动态 UI 的底层协议”。它们不只是生成页面，而是在解决 agent 和 UI 如何长期协作。

#### OpenAI Apps SDK / ChatGPT Apps

OpenAI 官方说明 Apps SDK 是 preview toolkit，基于 MCP，让开发者定义 app 的 chat logic 和 interface，并在 ChatGPT 内运行。Apps in ChatGPT 可以响应自然语言，并包含 chat 内的 interactive interfaces。来源：[OpenAI launch post](https://openai.com/index/introducing-apps-in-chatgpt/)、[Build with Apps SDK](https://help.openai.com/en/articles/12515353-build-with-the-apps-sdk.iso)

技术机制：

- App 由 MCP server + UI resource/tool metadata 组成。
- UI component 在 ChatGPT iframe 中运行。
- UI 通过 MCP Apps bridge 使用 JSON-RPC over `postMessage` 与 host 通信。
- Tool results 通过 `structuredContent` 提供给 UI。
- UI 可调用 tool、发送 follow-up message、更新 model-visible context。
- 新 app 推荐使用 MCP Apps standard bridge；只有需要 ChatGPT 特有能力时才使用 `window.openai` extensions。来源：[Build your ChatGPT UI](https://developers.openai.com/apps-sdk/build/chatgpt-ui)、[MCP Apps compatibility](https://developers.openai.com/apps-sdk/mcp-apps-in-chatgpt)

状态模型：

- authoritative business data 在 MCP server/backend。
- ephemeral UI state 在 widget instance。
- durable cross-session state 在 backend/storage。
- widget 是 message-scoped。来源：[Apps SDK state management](https://developers.openai.com/apps-sdk/build/state-management)

安全模型：

- widget 在 sandboxed iframe 中运行，有 CSP。
- 不应把 secrets/tokens 放入 component props。
- 写操作需要 server-side validation 和 human confirmation。
- 要假设 prompt injection 和 malicious inputs 会到达 server。来源：[Apps SDK security](https://developers.openai.com/apps-sdk/guides/security-privacy)

对行业的意义：

- 把“工具返回文本”升级为“工具返回可交互 UI”。
- 把 UI 数据、tool action、model context 纳入同一个 agent runtime。
- 为 MCP Apps 标准提供了早期样板。

#### MCP Apps

MCP Apps 是 MCP 的官方 UI extension。官方 MCP blog 描述：tool 可返回 interactive UI components，直接在 conversation 内渲染 dashboards、forms、visualizations、multi-step workflows 等；tool 用 `_meta.ui.resourceUri` 指向 UI resource，host 获取资源，在 sandboxed iframe 渲染，并用 JSON-RPC over `postMessage` 双向通信。来源：[MCP Apps blog](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)

核心机制：

- Server 注册 `ui://` HTML resource。
- Tool descriptor 包含 `_meta.ui.resourceUri`。
- Host fetches resource and renders it in iframe。
- iframe 和 host 用 JSON-RPC bridge 通信。
- Host 不支持 MCP Apps 时仍应有 text fallback。

价值：

- 从 OpenAI/Claude/VS Code/Goose/Postman 等 host 之间抽出可移植 UI 模型。
- 对 app/agent 集成来说，UI 不再是每个 host 的私有扩展。
- 让工具输出从“文本墙”变成“host 内可操作界面”。

风险与限制：

- iframe sandbox 降低风险但不消灭风险；仍需要 CSP、permission、bridge allowlist、tool validation。
- 对移动端 Flutter 来说，完整 MCP Apps host 不是必要第一步，可以先实现一个子集。

#### AG-UI

AG-UI 官方定义为 open, lightweight, event-based protocol，标准化 AI agents 如何连接 user-facing applications。它是 agent backend 与 frontend 的双向连接层，而不是 UI DSL 本身。AG-UI 文档明确区分：A2UI 是 generative UI specification，允许 agents deliver UI widgets；AG-UI 是 Agent-User Interaction protocol，负责连接 agentic frontend 和 backend。来源：[AG-UI overview](https://docs.ag-ui.com/introduction)

核心 building blocks：

- streaming chat
- typed attachments / multimodality
- static generative UI
- declarative generative UI
- shared state with streamed diffs
- frontend tool calls
- backend tool rendering
- human-in-the-loop interrupts
- sub-agent composition
- agent steering
- tool output streaming
- custom events

对动态 UI 的价值：

- 适合长任务 agent：进度、tool call、状态变更、用户审批、取消、恢复。
- 适合把 agent activity 从文本日志变成可交互 UI。
- 适合作为 Memex 这类 event-driven local app 的 UI event protocol 参考。

限制：

- AG-UI 本身不规定具体组件树怎么写；需要和 A2UI、OpenUI、自定义 component schema 或 HTML sandbox 结合。
- 当前生态主要是 Web/React/CopilotKit/LangGraph 等，Flutter 需要自己实现 client 或映射层。

#### A2UI

A2UI 协议的目标是从 agent 发送的 JSON object stream 动态渲染 UI；它强调 UI structure 与 application data 分离，并支持 progressive rendering。来源：[A2UI protocol docs](https://a2ui.org/specification/v0_10/docs/a2ui_protocol/)

核心价值：

- 比 raw HTML 更安全：agent 输出结构化 operations，而不是任意代码。
- 支持 progressive UI：agent 可以边生成边让界面逐步出现。
- 与 AG-UI 可以互补：A2UI 负责 UI 描述，AG-UI 负责 agent/frontend event transport。

对移动端的启发：

- Memex 可以定义自己的 `component_tree_v1`，先不用完整 A2UI，但应吸收“结构/数据分离、schema 校验、渐进渲染”的思想。

#### Vercel AI SDK Generative UI

Vercel AI SDK 3.0 曾发布 RSC-based generative UI，把 LLM/tool calls 映射到 streaming React Server Components。后续 Vercel 模板页面提示 AI SDK RSC development paused；Vercel Academy 现在更强调 tool results 渲染为 custom React components、multi-step tool calling 和 message parts。来源：[AI SDK 3.0 blog](https://vercel.com/blog/ai-sdk-3-generative-ui)、[RSC GenUI template](https://vercel.com/new/templates/next.js/rsc-genui)、[Vercel Academy](https://vercel.com/academy/ai-sdk/multi-step-and-generative-ui)

重要启发：

- “LLM 选择工具 -> 工具返回结构化结果 -> 前端用定制组件渲染”是稳定路线。
- 直接 streaming raw UI 框架特性可能受平台演进影响；生产系统最好有自己的数据和组件契约。
- 动态 UI 不是让模型写 UI，而是让模型在工具、数据、组件之间做决策。

#### LangGraph Generative UI / Agent Chat UI

LangGraph docs 描述 generative UI 让 agents 超越文本，生成 rich UIs；React components 可与 graph code 共置，并通过 `useStream` 接入 Agent Chat UI。LangChain 的 Agent Chat UI 支持 tool visualization、interrupts、state forking、time-travel debugging 等。来源：[LangGraph Generative UI](https://docs.langchain.com/langgraph-platform/generative-ui-react)、[Agent Chat UI](https://docs.langchain.com/oss/python/langchain/ui)

启发：

- Agent state 和 UI component 应共享 graph/thread/run 的生命周期。
- Human-in-the-loop、time travel、branching、interrupts 对复杂 agent UI 是刚需。
- UI 组件可以延迟加载，并按 agent/tool result 选择。

局限：

- 与 LangGraph/LangSmith/React ecosystem 绑定较深；Flutter 可学习状态模型，不宜直接搬迁。

#### OpenUI

OpenUI 是 LangChain 文档中的 generative UI library，让模型生成 openui-lang declarative format；Renderer 将 cards、charts、tables、tabs、forms 等转为 React UI。来源：[OpenUI docs](https://docs.langchain.com/oss/python/langchain/frontend/integrations/openui)

启发：

- 组件 DSL 可以比 JSON 更节省 token、更适合模型输出。
- 适合数据密集型 reports/dashboards。
- 宿主 renderer 仍掌控最终组件和样式，兼顾灵活性和安全。

对移动端启发：

- Memex 可定义一个面向 LLM 的简洁 DSL，但最终应编译成 JSON/RFW/component tree 并校验。

### 2.3 Server-driven UI / 声明式 UI 标准

#### Flutter Remote Flutter Widgets (RFW)

RFW 官方说明：它把运行时获得的 widget descriptions、运行时数据、编译期预置 widgets 和编译期逻辑组合起来，在运行时生成 widget tree。远程 widget library 可用 `.rfwtxt` 文本格式或二进制格式传输。来源：[RFW pub.dev](https://pub.dev/packages/rfw)

关键限制：

- RFW 只能使用宿主 app 预置的 widget，不会创造新的 Flutter widget class。
- 不适合 page transitions、复杂 drag/drop、custom painters、改变 navigation、把整个 app 迁移到 remote UI。
- 适合 message-of-the-day、announcements、database front-end、search result cards、自定义数据编辑器。

对移动端动态 UI 的意义：

- 这是 Flutter 生态中最接近“安全动态原生 UI”的官方路线。
- 它与 App Store/Play 审核更兼容，因为动态内容是声明式描述，执行能力来自 app 内置 renderer 和预置组件。
- 对 Memex 的卡片、洞察、dashboard、表单非常契合。

#### Adaptive Cards

Adaptive Cards 是 Microsoft 的 platform-agnostic UI exchange format；payload 用 JSON 描述，host app 按自己的样式渲染。来源：[Adaptive Cards overview](https://learn.microsoft.com/en-us/adaptive-cards/)

启发：

- 同一声明式 payload 可在不同宿主中保留语义，但视觉适配宿主。
- 适合通知、审批、表单、摘要卡片。
- schema 和 host capability negotiation 是长期兼容的关键。

限制：

- 表达力偏卡片和轻交互，不适合复杂 dashboard 或全页面体验。

### 2.4 研究工作和评估方向

#### Macaron-A2UI

arXiv 论文《Macaron-A2UI: A Model for Generative UI in Personal Agents》指出，个人 agent 处理复杂用户任务时，静态纯文本聊天成为瓶颈；generative UI 是必要的新 interface layer，可根据交互上下文实时合成控件、选项和状态。来源：[arXiv:2605.24830](https://arxiv.org/abs/2605.24830)

启发：

- Personal agent 的 UI 不是固定菜单，而应根据用户数据、任务阶段、上下文动态变化。
- 但这种动态变化需要 benchmark、evaluation protocol 和专门模型能力。
- 对 Memex 这类个人生活记录 app，personal agent + dynamic UI 是自然方向。

#### PromptInfuser

PromptInfuser 是一个 Figma plugin 研究，让设计师把 UI elements 与 prompt inputs/outputs 连接，生成 semi-functional mockups。来源：[arXiv:2310.15435](https://arxiv.org/abs/2310.15435)

启发：

- AI UI 不只是自动生成界面，也可以把现有 UI 元素和 AI outputs 绑定，变成半功能原型。
- 对 Memex 来说，可以把现有 NativeCardFactory/NativeWidgetFactory 组件作为“可绑定组件”，由 agent 填数据而不是从零画 UI。

#### Prompt-to-app benchmark / full-stack agent systems

近期研究开始评估 Replit、Bolt、Firebase Studio 等 prompt-to-app systems，以及 full-stack agentic coding 的测试和环境 scaffold。来源：[From Prompt to Product](https://arxiv.org/abs/2512.18080)、[FullStack-Agent](https://arxiv.org/abs/2602.03798)、[app.build](https://arxiv.org/abs/2509.03310)

启发：

- prompt-to-app 的难点不在第一次生成，而在可靠性、测试、修复、环境、部署和长期维护。
- 动态 UI 平台也需要 eval：schema validity、visual correctness、权限最小化、数据准确性、可恢复性。

## 3. 横向技术模式比较

| 模式 | 代表 | 表达力 | 安全性 | 移动端适配 | 适合场景 | 主要风险 |
| --- | --- | --- | --- | --- | --- | --- |
| Raw HTML/JS sandbox | Claude Artifacts、MCP Apps、Apps SDK widgets | 高 | 中，依赖 sandbox/CSP/bridge | WebView 可做，但需限制 | 图表、原型、复杂可视化 | 外网泄露、XSS、性能、审核风险 |
| Tool-result -> native component | Vercel Academy pattern、Memex current cards | 中 | 高 | 很好 | 卡片、摘要、列表、审批 | 灵活性有限 |
| Declarative component DSL | OpenUI、A2UI、Adaptive Cards | 中高 | 高 | 需要 Flutter renderer | dashboard、form、report | schema 设计复杂 |
| RFW / server-driven Flutter | Flutter RFW | 中 | 高 | 原生 Flutter | 卡片、数据编辑器、搜索结果 | 组件目录受限 |
| Full prompt-to-code app | v0、Lovable、Bolt、Replit | 很高 | 低到中，取决于审查 | 不适合作 runtime | 开发、原型、生成插件包 | 任意代码、依赖、安全、审核 |
| Agent UI event protocol | AG-UI、LangGraph streams | 不是 UI 本身 | 取决于 action model | 可实现 | 长任务、进度、审批、共享状态 | 协议复杂、状态一致性 |

## 4. 安全与平台约束

### 4.1 App Store / Play 动态代码约束

Apple App Review Guidelines 2.5.2 要求 app self-contained，不得下载、安装或执行会引入/改变 app 功能的代码；Google Play 也限制从 Google Play 以外来源下载 executable code，并对运行时加载解释型语言代码提出风险要求。来源：[Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)、[Google Play policy](https://support.google.com/googleplay/android-developer/answer/15402170)、[Android dynamic code loading risks](https://developer.android.com/privacy-and-security/risks/dynamic-code-loading)

对移动端动态 UI 的含义：

- 不应下载 Dart/Swift/Kotlin/native executable code。
- 不应把远端脚本作为 app 功能更新主机制。
- 可行路线是：动态内容是数据、schema、HTML document 或用户生成内容，执行能力由 app 内置 renderer 和有限 sandbox 提供。
- 对外发布时需要在审核说明里清晰描述：动态 UI 是用户生成内容/本地文档渲染，不是远端下发 app code。

### 4.2 Prompt injection 与 UI/action 风险

动态 UI 最大风险不是“显示错了”，而是“界面诱导用户或模型执行不该执行的动作”：

- HTML 偷发用户数据到外网。
- UI 伪装成系统确认按钮。
- Agent 读到恶意 Markdown 后生成越权 action。
- 组件 schema 注入未知 props 或 action id。
- Tool result 内含 prompt injection，影响后续 model-visible context。

缓解原则：

- 所有 data source 先经权限检查和 projection。
- UI 只拿当前 surface 所需最小数据。
- action 必须声明 args schema、权限和确认等级。
- HTML bridge 只暴露 allowlist API。
- 默认禁止 network；需要外网时用户显式授权并展示域名。
- 所有动态 surface 必须有 Markdown/text fallback。
- 安装、升级、启用、外网、写操作都有审计日志。

## 5. 结论：行业对 Memex 的主要启发

1. **不要把动态 UI 做成任意代码运行平台。** 成熟路线是 schema/component/action/permission/sandbox。
2. **HTML 是强表达力实验层，不是默认长期层。** 默认应是 native declarative/RFW 或 tool-result-to-component。
3. **动态 UI 需要 artifact 化。** 每个界面都应有 manifest、版本、数据源、权限、渲染器、fallback、示例、回滚。
4. **Agent 需要 authoring workflow。** 用户应看到 plan、preview、diff、validation、approval，而不是 agent 静默改文件。
5. **长期竞争力来自数据闭环。** v0/Lovable 生成的是通用 app；Memex 可以生成贴合个人 Markdown、timeline、facts、schedule、memory 的个人界面。
6. **AG-UI/MCP Apps 是协议参考，不是必须完整照搬。** Memex 可以先实现更小的 local-first subset：structured data + component tree + action bridge + event stream。

## 6. Sources

- OpenAI Apps SDK and ChatGPT Apps: <https://openai.com/index/introducing-apps-in-chatgpt/>, <https://help.openai.com/en/articles/12515353-build-with-the-apps-sdk.iso>, <https://developers.openai.com/apps-sdk/build/chatgpt-ui>
- OpenAI Apps SDK state/security: <https://developers.openai.com/apps-sdk/build/state-management>, <https://developers.openai.com/apps-sdk/guides/security-privacy>
- MCP Apps: <https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/>
- AG-UI: <https://docs.ag-ui.com/introduction>
- A2UI: <https://a2ui.org/specification/v0_10/docs/a2ui_protocol/>
- Vercel v0: <https://v0.app/docs>, <https://v0.app/docs/full-stack-apps>
- Vercel AI SDK Generative UI: <https://vercel.com/blog/ai-sdk-3-generative-ui>, <https://vercel.com/new/templates/next.js/rsc-genui>, <https://vercel.com/academy/ai-sdk/multi-step-and-generative-ui>
- Figma Make: <https://www.figma.com/make/>, <https://developers.figma.com/docs/code>, <https://help.figma.com/hc/en-us/articles/32640822050199-Add-a-backend-to-a-functional-prototype-or-web-app>
- Lovable: <https://docs.lovable.dev/>, <https://docs.lovable.dev/introduction/faq>, <https://docs.lovable.dev/integrations/supabase>
- Bolt and StackBlitz WebContainers: <https://support.bolt.new/building/getting-started>, <https://developer.stackblitz.com/platform/api/webcontainer-api>, <https://developer.stackblitz.com/guides/user-guide/what-is-stackblitz>
- Replit Agent: <https://docs.replit.com/core-concepts/agent/>, <https://docs.replit.com/replitai/getting-started>
- Claude Artifacts: <https://support.anthropic.com/en/articles/9487310-what-are-artifacts-and-how-do-i-use-them>, <https://www.anthropic.com/news/artifacts>
- LangGraph / LangChain UI: <https://docs.langchain.com/langgraph-platform/generative-ui-react>, <https://docs.langchain.com/oss/python/langchain/ui>, <https://docs.langchain.com/oss/python/langchain/frontend/integrations/openui>
- Flutter RFW: <https://pub.dev/packages/rfw>
- Adaptive Cards: <https://learn.microsoft.com/en-us/adaptive-cards/>
- Platform policy: <https://developer.apple.com/app-store/review/guidelines/>, <https://support.google.com/googleplay/android-developer/answer/15402170>, <https://developer.android.com/privacy-and-security/risks/dynamic-code-loading>
- Research: <https://arxiv.org/abs/2605.24830>, <https://arxiv.org/abs/2310.15435>, <https://arxiv.org/abs/2512.18080>, <https://arxiv.org/abs/2602.03798>, <https://arxiv.org/abs/2509.03310>
