# Memex 动态 UI Roadmap

截至日期：2026-06-01

配套行业调研见：[dynamic-ui-industry-research.md](dynamic-ui-industry-research.md)

实验分支当前已先落了一版更自由的 `Dynamic Surface` slice：AI 可写
HTML/CSS/JS + Markdown，Memex 用 manifest 中的 Markdown data spec 做确定性
解析，并把已安装 surface 插入 Timeline 内部 PageView 的 Insight/Schedule
之后、用户 tag 之前。这个 slice 不是 timeline card 动态化，而是 page-level
动态页面；内置系统 agent `dynamic-surface-author` 负责从用户需求创建新页面，
每个页面再可通过 `managedSurfaceId` 绑定一个自定义 page agent 维护。

## 0. 目标

Memex 的核心数据是 Markdown/JSON/YAML/SQLite 中的本地个人记录。动态 UI 能力的目标是让用户和 AI 可以围绕这些本地数据创建新的界面和工作流，例如：

- 一个由 AI 持续维护的“每周复盘”tab。
- 一个读取健康/运动记录的 dashboard。
- 一个从 timeline locations 生成的旅行地图。
- 一个面向某个项目文件夹的任务/笔记面板。
- 一个由 agent 在洞察详情页生成的交互图表。
- 一个 schedule/routine 管理界面，不必先走传统开发内置 tab。

这不是要把 Memex 变成任意代码执行器，也不是替代 Flutter 发布流程。推荐目标是：

> 在本地 Markdown 数据源之上，提供一个受权限、schema、组件目录、沙箱和版本控制约束的 Dynamic Surface runtime。AI 可以维护数据和 UI 描述，Memex 负责验证、渲染、执行动作、审计和回滚。

## 1. 当前 Memex 基础

### 1.1 已有优势

Memex 现在已经具备动态 UI 的若干前提：

1. **Markdown-first 数据叙事。** README 已将“Pure Text & Data Freedom”作为产品核心，强调记录最终沉淀为 Markdown 文件，并可随着 AI 能力增强解锁新的交互体验。
2. **Custom Agent System。** 用户可创建 custom agents，配置 event trigger、LLM、Skill、working directory、sync/async execution、dependsOn、retry 等。
3. **Timeline card 已是数据驱动。** `CardData.uiConfigs` 使用 `template_id + data` 描述 UI；`CardRenderer` 支持 native template、HTML template、`legacy_html` 混合。
4. **Insight 已有 widget 抽象。** `KnowledgeInsightCard` 有 `widget_type`、`widget_template`、`widget_data`；`NativeWidgetFactory` 有 registry 挂载 map、chart、gallery、summary 等组件。
5. **HTML/WebView 入口存在。** `HtmlWebViewCard` 已统一处理 HTML 渲染、高度计算、容器配置；`CardRenderer` 能读取 `_System/Templates/<templateId>/view.html` 并渲染为 `legacy_html`。
6. **文件路径集中。** `FileSystemService` 已管理 workspace、Facts、Cards、Templates、KnowledgeInsights、UserSettings、assets 与 `fs://` 替换。
7. **Roadmap 已有插件市场方向。** README 中已有 “Extension Market & Plugin Architecture — agents, UI card templates, persona configs with one-tap install and hot-reload”。

这些基础说明：Memex 不需要先发明完整插件平台；可以把现有 card/template/agent/file-system 机制抽象为更通用的 Dynamic Surface。

### 1.2 当前缺口

现有能力仍不足以安全承载用户/AI 生成的动态 UI：

- HTML template 缺少 manifest、权限、CSP、schema、版本、fallback、安装/卸载/回滚。
- Native widget registry 是内部工程结构，不是 agent 可读的 component catalog。
- `ui_configs` 能描述卡片，但不够描述 custom tab、数据源、动作和刷新策略。
- UI action 缺少统一权限模型，无法安全表达“按钮点击后写某个 Markdown 或更新某个 card”。
- Agent 可以写文件和技能，但缺少 dynamic UI authoring skill、validation tool、preview tool。
- 没有插件包格式把 agent + skill + surface + template + persona configs 串起来。

