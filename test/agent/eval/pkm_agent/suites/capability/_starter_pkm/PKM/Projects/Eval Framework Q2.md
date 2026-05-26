# Eval Framework Q2

Goal: ship eval infrastructure for card / pkm / insight agents by end of June 2026.

<!-- fact_id: fact_pkm_proj_eval_001 -->
- 2026-04-15: Cloned dart_agent_core, started designing the runner abstraction.
- 2026-05-08: First end-to-end run of the calculator demo, 100% pass.
- 2026-05-22: card_agent capability suite landed (25 tasks, 96% trial pass on sonnet-4.6).

## Open items
- Add LLM judge for card title quality
- Migrate LangSmith integration to read from FileReportStore
