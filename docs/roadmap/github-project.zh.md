# GitHub 项目配置

中文 | [English](github-project.md)

使用 GitHub Projects 推进路线图执行，用路线图 Issue 明确产品方向。项目应跟踪路线图 Epic、功能 Issue 和实施进度，而不是把仓库文档变成任务看板。

## 项目

名称：`Memex Roadmap`

推荐视图：
- `Backlog`：看板视图，按 `Status` 分组。
- `Priority board`：看板视图，列按 `Status` 分组，行按 `Priority` 分组。
- `Roadmap`：表格或时间线视图，用于路线图 Epic 和主要功能 Issue。
- `Archive`：筛选 `Status = Done`。

## 字段

Status：
- Inbox
- Ready
- In Progress
- In Review
- Blocked
- Done

Priority：
- P0
- P1
- P2
- Later

User Impact：
- Activation
- Retention
- Monetization
- Performance
- UX Quality
- Platform Capability

## Issue 层级

使用以下层级：

```txt
Epic issue
  -> Feature issue
       -> Pull request
```

Epic Issue 应描述产品方向、背景、待解决问题和成功信号。Feature Issue 应在方向明确、可以落地为可执行工作时再创建。

## 标签 vs 项目字段

保持标签稳定且粒度适中。标签用于仓库级分类，例如 `area: ai-agents`、`area: timeline`、`area: llm-provider`、`area: ux`、`area: performance`、`type: roadmap` 和 `priority: p0`。

不要仅为重复 Issue 标题、标签或路线图章节中已有的信息，就创建 `Area`、`Initiative`、`Target`、`Work Type` 或 `Effort` 等项目字段。

仅在有助于排序或执行工作时使用项目字段：
- `Priority`：重要性
- `User Impact`：主要影响的结果

## CLI 配置

以下命令假设仓库远程为 `memex-lab/memex`，且已认证的 GitHub 用户可以创建组织项目和 Issue。

```sh
gh project create --owner memex-lab --title "Memex Roadmap"
```

创建后，记录返回的项目编号，用于创建字段：

```sh
PROJECT_NUMBER=<number>

gh project field-create "$PROJECT_NUMBER" --owner memex-lab --name "Priority" --data-type SINGLE_SELECT --single-select-options "P0,P1,P2,Later"
gh project field-create "$PROJECT_NUMBER" --owner memex-lab --name "User Impact" --data-type SINGLE_SELECT --single-select-options "Activation,Retention,Monetization,Performance,UX Quality,Platform Capability"
```

然后创建路线图 Epic Issue 并添加到项目中。在路线图准备好进入具体交付阶段之前，不要创建 Milestone。
