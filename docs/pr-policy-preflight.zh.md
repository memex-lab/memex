# PR 规则预检规则

`Policy Preflight` 是 PR 的确定性规则检查。它不调用 AI，不运行 Flutter，不执行
PR 代码，也不判断代码语义是否正确。它只把 PR 当作数据读取，根据 PR 元数据、
变更文件和 diff 内容识别治理面、信任边界和明显策略违规。

当前阶段是 shadow mode，Preflight 只输出判定结果，不把判定作为合并阻塞依据。

面向人的 Markdown comment 按语言分成两个独立区块：先中文，后 English，不做中英
交替展示。人类可读输出不展示风险分数；JSON 保持稳定英文字段名，并包含
`decision_zh`、`message_zh` 等中文标签和说明。

## 和 Flutter CI 的分工

Preflight 适合放在 `pull_request_target` 里运行，因为它只执行默认分支里的可信脚本，
不会执行 PR 分支代码。它应该只负责治理面和信任边界的硬规则，例如 workflow、review
policy、lint 配置、secrets、签名材料和无法安全 review 的内容。

普通业务代码不应主要依赖目录规则判定风险。代码质量由单独的普通 `pull_request`
CI 负责，因为这类 job 会执行 PR 代码，必须运行在无 secrets、低权限的环境里。当前
仓库使用 `.github/workflows/pr-flutter-quality.yml` 承担这部分检查，并通过
`scripts/compare_flutter_analyze.py` 对 base 与 PR 的 analyzer 输出做 baseline 对比。

推荐质量门禁：

- `flutter analyze --no-pub`：优先要求全绿。
- 如果仓库暂时存在历史 analyzer 问题，则维护 baseline，只要求 PR 不新增 analyzer
  issue；长期目标仍然是全绿。
- `flutter test --no-pub`：要求通过。
- 涉及平台、flavor、release 或构建链路时，再补充对应 compile/build。

后续真正接入低风险快速通道时，建议同时满足：

- Preflight 没有 `reject` 或 `high_risk`。
- Flutter CI 全绿，或者没有新增 analyzer/test 问题。
- AI review 判断合规且低风险。
- 仍然由 maintainer 手动点击合并，不做自动合并。

## 判定等级

### `reject`

PR 命中了客观策略违规，或者无法安全完成检查。作者应该先 rework，再进入正常合并流程。

### `high_risk`

PR 触及 review 规则、仓库自动化、lint 配置等治理面，或者包含无法从 diff 安全确认的
内容，需要 maintainer review。

### `low_risk`

没有确定性规则要求打回或人工审核。警告、AI review 和普通 CI 仍然可以提出额外问题。

## 直接打回规则

这些规则命中后判定为 `reject`。

| 规则 | 如何检查 | 为什么打回 |
| --- | --- | --- |
| Secret 或签名材料 | 变更路径匹配 keystore、`.pem`、`.p8`、`.key`、`key.properties` 或 credential-like pattern | secrets 和签名材料不应该进入 PR review。 |
| generated Dart 缺少源文件 | `*.g.dart`、`*.freezed.dart` 或 `*.gr.dart` 变化，但对应 `.dart` 源文件没有变化 | generated output 不应该手工修改。 |
| 审核控制文件被删除 | 删除 preflight 文档、preflight 脚本或 CODEOWNERS 类控制文件 | 审核控制不应该被静默削弱。 |
| 危险 workflow 模式 | workflow 新增内容包含 `permissions: write-all`、Docker socket、privileged container、`curl | bash` 或 `wget | sh` | workflow 可能暴露 token 或执行不可信代码。 |
| Preflight 采集失败 | 脚本无法读取 git refs、changed files 或 diff context | 无法检查的 PR 不能被当作低风险。 |

## 高风险规则

这些规则命中后判定为 `high_risk`。

| 规则 | 如何检查 | 为什么高风险 |
| --- | --- | --- |
| GitHub 配置或 workflow | 变更 `.github/**` | CI、发布和仓库自动化会改变信任边界。 |
| Analyzer/lint 配置 | 变更 `analysis_options.yaml` | lint 配置会影响 `flutter analyze` 的可信度。 |
| Review policy 控制文件 | 变更 preflight 文档、preflight 脚本或 CODEOWNERS 类文件 | 审核规则本身应该由 maintainer 看一眼。 |
| diff 被截断 | diff 超过配置的 byte 限制 | reviewer 和 AI 都无法看到完整变更。 |
| 二进制文件变化 | 二进制文件变化且不在 `assets/icons/**` 低风险路径下 | 二进制内容无法从 diff 中有效 review。 |

## 警告规则

警告本身不会把 PR 升级成 `high_risk`，只提醒 reviewer 或 AI review 关注。

| 规则 | 如何检查 | 为什么警告 |
| --- | --- | --- |
| generated Dart 和源文件一起变化 | generated file 和对应源文件都发生变化 | 通常代表 codegen，需要确认生成来源。 |
| 本地化文件未成对变化 | 只改了 `lib/l10n/app_en.arb` 或 `lib/l10n/app_zh.arb` 其中一个 | 用户可见文案通常需要中英文同步。 |
| 文件数较多 | changed files 超过关注阈值 | 大范围变更需要更清晰的验证说明。 |
| diff 较大 | 总变更行数超过关注阈值 | 大 diff 需要更清晰的验证说明。 |
| 单文件改动较大 | 单个文件变更行数超过关注阈值 | 集中大改需要 reviewer 留意。 |
| 缺少测试信号 | production Dart 文件变化，但没有测试文件变化，也没有清晰 test plan | PR 可能没问题，但证据不足。 |
| 缺少 PR title | PR title 为空 | review context 不完整。 |
| 缺少 PR body | PR body 为空 | review context 不完整。 |
| 敏感关键词 | 新增行出现 `UserStorage`、`PermissionRule`、`GlobalEventBus`、`apiKey`、`deleteSync` 等关键词 | 这些词不一定有问题，但值得 AI 或 reviewer 留意。 |

## Shadow Mode 行为

在 shadow mode 中：

- `low_risk`、`high_risk`、`reject` 都只作为结果输出。
- workflow 始终成功退出，不阻塞 PR。
- 结果写入 workflow summary，更新 PR comment，并作为 artifact 上传。

规则稳定后，可以由单独的 gate 决定如何把结果接入 required check。