## 2. 设计原则

### 2.1 Local-first

- 所有 Dynamic Surface 默认安装在用户 workspace 内。
- 原始数据仍是 Markdown/JSON/YAML/SQLite，动态 UI 只是视图和动作层。
- 删除 surface 不应删除原始记录。
- 任何 cloud registry 只能是分发渠道，不是运行依赖。

### 2.2 Least privilege

- Surface manifest 明确声明读哪些 collection、写哪些 path、能调用哪些 action、是否需要外网。
- 默认只读；写操作必须通过 action API。
- UI 不能直接读写 workspace 文件。
- Agent authoring 也必须使用 FilePermissionManager 限定目录。

### 2.3 Host-controlled rendering

- 默认使用 Memex 内置 renderer 和组件目录。
- AI 输出的是声明式 UI / schema / data binding，不是任意 Flutter/Dart code。
- HTML/JS 只作为高表达力沙箱 renderer。
- App shell、root navigation、安全设置、LLM 配置、备份恢复不可被动态 UI 替换。

### 2.4 可审计、可预览、可回滚

- 每个 surface 有 manifest、version、changelog、validation result、install log。
- Agent 生成或修改前先 preview。
- 用户确认后才 enable。
- 每次升级保留前一版本，可 rollback。

### 2.5 AI-friendly but deterministic

- 给 agent 的 authoring API 应简单、明确、可验证。
- Component catalog 要有 schema、示例、反例、截图测试或 snapshot。
- Agent 输出必须通过 validator；validator 不依赖 LLM 判断。

## 3. 核心概念：Dynamic Surface

Dynamic Surface 是一个可安装、可授权、可回滚的动态界面单元。它可以挂载到 timeline card、insight detail、custom tab、settings panel 或 agent workspace preview。

### 3.1 文件布局

建议路径：

```text
workspace/_<userId>/_UserSettings/DynamicSurfaces/
  weekly-review/
    manifest.json
    schema.json
    data_sources.json
    actions.json
    view.rfwtxt
    view.json
    view.html
    fallback.md
    prompt.md
    README.md
    examples/
      sample-data.json
      expected-render.json
      screenshot.png
    versions/
      1.0.0/
      1.1.0/
    migrations/
      001.json
```

不是每个 renderer 都需要所有文件：

- `component_tree_v1`：主要用 `view.json`。
- `rfw_v1`：主要用 `view.rfwtxt`。
- `html_sandbox_v1`：主要用 `view.html`。
- `markdown_fallback_v1`：使用 `fallback.md`。

### 3.2 manifest 草案

```json
{
  "id": "weekly-review",
  "name": "Weekly Review",
  "description": "A local weekly review dashboard generated from timeline cards and notes.",
  "version": "1.0.0",
  "schemaVersion": 1,
  "surfaces": [
    {
      "type": "custom_tab",
      "title": "Weekly",
      "icon": "calendar-days",
      "order": 40
    },
    {
      "type": "insight_detail",
      "match": {
        "tagsAny": ["weekly-review"]
      }
    }
  ],
  "renderer": {
    "type": "component_tree_v1",
    "entry": "view.json",
    "fallback": "fallback.md",
    "minRendererVersion": 1
  },
  "dataSources": [
    {
      "id": "week_cards",
      "type": "timeline_query",
      "range": "last_7_days",
      "projection": ["id", "title", "timestamp", "tags", "summary", "status"]
    },
    {
      "id": "weekly_notes",
      "type": "markdown_collection",
      "path": "PKM/WeeklyReview",
      "mode": "read"
    }
  ],
  "actions": [
    {
      "id": "create_followup_task",
      "kind": "memex.card.create",
      "confirmation": "required",
      "argsSchemaRef": "schema.json#/actions/create_followup_task"
    },
    {
      "id": "append_weekly_note",
      "kind": "memex.markdown.append",
      "confirmation": "optional",
      "argsSchemaRef": "schema.json#/actions/append_weekly_note"
    }
  ],
  "permissions": {
    "read": ["Cards", "Facts", "PKM/WeeklyReview"],
    "write": ["PKM/WeeklyReview"],
    "network": {
      "enabled": false,
      "domains": []
    },
    "requiresConfirmation": ["create_followup_task"]
  },
  "owner": {
    "type": "user",
    "createdByAgent": "weekly-review-agent"
  },
  "compatibility": {
    "minMemexVersion": "0.0.0",
    "platforms": ["ios", "android"]
  }
}
```

