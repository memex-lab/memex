# PR 规则预检规则

`Policy Preflight` 是 PR 的确定性规则检查。它不调用 AI，不运行 Flutter，不执行
PR 代码，也不判断代码语义是否正确。它只把 PR 当作数据读取，根据 PR 元数据、
变更文件和 diff 内容识别治理面、信任边界和客观硬规则违规。

打回会使治理作业失败，高风险交维护者判断。是否强制阻止合并由仓库分支保护单独配置。

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
`scripts/compare_flutter_analyze.py` 和 `scripts/compare_flutter_test_failures.py`
对 base 与 PR 的 analyzer/test 输出做 baseline 对比。

Flutter 质量检查运行工具测试、核对各语言的 ARB 键，并运行 `scripts/verify_pr.py` 按改动选出的回归场景。工作流以 base 提交为基线，比对 analyzer 发现和 Flutter 测试失败。出现新增问题、基线结果不完整或选中的场景失败时，质量检查无法通过。

## 进入本地 Codex 审查

开放且非草稿的 PR 在两项预检均通过、报告与当前 PR 编号及 base/head 提交匹配、当前版本待审时进入本地队列。`low_risk` 和 `high_risk` 都可以入队，`reject` 会阻止入队。

本地 Codex 发表审查评论，并为本次审过的 PR、base、head、标题和正文记录结论。治理判定为高风险，或审查工具命中敏感改动时，记录 `passed` 前须由作者以外、有仓库写权限的维护者批准当前 head。最终由维护者决定是否合并。领取和记录结论的命令见[本地审查手册](local-pr-review.md)。

## 判定等级

### `reject`

PR 命中了客观策略违规，或者无法安全完成检查。作者应该先 rework，再进入正常合并流程。

### `high_risk`

PR 触及 review 规则、仓库自动化、lint 配置等治理面，或者包含无法从 diff 安全确认的
内容，需要 maintainer review。

### `low_risk`

治理预检未发现策略风险。该 PR 仍须经过 Flutter 验证和本地 Codex 审查。

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
| diff 被截断 | diff 超过配置的 byte 限制，目前默认 1,000,000 bytes | reviewer 和 AI 都无法看到完整变更。 |
| 二进制文件变化 | 二进制文件变化且不在 `assets/icons/**` 低风险路径下 | 二进制内容无法从 diff 中有效 review。 |

## 不负责的范围

Policy Preflight 不负责语义 review 或注意力启发式规则。
本地 Codex 结合实际 diff 和 PR 上下文审查以下问题。缺少独立人工判断或关键证据时，记录 `needs-human`。

- 测试证据缺失或不足。
- 用户可见本地化、UI 行为或交互体验风险。
- `UserStorage`、`PermissionRule`、`GlobalEventBus`、`apiKey`、`deleteSync`
  等架构或安全敏感关键词。
- 大范围 diff、单文件大改，以及 PR title/body 过少导致的 review context 不完整。
- generated file 和源文件一起变化时，是否来自预期 codegen 链路。
