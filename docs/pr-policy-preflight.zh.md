# PR 规则预检规则

`Policy Preflight` 是 PR 的确定性规则检查。它不调用 AI，不运行 Flutter，不执行
PR 代码，也不判断代码语义是否正确。它只根据 PR 元数据、变更文件和 diff 内容识别
客观风险信号。

当前阶段是 shadow mode，Preflight 只输出判定结果，不把判定作为合并阻塞依据。

面向人的 Markdown 输出是中英双语。JSON 保持稳定的英文字段名，同时包含
`decision_zh`、`message_zh` 等中文标签和说明。

## 判定等级

### `reject`

PR 命中了客观策略违规，或者无法安全完成检查。作者应该先 rework，再进入正常合并流程。

### `high_risk`

PR 可能是合理的，但触及敏感区域，或者改动规模已经不适合走低风险快速通道，需要
maintainer review。

### `low_risk`

没有确定性规则要求打回或人工审核。后续 AI review 和普通 CI 仍然可以提出额外问题。

## 直接打回规则

这些规则命中后判定为 `reject`。

| 规则 | 如何检查 | 为什么打回 |
| --- | --- | --- |
| Secret 或签名材料 | 变更路径匹配 keystore、`.pem`、`.p8`、`.key`、`key.properties` 或 credential-like pattern | secrets 和签名材料不应该进入 PR review。 |
| generated Dart 缺少源文件 | `*.g.dart`、`*.freezed.dart` 或 `*.gr.dart` 变化，但对应 `.dart` 源文件没有变化 | generated output 不应该手工修改。 |
| 审核控制文件被删除 | 删除 preflight 文档、preflight 脚本或 CODEOWNERS 类控制文件 | 审核控制不应该被静默削弱。 |
| 危险 workflow 模式 | workflow 新增内容包含 `permissions: write-all`、Docker socket、privileged container、`curl | bash` 或 `wget | sh` | workflow 可能暴露 token 或执行不可信代码。 |
| Preflight 采集失败 | 脚本无法读取 git refs、changed files 或 diff context | 无法检查的 PR 不能被当作低风险。 |

## 高风险路径规则

这些规则命中后判定为 `high_risk`。

| 路径或区域 | 为什么高风险 |
| --- | --- |
| `.github/**` | CI、发布和仓库自动化会改变信任边界。 |
| `android/**` | 平台权限、签名、flavor、打包会影响发布安全。 |
| `ios/**` | 平台权限、entitlements、签名、打包会影响发布安全。 |
| `pubspec.yaml`、`pubspec.lock` | 依赖变化会影响构建、运行时和供应链风险。 |
| `analysis_options.yaml` | analyzer/lint 变化可能削弱代码质量检查。 |
| `lib/main.dart`、`lib/dependencies.dart`、`lib/router.dart` | App 启动、依赖注册和导航是黄金链路。 |
| `lib/utils/user_storage.dart` | 用户身份、locale、存储、LLM 配置和偏好属于隐私敏感边界。 |
| `lib/data/services/file_system_service.dart` | workspace 路径和本地数据访问影响数据完整性。 |
| `lib/data/services/backup_service.dart` | backup/restore 变化可能导致数据丢失。 |
| `lib/data/services/global_event_bus.dart` | event routing 会影响多个独立消费者。 |
| `lib/data/services/local_task_executor.dart` | 持久后台任务必须正确完成和重试。 |
| `lib/data/services/event_bus_service.dart` | UI refresh event 可能隐藏或暴露旧数据。 |
| `lib/data/services/task_handlers/**` | agent/task processing 会触发慢任务、持久任务或跨模块行为。 |
| `lib/agent/**` | agent prompts、tools、skills、file permissions 会影响安全边界。 |
| Timeline/card rendering factories | Timeline 和卡片渲染是核心用户链路。 |
| Preflight 文档、脚本、控制文件 | 审核策略变化需要 maintainer 看一眼。 |

## 高风险结构规则

这些规则也会判定为 `high_risk`。

| 规则 | 如何检查 | 为什么高风险 |
| --- | --- | --- |
| generated Dart 和源文件一起变化 | generated file 和对应源文件都发生变化 | maintainer 应确认 codegen 是有意且正确的。 |
| 本地化文件未成对变化 | 只改了 `lib/l10n/app_en.arb` 或 `lib/l10n/app_zh.arb` 其中一个 | 用户可见文案需要中英文同步。 |
| 文件数过多 | changed files 超过低风险阈值 | 大范围变更不适合快速通道。 |
| diff 过大 | 总变更行数超过低风险阈值 | 大 diff 难以快速确认。 |
| 单文件改动过大 | 单个文件变更行数超过低风险阈值 | 集中大改需要人工上下文。 |
| diff 被截断 | diff 超过配置的 byte 限制 | reviewer 无法看到完整变更。 |
| 二进制文件变化 | 二进制文件变化且不在 `assets/icons/**` 低风险路径下 | 二进制内容无法从 diff 中有效 review。 |

## 敏感关键词规则

对选定的源码和配置路径，脚本会扫描新增行里的敏感关键词。命中后判定为 `high_risk`。

例子：

- `UserStorage`
- `FilePermissionManager`
- `PermissionRule`
- `GlobalEventBus`
- `LocalTaskExecutor`
- `BackupService`
- workspace path helper，例如 `getCardsPath` 或 `getFactsPath`
- credential-like identifier，例如 `apiKey`、`accessToken`、`secret`、`password`、`credential`
- network-related code，例如 `http`、`dio`、`WebSocket`、`request(`
- destructive file operation，例如 `deleteSync`、`unlinkSync`、`delete(`

## 警告规则

警告本身不会把 PR 升级成 `high_risk`。

| 规则 | 如何检查 | 为什么警告 |
| --- | --- | --- |
| 缺少测试信号 | production Dart 文件变化，但没有测试文件变化，也没有清晰 test plan | PR 可能没问题，但 reviewer 应该看到这个证据缺口。 |
| 缺少 PR title | PR title 为空 | review context 不完整。 |
| 缺少 PR body | PR body 为空 | review context 不完整。 |

## Shadow Mode 行为

在 shadow mode 中：

- `low_risk`、`high_risk`、`reject` 都只作为结果输出。
- workflow 始终成功退出，不阻塞 PR。
- 结果写入 workflow summary，并作为 artifact 上传。

规则稳定后，可以由单独的 gate 决定如何把结果接入 required check。