### 3.3 Surface 类型

第一阶段不要支持所有挂载点。建议顺序：

| Surface type | 描述 | 优先级 | 原因 |
| --- | --- | --- | --- |
| `card_detail_extension` | 在 card detail 底部展示动态 UI | P0 | 风险低，能复用 card 数据 |
| `insight_detail_extension` | 在 insight detail 展示动态 UI | P0 | 与现有 insight widget 模型接近 |
| `timeline_card` | 作为 timeline card 的 renderer | P1 | 价值高，但列表性能和 fallback 要做好 |
| `custom_tab` | 新增主 tab 内容 | P2 | 产品价值最高，但 app shell 风险更大 |
| `settings_panel` | 设置页扩展 | P3 | 涉及安全/配置，后置 |
| `agent_workspace_preview` | agent 生成 UI 时的预览面板 | P1 | authoring 工作流需要 |

## 4. 推荐架构

### 4.1 Data layer

新增 repository/service，遵守项目架构约束：repository 返回 `Future<Result<T>>`，复杂逻辑放 service，不把业务逻辑塞进 `MemexRouter`。

#### DynamicSurfaceRepository

职责：

- list installed surfaces。
- get surface by id。
- enable/disable。
- install local package。
- uninstall。
- rollback。
- return domain models。

接口草案：

```dart
Future<Result<List<DynamicSurfaceModel>>> listDynamicSurfaces(String userId);
Future<Result<DynamicSurfaceModel>> getDynamicSurface(String userId, String id);
Future<Result<void>> installDynamicSurface(
  String userId,
  DynamicSurfacePackage package,
);
Future<Result<void>> setDynamicSurfaceEnabled(
  String userId,
  String id,
  bool enabled,
);
Future<Result<void>> rollbackDynamicSurface(
  String userId,
  String id,
  String version,
);
```

#### DynamicSurfaceService

职责：

- manifest parse/validate。
- schema validate。
- renderer asset validate。
- permission validation。
- data source resolution。
- package install/migration/rollback。
- surface health check。

原则：

- 只通过 `FileSystemService` 访问 workspace path。
- 不直接依赖 UI。
- 可在 agent task handler 中调用。

#### DynamicSurfaceDataSourceService

负责把 declarative data source 转成 snapshot：

- `timeline_query`
- `card_query`
- `insight_query`
- `markdown_file`
- `markdown_collection`
- `tag_query`
- `schedule_state`
- `health_summary`
- `asset_collection`

Snapshot 应带 metadata：

```json
{
  "sourceId": "week_cards",
  "generatedAt": 1780300800,
  "version": 1,
  "data": [],
  "provenance": {
    "query": {},
    "recordCount": 42,
    "truncated": false
  }
}
```

#### DynamicSurfaceActionService

职责：

- 接收 UI action request。
- 根据 manifest 检查权限和 schema。
- 需要时触发用户确认。
- 调用已有 repository/service。
- emit EventBusService event 让 UI 刷新。
- 写 audit log。

所有 UI 写操作都应走这里，不能让 HTML 或 component 直接改文件。

### 4.2 Renderer layer

#### component_tree_v1

默认推荐 renderer。AI 输出 JSON component tree，Memex 内置 renderer 渲染。

基础 schema：

```json
{
  "type": "Column",
  "props": {
    "spacing": 12
  },
  "children": [
    {
      "type": "MetricRow",
      "props": {
        "items": [
          {"label": "Records", "value": "{{week_cards.count}}"},
          {"label": "Tasks", "value": "{{tasks.openCount}}"}
        ]
      }
    },
    {
      "type": "Markdown",
      "props": {
        "source": "{{weekly_summary.markdown}}"
      }
    }
  ]
}
```

