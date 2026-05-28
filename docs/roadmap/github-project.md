# GitHub Project Setup

Use GitHub Projects for roadmap execution and roadmap issues for product direction. The project should track roadmap epics, feature issues, and implementation progress without turning repository docs into a task board.

## Project

Name: `Memex Roadmap`

Recommended views:
- `Backlog`: board view with columns grouped by `Status`.
- `Priority board`: board view with columns grouped by `Status` and rows grouped by `Priority`.
- `Roadmap`: table or timeline-style view for roadmap epics and major feature issues.
- `Archive`: filtered to `Status = Done`.

## Fields

Status:
- Inbox
- Ready
- In Progress
- In Review
- Blocked
- Done

Priority:
- P0
- P1
- P2
- Later

User Impact:
- Activation
- Retention
- Monetization
- Performance
- UX Quality
- Platform Capability

## Issue Hierarchy

Use this hierarchy:

```txt
Epic issue
  -> Feature issue
       -> Pull request
```

Epic issues should describe the product direction, background, open questions, and success signals. Feature issues should be created later when the direction is ready to become scoped execution work.

## Labels vs Project Fields

Keep labels stable and broad. Use labels for repository-wide categories such as `area: ai-agents`, `area: timeline`, `area: llm-provider`, `area: ux`, `area: performance`, `type: roadmap`, and `priority: p0`.

Do not create Project fields such as `Area`, `Initiative`, `Target`, `Work Type`, or `Effort` just to repeat information already visible in the issue title, labels, or roadmap section.

Use Project fields only when they help sort or execute work:
- `Priority`: importance
- `User Impact`: the main outcome affected

## CLI Setup

The commands below assume the repository remote is `memex-lab/memex` and that the authenticated GitHub user can create organization projects and issues.

```sh
gh project create --owner memex-lab --title "Memex Roadmap"
```

After creation, capture the returned project number and use it for field creation:

```sh
PROJECT_NUMBER=<number>

gh project field-create "$PROJECT_NUMBER" --owner memex-lab --name "Priority" --data-type SINGLE_SELECT --single-select-options "P0,P1,P2,Later"
gh project field-create "$PROJECT_NUMBER" --owner memex-lab --name "User Impact" --data-type SINGLE_SELECT --single-select-options "Activation,Retention,Monetization,Performance,UX Quality,Platform Capability"
```

Then create the roadmap epic issues and add them to the project. Do not create a milestone until the roadmap is ready to be committed to a concrete delivery phase.
