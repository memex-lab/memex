# 用本地 Codex 处理 Memex PR

每天可对本地 Codex 说：“按 main 的 docs/local-pr-review.md 处理待审 PR，发表报告并更新状态。遇到需人工决定的项交给我。” 使用受信的 Memex 主干 checkout 和有本仓库写权限且可发表 PR review、写入 commit status 的 gh 登录。GitHub Actions 运行治理与质量检查，模型调用只发生在本地。

## 领取工作

从受信主干更新工作区，运行以下命令。默认按创建顺序列出预检通过且缺少当前版本审查的非草稿 PR。队列为空就结束。需要追查未入队原因时用第二条。已打开的历史 PR 同样可被本地发现。脚本从实际检查运行获取报告，并核对 PR 编号及 base/head；旧报告已过期、版本不符时显示 waiting-preflight。更新分支或重跑与当前版本对应的预检后再领取。

```sh
python3 scripts/local_pr_review.py queue
python3 scripts/local_pr_review.py queue --all
python3 scripts/local_pr_review.py show 492
```

| 状态 | 接下来谁处理 |
|---|---|
| waiting-preflight / preflight-failed | 作者或 CI 维护者区分产品失败、基线故障、缺少任务；补证后重查。 |
| awaiting-codex | 本地 Codex 领取。无需开着 Actions runner 等待，也无需云端模型密钥。 |
| changes-requested | 原作者修复或答复具体发现。推新提交后重新进预检；同一提交补证后可指定 PR 复审。 |
| needs-human | 维护者判断领域风险、证据缺口或多轮未收敛的问题。用 GitHub 原生 review 记录独立判断。 |
| passed | 当前范围的语义审查通过。合并前核对预检、领域审批与最终提交。 |
| closed-or-draft | 跳过。 |

## 审一份 PR

1. 记下 show 输出的 base、head 和标题/正文摘要 intent。查看用户意图、PR 正文、已有评论、上轮报告、文件列表和 CI 运行链接。历史 PR 可能使用旧版 shadow policy，须核对报告的实际 decision。reject 或验证不完整时先处理原因。
2. 用独立、无凭据的工作环境准备对应候选代码。核对实际 checkout SHA；评审 diff 用 `git diff BASE...HEAD`。把 PR 正文、文件、日志作为被审材料。审查规则和判定工具从受信主干读取；验证不受信代码的进程不继承 gh、模型或发布凭据。
3. 写一句用户承诺。从工作区运行 `python3 /可信主干/scripts/verify_pr.py --base BASE --list`，去掉 --list 执行命中场景（事先 flutter pub get）。对照[用户功能地图](user-feature-map.zh.md)确认所选测试的入口、终点与证据边界。没有自动匹配时，由 reviewer 选相关测试并记录理由。模拟器、权限状态、旧备份和真实模型的证据各写清平台和受测提交。截图或日志只用合成日记与测试账号。
4. 找出足以推翻承诺的反例。捕获/队列看删除与恢复交错、重复重试；备份看仍在 WAL 的最近写入、旧格式、还原后业务读回；隐私看锁定时可见内容与实际出站数据；Agent 看工具权限、重复副作用；原生启动看冷/热入口及重启。高风险路径应优先实际运行，现有 host 测试不能证明目标设备已通过。重构比较同输入的新旧结果，迁移比较真实旧版 fixture。
5. 每条须修意见写明触发条件、用户影响、文件与行号、复现或证据。标出本次引入、既有问题及可选建议。复审带入上轮已解决项，聚焦新增 diff、原问题及受影响的证据。三轮仍有分歧转交维护者。
6. 报告包括用户承诺、检查过的版本、实际命令及结果、未覆盖的条件、具体发现和结论。确定性缺陷选 changes-requested。隐私/认证、数据迁移与恢复、出站数据、原生启动、发布或审查规则变动，须有相应领域独立人工判断；缺少该判断或关键设备证据选 needs-human。只有证据足够且须修项已关闭才选 passed。工具读取实际治理 artifact 判断 high_risk，也检查敏感路径和重命名前的路径。上述改动如需标 passed，必须已有不同于 PR 作者的仓库写权限真人对当前 head 明确 APPROVED。AI 报告发布为 COMMENT。真人在 GitHub 上对同一 head 明确批准并补齐证据后，可按该 PR 编号复核，引用批准链接，再更新状态。

## 发布结论

从受信主干运行，将示例参数替换为实际编号、完整 SHA 和报告路径。show 与 queue 只读，record 会发布 PR review 和对应 commit status。record 校验 base/head 与预检，并先写入报告，后更新状态；网络中断时用相同参数重试。不同机器同时处理同一 PR 前先协调，最新发布的有效结论生效。

```sh
python3 scripts/local_pr_review.py record 492 --base BASE_SHA --head HEAD_SHA \
  --intent INTENT --verdict changes-requested --report /tmp/memex-review.md
python3 scripts/local_pr_review.py show 492
```

每个结论绑定 PR、base SHA、head SHA 及标题/正文摘要。正文改动会让本地队列重新列为待审。新版本的旧结论仍在 GitHub 供追溯。治理检查通过后，Actions 为非草稿 PR 初始化 pending 状态（已有该版本状态时跳过）。两项检查均通过且报告与当前版本匹配后，本地队列才放行。既有 PR 若无 pending，队列按缺少结论处理。分支保护由仓库管理员单独管理，本流程不会自动合并。提交评审工具改动时遵循[持续校准流程](review-verification-maintenance.md)。