第一批组件：

- Layout：`Column`、`Row`、`Stack`、`Grid`、`Section`、`Divider`、`Spacer`
- Text：`Text`、`Heading`、`Markdown`、`Badge`
- Data：`Metric`、`MetricRow`、`Table`、`KeyValueList`
- Temporal：`Timeline`、`CalendarStrip`、`ScheduleList`
- Visual：`Image`、`Gallery`、`MapPreview`
- Charts：`BarChart`、`LineChart`、`ProgressRing`、`RadarChart`
- Input：`Button`、`Toggle`、`SegmentedControl`、`TextField`、`Select`
- Memex-specific：`CardList`、`FactList`、`TagCloud`、`InsightSummary`、`AgentActivityPanel`

绑定规则：

- 使用简单路径表达式：`{{source.field}}`。
- 不在 v1 支持任意 JS 表达式。
- 列表使用 `repeat`。
- 条件使用受限 `visibleWhen`。

```json
{
  "type": "CardList",
  "repeat": {
    "source": "week_cards.items",
    "as": "card"
  },
  "props": {
    "title": "{{card.title}}",
    "subtitle": "{{card.timestampText}}",
    "tags": "{{card.tags}}"
  },
  "actions": {
    "onTap": {
      "kind": "memex.open_card",
      "args": {"cardId": "{{card.id}}"}
    }
  }
}
```

#### rfw_v1

基于 Flutter RFW 的实验 renderer。

适用：

- 更接近 Flutter widget 的布局。
- 需要比 JSON component tree 更灵活的组合。
- 需要使用 RFW 已有 parser/runtime。

限制：

- 只能用 app 注册的 local widget libraries。
- 不用于复杂导航、custom painter、拖拽、系统权限。
- 所有 event callback 仍转成 action request。

P2 应做 spike 后再决定是否成为长期主 renderer。

#### html_sandbox_v1

用于高表达力、复杂图表、快速实验。

要求：

- 完整 manifest。
- 默认无外网。
- CSP allowlist。
- HTML size limit。
- 禁止动态加载远端 script。
- bridge 默认关闭；需要时按 action allowlist 开启。
- timeline list 中只显示静态 preview 或有限高度。
- 必须有 `fallback.md`。

Bridge v1：

```ts
window.memex.getDataSnapshot()
window.memex.callAction(actionId, args)
window.memex.updateViewState(patch)
window.memex.requestOpenCard(cardId)
window.memex.requestUserConfirm(payload)
window.memex.reportHeight(height)
```

不暴露：

- arbitrary file read/write
- arbitrary shell/code execution
- raw local path
- raw API keys
- unrestricted network
- navigation outside allowed URL schemes

#### markdown_fallback_v1

每个 surface 必须提供。用于：

- renderer 不支持。
- manifest validation fail。
- HTML/RFW runtime crash。
- 用户选择低风险模式。
- 导出到其他 Markdown app。

### 4.3 Component Catalog

把 `NativeCardFactory` / `NativeWidgetFactory` 的隐式注册表变成 agent 可读的公开 catalog。

Catalog entry：

```json
{
  "id": "MetricRow",
  "version": 1,
  "description": "Display 2-4 compact metrics.",
  "surfaces": ["timeline_card", "insight_detail", "custom_tab"],
  "propsSchema": {
    "type": "object",
    "properties": {
      "items": {
        "type": "array",
        "minItems": 1,
        "maxItems": 4
      }
    },
    "required": ["items"]
  },
  "events": [],
  "examples": [
    {
      "props": {
        "items": [
          {"label": "Records", "value": "42"},
          {"label": "Tasks", "value": "7"}
        ]
      }
    }
  ]
}
```

Agent tool：

- `list_component_catalog`
- `get_component_schema`
- `validate_component_tree`
- `render_component_tree_preview`

### 4.4 Agent integration

