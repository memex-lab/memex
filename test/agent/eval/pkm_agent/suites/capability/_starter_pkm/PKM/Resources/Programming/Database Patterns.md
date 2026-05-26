# Database Patterns

Patterns I've used and want to remember.

<!-- fact_id: fact_pkm_db_001 -->
- Outbox pattern for distributed transactions across SQL + queue.
- CDC > polling for cache invalidation.
- Soft deletes are tax — only use when you really need restore semantics.