新增内置 skill：`dynamic_surface_authoring`。

Skill 应要求 agent：

1. 明确用户目标和 surface 类型。
2. 读取可用 data source 和 component catalog。
3. 先生成 manifest + schema + sample data + fallback。
4. 调用 validator。
5. 生成 preview。
6. 展示权限 diff。
7. 等用户批准后 install/enable。
8. 后续修改必须保留 changelog 和 previous version。

建议 tools：

- `DynamicSurfaceCreateDraft`
- `DynamicSurfaceValidate`
- `DynamicSurfacePreview`
- `DynamicSurfaceInstall`
- `DynamicSurfaceEnable`
- `DynamicSurfaceRollback`
- `DynamicSurfaceListComponents`
- `DynamicSurfaceListDataSources`

所有工具都走 `DynamicSurfaceService`，不让 agent 直接写最终安装目录。

## 5. 权限模型

### 5.1 权限类别

| 权限 | 示例 | 默认 | 说明 |
| --- | --- | --- | --- |
| read collection | `Cards`, `Facts`, `PKM/Books` | deny | 只能读声明范围 |
| write path | `PKM/WeeklyReview` | deny | 只能写声明路径 |
| action | `memex.card.create` | deny | 每个 action 单独授权 |
| network | `api.example.com` | deny | 默认无外网 |
| asset | `Facts/assets` | limited | 只给转换后的 local HTTP URL |
| model context | selected data summary | limited | 进入模型上下文的数据要可见 |
| user confirmation | destructive writes | required | 删除、覆盖、外发必须确认 |

### 5.2 权限 UI

安装/升级 surface 时展示：

- 这个 surface 会显示在哪里。
- 读取哪些数据。
- 写入哪些位置。
- 可以执行哪些动作。
- 是否需要网络，以及域名。
- 是否由 agent 自动维护。
- 与上一版本相比新增了什么权限。

### 5.3 审计日志

记录：

- install/enable/disable/uninstall/rollback。
- agent 修改 manifest/view/schema。
- action call。
- permission denial。
- network attempt。
- validation fail。
- user approval/rejection。

日志放 `_System` 或 `_UserSettings/DynamicSurfaces/<id>/audit.log`，具体路径由 FileSystemService 定义。

## 6. Roadmap

### Phase 0：设计冻结与风险边界（1-2 周）

目标：先把边界定义清楚，避免后续实现变成任意动态代码平台。

Deliverables：

- `docs/dynamic-surface-technical-design.md`
- `DynamicSurfaceManifest` JSON schema draft
- renderer 类型定义：`component_tree_v1`、`html_sandbox_v1`、`rfw_v1`、`markdown_fallback_v1`
- data source 类型清单
- action kind 清单
- threat model
- App Store / Play review note draft

关键决策：

- v1 不支持动态 Dart/Flutter code。
- v1 不支持自定义 root tab shell，只支持 custom tab content。
- HTML 默认无外网。
- 所有 writes 必须经 action。

验收：

- 设计文档能回答“AI 生成一个新 tab 需要哪些文件、哪些权限、如何验证、如何回滚”。
- 工程团队认可不破坏现有 MVVM/Provider/data layer 边界。

### Phase 1：Dynamic Surface Manifest + Repository（2-3 周）

目标：让 Memex 能识别、列出、校验、启停 Dynamic Surface，但先不做复杂 renderer。

Scope：

- `domain/models/dynamic_surface_model.dart`
- `data/repositories/dynamic_surface.dart`
- `data/services/dynamic_surface_service.dart`
- `FileSystemService` 增加：
  - `getDynamicSurfacesPath(userId)`
  - `getDynamicSurfacePath(userId, surfaceId)`
  - `readDynamicSurfaceManifest(...)`
  - `writeDynamicSurfaceDraft(...)`
- `MemexRouter` 只做 facade：list/get/install/enable/disable。
- settings debug page 增加 Dynamic Surfaces 列表。

验收：

- 本地放一个 manifest，设置页能看到。
- invalid manifest 有结构化错误。
- enable/disable 状态持久化。
- 不触碰现有 timeline/insight 行为。

测试：

- manifest parser unit tests。
- path traversal tests。
- invalid permissions tests。
- repository Result error handling tests。

### Phase 2：HTML Sandbox MVP（2-4 周）

目标：复用现有 HTML/WebView 能力，先支持动态 insight/card extension。

Scope：

- `html_sandbox_v1` renderer。
- 支持 `static_json` 和 `markdown_file` data source。
- 支持 `view.html` 模板变量替换。
- HTML size limit。
- local asset URL conversion。
- no-bridge mode。
- `fallback.md`。
- detail page 挂载：先做 `insight_detail_extension` 或 `card_detail_extension`。

安全要求：

- 默认禁止外网。
- 禁止未知 scheme。
- WebView JS bridge 不暴露 Memex API。
- 只支持 fragment/template 渲染，不加载远端 script。

示例：

- “读书笔记摘要” insight extension。
- “周报” card/insight extension。

验收：

- 用户能安装一个本地 HTML dynamic surface 并看到渲染结果。
- 禁用后回到 fallback。
- surface crash 不影响原页面。
- 无权限 data source 不会被注入。

测试：

- widget test 覆盖 fallback/error state。
- service test 覆盖 data injection。
- security test 覆盖外网 disabled 和 path traversal。

### Phase 3：Authoring Preview + Agent Tools（3-5 周）

目标：让 AI 可以生成 draft，但必须先 validate/preview，不能静默启用。

Scope：

- Draft directory：
  - `_UserSettings/DynamicSurfaceDrafts/<draftId>/`
- Agent tools：
  - `dynamic_surface_create_draft`
  - `dynamic_surface_validate`
  - `dynamic_surface_preview`
  - `dynamic_surface_install`
- UI：
  - preview page
  - validation report
  - permission diff
  - install confirmation
- 内置 `dynamic_surface_authoring` skill。

Workflow：

1. 用户对 agent 说：“做一个每周复盘页面。”
2. Agent 生成 draft。
3. Validator 产出错误/警告。
4. Preview 渲染 sample data。
5. 用户批准安装。
6. Surface enable。

验收：

- Agent 不能直接写 installed surfaces。
- Draft validation fail 时 install 被拒绝。
- 用户能看到权限和文件 diff。
- 安装后可 rollback。

测试：

- agent tool functional test。
- draft install validation test。
- permission diff snapshot test。

### Phase 4：Component Catalog + component_tree_v1（4-8 周）

目标：建立长期默认的安全原生动态 UI 路线。

Scope：

- `ComponentCatalogService`
- component schema registry。
- `component_tree_v1` parser/validator。
- Flutter renderer。
- 基础组件集：
  - layout/text/markdown/image/metric/list/table/button/toggle/chart
- data binding：
  - path interpolation
  - repeat
  - visibleWhen
- action binding：
  - `memex.open_card`
  - `memex.open_insight`
  - `memex.markdown.append`
  - `memex.card.create`

Agent tools：

- `list_component_catalog`
- `validate_component_tree`
- `preview_component_tree`

验收：

- Agent 可生成一个无需 HTML 的 Weekly Review dashboard。
- 无效 component/props/action 被 validator 拒绝。
- UI 风格与 Memex native components 一致。
- 同一个 data source 能用 HTML renderer 和 component renderer 展示。

测试：

- parser/validator tests。
- renderer widget tests。
- golden tests for sample surfaces。
- action permission tests。

### Phase 5：RFW spike（2-4 周）

目标：验证 Flutter RFW 是否适合作为 component_tree 的底层 runtime 或补充 renderer。

Scope：

- 集成 `rfw` package spike。
- 注册 local widget libraries：
  - core layout
  - Memex card widgets
  - chart wrappers
  - action buttons
- 将 sample Weekly Review 用 `.rfwtxt` 表达。
- 对比：
  - 表达力
  - validation
  - 性能
  - hot update
  - widget test/golden
  - schema 可读性

决策：

- 如果 RFW 足够稳定：作为 `rfw_v1` renderer。
- 如果表达/测试成本高：保留自研 `component_tree_v1`，RFW 作为高级实验 renderer。

验收：

- 有 spike report 和推荐结论。
- 不影响现有 renderer。

### Phase 6：Custom Tab Surface（4-6 周）

目标：支持真正的用户定制 tab，但 tab 内容仍受 Dynamic Surface runtime 管理。

Scope：

- `surface.type = custom_tab`
- RootShell 动态读取 enabled custom tabs。
- 每个 custom tab 有独立 ViewModel。
- 支持 refresh policy：
  - manual
  - on app open
  - on event
  - scheduled
- 支持 empty/loading/error/fallback。
- 支持 tab order 和 icon。

边界：

- Dynamic tab 只能渲染内容区域。
- 不能替换 bottom nav 行为。
- 不能进入 settings/security/backup/private config。

示例：

- Weekly Review tab。
- Project Tracker tab。
- Health Dashboard tab。
- Travel Map tab。

验收：

- 用户安装 surface 后出现新 tab。
- disable 后 tab 消失。
- renderer fail 不影响其他 tabs。
- 数据刷新不阻塞 root shell。

测试：

- root shell tab loading tests。
- dynamic tab ViewModel tests。
- lifecycle/refresh tests。

### Phase 7：Action Bridge + Interactive UI（4-8 周）

目标：让动态 UI 不只是展示，还能安全执行 Memex 动作。

Scope：

- `DynamicSurfaceActionService`
- action schema validation。
- confirmation dialog。
- audit log。
- WebView bridge for HTML。
- Component renderer action binding。
- EventBusService refresh。

第一批 actions：

- `memex.open_card`
- `memex.open_insight`
- `memex.card.create`
- `memex.card.update_ui_config`
- `memex.markdown.append`
- `memex.markdown.create`
- `memex.agent.run`

验收：

- HTML 和 component renderer 都能调用同一个 action layer。
- 未授权 action 被拒绝并记录。
- destructive/write action 会确认。
- action 成功后相关 UI 刷新。

测试：

- action schema tests。
- confirmation flow widget tests。
- WebView bridge allowlist tests。
- audit log tests。

### Phase 8：Agent UI Event Protocol（6-10 周）

目标：让 agent 生成和维护 surface 的过程可见、可恢复、可审批。

Scope：

- 定义 `AgentUiEvent`：
  - `run_started`
  - `message_delta`
  - `tool_call_started`
  - `tool_call_result`
  - `surface_draft_created`
  - `surface_validation_failed`
  - `surface_preview_ready`
  - `approval_requested`
  - `state_patch`
  - `error`
  - `completed`
- 与 `LocalTaskExecutor` task id 关联。
- 支持 app 重启后恢复 task UI。
- UI：
  - progress timeline
  - tool call cards
  - preview diff
  - approve/reject/retry

设计参考：

- AG-UI 的 event-based protocol。
- LangGraph 的 interrupt/time-travel 思路。
- 但先实现 Memex 子集，不追求完整 AG-UI 兼容。

验收：

- 用户能看到 agent 生成 surface 的完整过程。
- 中断后回到 app 能继续看到 draft 状态。
- 用户拒绝后不会安装。
- 用户反馈后 agent 能基于 validation errors 修复。

### Phase 9：Plugin Package + Marketplace（8-12 周）

目标：把 Dynamic Surface 与 custom agent、skill、template、persona config 统一成可分发插件。

Package layout：

```text
weekly-review.memex-plugin/
  memex_plugin.json
  surfaces/
    weekly-review/
  agents/
    weekly-review-agent.json
  skills/
    weekly-review/
      SKILL.md
  templates/
  personas/
  README.md
  signature.json
```

`memex_plugin.json`：

```json
{
  "id": "weekly-review-pack",
  "name": "Weekly Review Pack",
  "version": "1.0.0",
  "description": "Agent + dynamic tab + card templates for weekly review.",
  "components": {
    "surfaces": ["surfaces/weekly-review"],
    "agents": ["agents/weekly-review-agent.json"],
    "skills": ["skills/weekly-review"]
  },
  "permissions": {
    "read": ["Cards", "Facts", "PKM/WeeklyReview"],
    "write": ["PKM/WeeklyReview"],
    "network": false
  },
  "compatibility": {
    "minMemexVersion": "0.0.0"
  }
}
```

Scope：

- 本地 package install。
- signature/hash verification。
- permission diff。
- upgrade/migration/rollback。
- later：cloud registry。

验收：

- 一个插件安装后同时出现 agent、skill、surface。
- 更新时展示新增权限。
- 插件可导出和备份。
- 禁用插件不会删除原始数据。

## 7. 推荐第一刀

不要先做 custom tab。推荐第一刀是：

> Dynamic Surface Manifest + HTML Sandbox MVP + Insight/Card Detail Extension + Authoring Preview。

原因：

- 复用现有 `CardRenderer`、`HtmlWebViewCard`、insight detail。
- 不改 RootShell，风险小。
- 用户价值明确：动态周报、读书复盘、关系图谱、健康摘要。
- 先把 manifest/permission/validation/fallback 做实，后续 native renderer 和 custom tab 都能复用。

第一批 PR：

1. `DynamicSurfaceModel` + manifest schema。
2. `FileSystemService` 增加 dynamic surface paths。
3. `DynamicSurfaceService` + validator。
4. `DynamicSurfaceRepository` + router facade。
5. `html_sandbox_v1` renderer，无 bridge。
6. insight/card detail extension mount point。
7. settings debug page list/enable/disable。
8. sample Weekly Review surface。
9. draft preview + install confirmation。

## 8. 示例场景

### 8.1 Weekly Review

数据源：

- last 7 days timeline cards。
- tags。
- schedule state。
- PKM/WeeklyReview notes。

UI：

- 本周数字摘要。
- 高频主题 tag cloud。
- 未完成任务。
- 情绪/活动趋势。
- AI summary Markdown。
- follow-up task button。

动作：

- append weekly note。
- create follow-up task。
- open source card。

### 8.2 Project Tracker

数据源：

- `PKM/Projects/<project>`。
- related cards by tag。
- task cards。

UI：

- project overview。
- milestone timeline。
- task board。
- notes list。

动作：

- create task。
- append note。
- mark task done。

### 8.3 Travel Map

数据源：

- cards with location。
- image assets。
- tags。

UI：

- map。
- location list。
- gallery。
- route summary。

动作：

- open card。
- create trip note。

### 8.4 Personal Health Dashboard

数据源：

- health records。
- timeline cards tagged health/exercise/sleep。
- schedule/routine state。

UI：

- trend charts。
- routine adherence。
- notes and anomalies。

动作：

- create reminder。
- append health note。

## 9. Open Questions

1. Dynamic surfaces 是否默认进入普通用户设置，还是先放 debug/advanced？
2. `component_tree_v1` 是否自研，还是优先 RFW？
3. HTML sandbox 在 iOS review 中如何表述最稳？
4. Custom tab 数量和排序如何避免破坏主导航？
5. 插件市场是否允许外网 surface，还是初期只允许 local/no-network？
6. Agent 自动维护 surface 的频率如何控制 token/cost？
7. Dynamic UI 的导出格式如何与 Markdown-first 叙事保持一致？
8. 是否需要一套 surface eval：visual snapshot、schema validity、permission minimization、data faithfulness？

## 10. 成功标准

短期：

- 用户能安装一个本地动态 insight/card surface。
- Agent 能生成 draft、preview、validation report。
- HTML surface 无外网、无 direct file write。

中期：

- 用户能用自然语言创建 custom tab。
- 默认 renderer 是 native component tree/RFW。
- Surface action 统一走 permission/action bridge。

长期：

- 插件包可分发 agent + skill + surface。
- 用户个人 Markdown 数据能持续驱动新的 UI 和 workflows。
- Memex 的内置洞察/日程只是默认插件，用户和 AI 可以组合出自己的版本。
